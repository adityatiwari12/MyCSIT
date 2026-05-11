# MyCSIT — Logic Documentation

## 1. Authentication & Account Lifecycle

### Student Registration Flow

```
Student submits (rollNo, name, year, section, password)
  → Cloud Function: onUserCreate
    → Check if rollNo already exists in /users collection
      → If duplicate: delete the new Auth user, return error "Roll number already registered"
      → If unique: create /users/{uid} with status: "pending"
  → Student sees "Pending Approval" screen
  → Faculty sees new entry in Approval Queue > Student Registrations

Faculty approves:
  → Update /users/{uid}.status = "active"
  → Set custom claim: { role: "student" }
  → Refresh student's ID token (force re-fetch on next login)
  → Student gets push notification "Your account has been approved"

Faculty rejects:
  → Update /users/{uid}.status = "rejected"
  → Student sees "Account Rejected" screen with optional reason
  → Student cannot log in (guarded by status check)
```

### Login Guard Logic

```
On app start:
  if (no auth user) → Login screen
  if (auth user exists):
    fetch /users/{uid}.status
    if "pending" → Pending Approval screen (no nav access)
    if "rejected" → Rejected screen (with contact info)
    if "active" → Home screen
```

### Faculty Auth

- Faculty accounts exist in /users/{uid} with role: "faculty"
- Faculty must be seeded via admin script (no public registration for faculty)
- Faculty login uses same email/password system but custom claim `role: faculty`

---

## 2. Activity Entry Logic

### Submission

```
Student submits activity:
  required: type, title, date, description, proofFile
  
  Validations:
  - date must be <= today
  - proofFile must be image/jpeg, image/png, or application/pdf
  - proofFile size <= 5MB
  - title must be 3–100 characters
  
  If valid:
    - Upload proof to Storage: /proofs/{uid}/activities/{uuid}.{ext}
    - Write to /activities/{activityId} with status: "pending"
    - Increment /users/{uid}.pendingActivityCount (for badge display)
```

### Approval Flow

```
Faculty approves activity:
  - Update /activities/{id}.status = "approved"
  - Set approvedBy = faculty uid
  - Trigger Cloud Function: recalculateScore(userId)

Faculty rejects:
  - Update /activities/{id}.status = "rejected"
  - Set rejectionReason = reason string
  - Notify student

Student edits rejected entry:
  - Allowed only if status = "rejected"
  - On re-submit: status resets to "pending", rejectionReason cleared
  - Proof file can be replaced (old file deleted from Storage)

Student cannot:
  - Edit a "pending" or "approved" entry
  - Delete any entry (read-only after submission)
  - Submit more than 20 activity entries total (soft cap, prevents abuse)
```

### Activity Scoring (within 30% Activities weight)

```
Activities are split into two separately-scored buckets matching faculty priorities:

BUCKET 1 — Hackathon/Events score (35% of totalScore):
  Eligible types: hackathon, achievement, certification
  typeWeight = { hackathon: 1.0, achievement: 0.7, certification: 0.5 }
  Per type: top 3 approved entries count (most recent)
  rawHackathon = sum of typeWeight for counted entries
  maxHackathon = 3 × 1.0 × 3 = 9
  hackathonScore = min((rawHackathon / maxHackathon) × 100, 100)

BUCKET 2 — Projects/Internships score (25% of totalScore):
  Eligible types: project, internship, research
  typeWeight = { internship: 1.0, research: 0.9, project: 0.8 }
  Per type: top 3 approved entries count
  rawProject = sum of typeWeight for counted entries
  maxProject = 3 × 1.0 × 3 = 9
  projectScore = min((rawProject / maxProject) × 100, 100)

Cap logic: per-bucket caps prevent cross-bucket inflation.
```

---

## 3. Coding Activity Logic

### Entry Types

| Type | Required Fields | Example |
|---|---|---|
| milestone | platform, value (problem count) | "Solved 200 LeetCode problems" |
| contest | platform, contestName, rank | "Codeforces Round 940, Rank 1200" |
| highValueProblem | platform, problemName, difficulty | "Solved 'Hard DP' on LeetCode" |

### Validation

```
milestone:
  - value must be integer > 0
  - value should be a round milestone: 50, 100, 150, 200... (warn if not, don't block)
  - Per platform, only the HIGHEST approved milestone counts (not cumulative)
    e.g., if student submits 50 then 200 on LeetCode, only 200 is scored

contest:
  - rank must be a positive integer
  - contestName required
  - Proof required (screenshot of result page)

highValueProblem:
  - difficulty: easy/medium/hard
  - Max 5 counted toward score
```

### Coding Score Formula

```
Per platform (LeetCode, Codeforces, CodeChef, Other):
  milestoneValue = highest approved milestone value (0 if none)
  normalizedMilestone = min(milestoneValue / 500, 1)  // 500 problems = max

approvedContests = count of approved contest entries (all platforms)
contestScore = min(approvedContests / 10, 1)  // 10 contests = max

codingScore = (avg(normalizedMilestone across platforms with entries) × 0.5 
              + contestScore × 0.5) × 100
```

---

## 4. Academic Score Logic

### Input (Faculty-entered)

```
/academics/{userId}/semesters/{semId}:
  cgpa: float (0–10)  // manual entry per semester
  subjects: [{name, marks, maxMarks}]
  attendance: {total, attended}
```

### Academic Score Formula

```
latestCGPA = most recently updated semester's cgpa field

academicScore = (latestCGPA / 10) × 100

If no CGPA entered: academicScore = 0 (no penalty assumption — data not yet entered)
```

### Attendance (Display Only, Not Scored in MVP)

```
attendancePercentage = (attended / total) × 100
Display: shown on student profile and faculty detail view
Color coding: <75% red, 75–85% amber, >85% green
Not included in total score in Phase 1 (future extension)
```

---

## 5. Total Score Engine

### Formula

```
totalScore = (hackathonScore  × 0.35)
           + (projectScore    × 0.25)
           + (academicScore   × 0.25)
           + (codingScore     × 0.15)

All component scores are 0–100.
totalScore is therefore 0–100.
```

### Rationale
Faculty ranked real-world exposure over academic metrics:
1. Hackathons/Events (35%) — highest signal of applied problem-solving
2. Projects & Internships (25%) — sustained applied work
3. Academic / CGPA (25%) — foundational baseline
4. Coding Activity (15%) — supporting signal, not primary

### Score Caching

```
/users/{uid}/scoreCache:
  totalScore: float
  hackathonScore: float
  projectScore: float
  academicScore: float
  codingScore: float
  lastComputed: timestamp

Invalidated and recomputed when:
  - Any activity/coding entry changes status (approved/rejected)
  - Faculty updates marks/CGPA for the student

Cloud Function: onScoreInvalidate(userId)
  → Recalculates all components
  → Writes to scoreCache
  → max 1 recalculation per 30 seconds per user (rate-limited)
```

### Score Visibility Rules

```
Student: can see their own totalScore + breakdown
Faculty: can see all student scores
Pending students: score not shown (incomplete data)
```

---

## 6. Faculty Filtering Logic

### Available Filters

```
year: [1, 2, 3, 4] (multi-select)
section: ["A", "B", "C"] (multi-select)
cgpaMin: float, cgpaMax: float
scoreMin: float, scoreMax: float
hasActivities: boolean
hasCodingEntries: boolean
activityTypes: string[] (subset of activity type enum)
```

### Firestore Query Strategy

Firestore does not support multi-field range queries. Strategy:

```
Primary query: filter by year + section (equality, indexed)
Client-side filtering: CGPA range, score range, activity flags

Reason: CGPA and score ranges combined with array membership 
require composite indexes that become unwieldy. 
For MVP with ~200 students, client-side filtering is acceptable.

Future: Use Algolia or a Cloud Function that writes a 
denormalized search document for each student.
```

### Sorting

```
Available sort keys:
  - totalScore (desc default)
  - cgpa (desc)
  - name (asc)
  - year
  - codingScore (desc)
  - activityCount (desc)
```

---

## 7. File Handling Logic

### Upload Rules

```
Allowed MIME types: image/jpeg, image/png, image/jpg, application/pdf
Max size: 5MB per file
Storage path: /proofs/{userId}/{entryType}/{uuid}.{ext}

Client-side compression:
  - Images > 1MB → compress to 80% quality before upload
  - PDFs: no compression (serve as-is)

Naming:
  - UUID generated client-side (prevent collision)
  - Original filename not preserved (security)
```

### Proof Access Control (Storage Rules)

```
/proofs/{userId}/{everything=**}:
  read: request.auth.uid == userId || isFaculty()
  write: request.auth.uid == userId && isValidFile()

isValidFile():
  request.resource.size < 5 * 1024 * 1024
  && request.resource.contentType.matches('image/.*|application/pdf')
```

---

## 8. Notification Logic

### Events that trigger notifications (FCM)

| Event | Recipient | Message |
|---|---|---|
| Account approved | Student | "Your MyCSIT account has been approved. Welcome!" |
| Account rejected | Student | "Your registration was not approved. Contact faculty." |
| Activity approved | Student | "[Title] has been approved ✓" |
| Activity rejected | Student | "[Title] was rejected: [reason]" |
| New student registration | Faculty (all) | "New student [name] is awaiting approval" |
| New activity submitted | Faculty (all) | "[Name] submitted [type]: [title]" |

Faculty notifications are broadcast to all faculty (no per-faculty assignment in MVP).

---

## 9. Data Integrity Rules

### Immutability

- Approved entries cannot be edited by students
- Faculty can remove (soft-delete) any entry with a reason
- Deleted entries: set `isDeleted: true`, never hard-deleted (audit trail)

### Audit Trail

Every status change writes to `/auditLog/{logId}`:
```
  action: "approved" | "rejected" | "deleted" | "account_approved"
  targetId: string
  targetType: "activity" | "coding" | "user"
  performedBy: faculty uid
  reason: string | null
  timestamp: timestamp
```

### Score Anti-Manipulation

- Score is computed server-side only (Cloud Function)
- Students cannot write to `/scoreCache`
- Only entries with `status: "approved"` are included
- Per-category caps prevent spam farming

---

## 10. Edge Cases Reference Table

| Scenario | Behavior |
|---|---|
| Student submits same activity twice | Warn client-side (fuzzy title match), allow submission |
| Faculty deletes approved entry | Score invalidated and recomputed |
| Student reaches 20-entry cap | UI disables "Add" button with message |
| CGPA not yet entered | Academic score = 0, shown as "Pending" in score breakdown |
| Proof file corrupted/unreadable | Faculty can still approve; they flag on their end |
| Student changes phone/device | Session resumes via Firebase persistent auth |
| Faculty bulk-approves 20 items | Rate limiter on Cloud Function (1 batch per 5 seconds) |
| Milestone decreases (e.g., re-submission with lower count) | System takes max of all approved milestone values |
| Contest rank = 0 | Validation blocks: rank must be ≥ 1 |
| Roll number contains spaces/special chars | Normalized on write (trimmed, lowercase) |
