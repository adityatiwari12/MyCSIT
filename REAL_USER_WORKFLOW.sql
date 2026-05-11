-- ============================================================
-- MyCSIT — Real User Workflow (No Mock Data)
-- ============================================================

-- NOTE: Do NOT insert fake users with placeholder UUIDs
-- Users will be created through Supabase Auth signup
-- The trigger will automatically create public.users records

-- This script only creates sample activities/seed data
-- that will be linked to REAL users after they sign up

-- ============================================================
-- WHAT HAPPENS WHEN A REAL USER SIGNS UP:
-- ============================================================

-- 1. User signs up through Flutter app or React dashboard
-- 2. Supabase Auth creates user in auth.users
-- 3. Trigger automatically creates record in public.users
-- 4. Trigger creates profile in public.user_profiles
-- 5. Trigger creates score cache in public.score_cache
-- 6. User can now login and use the app

-- ============================================================
-- NO MOCK USER INSERTS - Real Workflow Only
-- ============================================================

-- The application will handle user creation through:
-- - Flutter: SupabaseAuth.signUp()
-- - React: supabase.auth.signUp()

-- Faculty will approve students through the dashboard
-- Students will have status 'pending' until approved

-- ============================================================
-- INSTRUCTIONS FOR TESTING:
-- ============================================================

-- Step 1: Create auth users in Supabase Dashboard
-- Go to: Authentication → Users → Add user

-- Step 2: Create a faculty account
-- Email: faculty@mycsit.edu
-- Password: Faculty123!

-- Step 3: Create a student account  
-- Email: student1@mycsit.edu
-- Password: Student123!

-- Step 4: Get the UUIDs
-- Run: SELECT id, email FROM auth.users;

-- Step 5: Update the user roles (optional - can be done through dashboard)
-- UPDATE public.users SET role = 'faculty', status = 'active' WHERE id = 'FACULTY_UUID';

-- Step 6: Test the apps
-- React dashboard: http://localhost:3001
-- Flutter app: flutter run

-- ============================================================
-- VERIFICATION - Check Real Users
-- ============================================================

SELECT 'Real User Workflow Ready!' as status;
SELECT 'Current auth users:' as info, COUNT(*) as count FROM auth.users;
SELECT 'Current public.users:' as info, COUNT(*) as count FROM public.users;

-- Show any users that were created through the trigger
SELECT u.id, u.name, u.email, u.role, u.status, u.created_at
FROM public.users u
ORDER BY u.created_at DESC
LIMIT 10;
