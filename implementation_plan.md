# MyCSIT — Implementation Plan

## Overview

5-phase build strategy. Each phase ships a usable state — no phase leaves the system broken. Firebase is the single backend for auth, data, storage, and serverless logic.

---

## Tech Stack (Final)

| Layer | Technology |
|---|---|
| Mobile App | Flutter 3.x (Dart) |
| Web Dashboard | React 18 + TypeScript + Vite |
| Auth | Firebase Authentication (Email/Password, custom claims for roles) |
| Database | Cloud Firestore |
| File Storage | Firebase Storage |
| Backend Logic | Firebase Cloud Functions (Node.js) |
| Hosting (Web) | Firebase Hosting |
| State (Mobile) | Riverpod |
| State (Web) | Zustand or React Context + useReducer |
| UI (Web) | Tailwind CSS + shadcn/ui |

---

## Phase 1 — Foundation (Auth + Schema + Roles)

**Duration estimate:** 1–1.5 weeks

### Goals
- Firebase project setup
- Firestore schema locked in
- Auth flow with role-based access
- Student registration → pending state → faculty approval flow

### Firebase Collections to Initialize

```
/users/{uid}
  - role: "student" | "faculty"
  - status: "pending" | "active" | "rejected"
  - rollNumber: string
  - name: string
  - year: number
  - section: string
  - createdAt: timestamp

/faculty/{uid}
  - name: string
  - email: string
  - department: string
```

### Auth Flow
1. Student registers with roll number + password
2. Firebase Auth creates user
3. Cloud Function triggers on user creation → writes `/users/{uid}` with `status: "pending"`
4. Faculty dashboard shows pending approvals list
5. Faculty approves → Function updates `status: "active"` + sets custom claim `role: student`
6. Student app checks status on login; if pending → show "Awaiting approval" screen

### Edge Cases to Handle
- Student tries to access app while pending → locked screen, not a crash
- Faculty accidentally rejects → re-approval must be possible (status toggle)
- Duplicate roll number registration → Cloud Function validates uniqueness before write
- Faculty account cannot self-register → must be seeded; block faculty role from public signup endpoint

---

## Phase 2 — Student Profile + Social Links

**Duration estimate:** 1 week

### Goals
- Complete student profile screen
- Social/coding platform link management
- Profile completeness score (local computation)

### Firestore Additions

```
/users/{uid}/profile
  - bio: string
  - profilePhotoUrl: string
  - linkedIn: string
  - github: string
  - portfolio: string
  - leetcode: string
  - codeforces: string
  - codechef: string
  - profileCompleteness: number (0–100, computed)
  - lastUpdated: timestamp
```

### Edge Cases
- URL validation on social links (regex + basic format check, not live ping)
- Profile photo upload size cap at 2MB; compress client-side before upload
- Profile completeness must not count unverified activity entries
- If student changes roll number field → require faculty re-verification (flag in Firestore)

---

## Phase 3 — Activity Logging System

**Duration estimate:** 1.5–2 weeks

### Goals
- Full CRUD for activity entries (student side)
- Proof file upload to Firebase Storage
- Faculty approval queue (web dashboard)
- Status tracking (pending/approved/rejected)

### Firestore Additions

```
/activities/{activityId}
  - userId: string
  - type: "hackathon" | "certification" | "research" | "project" | "internship" | "achievement"
  - title: string
  - description: string
  - date: timestamp
  - proofUrl: string (Firebase Storage URL)
  - status: "pending" | "approved" | "rejected"
  - rejectionReason: string | null
  - approvedBy: string (faculty uid) | null
  - createdAt: timestamp
  - updatedAt: timestamp
```

### Activity Scoring — Two Separate Buckets

**Bucket 1: Hackathons & Events (35% of totalScore)**
| Type | Weight |
|---|---|
| Hackathon | 1.0 |
| Achievement | 0.7 |
| Certification | 0.5 |

**Bucket 2: Projects & Internships (25% of totalScore)**
| Type | Weight |
|---|---|
| Internship | 1.0 |
| Research | 0.9 |
| Project | 0.8 |

**Cap:** Max 3 entries per type count toward score. Additional entries are stored and approved but do not increase the score.

### Edge Cases
- Proof file must be PDF/image (validate MIME type client-side and in Storage rules)
- Rejected entry can be edited and resubmitted (new status: "pending", old rejection reason cleared)
- Student cannot delete an approved entry — only faculty can remove it
- Faculty bulk approve: max 20 at a time to prevent accidental mass approvals
- Activity date cannot be in the future
- Duplicate detection: warn (not block) if same title + type exists for the same student

---

## Phase 4 — Coding Activity + Academic Data

**Duration estimate:** 1.5 weeks

### Coding System

```
/codingActivities/{id}
  - userId: string
  - platform: "leetcode" | "codeforces" | "codechef" | "other"
  - type: "milestone" | "contest" | "highValueProblem"
  - title: string
  - value: number (e.g., problem count for milestones, rank for contests)
  - proofUrl: string
  - status: "pending" | "approved" | "rejected"
  - createdAt: timestamp
```

### Milestone Examples (structured input, not free text)
- "Solved 50 problems" → type: milestone, value: 50
- "Solved 200 problems" → type: milestone, value: 200
- "Codeforces Round 940 — Rank 1200" → type: contest

### Coding Score Formula (within 30% block)
```
codingScore = (milestoneScore × 0.5) + (contestScore × 0.5)

milestoneScore = min(approvedMilestones.maxValue / 500, 1) × 100
contestScore = approved contests count (capped at 10) / 10 × 100
```

### Academic Data (Faculty-entered)

```
/academics/{userId}/semesters/{semId}
  - subjects: [{name, marks, maxMarks}]
  - attendance: {total, attended}
  - cgpa: number (auto-computed or manual override)
  - updatedBy: faculty uid
  - updatedAt: timestamp
```

### Edge Cases
- CGPA entered manually by faculty; no auto-compute from marks (avoids complex grading scheme handling)
- Attendance percentage shown as derived field, never stored (computed: attended/total × 100)
- If marks are missing for a semester, academic score uses available data only (no zero penalty for incomplete semesters)
- Faculty CSV upload for marks: validate headers, roll numbers, and reject malformed rows with error report before commit

---

## Phase 5 — Scoring Engine + Analytics + Polish

**Duration estimate:** 1.5–2 weeks

### Scoring Engine (Cloud Function)

Triggered on:
- Activity/coding entry approved
- Marks updated
- Called on-demand when faculty views student

```
totalScore = (hackathonScore × 0.35)
           + (projectScore   × 0.25)
           + (academicScore  × 0.25)
           + (codingScore    × 0.15)
```
Priority order (faculty-ranked): Hackathons > Projects & Internships > CGPA > Coding

Result cached in `/users/{uid}/scoreCache` with `lastComputed: timestamp`

Invalidated and recomputed on any approval/rejection event.

### Faculty Analytics Dashboard

Metrics:
- CGPA distribution (histogram)
- Top 10 students by total score
- Activity participation rate by type
- Coding engagement by platform
- Students with 0 approved activities (at-risk list)

### Edge Cases
- Score must never display for students with `status: pending`
- If a student has no coding entries, coding score = 0 (not null)
- Analytics must exclude pending/rejected student accounts
- Score leaderboard is only visible to faculty, not students (students see their own score only)

---

## Firebase Security Rules Summary

```
- Students can only read/write their own documents
- Students cannot write to /academics/
- Students cannot modify status fields (pending/approved/rejected)
- Faculty can read all student documents
- Faculty can write to approval status fields only
- Proof files in Storage: student can upload to own folder; faculty can read all; no public access
- Score cache: read by owner student + all faculty; write only by Cloud Functions
```

---

## Deployment Checklist

- [ ] Firebase project created (production + dev environments separate)
- [ ] Firestore indexes configured for filter queries (CGPA + score + year compound)
- [ ] Storage rules set (MIME type enforcement)
- [ ] Cloud Functions deployed (user creation trigger, score recompute trigger)
- [ ] Faculty accounts seeded via admin script
- [ ] Flutter app built for Android APK (iOS later)
- [ ] React web deployed to Firebase Hosting
