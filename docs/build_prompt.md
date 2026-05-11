# MyCSIT — AI Build Prompts

These prompts are designed to be used with an AI coding assistant (Cursor, Claude Code, etc.) to build MyCSIT step by step. Use them in sequence within each phase.

---

# PART 1: FLUTTER MOBILE APP (Student-Facing)

---

## Prompt 1.1 — Project Setup & Firebase Integration

```
Create a new Flutter project named "mycsit" targeting Android and iOS.

Set up the following:

1. Add dependencies:
   - firebase_core
   - firebase_auth
   - cloud_firestore
   - firebase_storage
   - flutter_riverpod
   - go_router
   - google_fonts
   - cached_network_image
   - file_picker
   - image_picker
   - image_compress (flutter_image_compress)
   - intl
   - uuid
   - flutter_local_notifications
   - firebase_messaging

2. Initialize Firebase in main.dart using FlutterFire CLI output.

3. Create the following folder structure:
   lib/
     core/
       constants/         # colors, text styles, spacing
       theme/             # ThemeData
       utils/             # validators, formatters
     data/
       models/            # Dart model classes
       repositories/      # Firestore + Storage access
     features/
       auth/
       profile/
       activities/
       coding/
       academics/
       dashboard/
       timeline/
       notifications/
     shared/
       widgets/           # reusable UI components

4. Set up go_router with the following routes:
   / → SplashScreen
   /login → LoginScreen
   /register → RegisterScreen
   /pending → PendingApprovalScreen
   /rejected → AccountRejectedScreen
   /home → HomeScreen (shell route with bottom nav)
   /home/profile → ProfileScreen
   /home/timeline → TimelineScreen
   /home/add → AddEntryScreen
   /home/academics → AcademicsScreen
   /activities/:id → ActivityDetailScreen
   /coding/:id → CodingDetailScreen
   /notifications → NotificationsScreen

5. Create AppTheme with:
   Primary color: #FF6B35
   Background: #F8F8F8
   Surface: #FFFFFF
   Font family: Poppins (headings) + DM Sans (body)
   Use Google Fonts package.

Do not build screens yet. Just architecture, routing, and theming.
```

---

## Prompt 1.2 — Auth Screens + Pending State

```
Build the following screens for the MyCSIT Flutter app. 
Use the AppTheme already configured. All screens use Scaffold with white background (#F8F8F8).

Design reference: Clean card-based UI, coral (#FF6B35) primary buttons (pill-shaped, full-width), 
DM Sans body text, Poppins Bold headings.

1. LoginScreen (/login)
   - Top padding: 80px
   - Poppins Bold 28px: "Welcome Back 👋"
   - DM Sans 14px muted: "Log in with your college credentials"
   - Vertical spacing 40px
   - Text field: Roll Number (outlined, rounded 12px, coral focus border)
   - Text field: Password (with show/hide toggle icon)
   - 24px spacing
   - Coral pill button: "Login" (full width, 52px height)
   - 16px below: centered text "New here? Register" (tappable, coral color)
   - Form validation: both fields required, roll number min 8 chars
   - On login: call FirebaseAuth.signInWithEmailAndPassword using 
     email = rollNumber + "@mycsit.aitr.ac.in" (construct email internally)
   - After login: check Firestore /users/{uid}.status
     - "pending" → go /pending
     - "rejected" → go /rejected
     - "active" → go /home

2. RegisterScreen (/register)
   - Back arrow top left
   - Poppins Bold 26px: "Create Account"
   - Fields (all outlined, 12px radius, coral focus):
     - Full Name
     - Roll Number (hint: "e.g. 0191CSBT2022001")
     - Year (DropdownButtonFormField: 1st, 2nd, 3rd, 4th)
     - Section (Dropdown: A, B, C)
     - Password
     - Confirm Password
   - Coral pill button: "Register"
   - Validation: passwords match, all fields required
   - On submit: create Firebase Auth user with 
     email = rollNumber + "@mycsit.aitr.ac.in"
     Then write to Firestore /users/{uid}:
       { name, rollNumber, year, section, role: "student", status: "pending", createdAt: now }
   - Navigate to /pending

3. PendingApprovalScreen (/pending)
   - Center-aligned vertically
   - SVG/Lottie placeholder for clock illustration (use Icon(Icons.hourglass_top) 
     in coral color, size 80, for now)
   - Poppins SemiBold 22px: "Awaiting Approval"
   - DM Sans 14px muted: "Your account is being reviewed by faculty. 
     You'll receive a notification once approved."
   - 40px spacing
   - Outlined button (coral border): "Logout"

4. AccountRejectedScreen (/rejected)
   - Same layout as pending but with red icon, different text
   - Message: "Account Not Approved. Please contact your faculty coordinator."
   - Logout button
```

---

## Prompt 1.3 — Auth State Management with Riverpod

```
In the MyCSIT Flutter app, implement auth state management using Riverpod.

1. Create AuthRepository (lib/data/repositories/auth_repository.dart):
   - signIn(rollNumber, password): signs in using constructed email
   - register(name, rollNumber, year, section, password): creates auth user + Firestore doc
   - signOut(): FirebaseAuth.signOut()
   - getCurrentUserStatus(): fetches /users/{uid}.status from Firestore
   - Stream<User?> authStateChanges: exposes Firebase auth stream

2. Create authProvider (StateNotifierProvider) that:
   - Watches authStateChanges
   - On user present: fetches status from Firestore
   - Exposes: AuthState { user, status, isLoading, error }
   - Status enum: pending | active | rejected | unauthenticated

3. In go_router, create a redirect function:
   - If unauthenticated → /login
   - If pending → /pending
   - If rejected → /rejected
   - If active → /home (if trying to access /login, redirect to /home)

4. Handle token refresh after faculty approves account:
   - On PendingApprovalScreen, listen to a Firestore stream on /users/{uid}.status
   - When status changes to "active": force ID token refresh, navigate to /home
```

---

## Prompt 1.4 — Home Dashboard Screen

```
Build the HomeScreen for MyCSIT Flutter app. 
It's a shell with BottomNavigationBar (4 tabs: Home, Timeline, Add, Profile).

Home tab content (DashboardTab):

1. AppBar (no elevation):
   - Left: CircleAvatar (user initials or photo) + "Hi, [FirstName] 👋" in Poppins SemiBold 18px
   - Right: Bell icon (notifications), coral color

2. Score Card (full-width, gradient coral card):
   - LinearGradient: [#FF6B35 → #FF9F1C]
   - BorderRadius: 20px
   - Shadow: 0 4px 16px rgba(255,107,53,0.3)
   - Left side: Circular progress indicator (profile completeness %)
     center text: "72%" in white Poppins Bold 20px
     label below: "Profile" in white DM Sans 12px
   - Right side column:
     - totalScore in Poppins Bold 32px white
     - "Total Score" label in white 70% opacity
     - Row of 3 mini stats: Activities count | Coding count | Pending count
       each with small label below in white

3. Quick Actions Row (horizontal scroll, icon buttons):
   - "Add Activity" (+ icon)
   - "Add Coding" (code icon)  
   - "Timeline" (list icon)
   - "Academics" (school icon)
   Each: white card, 64×64px, rounded 16px, coral icon, label below in 11px

4. Section: "Recent Activity" (Poppins SemiBold 16px)
   - Last 3 entries from Firestore query:
     /activities where userId == uid, orderBy createdAt desc, limit 3
   - ActivityCard widget (see below)

5. Section: "Marks Snapshot" (if data exists)
   - Horizontal scroll of semester cards
   - Each card: "Sem 3" heading, CGPA badge, subjects count

ActivityCard widget:
- White card, radius 12px, shadow
- Left: colored vertical bar (type color)
- Title in DM Sans Medium 14px
- Date in muted 12px
- Right: StatusBadge widget
  - Pill shape, colored background based on status
  - pending: amber bg, amber text
  - approved: green bg, green text  
  - rejected: red bg, red text

BottomNavigationBar:
- Selected item: coral color
- Icons: home_rounded, timeline, add_circle_rounded, person_rounded
- No labels (icons only)
- The "Add" tab opens an AddEntryBottomSheet instead of navigating
```

---

## Prompt 1.5 — Activity System (Add + List + Detail)

```
Build the full Activity feature for MyCSIT Flutter app.

1. ActivityModel (lib/data/models/activity_model.dart):
   class ActivityModel {
     String id;
     String userId;
     String type; // hackathon | certification | research | project | internship | achievement
     String title;
     String description;
     DateTime date;
     String proofUrl;
     String status; // pending | approved | rejected
     String? rejectionReason;
     String? approvedBy;
     DateTime createdAt;
     DateTime updatedAt;
   }
   Include fromFirestore() and toFirestore() methods.

2. ActivityRepository (lib/data/repositories/activity_repository.dart):
   - Stream<List<ActivityModel>> watchActivities(userId): real-time stream
   - Future<void> addActivity(ActivityModel): writes to Firestore
   - Future<String> uploadProof(File file, userId, activityId): uploads to Storage, returns URL
   - Future<void> resubmitActivity(id, updatedData): only if status == rejected

3. AddActivitySheet (bottom sheet, 3 steps):

   Step 1: Activity Type Selection
   - Title: "What are you adding?"
   - 3x2 grid of large type cards (each 100px height):
     Icons: 🏆 Hackathon | 📜 Certification | 🔬 Research | 💻 Project | 💼 Internship | 🎖 Achievement
   - Selected card: coral border, light coral background
   - Next button (coral, pill)

   Step 2: Details
   - Title field (required)
   - Date picker (tap → DatePicker, cannot select future)
   - Description field (multiline, 3 lines)
   - Next button

   Step 3: Upload Proof
   - "Upload Proof" card (dashed border, coral, rounded 16px)
     - Icon: upload_file
     - Text: "Tap to select PDF or image"
     - On tap: FilePicker.platform.pickFiles()
     - On file selected: show filename + size + green checkmark
   - "Submit" button (coral, pill, full width)
   - On submit: upload file → get URL → write to Firestore → close sheet → show snackbar

4. ActivityListScreen (within Timeline or standalone):
   - Filter tabs at top (horizontal scroll): All | Pending | Approved | Rejected
   - Filtered list of ActivityCard widgets
   - Empty state for each filter

5. ActivityDetailScreen:
   - Full details view
   - Proof: if PDF show PDF icon + "View Proof" button (opens URL); if image show thumbnail
   - If rejected: show rejection reason in red card
   - If rejected: "Edit & Resubmit" button
   - Edit mode: only title, description, date, proof editable; type locked
```

---

## Prompt 1.6 — Coding Activity System

```
Build the Coding Activity feature for MyCSIT Flutter app.

1. CodingActivityModel:
   String id, userId, platform, type, title;
   int? value; // for milestones: problem count; for contests: rank
   String? contestName;
   String? difficulty; // for highValueProblem
   String proofUrl;
   String status;
   String? rejectionReason;
   DateTime createdAt;

2. CodingRepository:
   - Stream<List<CodingActivityModel>> watchCodingActivities(userId)
   - Future<void> addCodingActivity(...)
   - Future<String> uploadProof(...)

3. CodingScreen (tab-based):
   - 3 tabs: Milestones | Contests | Problems
   - Each tab shows filtered list of CodingActivityModel cards
   - FAB: "+" opens AddCodingSheet

4. AddCodingSheet (bottom sheet):
   
   Step 1: Select Type
   - 3 option cards: "Milestone" | "Contest" | "Notable Problem"
   
   Step 2: Platform (if Milestone or Contest)
   - Row of platform chips: LeetCode | Codeforces | CodeChef | Other
   - Each chip: platform logo + name (use colored circles as placeholder)
   
   Step 3: Details (conditional by type):
   
   If Milestone:
     - "Problems Solved" number input (integer, >0)
     - Hint: "Enter a round number like 50, 100, 200..."
     - If not divisible by 50: show inline warning (orange) "Milestones are typically round numbers"
   
   If Contest:
     - Contest Name text field
     - "Your Rank" number input
     - Validation: rank >= 1
   
   If Problem:
     - Problem Name
     - Difficulty dropdown: Easy | Medium | Hard
   
   Step 4: Upload Proof (same as activity proof upload step)

5. CodingCard widget:
   - Platform logo (colored circle with initial) on left
   - Title + type badge
   - Value display (e.g., "200 problems" or "Rank 1,200")
   - Status badge
```

---

## Prompt 1.7 — Profile Screen + Social Links

```
Build the ProfileScreen for MyCSIT Flutter app.

Layout (ScrollView):

1. Top: Coral gradient header (100px tall)
   - Overlapping CircleAvatar (80px diameter, white border, shadow)
     - Shows initials if no photo
     - Edit icon overlay (small coral circle, bottom-right of avatar)
   - On avatar tap: ImagePicker → compress → upload to Storage → update profilePhotoUrl

2. Below avatar:
   - Name in Poppins Bold 20px
   - "Year [n] • Section [x] • Roll: [rollNo]" in muted DM Sans 13px

3. Profile Completeness Card:
   - White card, radius 16px, shadow
   - LinearProgressIndicator (coral, 8px height, rounded)
   - "X% Complete" label
   - Below: list of incomplete fields as chips ("Add GitHub", "Add LinkedIn", etc.)

4. Social Links Section:
   Title: "Online Presence" (Poppins SemiBold 16px)
   Grid of platform tiles (2 columns):
   Each tile:
   - Icon (use simple colored icon for each platform)
   - Platform name
   - If linked: show username in coral, small check badge
   - If not linked: "Add" in muted text
   - On tap: bottom sheet with URL input field + save

   Platforms: LinkedIn, GitHub, LeetCode, Codeforces, CodeChef, Portfolio

   URL Validation:
   - LinkedIn: must contain "linkedin.com"
   - GitHub: must contain "github.com"  
   - LeetCode: must contain "leetcode.com"
   - Others: must be valid URL format

5. Account Section:
   - "Logout" list tile (red text)

SocialLinksRepository:
   - updateSocialLink(userId, platform, url)
   - getSocialLinks(userId): returns Map<String, String>
   
Store at: /users/{uid}/profile (Firestore document)
```

---

## Prompt 1.8 — Timeline Screen

```
Build the Timeline screen for MyCSIT Flutter app.

This is a unified chronological feed of ALL student entries (activities + coding).

1. Top filter section (horizontally scrollable chips):
   All | Hackathon | Certification | Research | Project | Internship | Achievement | Milestone | Contest
   
   Status toggle row below:
   [ All ] [ Pending ] [ Approved ] [ Rejected ] (segmented control style)

2. Data fetching:
   - Query /activities where userId == uid, orderBy date desc
   - Query /codingActivities where userId == uid, orderBy createdAt desc
   - Merge and sort by date in the repository/provider
   - Use a union type or sealed class: TimelineEntry { ActivityEntry | CodingEntry }

3. TimelineEntry card:
   - Left: vertical type-color indicator bar (4px wide, full card height)
   - Type colors:
     hackathon: #8B5CF6, certification: #3B82F6, research: #EC4899,
     project: #10B981, internship: #F59E0B, achievement: #EF4444,
     milestone: #06B6D4, contest: #FF6B35
   - Content:
     - Type pill badge (color-matched)
     - Title in DM Sans Medium 14px
     - Date in muted 12px
     - Status badge (right-aligned)
   - On tap → navigate to detail screen

4. Empty state (when no entries at all):
   - Icon: timeline (outlined)
   - "Your journey starts here"
   - "Log your first activity or coding milestone"
   - Button: "Add Entry" (coral)

5. Implement infinite scroll / pagination:
   - Load 15 entries initially
   - Load more on scroll to bottom
```

---

# PART 2: REACT WEB DASHBOARD (Faculty-Facing)

---

## Prompt 2.1 — Project Setup

```
Create a new React + TypeScript + Vite project named "mycsit-faculty".

Setup:
1. Install dependencies:
   - firebase (v10)
   - react-router-dom v6
   - tailwindcss + postcss + autoprefixer
   - @radix-ui/react-* (dialog, dropdown, tabs, select, checkbox)
   - recharts (for analytics charts)
   - react-hook-form + zod
   - zustand
   - date-fns
   - lucide-react (icons)
   - @tanstack/react-table (for student directory table)

2. Configure Tailwind with custom theme:
   colors:
     primary: { DEFAULT: '#FF6B35', light: '#FFF3EE', dark: '#E85520' }
     accent: '#FF9F1C'
     success: '#22C55E'
     warning: '#F59E0B'
     error: '#EF4444'
   fontFamily:
     display: ['Poppins', 'sans-serif']
     body: ['DM Sans', 'sans-serif']
   borderRadius:
     card: '16px'
     pill: '9999px'
   Add Google Fonts in index.html: Poppins (400,600,700) + DM Sans (400,500)

3. Folder structure:
   src/
     components/
       layout/        # AppShell, Sidebar, TopBar
       ui/            # Button, Badge, Card, Input, Modal, Table
       charts/        # all recharts wrappers
     features/
       auth/
       students/
       approvals/
       marks/
       attendance/
       analytics/
     lib/
       firebase.ts    # Firebase init
       firestore.ts   # collection helpers
       storage.ts
     hooks/           # useStudents, useApprovals, etc.
     stores/          # zustand stores
     types/           # TypeScript interfaces

4. Configure react-router with:
   / → redirect to /login
   /login → LoginPage
   /dashboard/* → protected routes (faculty only), wrapped in AppShell
   /dashboard → DashboardOverview
   /dashboard/students → StudentDirectory
   /dashboard/students/:id → StudentDetail
   /dashboard/approvals → ApprovalQueue
   /dashboard/marks → MarksManagement
   /dashboard/attendance → AttendanceManagement
   /dashboard/analytics → Analytics

5. Auth guard: if not logged in or not faculty role → redirect to /login
```

---

## Prompt 2.2 — AppShell + Sidebar

```
Build the AppShell layout for MyCSIT faculty dashboard.

AppShell:
- Fixed left sidebar (240px wide)
- Main content area (fluid, overflow-y-auto)
- Fixed top bar (height 64px) within main content
- Background: #F8F8F8

Sidebar:
- White background, right border: 1px solid #EEEEEE
- Top: MyCSIT logo (text logo: "My" in coral + "CSIT" in dark, Poppins Bold 22px)
- Navigation items (with active state):
  - Dashboard (LayoutDashboard icon)
  - Students (Users icon)
  - Approvals (ClipboardCheck icon) + badge showing pending count
  - Marks (BookOpen icon)
  - Attendance (CalendarCheck icon)
  - Analytics (BarChart2 icon)
  
  Each nav item:
  - Padding: 12px 20px
  - Border-radius: 12px
  - Active: coral background (#FFF3EE), coral text + icon, left border 3px coral
  - Hover: #F8F8F8
  - Icon size: 18px, margin-right: 12px
  - Text: DM Sans Medium 14px

- Bottom: Faculty avatar + name + "Logout" icon button

TopBar:
- White background, bottom border: 1px solid #EEEEEE
- Left: Page title (Poppins SemiBold 20px, from current route)
- Right: Search input (global student search) + notification bell

Pending count badge on Approvals nav item:
- Realtime Firestore query: 
  count of /activities where status=="pending" 
  + count of /users where status=="pending" (new registrations)
- Red circle badge (16px, Poppins Bold 10px white text)
```

---

## Prompt 2.3 — Student Directory

```
Build the Student Directory page for MyCSIT faculty dashboard.

1. Filter Panel (left, collapsible, 280px):
   
   Section: "Year"
   - Checkbox group: 1st Year, 2nd Year, 3rd Year, 4th Year
   
   Section: "Section"
   - Checkbox group: A, B, C
   
   Section: "CGPA Range"
   - Two number inputs (min, max) with range 0–10
   
   Section: "Score Range"
   - Two number inputs (min, max) with range 0–100
   
   Section: "Activity"
   - Toggle: "Has Activities"
   - Toggle: "Has Coding Entries"
   
   "Apply Filters" button (coral, full width)
   "Clear All" text button

2. Student Table (@tanstack/react-table):
   
   Columns:
   - Checkbox (for bulk select)
   - Name (with avatar initials)
   - Roll Number
   - Year + Section (combined)
   - CGPA (sortable)
   - Total Score (sortable, shown as progress bar + number)
   - Activities (count badge, colored by count)
   - Actions (eye icon → Student Detail)
   
   Sorting: click column header to toggle asc/desc
   Row click: navigate to /dashboard/students/:id
   
   Table styling:
   - White background, radius 16px, shadow
   - Header: #F8F8F8 background, muted text, DM Sans Medium 13px
   - Row hover: #FFF8F6
   - Border: none, row separator: 1px solid #F3F3F3
   
   Pagination: 20 rows per page, prev/next controls

3. Top action bar:
   - Left: student count ("128 students")
   - Right: "Export CSV" button, search input
   
4. Data fetching:
   - Load all active students from Firestore /users where role=="student" && status=="active"
   - Fetch their scoreCache subcollection for scores
   - Client-side filtering (for MVP, dataset is small enough)
   - Show loading skeletons (3 rows) while fetching
```

---

## Prompt 2.4 — Approval Queue

```
Build the Approval Queue page for MyCSIT faculty dashboard.

Tabs (at top, styled with coral active indicator):
1. "Student Registrations" (count badge)
2. "Activity Entries" (count badge)
3. "Coding Entries" (count badge)

Tab 1: Student Registrations
- Query: /users where status=="pending", orderBy createdAt desc
- Card per student (white, radius 16px, shadow):
  - Left: initials avatar (coral background)
  - Name in Poppins SemiBold 15px
  - Roll No, Year, Section in muted DM Sans 13px
  - Submitted: relative time (e.g., "2 hours ago")
  - Right side: 
    - "Approve" button (green, pill, small)
    - "Reject" button (red, outlined, pill, small) → opens RejectModal
  - On approve: update /users/{uid}.status = "active" + set custom claim via callable Cloud Function
  - On reject: modal asks for optional reason → update status = "rejected"

Tab 2 & 3: Activity / Coding Entries
- Query respective collections where status=="pending"
- Sort: oldest first (faculty should clear backlog FIFO)
- Entry card:
  - Student name + roll no (clickable → student detail)
  - Entry type badge (colored pill)
  - Entry title
  - Date of activity
  - "View Proof" button (opens proof URL in new tab)
  - "Approve" / "Reject" buttons
  - On reject: modal with required reason text input

Bulk Actions (for Activity/Coding tabs):
- Checkboxes on each card
- "Select All" at top
- When any selected: floating action bar appears at bottom:
  "X selected — [Approve All] [Reject All]"
  Max 20 bulk at once.

Empty state per tab:
- Green check icon + "All caught up! No pending items."
```

---

## Prompt 2.5 — Student Detail View

```
Build the Student Detail page for MyCSIT faculty dashboard (/dashboard/students/:id).

Layout: Two-column (left 300px sidebar, right fluid main)

Left Sidebar:
- Large avatar (80px, initials or photo)
- Name (Poppins Bold 22px)
- Roll No, Year, Section, Branch (DM Sans 14px muted)
- Score Card:
  - Coral gradient card
  - "Total Score: [XX]" in white Poppins Bold 28px
  - 3 sub-scores (academic, activities, coding) as pill badges
- Social Links section:
  - Each linked platform shown as icon + username chip
  - Each chip is clickable → opens link

Right Main (Tabs):

Tab 1: Overview
- Score breakdown bar chart (horizontal, 3 bars: Academic, Activities, Coding)
  Each bar: coral gradient, shows percentage contribution
- Quick stats row: Total activities | Approved activities | Coding entries | CGPA

Tab 2: Activities
- List of all student's activities (all statuses)
- Status filter (All/Pending/Approved/Rejected)
- Each row: type | title | date | status | proof link | approve/reject actions (if pending)
- Faculty can also remove (soft-delete) an approved entry → opens confirmation modal with reason

Tab 3: Coding
- Same as activities but for /codingActivities collection
- Group by platform using accordion

Tab 4: Academics
- Per-semester accordion (Semester 1, 2, 3...)
- Subject table per semester: Subject Name | Marks | Max Marks
- CGPA field (editable inline by faculty) with save button
- Attendance row: Total classes | Attended | Percentage (color coded)

Tab 5: Score Breakdown
- Detailed score computation shown visually
- "Academic: [score] (CGPA [X] → [X]%)" 
- "Activities: [score] ([n] approved, [X]pts)"
- "Coding: [score] (Milestones: [X], Contests: [X])"
- Total at bottom with coral gradient badge
```

---

## Prompt 2.6 — Marks & Attendance Management

```
Build Marks Management and Attendance Management pages.

MARKS PAGE:

1. Student selector at top:
   - Searchable combobox: type name or roll no → select student
   - Shows selected student card (name + year + section)

2. Semester tabs (Sem 1 through Sem 8):
   - Only show semesters that exist; faculty can "Add Semester" button

3. Per semester:
   - Subject rows table:
     | Subject Name | Marks | Max Marks | Percentage |
     Marks + Max Marks: inline editable inputs (number, 0–100)
     Percentage: auto-computed cell (marks/maxMarks × 100)
   - "Add Subject" row at bottom (blank inputs)
   - CGPA field: manual input (float, 0–10), labeled "CGPA (manual)"
   - Save button (coral) → writes to /academics/{userId}/semesters/{semId}

4. CSV Upload:
   - "Upload CSV" button → file input (accepts .csv)
   - Expected format: RollNumber, Semester, SubjectName, Marks, MaxMarks, CGPA
   - Show preview table after parsing
   - Row validation: highlight invalid rows in red
   - "Confirm Import" button → batch write to Firestore

ATTENDANCE PAGE:

1. Year + Section filter at top

2. Editable table:
   | Roll No | Name | Total Classes | Attended | Percentage |
   - Total Classes + Attended: inline editable number inputs
   - Percentage: auto-computed, color-coded cell:
     < 75%: red text + light red background
     75–85%: amber text + light amber background
     > 85%: green text + light green background
   - Per-row save icon (check) on change

3. Bulk: "Set Total Classes for All" input + apply button
   (sets the totalClasses field for all shown students at once)
```

---

## Prompt 2.7 — Analytics Dashboard

```
Build the Analytics page for MyCSIT faculty dashboard using Recharts.

All charts use the color palette: primary #FF6B35, secondary #FF9F1C, 
third #3B82F6, fourth #22C55E. White chart backgrounds, clean gridlines (#F3F3F3).

1. Stats Row (4 cards):
   - Total Active Students: number
   - Average CGPA: float (1 decimal)
   - Avg Total Score: float (1 decimal)
   - Activity Participation Rate: percentage (students with ≥1 approved activity / total)
   Card design: white, radius 16px, shadow, coral icon in rounded square bg

2. Chart: CGPA Distribution (BarChart)
   - X-axis: CGPA buckets (0–4, 4–5, 5–6, 6–7, 7–8, 8–9, 9–10)
   - Y-axis: number of students
   - Coral bars, hover tooltip

3. Chart: Top 10 Students by Score (HorizontalBarChart)
   - Y-axis: student names
   - X-axis: total score (0–100)
   - Gradient bar from coral to amber
   - Clickable bars → navigate to student detail

4. Chart: Activity Type Breakdown (BarChart grouped)
   - X-axis: activity types
   - Y-axis: count of approved entries
   - Each bar: type-specific color

5. Chart: Coding Platform Distribution (PieChart/DonutChart)
   - Segments: LeetCode, Codeforces, CodeChef, Other
   - Platform-specific colors
   - Center label: total coding entries

6. At-Risk Students List:
   - Title: "Students with 0 Approved Activities" (red indicator)
   - Table: Name | Roll No | Year | Section | CGPA | Score
   - "View Profile" action per row

All charts fetch from:
- /users (for student list + scores)
- /activities (for activity breakdown)
- /codingActivities (for coding data)
Aggregate client-side.
```

---

## Prompt 2.8 — Cloud Functions

```
Write Firebase Cloud Functions (Node.js + TypeScript) for MyCSIT.

1. onStudentCreated (Firestore trigger: onCreate /users/{uid}):
   - Check if rollNumber already exists in collection
   - If duplicate: add a field "error: duplicate_roll" and log — 
     the client should have checked but this is the safety net
   - Send FCM notification to all faculty: 
     "New student registration: [name]"

2. onActivityStatusChanged (Firestore trigger: onUpdate /activities/{activityId}):
   - If status changed to "approved" or "rejected":
     - Get the student's FCM token from /users/{userId}.fcmToken
     - Send notification:
       approved → "Your activity '[title]' has been approved ✓"
       rejected → "Your activity '[title]' was not approved: [reason]"
     - Call recalculateScore(userId)

3. onCodingStatusChanged (same pattern for /codingActivities/{id})

4. recalculateScore(userId) - callable function:
   Input: { userId: string }
   Steps:
   a) Fetch approved activities for user
   b) Compute activityScore using weighted category system (see logic.md)
   c) Fetch approved coding entries
   d) Compute codingScore (highest milestone per platform, contest count)
   e) Fetch latest CGPA from /academics/{userId} (most recent semester)
   f) Compute academicScore = (cgpa / 10) × 100
   g) totalScore = (academicScore × 0.40) + (activityScore × 0.30) + (codingScore × 0.30)
   h) Write to /users/{userId}/scoreCache: { totalScore, academicScore, activityScore, codingScore, lastComputed }
   
   Rate limit: use a Firestore timestamp check — if lastComputed < 30 seconds ago, skip.

5. approveFacultyRole - HTTP callable (admin only):
   Input: { uid: string }
   Sets custom claim: { role: 'faculty' }
   Updates /users/{uid}.status = "active"
   (Used during faculty account seeding)
```

---

## Prompt 2.9 — Firestore Security Rules

```
Write complete Firestore security rules for MyCSIT.

Requirements:
- Students can only read/write their own documents
- Students cannot write status, role, or score fields
- Faculty can read all student documents
- Faculty can write approval status fields
- Scores can only be written by Cloud Functions (service account)
- Proof file URLs are read-only after being set
- Audit log is append-only (no updates/deletes)

Helper functions needed:
- isAuthenticated(): request.auth != null
- isStudent(): request.auth.token.role == 'student'
- isFaculty(): request.auth.token.role == 'faculty'
- isOwner(userId): request.auth.uid == userId
- isNotChangingProtectedFields(): 
    !('status' in request.resource.data.diff(resource.data).affectedKeys()
    || 'role' in ...)

Write rules for:
- /users/{uid}: students read/write own, faculty read all, faculty write status only
- /users/{uid}/profile: student read/write own, faculty read
- /users/{uid}/scoreCache: read by owner + faculty, write by nobody (functions only)
- /activities/{activityId}: 
    read: owner or faculty
    create: owner (with required fields validation)
    update: owner if status==rejected only (resubmit); faculty for status field only
    delete: nobody (soft delete via isDeleted field)
- /codingActivities/{id}: same as activities
- /academics/{uid}/{semId}: faculty read/write, student read only
- /auditLog/{logId}: create by faculty, no updates/deletes, read by faculty

Include Firebase Storage rules:
- /proofs/{userId}/**:
    read: owner or faculty
    write: owner (size < 5MB, content type image/* or application/pdf)
```

---

*End of Build Prompts. Use prompts in sequence within each numbered phase. Each prompt assumes the previous one is complete. Adjust Firebase project IDs and collection names to match your actual Firebase setup.*
