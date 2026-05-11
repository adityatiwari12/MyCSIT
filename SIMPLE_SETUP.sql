-- ============================================================
-- MyCSIT — Simple Working Setup (Under 100 lines)
-- ============================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create basic enum types
CREATE TYPE user_status AS ENUM ('pending', 'active', 'rejected');
CREATE TYPE user_role AS ENUM ('student', 'faculty');

-- Create users table
CREATE TABLE public.users (
  id            UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name          TEXT NOT NULL,
  roll_number   TEXT NOT NULL UNIQUE,
  year          INTEGER NOT NULL CHECK (year BETWEEN 1 AND 4),
  section       TEXT NOT NULL CHECK (section IN ('A', 'B', 'C')),
  role          user_role NOT NULL DEFAULT 'student',
  status        user_status NOT NULL DEFAULT 'pending',
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create user profiles table
CREATE TABLE public.user_profiles (
  user_id               UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
  bio                   TEXT,
  profile_photo_url     TEXT,
  linkedin_url          TEXT,
  github_url            TEXT,
  profile_completeness  INTEGER NOT NULL DEFAULT 0 CHECK (profile_completeness BETWEEN 0 AND 100),
  updated_at            TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create activities table
CREATE TABLE public.activities (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id           UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  type              TEXT NOT NULL,
  title             TEXT NOT NULL,
  description       TEXT NOT NULL DEFAULT '',
  date              DATE NOT NULL,
  proof_url         TEXT NOT NULL,
  status            user_status NOT NULL DEFAULT 'pending',
  rejection_reason  TEXT,
  approved_by       UUID REFERENCES public.users(id),
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create notifications table
CREATE TABLE public.notifications (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id     UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  title       TEXT NOT NULL,
  message     TEXT NOT NULL,
  is_read     BOOLEAN NOT NULL DEFAULT FALSE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Enable RLS on tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.activities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Simple RLS policies
CREATE POLICY "Users can view own profile" ON public.users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.users
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own record" ON public.users
  FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can manage own profile" ON public.user_profiles
  FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can view own activities" ON public.activities
  FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can view own notifications" ON public.notifications
  FOR ALL USING (auth.uid() = user_id);

-- Faculty policies
CREATE POLICY "Faculty can view all users" ON public.users
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.users 
      WHERE id = auth.uid() AND role = 'faculty' AND status = 'active'
    )
  );

CREATE POLICY "Faculty can update users" ON public.users
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.users 
      WHERE id = auth.uid() AND role = 'faculty' AND status = 'active'
    )
  );

CREATE POLICY "Faculty can view all profiles" ON public.user_profiles
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.users 
      WHERE id = auth.uid() AND role = 'faculty' AND status = 'active'
    )
  );

CREATE POLICY "Faculty can view all activities" ON public.activities
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.users 
      WHERE id = auth.uid() AND role = 'faculty' AND status = 'active'
    )
  );

CREATE POLICY "Faculty can update activities" ON public.activities
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.users 
      WHERE id = auth.uid() AND role = 'faculty' AND status = 'active'
    )
  );

-- Create basic storage bucket
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES 
  ('activity-proofs', 'activity-proofs', false, 5242880, ARRAY['image/jpeg', 'image/png', 'application/pdf'])
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

-- Verification
SELECT 'Simple MyCSIT Setup Complete!' as status;
SELECT COUNT(*) as tables_created FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE';
