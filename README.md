# MyCSIT - Student Intelligence Platform

A comprehensive platform for CSIT Department students to track their academic performance, activities, and achievements. Built with Flutter for mobile and React for faculty dashboard.

## 📱 Applications

### Student App (Flutter)
- **Location:** `mycsit/`
- **Platform:** Android
- **Purpose:** Students can register, submit activities, track academics, and view their profile

### Faculty Dashboard (React)
- **Location:** `mycsit-faculty/`
- **Platform:** Web
- **Purpose:** Faculty can approve student registrations, review activities, and monitor student progress

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (3.0+)
- Node.js (18+)
- Supabase account
- Git

### Database Setup

1. **Execute SQL files in order:**
   ```bash
   # In Supabase SQL Editor, run:
   database/ENSURE_FLUTTER_TABLES.sql
   database/setup_supabase.sql
   database/seed_faculty.sql
   ```

2. **Disable Email Confirmation** (to avoid rate limits):
   - Go to Supabase Dashboard → Authentication → Settings
   - Toggle OFF "Confirm email"
   - Click Save

### Student App Setup

```bash
cd mycsit
flutter pub get
flutter run
```

**Build APK:**
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Faculty Dashboard Setup

```bash
cd mycsit-faculty
npm install
npm run dev
```

## 🔐 Authentication



### Student Registration
- Students register with their email and password
- Status defaults to `pending`
- Faculty must approve via dashboard

## 📁 Project Structure

```
MyCSIT/
├── mycsit/                 # Flutter Student App
│   ├── lib/
│   │   ├── screens/       # UI screens
│   │   ├── services/      # Supabase services
│   │   ├── providers/     # State management
│   │   └── models/        # Data models
│   └── android/           # Android configuration
├── mycsit-faculty/        # React Faculty Dashboard
│   ├── src/
│   │   ├── features/      # Feature modules
│   │   ├── stores/        # State management
│   │   └── lib/           # Supabase client
│   └── package.json
├── database/              # SQL scripts
├── docs/                  # Documentation
├── config/                # Firebase/Supabase config
├── functions/             # Firebase Functions
└── supabase/              # Supabase migrations
```

## ✨ Features

### Student App
- ✅ Student registration with approval workflow
- ✅ Activity submission (hackathons, projects, certifications)
- ✅ Coding activity tracking (LeetCode, Codeforces, CodeChef)
- ✅ Academic data entry (semesters, subjects, attendance)
- ✅ Profile management with social links
- ✅ Real-time status updates

### Faculty Dashboard
- ✅ Student registration approval/rejection
- ✅ Activity approval workflow
- ✅ Student analytics dashboard
- ✅ Academic performance tracking
- ✅ Activity monitoring
- ✅ Score calculation and ranking

## 📊 Database Tables

- `users` - User profiles and authentication
- `user_profiles` - Extended user information
- `activities` - Student activities (hackathons, projects, etc.)
- `coding_activities` - Coding platform activities
- `semesters` - Academic semester data
- `subjects` - Subject-wise marks
- `attendance` - Attendance records
- `score_cache` - Computed score cache
- `notifications` - User notifications

## 🔧 Configuration

### Supabase
- **Project URL:** `https://znhipxtgjileabyrooxf.supabase.co`
- **Anon Key:** Configured in `mycsit/lib/core/config/supabase_config.dart`

### Environment Variables
Create `.env` in `mycsit-faculty/`:
```env
VITE_SUPABASE_URL=your_supabase_url
VITE_SUPABASE_ANON_KEY=your_anon_key
```

## 📝 Documentation

- [Flutter Setup Guide](docs/FLUTTER_SETUP_GUIDE.md)
- [Supabase Setup Guide](docs/SUPABASE_SETUP_GUIDE.md)
- [Android Studio Guide](docs/ANDROID_STUDIO_GUIDE.md)
- [Implementation Plan](docs/implementation_plan.md)

## 🐛 Troubleshooting

### Registration Fails with Rate Limit Error
- Disable email confirmation in Supabase Dashboard
- See [FIX_RATE_LIMIT.md](docs/FIX_RATE_LIMIT.md)

### Dashboard Loading State
- Ensure all database tables exist
- Run `database/ENSURE_FLUTTER_TABLES.sql`

### Build Errors
- Run `flutter clean` then `flutter pub get`
- Check Flutter SDK version compatibility

## 📦 Building for Production

### Student App APK
```bash
cd mycsit
flutter build apk --release
```

### Faculty Dashboard
```bash
cd mycsit-faculty
npm run build
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📄 License

This project is for educational purposes for the CSIT Department at AITR.

## 👥 Team

- **Faculty Dashboard:** CSIT Faculty
- **Student App:** CSIT Students
