# 🚀 MyCSIT Supabase Setup Guide

## ✅ Setup Files Created

1. **COMPLETE_SETUP.sql** - Full database schema with tables, functions, RLS policies, and storage buckets
2. **SEED_DATA.sql** - Sample faculty and student data (run after creating auth users)
3. **SUPABASE_SETUP_GUIDE.md** - This setup guide

## 📋 Step-by-Step Setup

### Step 1: Execute Database Schema

1. Open Supabase Dashboard: https://wxnafmsqhlqjdujplk.supabase.co
2. Navigate to **SQL Editor**
3. Copy the entire contents of `COMPLETE_SETUP.sql`
4. Paste and click **Run**
5. Verify success with the verification queries at the bottom

### Step 2: Create Authentication Users

In Supabase Dashboard → **Authentication** → **Users**, create these users:

**Faculty Accounts:**
- Email: `faculty@mycsit.edu` | Password: `Faculty123!`
- Email: `hod@mycsit.edu` | Password: `HOD123!`
- Email: `coordinator@mycsit.edu` | Password: `Coord123!`

**Student Accounts:**
- Email: `student1@mycsit.edu` | Password: `Student123!`
- Email: `student2@mycsit.edu` | Password: `Student123!`
- Email: `student3@mycsit.edu` | Password: `Student123!`

### Step 3: Get User UUIDs

After creating users, get their UUIDs by running this in SQL Editor:

```sql
SELECT id, email FROM auth.users ORDER BY created_at DESC;
```

### Step 4: Update Seed Data

Open `SEED_DATA.sql` and replace the placeholder UUIDs:

```sql
-- Replace these with actual UUIDs from Step 3
faculty_1 UUID := 'ACTUAL_FACULTY_UUID_1';  -- faculty@mycsit.edu
faculty_2 UUID := 'ACTUAL_FACULTY_UUID_2';  -- hod@mycsit.edu
faculty_3 UUID := 'ACTUAL_FACULTY_UUID_3';  -- coordinator@mycsit.edu
student_1 UUID := 'ACTUAL_STUDENT_UUID_1';  -- student1@mycsit.edu
student_2 UUID := 'ACTUAL_STUDENT_UUID_2';  -- student2@mycsit.edu
student_3 UUID := 'ACTUAL_STUDENT_UUID_3';  -- student3@mycsit.edu
```

### Step 5: Execute Seed Data

1. Copy the updated `SEED_DATA.sql`
2. Paste in SQL Editor and run
3. Verify data insertion with the verification queries

### Step 6: Test Applications

**React Faculty Dashboard:**
- ✅ Already running on http://localhost:3001
- Login with: `faculty@mycsit.edu` / `Faculty123!`

**Flutter Mobile App:**
- Fix dependency issues (see Flutter setup instructions)
- Run with: `flutter run`

## 🔧 Database Schema Overview

### Core Tables
- **users** - User accounts with role-based access
- **user_profiles** - Extended profile information
- **score_cache** - Computed student scores
- **activities** - Student activities (hackathons, projects, etc.)
- **coding_activities** - Coding platform achievements
- **semesters/subjects/attendance** - Academic data
- **notifications** - User notifications
- **audit_log** - System audit trail

### Key Features
- **Row Level Security** - Users can only access their own data
- **Faculty Override** - Faculty can view all student data
- **Score Calculation** - Automatic scoring based on approved activities
- **Notifications** - Automated notifications for approvals
- **File Storage** - Secure file upload buckets

### Scoring Algorithm
- **Hackathons/Events**: 35% (max 3 entries per type)
- **Projects/Internships**: 25% (max 3 entries per type)
- **Academic (CGPA)**: 25% (based on latest semester CGPA)
- **Coding Activity**: 15% (milestones + contests)

## 📱 Application Features

### Faculty Dashboard (React)
- ✅ Student management and approval
- ✅ Activity review and approval
- ✅ Academic data entry
- ✅ Analytics and reporting
- ✅ Real-time notifications

### Student App (Flutter)
- ⏳ Registration and profile setup
- ⏳ Activity logging with proof uploads
- ⏳ Score tracking and progress
- ⏳ Notifications and updates

## 🧪 Testing the System

### Test Faculty Workflow
1. Login to React dashboard
2. View pending student registrations
3. Approve/reject student accounts
4. Review pending activities
5. Enter academic data
6. View analytics dashboard

### Test Student Workflow
1. Register new student account
2. Complete profile with social links
3. Log activities with proof uploads
4. View score and progress
5. Receive notifications

## 🔍 Troubleshooting

### Common Issues

**RLS Policy Blocking Access**
```sql
-- Check current user
SELECT auth.uid();

-- Check user role
SELECT role, status FROM public.users WHERE id = auth.uid();
```

**Score Not Calculating**
```sql
-- Manually recalculate score
SELECT calculate_score('user_uuid_here');

-- Check score cache
SELECT * FROM public.score_cache WHERE user_id = 'user_uuid_here';
```

**Storage Upload Issues**
```sql
-- Check storage policies
SELECT * FROM pg_policies WHERE tablename LIKE 'storage%';

-- Check bucket permissions
SELECT * FROM storage.buckets;
```

**Function Errors**
```sql
-- Check function exists
SELECT proname FROM pg_proc WHERE proname = 'calculate_score';

-- Test function
SELECT calculate_score('user_uuid_here');
```

## 📊 Verification Queries

Run these to verify setup:

```sql
-- Check all tables created
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' AND table_type = 'BASE TABLE';

-- Check users and roles
SELECT name, roll_number, role, status FROM public.users;

-- Check scores calculated
SELECT u.name, sc.total_score 
FROM public.users u 
JOIN public.score_cache sc ON u.id = sc.user_id 
WHERE u.role = 'student';

-- Check pending activities
SELECT u.name, a.title, a.status 
FROM public.activities a 
JOIN public.users u ON a.user_id = u.id 
WHERE a.status = 'pending';
```

## 🎯 Next Steps

1. **Execute COMPLETE_SETUP.sql** ✅
2. **Create auth users** in Supabase Dashboard
3. **Update SEED_DATA.sql** with real UUIDs
4. **Execute SEED_DATA.sql**
5. **Test React dashboard** ✅
6. **Fix Flutter dependencies** and test mobile app
7. **End-to-end testing** of complete system

## 📞 Support

For issues:
1. Check Supabase logs in Dashboard
2. Verify RLS policies are working
3. Test with sample data
4. Check browser console for React issues
5. Run `flutter doctor` for Flutter issues

---

**Status:** Database setup complete ✅ | React dashboard running ✅ | Flutter app pending ⏳
