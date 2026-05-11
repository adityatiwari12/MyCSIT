-- ============================================================
-- Fix Infinite Recursion in RLS Policies
-- ============================================================

-- Step 1: Disable RLS temporarily
ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.score_cache DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.activities DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.coding_activities DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.semesters DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.subjects DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.attendance DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications DISABLE ROW LEVEL SECURITY;

-- Step 2: Drop all existing policies
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

-- Step 3: Create simple, non-recursive RLS policies
-- Users table policies
CREATE POLICY "Users can view own profile" ON public.users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.users
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own record" ON public.users
  FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Faculty can view all users" ON public.users
  FOR SELECT USING (
    auth.uid() IN (
      SELECT id FROM auth.users 
      WHERE id = auth.uid() 
      AND email = 'faculty@mycsit.edu'
    )
  );

CREATE POLICY "Faculty can update users" ON public.users
  FOR UPDATE USING (
    auth.uid() IN (
      SELECT id FROM auth.users 
      WHERE id = auth.uid() 
      AND email = 'faculty@mycsit.edu'
    )
  );

-- User profiles policies
CREATE POLICY "Users can manage own profile" ON public.user_profiles
  FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Faculty can view all profiles" ON public.user_profiles
  FOR SELECT USING (
    auth.uid() IN (
      SELECT id FROM auth.users 
      WHERE id = auth.uid() 
      AND email = 'faculty@mycsit.edu'
    )
  );

-- Score cache policies
CREATE POLICY "Users can view own score" ON public.score_cache
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Faculty can view all scores" ON public.score_cache
  FOR SELECT USING (
    auth.uid() IN (
      SELECT id FROM auth.users 
      WHERE id = auth.uid() 
      AND email = 'faculty@mycsit.edu'
    )
  );

-- Activities policies
CREATE POLICY "Users can view own activities" ON public.activities
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own activities" ON public.activities
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own activities" ON public.activities
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Faculty can view all activities" ON public.activities
  FOR SELECT USING (
    auth.uid() IN (
      SELECT id FROM auth.users 
      WHERE id = auth.uid() 
      AND email = 'faculty@mycsit.edu'
    )
  );

CREATE POLICY "Faculty can approve activities" ON public.activities
  FOR UPDATE USING (
    auth.uid() IN (
      SELECT id FROM auth.users 
      WHERE id = auth.uid() 
      AND email = 'faculty@mycsit.edu'
    )
  );

-- Coding activities policies
CREATE POLICY "Users can view own coding activities" ON public.coding_activities
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own coding activities" ON public.coding_activities
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own coding activities" ON public.coding_activities
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Faculty can view all coding activities" ON public.coding_activities
  FOR SELECT USING (
    auth.uid() IN (
      SELECT id FROM auth.users 
      WHERE id = auth.uid() 
      AND email = 'faculty@mycsit.edu'
    )
  );

-- Academic policies
CREATE POLICY "Users can view own academics" ON public.semesters
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can view own subjects" ON public.subjects
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.semesters s
      JOIN public.subjects sub ON s.id = sub.semester_id
      WHERE s.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can view own attendance" ON public.attendance
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Faculty can view all academics" ON public.semesters
  FOR SELECT USING (
    auth.uid() IN (
      SELECT id FROM auth.users 
      WHERE id = auth.uid() 
      AND email = 'faculty@mycsit.edu'
    )
  );

CREATE POLICY "Faculty can view all subjects" ON public.subjects
  FOR SELECT USING (
    auth.uid() IN (
      SELECT id FROM auth.users 
      WHERE id = auth.uid() 
      AND email = 'faculty@mycsit.edu'
    )
  );

CREATE POLICY "Faculty can view all attendance" ON public.attendance
  FOR SELECT USING (
    auth.uid() IN (
      SELECT id FROM auth.users 
      WHERE id = auth.uid() 
      AND email = 'faculty@mycsit.edu'
    )
  );

CREATE POLICY "Faculty can manage academics" ON public.semesters
  FOR ALL USING (
    auth.uid() IN (
      SELECT id FROM auth.users 
      WHERE id = auth.uid() 
      AND email = 'faculty@mycsit.edu'
    )
  );

CREATE POLICY "Faculty can manage subjects" ON public.subjects
  FOR ALL USING (
    auth.uid() IN (
      SELECT id FROM auth.users 
      WHERE id = auth.uid() 
      AND email = 'faculty@mycsit.edu'
    )
  );

CREATE POLICY "Faculty can manage attendance" ON public.attendance
  FOR ALL USING (
    auth.uid() IN (
      SELECT id FROM auth.users 
      WHERE id = auth.uid() 
      AND email = 'faculty@mycsit.edu'
    )
  );

-- Notifications policies
CREATE POLICY "Users can view own notifications" ON public.notifications
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own notifications" ON public.notifications
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Faculty can insert notifications" ON public.notifications
  FOR INSERT WITH CHECK (
    auth.uid() IN (
      SELECT id FROM auth.users 
      WHERE id = auth.uid() 
      AND email = 'faculty@mycsit.edu'
    )
  );

-- Step 4: Re-enable RLS
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.score_cache ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.activities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.coding_activities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.semesters ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subjects ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attendance ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

SELECT 'RLS recursion fixed!' as status;
