# MyCSIT — Student Intelligence Platform

## Prerequisites

- **Flutter SDK** (latest stable)
- **Node.js** 18+ and **npm**
- **Android Emulator** or physical device
- **Supabase** account (free tier works)

---

## 1. Faculty Dashboard (React + Vite)

### Setup
```bash
cd mycsit-faculty
npm install
```

### Configure Supabase
Create `.env` in `mycsit-faculty/`:
```env
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key
```

### Run
```bash
npm run dev
```
Opens at **http://localhost:3001**

### Build for Production
```bash
npm run build
npm run preview
```

---

## 2. Flutter Student App

### Setup
```bash
cd mycsit
flutter pub get
```

### Configure Supabase
Edit `lib/core/config/supabase_config.dart`:
```dart
class SupabaseConfig {
  static const String url = 'https://your-project.supabase.co';
  static const String anonKey = 'your-anon-key';
}
```

### Run on Emulator
```bash
flutter run -d emulator-5556
```

### Run on Physical Device
```bash
flutter run -d <device-id>
```

---

## 3. Supabase Database Setup

### One-time Setup
1. Go to [Supabase Dashboard](https://app.supabase.com)
2. Open your project → **SQL Editor**
3. Run the contents of:
   - `mycsit-faculty/src/lib/supabase_minimal_setup.sql`
   
   OR
   
   - `setup_supabase.sql` (full setup with triggers)

### Required Tables
- `users` — students & faculty
- `activities` — student activity entries
- `coding_activities` — coding milestones & contests
- `score_cache` — computed leaderboard scores
- `semesters` / `subjects` — academic marks
- `notifications` — in-app alerts

---

## Architecture

```
┌─────────────────┐     ┌─────────────────┐
│  Flutter App    │     │  Faculty React  │
│  (Students)     │◄────►│  Dashboard      │
│                 │     │  (Faculty)      │
└────────┬────────┘     └────────┬────────┘
         │                         │
         └──────────┬──────────────┘
                    │
              ┌─────▼─────┐
              │  Supabase │
              │  (Auth +  │
              │  Database)│
              └───────────┘
```

### Key Workflows
- **Registration**: Student registers → Status = `pending` → Faculty sees in Approvals tab
- **Approval**: Faculty approves → Status = `active` → Student can login
- **Activity Submit**: Student submits → Faculty approves/rejects → Score recalculated

---

## Common Issues

### Faculty dashboard stuck on loading
- **Cause**: Missing `coding_activities` table in Supabase
- **Fix**: Run the SQL setup script in Supabase SQL Editor

### Flutter build errors
- **Fix**: `flutter clean && flutter pub get`

### Port conflicts (3000 occupied)
- **Fix**: Already set to 3001 in `vite.config.ts`

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend (Student) | Flutter + Riverpod |
| Frontend (Faculty) | React + Vite + Tailwind |
| Backend | Supabase (PostgreSQL + Auth + Realtime) |
| State Management | Riverpod (Flutter) / Zustand (React) |

---

## Support

For issues, check:
1. Supabase connection strings are correct in both apps
2. Database tables are created via SQL setup
3. Faculty account has `role = 'faculty'` in `users` table
