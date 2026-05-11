-- ============================================================
-- Minimal RLS Fix - Only Use Existing Tables
-- ============================================================

-- Step 1: Check what tables exist first
SELECT 'Checking existing tables...' as status;

-- Step 2: Only create policies for tables that exist
-- Users table policies (this should exist)
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Drop any existing policies first
DROP POLICY IF EXISTS "Users can view own profile" ON public.users;
DROP POLICY IF EXISTS "Users can update own profile" ON public.users;
DROP POLICY IF EXISTS "Users can insert own record" ON public.users;
DROP POLICY IF EXISTS "Faculty can view all users" ON public.users;
DROP POLICY IF EXISTS "Faculty can update users" ON public.users;

-- Create simple user policies
CREATE POLICY "Users can view own profile" ON public.users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.users
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own record" ON public.users
  FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Faculty can view all users" ON public.users
  FOR SELECT USING (auth.jwt() ->> 'email' = 'faculty@mycsit.edu');

CREATE POLICY "Faculty can update users" ON public.users
  FOR UPDATE USING (auth.jwt() ->> 'email' = 'faculty@mycsit.edu');

-- Activities table policies (if it exists)
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'activities' AND table_schema = 'public') THEN
    ALTER TABLE public.activities ENABLE ROW LEVEL SECURITY;
    
    DROP POLICY IF EXISTS "Users can view own activities" ON public.activities;
    DROP POLICY IF EXISTS "Users can insert own activities" ON public.activities;
    DROP POLICY IF EXISTS "Users can update own activities" ON public.activities;
    DROP POLICY IF EXISTS "Faculty can view all activities" ON public.activities;
    DROP POLICY IF EXISTS "Faculty can approve activities" ON public.activities;
    
    CREATE POLICY "Users can view own activities" ON public.activities
      FOR SELECT USING (auth.uid() = user_id);
    
    CREATE POLICY "Users can insert own activities" ON public.activities
      FOR INSERT WITH CHECK (auth.uid() = user_id);
    
    CREATE POLICY "Users can update own activities" ON public.activities
      FOR UPDATE USING (auth.uid() = user_id);
    
    CREATE POLICY "Faculty can view all activities" ON public.activities
      FOR SELECT USING (auth.jwt() ->> 'email' = 'faculty@mycsit.edu');
    
    CREATE POLICY "Faculty can approve activities" ON public.activities
      FOR UPDATE USING (auth.jwt() ->> 'email' = 'faculty@mycsit.edu');
  END IF;
END $$;

-- User profiles table policies (if it exists)
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'user_profiles' AND table_schema = 'public') THEN
    ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
    
    DROP POLICY IF EXISTS "Users can manage own profile" ON public.user_profiles;
    DROP POLICY IF EXISTS "Faculty can view all profiles" ON public.user_profiles;
    
    CREATE POLICY "Users can manage own profile" ON public.user_profiles
      FOR ALL USING (auth.uid() = user_id);
    
    CREATE POLICY "Faculty can view all profiles" ON public.user_profiles
      FOR SELECT USING (auth.jwt() ->> 'email' = 'faculty@mycsit.edu');
  END IF;
END $$;

-- Notifications table policies (if it exists)
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'notifications' AND table_schema = 'public') THEN
    ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
    
    DROP POLICY IF EXISTS "Users can view own notifications" ON public.notifications;
    DROP POLICY IF EXISTS "Users can update own notifications" ON public.notifications;
    DROP POLICY IF EXISTS "Faculty can insert notifications" ON public.notifications;
    
    CREATE POLICY "Users can view own notifications" ON public.notifications
      FOR SELECT USING (auth.uid() = user_id);
    
    CREATE POLICY "Users can update own notifications" ON public.notifications
      FOR UPDATE USING (auth.uid() = user_id);
    
    CREATE POLICY "Faculty can insert notifications" ON public.notifications
      FOR INSERT WITH CHECK (auth.jwt() ->> 'email' = 'faculty@mycsit.edu');
  END IF;
END $$;

SELECT 'Minimal RLS policies created!' as status;
SELECT 'Tables with RLS enabled:' as info, COUNT(*) as count 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND EXISTS (
  SELECT 1 FROM information_schema.table_constraints 
  WHERE table_name = information_schema.tables.table_name 
  AND constraint_name = 'enable_row_security'
);
