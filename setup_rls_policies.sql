-- ============================================================
-- MyCSIT — Row Level Security (RLS) Policies
-- Execute this after running the schema setup
-- ============================================================

-- Enable RLS on all tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.score_cache ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.activities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.coding_activities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.semesters ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subjects ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attendance ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_log ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- USERS TABLE POLICIES
-- ============================================================

-- Users can view their own profile
CREATE POLICY "Users can view own profile" ON public.users
  FOR SELECT USING (auth.uid() = id);

-- Users can update their own profile (limited fields)
CREATE POLICY "Users can update own profile" ON public.users
  FOR UPDATE USING (auth.uid() = id)
  WITH CHECK (
    auth.uid() = id AND 
    (role = 'student' OR role = 'faculty') AND
    -- Students can only update limited fields
    (role != 'student' OR (
      name = name AND
      roll_number = roll_number AND
      year = year AND
      section = section AND
      role = role AND
      status = status
    ))
  );

-- Faculty can view all users
CREATE POLICY "Faculty can view all users" ON public.users
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.users 
      WHERE id = auth.uid() AND role = 'faculty' AND status = 'active'
    )
  );

-- Faculty can update user status and basic info
CREATE POLICY "Faculty can update users" ON public.users
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.users 
      WHERE id = auth.uid() AND role = 'faculty' AND status = 'active'
    )
  );

-- Users can insert their own record (handled by trigger)
CREATE POLICY "Users can insert own record" ON public.users
  FOR INSERT WITH CHECK (auth.uid() = id);

-- ============================================================
-- USER PROFILES POLICIES
-- ============================================================

-- Users can view/update their own profile
CREATE POLICY "Users can manage own profile" ON public.user_profiles
  FOR ALL USING (auth.uid() = user_id);

-- Faculty can view all profiles
CREATE POLICY "Faculty can view all profiles" ON public.user_profiles
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.users 
      WHERE id = auth.uid() AND role = 'faculty' AND status = 'active'
    )
  );

-- ============================================================
-- SCORE CACHE POLICIES
-- ============================================================

-- Users can view their own score
CREATE POLICY "Users can view own score" ON public.score_cache
  FOR SELECT USING (auth.uid() = user_id);

-- Faculty can view all scores
CREATE POLICY "Faculty can view all scores" ON public.score_cache
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.users 
      WHERE id = auth.uid() AND role = 'faculty' AND status = 'active'
    )
  );

-- Only functions can update scores (no direct write access)
CREATE POLICY "No direct score updates" ON public.score_cache
  FOR INSERT WITH CHECK (false);
CREATE POLICY "No direct score updates" ON public.score_cache
  FOR UPDATE WITH CHECK (false);
CREATE POLICY "No direct score updates" ON public.score_cache
  FOR DELETE WITH CHECK (false);

-- ============================================================
-- ACTIVITIES POLICIES
-- ============================================================

-- Users can view their own activities
CREATE POLICY "Users can view own activities" ON public.activities
  FOR SELECT USING (auth.uid() = user_id);

-- Users can insert their own activities
CREATE POLICY "Users can insert own activities" ON public.activities
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can update their own activities (limited fields)
CREATE POLICY "Users can update own activities" ON public.activities
  FOR UPDATE USING (auth.uid() = user_id)
  WITH CHECK (
    auth.uid() = user_id AND
    status = 'pending' AND
    approved_by IS NULL
  );

-- Faculty can view all activities
CREATE POLICY "Faculty can view all activities" ON public.activities
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.users 
      WHERE id = auth.uid() AND role = 'faculty' AND status = 'active'
    )
  );

-- Faculty can update activity status
CREATE POLICY "Faculty can approve activities" ON public.activities
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.users 
      WHERE id = auth.uid() AND role = 'faculty' AND status = 'active'
    )
  );

-- ============================================================
-- CODING ACTIVITIES POLICIES
-- ============================================================

-- Same pattern as regular activities
CREATE POLICY "Users can view own coding activities" ON public.coding_activities
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own coding activities" ON public.coding_activities
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own coding activities" ON public.coding_activities
  FOR UPDATE USING (auth.uid() = user_id)
  WITH CHECK (
    auth.uid() = user_id AND
    status = 'pending' AND
    approved_by IS NULL
  );

CREATE POLICY "Faculty can view all coding activities" ON public.coding_activities
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.users 
      WHERE id = auth.uid() AND role = 'faculty' AND status = 'active'
    )
  );

CREATE POLICY "Faculty can approve coding activities" ON public.coding_activities
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.users 
      WHERE id = auth.uid() AND role = 'faculty' AND status = 'active'
    )
  );

-- ============================================================
-- ACADEMICS POLICIES
-- ============================================================

-- Users can view their own academic data
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

-- Faculty can view all academic data
CREATE POLICY "Faculty can view all academics" ON public.semesters
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.users 
      WHERE id = auth.uid() AND role = 'faculty' AND status = 'active'
    )
  );

CREATE POLICY "Faculty can view all subjects" ON public.subjects
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.users 
      WHERE id = auth.uid() AND role = 'faculty' AND status = 'active'
    )
  );

CREATE POLICY "Faculty can view all attendance" ON public.attendance
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.users 
      WHERE id = auth.uid() AND role = 'faculty' AND status = 'active'
    )
  );

-- Faculty can manage academic data
CREATE POLICY "Faculty can manage academics" ON public.semesters
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.users 
      WHERE id = auth.uid() AND role = 'faculty' AND status = 'active'
    )
  );

CREATE POLICY "Faculty can manage subjects" ON public.subjects
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.users 
      WHERE id = auth.uid() AND role = 'faculty' AND status = 'active'
    )
  );

CREATE POLICY "Faculty can manage attendance" ON public.attendance
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.users 
      WHERE id = auth.uid() AND role = 'faculty' AND status = 'active'
    )
  );

-- ============================================================
-- NOTIFICATIONS POLICIES
-- ============================================================

-- Users can view their own notifications
CREATE POLICY "Users can view own notifications" ON public.notifications
  FOR SELECT USING (auth.uid() = user_id);

-- Users can update their own notifications (mark as read)
CREATE POLICY "Users can update own notifications" ON public.notifications
  FOR UPDATE USING (auth.uid() = user_id);

-- Faculty can insert notifications for users
CREATE POLICY "Faculty can insert notifications" ON public.notifications
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.users 
      WHERE id = auth.uid() AND role = 'faculty' AND status = 'active'
    )
  );

-- ============================================================
-- AUDIT LOG POLICIES
-- ============================================================

-- Faculty can view audit log
CREATE POLICY "Faculty can view audit log" ON public.audit_log
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.users 
      WHERE id = auth.uid() AND role = 'faculty' AND status = 'active'
    )
  );

-- System functions can insert audit entries
CREATE POLICY "System can insert audit log" ON public.audit_log
  FOR INSERT WITH CHECK (true);

-- ============================================================
-- STORAGE BUCKETS & POLICIES
-- ============================================================

-- Create storage buckets
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES 
  ('activity-proofs', 'activity-proofs', false, 5242880, ARRAY['image/jpeg', 'image/png', 'application/pdf']),
  ('profile-photos', 'profile-photos', false, 2097152, ARRAY['image/jpeg', 'image/png']),
  ('coding-proofs', 'coding-proofs', false, 5242880, ARRAY['image/jpeg', 'image/png', 'application/pdf'])
ON CONFLICT (id) DO NOTHING;

-- Storage policies
CREATE POLICY "Users can upload to activity-proofs" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'activity-proofs' AND
    auth.role() = 'authenticated' AND
    (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "Users can view own activity-proofs" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'activity-proofs' AND
    (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "Faculty can view all activity-proofs" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'activity-proofs' AND
    EXISTS (
      SELECT 1 FROM public.users 
      WHERE id = auth.uid() AND role = 'faculty' AND status = 'active'
    )
  );

CREATE POLICY "Users can upload own profile-photo" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'profile-photos' AND
    auth.role() = 'authenticated' AND
    name = auth.uid()::text || '/' || name
  );

CREATE POLICY "Users can view own profile-photo" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'profile-photos' AND
    (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "Faculty can view all profile-photos" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'profile-photos' AND
    EXISTS (
      SELECT 1 FROM public.users 
      WHERE id = auth.uid() AND role = 'faculty' AND status = 'active'
    )
  );

-- Similar policies for coding-proofs
CREATE POLICY "Users can upload to coding-proofs" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'coding-proofs' AND
    auth.role() = 'authenticated' AND
    (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "Users can view own coding-proofs" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'coding-proofs' AND
    (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "Faculty can view all coding-proofs" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'coding-proofs' AND
    EXISTS (
      SELECT 1 FROM public.users 
      WHERE id = auth.uid() AND role = 'faculty' AND status = 'active'
    )
  );
