-- ============================================================
-- MyCSIT — Row Level Security Policies
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
ALTER TABLE public.audit_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- ── Helper functions ──────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION is_faculty()
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.users
    WHERE id = auth.uid() AND role = 'faculty'
  );
$$ LANGUAGE sql SECURITY DEFINER STABLE;

CREATE OR REPLACE FUNCTION is_active_student()
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.users
    WHERE id = auth.uid() AND role = 'student' AND status = 'active'
  );
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- ── USERS ─────────────────────────────────────────────────────────────────────

-- Students can read their own record
CREATE POLICY "users_select_own" ON public.users
  FOR SELECT USING (auth.uid() = id);

-- Faculty can read all users
CREATE POLICY "users_select_faculty" ON public.users
  FOR SELECT USING (is_faculty());

-- Students can update their own non-protected fields
CREATE POLICY "users_update_own" ON public.users
  FOR UPDATE USING (auth.uid() = id)
  WITH CHECK (
    auth.uid() = id
    -- Students cannot change role or status
    AND role = (SELECT role FROM public.users WHERE id = auth.uid())
    AND status = (SELECT status FROM public.users WHERE id = auth.uid())
  );

-- Faculty can update status field
CREATE POLICY "users_update_faculty" ON public.users
  FOR UPDATE USING (is_faculty());

-- Allow insert during registration (handled by trigger from auth)
CREATE POLICY "users_insert_self" ON public.users
  FOR INSERT WITH CHECK (auth.uid() = id);

-- ── USER PROFILES ─────────────────────────────────────────────────────────────

CREATE POLICY "profiles_select_own" ON public.user_profiles
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "profiles_select_faculty" ON public.user_profiles
  FOR SELECT USING (is_faculty());

CREATE POLICY "profiles_upsert_own" ON public.user_profiles
  FOR ALL USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ── SCORE CACHE ───────────────────────────────────────────────────────────────

-- Students can read their own score
CREATE POLICY "score_select_own" ON public.score_cache
  FOR SELECT USING (auth.uid() = user_id);

-- Faculty can read all scores
CREATE POLICY "score_select_faculty" ON public.score_cache
  FOR SELECT USING (is_faculty());

-- Only DB functions (SECURITY DEFINER) can write scores — no direct client writes

-- ── ACTIVITIES ────────────────────────────────────────────────────────────────

-- Students can read their own activities
CREATE POLICY "activities_select_own" ON public.activities
  FOR SELECT USING (auth.uid() = user_id AND is_deleted = FALSE);

-- Faculty can read all activities
CREATE POLICY "activities_select_faculty" ON public.activities
  FOR SELECT USING (is_faculty());

-- Students can insert their own activities
CREATE POLICY "activities_insert_own" ON public.activities
  FOR INSERT WITH CHECK (
    auth.uid() = user_id
    AND is_active_student()
    AND status = 'pending'
    AND is_deleted = FALSE
  );

-- Students can update only rejected activities (resubmit)
CREATE POLICY "activities_update_resubmit" ON public.activities
  FOR UPDATE USING (
    auth.uid() = user_id
    AND status = 'rejected'
  )
  WITH CHECK (
    auth.uid() = user_id
    AND status = 'pending'  -- can only set back to pending
  );

-- Faculty can update status fields
CREATE POLICY "activities_update_faculty" ON public.activities
  FOR UPDATE USING (is_faculty());

-- ── CODING ACTIVITIES ─────────────────────────────────────────────────────────

CREATE POLICY "coding_select_own" ON public.coding_activities
  FOR SELECT USING (auth.uid() = user_id AND is_deleted = FALSE);

CREATE POLICY "coding_select_faculty" ON public.coding_activities
  FOR SELECT USING (is_faculty());

CREATE POLICY "coding_insert_own" ON public.coding_activities
  FOR INSERT WITH CHECK (
    auth.uid() = user_id
    AND is_active_student()
    AND status = 'pending'
  );

CREATE POLICY "coding_update_faculty" ON public.coding_activities
  FOR UPDATE USING (is_faculty());

-- ── SEMESTERS ─────────────────────────────────────────────────────────────────

-- Students can read their own semesters
CREATE POLICY "semesters_select_own" ON public.semesters
  FOR SELECT USING (auth.uid() = user_id);

-- Faculty can read/write all semesters
CREATE POLICY "semesters_all_faculty" ON public.semesters
  FOR ALL USING (is_faculty());

-- ── SUBJECTS ─────────────────────────────────────────────────────────────────

CREATE POLICY "subjects_select_own" ON public.subjects
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.semesters s
      WHERE s.id = semester_id AND s.user_id = auth.uid()
    )
  );

CREATE POLICY "subjects_all_faculty" ON public.subjects
  FOR ALL USING (is_faculty());

-- ── ATTENDANCE ────────────────────────────────────────────────────────────────

CREATE POLICY "attendance_select_own" ON public.attendance
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "attendance_all_faculty" ON public.attendance
  FOR ALL USING (is_faculty());

-- ── AUDIT LOG ─────────────────────────────────────────────────────────────────

CREATE POLICY "audit_insert_faculty" ON public.audit_log
  FOR INSERT WITH CHECK (is_faculty());

CREATE POLICY "audit_select_faculty" ON public.audit_log
  FOR SELECT USING (is_faculty());

-- ── NOTIFICATIONS ─────────────────────────────────────────────────────────────

CREATE POLICY "notifications_select_own" ON public.notifications
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "notifications_update_own" ON public.notifications
  FOR UPDATE USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ============================================================
-- STORAGE BUCKETS (run after creating buckets in dashboard)
-- ============================================================

-- Create storage policies via SQL after creating buckets:
-- Bucket: "proofs" (private)
-- Bucket: "avatars" (private)

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES
  ('proofs', 'proofs', FALSE, 5242880, ARRAY['image/jpeg','image/png','image/jpg','application/pdf']),
  ('avatars', 'avatars', FALSE, 2097152, ARRAY['image/jpeg','image/png','image/jpg'])
ON CONFLICT (id) DO NOTHING;

-- Proof storage policies
CREATE POLICY "proofs_upload_own" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'proofs'
    AND auth.uid()::TEXT = (storage.foldername(name))[1]
  );

CREATE POLICY "proofs_read_own" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'proofs'
    AND (
      auth.uid()::TEXT = (storage.foldername(name))[1]
      OR is_faculty()
    )
  );

-- Avatar storage policies
CREATE POLICY "avatars_upload_own" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'avatars'
    AND auth.uid()::TEXT = (storage.foldername(name))[1]
  );

CREATE POLICY "avatars_read_own" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'avatars'
    AND (
      auth.uid()::TEXT = (storage.foldername(name))[1]
      OR is_faculty()
    )
  );

CREATE POLICY "avatars_update_own" ON storage.objects
  FOR UPDATE USING (
    bucket_id = 'avatars'
    AND auth.uid()::TEXT = (storage.foldername(name))[1]
  );
