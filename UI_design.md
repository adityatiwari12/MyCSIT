# MyCSIT — UI Design Specification

## Design Language

**Aesthetic Direction:** Clean, card-based, warm-white with coral/orange accent — directly inspired by the reference image. Feels like a modern ed-tech product, not an enterprise system. Friendly but credible.

**Tone:** Approachable, structured, motivating

---

## Design Tokens

### Color Palette

```
Primary Accent:    #FF6B35  (coral-orange, from reference image)
Secondary Accent:  #FF9F1C  (warm amber)
Highlight:         #FFF3EE  (peach tint for backgrounds/cards)
Success:           #22C55E
Warning:           #F59E0B
Error:             #EF4444
Info:              #3B82F6

Background:        #F8F8F8  (off-white, never pure white)
Surface:           #FFFFFF
Surface Elevated:  #FFFFFF + shadow
Border:            #EEEEEE

Text Primary:      #1A1A2E
Text Secondary:    #6B7280
Text Muted:        #9CA3AF
Text Inverse:      #FFFFFF
```

### Typography

```
Display / Headings:  Poppins (Bold, SemiBold)
Body:                DM Sans (Regular, Medium)
Monospace (scores):  JetBrains Mono
```

### Spacing Scale (8pt grid)
```
xs: 4px
sm: 8px
md: 16px
lg: 24px
xl: 32px
2xl: 48px
```

### Border Radius
```
sm: 8px
md: 12px
lg: 16px
xl: 24px
full: 9999px
```

### Shadows
```
card: 0 2px 12px rgba(0,0,0,0.06)
elevated: 0 4px 24px rgba(0,0,0,0.10)
accent-glow: 0 4px 16px rgba(255,107,53,0.25)
```

---

## Mobile App (Flutter) — Screen-by-Screen

### 1. Splash Screen
- White background, centered MyCSIT logo (wordmark + icon)
- Coral underline animation on load
- Auto-navigate to Login or Home based on auth state

### 2. Login Screen
- Top: Large greeting headline "Welcome Back 👋" in Poppins Bold
- Subtext in DM Sans muted
- Roll number input field (rounded, outlined)
- Password input field (with show/hide toggle)
- Coral "Login" button (full width, rounded-full)
- Bottom link: "New here? Register"
- No social login. No "Forgot password" in MVP.

### 3. Registration Screen
- Fields: Name, Roll Number, Year (dropdown 1–4), Section (A/B/C), Password, Confirm Password
- Coral "Register" CTA
- On submit → shows pending approval screen

### 4. Pending Approval Screen
- Illustrated empty state (clock/hourglass illustration)
- Headline: "Account Pending Approval"
- Subtext: "Your registration is being reviewed by faculty. You'll be notified once approved."
- Logout button (text, not primary CTA)

### 5. Home / Dashboard Screen
- **Top Bar:** Avatar + "Hi, [First Name] 👋" + notification bell (same as reference)
- **Profile Score Card:** Large coral gradient card
  - Profile completeness ring (circular progress)
  - Total score badge
  - Quick stats: Activities, Coding entries
- **Quick Actions Row:** Icon buttons — Add Activity, Add Coding, View Timeline, Profile
- **Recent Activity Feed:** Last 3 entries with status badges (pending = amber, approved = green, rejected = red)
- **Marks Snapshot:** Horizontal scroll card per semester
- **Bottom Nav Bar:** Home | Timeline | Add (+) | Profile (4 tabs)

### 6. Profile Screen
- Large circular avatar with edit overlay
- Name, Roll No, Year, Section (non-editable fields grayed)
- Profile completeness bar (linear, coral)
- Social Links section — each platform chip with icon + linked/unlinked state
  - LinkedIn, GitHub, LeetCode, Codeforces, CodeChef, Portfolio
- Edit button → inline editing

### 7. Activity Log Screen
- Segmented filter tabs: All | Pending | Approved | Rejected
- Each card shows:
  - Type badge (color-coded pill)
  - Title
  - Date
  - Status indicator (dot + label)
  - Tap → detail view with proof preview

### 8. Add Activity / Add Coding Screens
- Step-form feel (not all fields at once)
- Step 1: Select type (icon grid — large tap targets)
- Step 2: Fill metadata (title, date, description)
- Step 3: Upload proof (drag-area with file icon; shows filename on upload)
- Submit button → optimistic UI → shows in feed with "Pending" badge

### 9. Coding Activity Screen
- Tabs: Milestones | Contests | High-Value Problems
- Each entry card: Platform logo + title + value + status
- Add button (FAB, coral)
- Milestone entry: platform picker + problem count slider/input
- Contest entry: platform + contest name + rank achieved

### 10. Timeline Screen
- Unified chronological feed of ALL entries (activities + coding)
- Filter chips at top: All | Hackathon | Coding | Certification | Research | etc.
- Status filter toggle: Show pending / approved only
- Entry cards with left-border color by type

### 11. Academic View (Read-only for student)
- Per-semester accordion
- Subject list with marks
- Attendance percentage (large circular gauge, coral)
- CGPA badge at top

### 12. Notifications
- Simple list screen
- Entry approved → green icon + message
- Entry rejected → red icon + rejection reason
- Account approved → special welcome card

---

## Status Badge System (Mobile)

| Status | Color | Background |
|---|---|---|
| Pending | #F59E0B | #FEF3C7 |
| Approved | #22C55E | #DCFCE7 |
| Rejected | #EF4444 | #FEE2E2 |

---

## Faculty Web Dashboard (React + Tailwind)

### Layout
- **Left Sidebar:** Fixed, 240px wide
  - MyCSIT logo
  - Nav items: Dashboard, Students, Approvals, Marks, Attendance, Analytics
  - Faculty name + avatar at bottom
- **Main Content:** Fluid, max-width 1280px
- **Top Bar:** Page title + breadcrumb + action buttons

### 1. Dashboard Overview
- Stat cards row (4 cards): Total Students, Pending Approvals, Avg CGPA, Avg Score
- Each card: icon (coral background), number in Poppins Bold, label
- Charts section:
  - Score distribution bar chart
  - Activity participation donut chart
- Quick access: "Students with 0 activities" list (at-risk)

### 2. Student Directory
- Search bar (by name or roll number)
- Filter panel (collapsible):
  - Year: multi-select
  - Section: multi-select
  - CGPA range: dual slider
  - Score range: dual slider
  - Activity types: checkboxes
  - Coding entries: has/has-not toggle
- Results as data table:
  - Columns: Name, Roll No, Year, Section, CGPA, Score, Activities, Status
  - Sortable columns (click header)
  - Row click → Student Detail View
- Export to CSV button

### 3. Student Detail View
- Left panel: Avatar, name, roll no, social links
- Tabs: Overview | Activities | Coding | Academics | Score Breakdown
- Score Breakdown tab: Visual bar chart showing academic/activity/coding component weights
- Activity list: shows proof link, approve/reject buttons inline

### 4. Approval Queue
- Tabs: Student Registrations | Activity Entries | Coding Entries
- Each card: Student name, roll no, type, title, submitted date, proof preview link
- Approve (green) / Reject (red, with reason modal) buttons
- Bulk select + bulk approve for low-risk entries (checkboxes + top action bar)

### 5. Marks Management
- Student picker (search/dropdown)
- Semester accordion
- Subject rows: name + marks input + max marks
- CGPA field (manual override)
- CSV upload button → preview table → confirm/commit

### 6. Attendance Management
- Table: Roll No | Name | Total Classes | Attended | Percentage
- Inline edit cells
- Percentage auto-computed, colored: red <75%, amber 75–85%, green >85%

### 7. Analytics
- CGPA histogram (bar chart)
- Top 10 students leaderboard table
- Activity type breakdown (grouped bar chart by type)
- Coding platform distribution (donut)
- Engagement trend (if enough data — monthly activity submissions)
- All charts: coral/amber color palette, clean gridlines

---

## Component Library (Shared Patterns)

### Cards
```
Background: #FFFFFF
Border-radius: 16px
Shadow: 0 2px 12px rgba(0,0,0,0.06)
Padding: 16px (mobile), 24px (web)
```

### Primary Button
```
Background: #FF6B35
Text: white, Poppins SemiBold
Border-radius: 9999px (pill)
Padding: 14px 28px
Hover: darken 8%, slight scale(1.02)
Shadow on hover: accent-glow
```

### Input Fields
```
Border: 1px solid #EEEEEE
Border-radius: 12px
Focus border: #FF6B35
Background: #F8F8F8
Padding: 12px 16px
```

### Status Pills
```
Border-radius: 9999px
Font: DM Sans Medium, 12px
Padding: 4px 10px
```

### Accent Banner Card (like reference image's hero card)
```
Background: linear-gradient(135deg, #FF6B35, #FF9F1C)
Border-radius: 16px
Text: white
Shadow: accent-glow
```

---

## Motion & Micro-interactions

**Mobile (Flutter)**
- Screen transitions: slide-in from right (standard)
- Card entrance: fade + slight upward translate (200ms)
- FAB: scale bounce on tap
- Status badge: color fade on state change
- Score ring: animated fill on first render

**Web (CSS/Framer Motion)**
- Sidebar items: smooth active indicator slide
- Table rows: subtle hover background
- Cards: lift on hover (translateY -2px)
- Approval buttons: ripple on click
- Chart bars: staggered entrance animation

---

## Empty States

Every empty list/section has:
- Centered illustration (simple SVG, coral accent)
- Headline ("No activities yet")
- CTA button or instruction text

Examples:
- No activities: "Start building your profile"
- No coding entries: "Log your first milestone"
- Pending approval queue empty: "You're all caught up ✓"

---

## Accessibility

- All interactive elements min 44×44px touch target (mobile)
- Color is never the only differentiator (always paired with icon or label)
- Contrast ratio ≥ 4.5:1 for all text
- Focus states visible on all inputs/buttons (web)
