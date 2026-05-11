# MyCSIT Setup Instructions

## 🚀 Current Status

✅ **Completed:**
- Supabase credentials configured in both apps
- Database schema and RLS policies created
- Storage buckets set up
- React Faculty Dashboard running on http://localhost:3001
- Seed data prepared

⏳ **In Progress:**
- Flutter app setup (dependency issues)

## 📋 Setup Steps

### 1. Supabase Database Setup

Execute these SQL scripts in your Supabase Dashboard > SQL Editor:

**Step 1:** Run `setup_supabase.sql` - Creates all tables and functions
**Step 2:** Run `setup_rls_policies.sql` - Sets up security policies  
**Step 3:** Run `seed_faculty.sql` - Creates sample data

### 2. Create Authentication Users

In Supabase Dashboard > Authentication > Users, create these users:

**Faculty Accounts:**
- Email: `faculty@mycsit.edu` | Password: `Faculty123!`
- Email: `hod@mycsit.edu` | Password: `HOD123!`  
- Email: `coordinator@mycsit.edu` | Password: `Coord123!`

**Student Accounts:**
- Email: `student1@mycsit.edu` | Password: `Student123!`
- Email: `student2@mycsit.edu` | Password: `Student123!`

After creating users, note their UUIDs and update the `seed_faculty.sql` file with the actual UUIDs, then re-run the seed script.

### 3. React Faculty Dashboard

✅ **Already Running:** http://localhost:3001

**Login Credentials:**
- Email: `faculty@mycsit.edu`
- Password: `Faculty123!`

### 4. Flutter Mobile App

**Current Issue:** Flutter installation has web plugin conflicts.

**Solution Options:**

**Option A: Fix Flutter Installation**
```bash
# Run Flutter doctor to diagnose
flutter doctor -v

# Clean and reinstall
flutter clean
flutter pub cache repair
flutter pub get
```

**Option B: Use Compatible Dependencies**
Update `pubspec.yaml` with these versions:
```yaml
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^1.10.3
  flutter_riverpod: ^2.3.6
  go_router: ^7.1.1
  google_fonts: ^4.0.4
  cached_network_image: ^3.2.3
  image_picker: ^0.8.7+5
  flutter_image_compress: ^1.1.0
  intl: ^0.18.1
  uuid: ^3.0.7
  url_launcher: ^6.1.11
  cupertino_icons: ^1.0.5
```

**Option C: Fresh Flutter Install**
```bash
# Download fresh Flutter from flutter.dev
# Extract to C:\flutter
# Add to PATH: C:\flutter\bin
# Run: flutter doctor
```

### 5. Testing the System

**React Dashboard Features:**
- ✅ Faculty login
- ✅ Student management
- ✅ Activity approvals
- ✅ Academic data entry
- ✅ Analytics dashboard

**Flutter App Features (once running):**
- Student registration
- Activity logging
- Profile management
- Score viewing
- Notifications

## 🔧 Troubleshooting

**Flutter Issues:**
- Missing `flutter_web_plugins` → Reinstall Flutter
- Dependency conflicts → Use compatible versions
- Android SDK issues → Update Android Studio

**Supabase Issues:**
- RLS policies blocking access → Check user roles
- Storage upload failures → Check bucket policies
- Score calculation errors → Verify trigger functions

**React Issues:**
- Port conflicts → Change port in vite.config.ts
- Environment variables → Check .env file
- CORS errors → Verify Supabase URL

## 📱 Next Steps

1. **Fix Flutter setup** using Option A, B, or C above
2. **Create test users** in Supabase Auth
3. **Test student registration** flow
4. **Test activity approval** workflow
5. **Verify score calculation** system

## 🎯 System Architecture

```
Supabase (Backend)
├── Authentication
├── PostgreSQL Database
├── File Storage
└── Edge Functions

React Faculty Dashboard (Web)
├── http://localhost:3001
├── Faculty login
├── Student management
└── Analytics

Flutter Mobile App (Student)
├── Student registration
├── Activity logging
├── Profile management
└── Score tracking
```

## 📞 Support

For issues:
1. Check Supabase logs
2. Verify RLS policies
3. Test with sample data
4. Check browser console (React)
5. Run flutter doctor (Flutter)
