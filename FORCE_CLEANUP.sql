-- ============================================================
-- MyCSIT — Force Complete Cleanup
-- Run this first to remove ALL existing policies and tables
-- ============================================================

-- Step 1: Disable RLS on all tables
ALTER TABLE IF EXISTS public.users DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.user_profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.score_cache DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.activities DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.coding_activities DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.semesters DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.subjects DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.attendance DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.notifications DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.audit_log DISABLE ROW LEVEL SECURITY;

-- Step 2: Drop ALL policies explicitly
DROP POLICY IF EXISTS "Users can view own profile" ON public.users;
DROP POLICY IF EXISTS "Users can update own profile" ON public.users;
DROP POLICY IF EXISTS "Faculty can view all users" ON public.users;
DROP POLICY IF EXISTS "Faculty can update users" ON public.users;
DROP POLICY IF EXISTS "Users can insert own record" ON public.users;

DROP POLICY IF EXISTS "Users can manage own profile" ON public.user_profiles;
DROP POLICY IF EXISTS "Faculty can view all profiles" ON public.user_profiles;

DROP POLICY IF EXISTS "Users can view own score" ON public.score_cache;
DROP POLICY IF EXISTS "Faculty can view all scores" ON public.score_cache;
DROP POLICY IF EXISTS "No direct score updates" ON public.score_cache;

DROP POLICY IF EXISTS "Users can view own activities" ON public.activities;
DROP POLICY IF EXISTS "Users can insert own activities" ON public.activities;
DROP POLICY IF EXISTS "Users can update own activities" ON public.activities;
DROP POLICY IF EXISTS "Faculty can view all activities" ON public.activities;
DROP POLICY IF EXISTS "Faculty can approve activities" ON public.activities;

DROP POLICY IF EXISTS "Users can view own coding activities" ON public.coding_activities;
DROP POLICY IF EXISTS "Users can insert own coding activities" ON public.coding_activities;
DROP POLICY IF EXISTS "Users can update own coding activities" ON public.coding_activities;
DROP POLICY IF EXISTS "Faculty can view all coding activities" ON public.coding_activities;
DROP POLICY IF EXISTS "Faculty can approve coding activities" ON public.coding_activities;

DROP POLICY IF EXISTS "Users can view own academics" ON public.semesters;
DROP POLICY IF EXISTS "Users can view own subjects" ON public.subjects;
DROP POLICY IF EXISTS "Users can view own attendance" ON public.attendance;
DROP POLICY IF EXISTS "Faculty can view all academics" ON public.semesters;
DROP POLICY IF EXISTS "Faculty can view all subjects" ON public.subjects;
DROP POLICY IF EXISTS "Faculty can view all attendance" ON public.attendance;
DROP POLICY IF EXISTS "Faculty can manage academics" ON public.semesters;
DROP POLICY IF EXISTS "Faculty can manage subjects" ON public.subjects;
DROP POLICY IF EXISTS "Faculty can manage attendance" ON public.attendance;

DROP POLICY IF EXISTS "Users can view own notifications" ON public.notifications;
DROP POLICY IF EXISTS "Users can update own notifications" ON public.notifications;
DROP POLICY IF EXISTS "Faculty can insert notifications" ON public.notifications;

DROP POLICY IF EXISTS "Faculty can view audit log" ON public.audit_log;
DROP POLICY IF EXISTS "System can insert audit log" ON public.audit_log;

-- Step 3: Drop storage policies
DROP POLICY IF EXISTS "Users can upload to activity-proofs" ON storage.objects;
DROP POLICY IF EXISTS "Users can view own activity-proofs" ON storage.objects;
DROP POLICY IF EXISTS "Faculty can view all activity-proofs" ON storage.objects;
DROP POLICY IF EXISTS "Users can upload own profile-photo" ON storage.objects;
DROP POLICY IF EXISTS "Users can view own profile-photo" ON storage.objects;
DROP POLICY IF EXISTS "Faculty can view all profile-photos" ON storage.objects;
DROP POLICY IF EXISTS "Users can upload to coding-proofs" ON storage.objects;
DROP POLICY IF EXISTS "Users can view own coding-proofs" ON storage.objects;
DROP POLICY IF EXISTS "Faculty can view all coding-proofs" ON storage.objects;

-- Step 4: Drop all triggers
DROP TRIGGER IF EXISTS trg_users_updated_at ON public.users;
DROP TRIGGER IF EXISTS trg_activities_updated_at ON public.activities;
DROP TRIGGER IF EXISTS trg_activity_score ON public.activities;
DROP TRIGGER IF EXISTS trg_coding_score ON public.coding_activities;
DROP TRIGGER IF EXISTS trg_semester_score ON public.semesters;
DROP TRIGGER IF EXISTS trg_create_profile ON public.users;
DROP TRIGGER IF EXISTS trg_notify_activity ON public.activities;
DROP TRIGGER IF EXISTS trg_notify_coding ON public.coding_activities;
DROP TRIGGER IF EXISTS trg_notify_account ON public.users;

-- Step 5: Drop all functions
DROP FUNCTION IF EXISTS public.update_updated_at() CASCADE;
DROP FUNCTION IF EXISTS public.calculate_score(UUID) CASCADE;
DROP FUNCTION IF EXISTS public.trigger_recalculate_score() CASCADE;
DROP FUNCTION IF EXISTS public.trigger_recalculate_score_on_cgpa() CASCADE;
DROP FUNCTION IF EXISTS public.create_user_profile() CASCADE;
DROP FUNCTION IF EXISTS public.notify_user(UUID, TEXT, TEXT) CASCADE;
DROP FUNCTION IF EXISTS public.trigger_notify_activity_status() CASCADE;
DROP FUNCTION IF EXISTS public.trigger_notify_account_status() CASCADE;

-- Step 6: Drop all tables
DROP TABLE IF EXISTS public.audit_log CASCADE;
DROP TABLE IF EXISTS public.notifications CASCADE;
DROP TABLE IF EXISTS public.attendance CASCADE;
DROP TABLE IF EXISTS public.subjects CASCADE;
DROP TABLE IF EXISTS public.semesters CASCADE;
DROP TABLE IF EXISTS public.coding_activities CASCADE;
DROP TABLE IF EXISTS public.activities CASCADE;
DROP TABLE IF EXISTS public.score_cache CASCADE;
DROP TABLE IF EXISTS public.user_profiles CASCADE;
DROP TABLE IF EXISTS public.users CASCADE;

-- Step 7: Drop storage buckets and objects
DELETE FROM storage.objects WHERE bucket_id IN ('activity-proofs', 'profile-photos', 'coding-proofs');
DELETE FROM storage.buckets WHERE id IN ('activity-proofs', 'profile-photos', 'coding-proofs');

-- Step 8: Drop types
DROP TYPE IF EXISTS public.difficulty CASCADE;
DROP TYPE IF EXISTS public.coding_type CASCADE;
DROP TYPE IF EXISTS public.coding_platform CASCADE;
DROP TYPE IF EXISTS public.entry_status CASCADE;
DROP TYPE IF EXISTS public.activity_type CASCADE;
DROP TYPE IF EXISTS public.user_role CASCADE;
DROP TYPE IF EXISTS public.user_status CASCADE;

SELECT 'Force cleanup complete. Database is now completely empty.' as status;
