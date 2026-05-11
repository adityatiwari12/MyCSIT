# MyCSIT — Product Context

## What Is MyCSIT?

MyCSIT is a **department-level student intelligence platform** for the CSIT department at Acropolis Institute of Technology and Research (AITR), Indore. It consists of:

- A **Flutter mobile app** for students
- A **React (TypeScript) web dashboard** for faculty
- A **Firebase backend** powering auth, data, file storage, and real-time validation

The system transforms fragmented student data—academic records, projects, coding activity, hackathons—into a verified, queryable, and scored intelligence layer that faculty can act on.

---

## The Asymmetry Problem

**What faculty see today:** CGPA + whatever the student puts on a resume  
**What actually signals capability:** projects, coding consistency, hackathon participation, certifications, internships

MyCSIT bridges this gap by creating a structured pipeline:

> Student effort → Logged data → Faculty validation → Computed score → Faculty decision

---

## Deployment Context

- **Scope:** CSIT department only, AITR
- **Users:** ~120–200 students per year, ~10–20 faculty members
- **Scale:** Single-institution MVP, designed to be extensible later

---

## Core Constraints

| Constraint | Decision |
|---|---|
| Backend | Firebase (Auth, Firestore, Storage, Functions) |
| Mobile | Flutter (iOS + Android) |
| Web dashboard | React + TypeScript |
| Auth method | Roll number + password |
| Account activation | Faculty approval required after student signup |
| Proof upload | Mandatory for every activity/coding entry |
| UI Theme | Light-first, dark mode toggle available |

---

## User Roles

### Student
- Self-registers with roll number + password
- Account is **pending** until a faculty member approves it
- Once approved, has full access to log activities, coding milestones, view their score, and update profile

### Faculty
- Pre-seeded accounts (created by system admin, not self-registered)
- Approves/rejects new student registrations
- Approves/rejects student-submitted activity entries
- Manages marks and attendance
- Views filtered student rankings and analytics

### System Admin (implicit)
- Controls faculty account creation
- Has full Firestore access
- Not exposed in the UI (managed via Firebase console or a separate admin script)

---

## Key Design Principles

1. **Separation of Trust** — Students generate, faculty validate, system computes
2. **Signal over Noise** — Milestones and verified achievements; no raw activity logs
3. **Decision-Oriented** — Every feature must enable a better faculty decision
4. **Proof-Gated** — No entry is approved without an uploaded proof file
5. **Score as Derivative** — Scores are computed dynamically from approved entries only; never inflatable by spamming

---

## Scoring Logic Summary

| Component | Weight | Source |
|---|---|---|
| Hackathons & Events | 35% | Approved hackathon/achievement entries |
| Projects & Internships | 25% | Approved project/internship/research entries |
| Academic (CGPA) | 25% | Faculty-entered CGPA, normalized |
| Coding Activity | 15% | Approved milestones + contest results |

**Priority order (faculty-ranked):**  
Hackathons/Events > Projects & Internships > Academic (CGPA) > Coding activity

This ranking reflects what faculty at AITR CSIT actually use to evaluate student capability — real-world exposure and applied work outweigh academic scores and platform grinding.

---

## Success Criteria

- Faculty can shortlist top 10 students for an opportunity in under 2 minutes
- 0 unverified entries affect scores
- Students log at least 3+ activities per semester
- Proof file attached to 100% of approved entries
