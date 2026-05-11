-- Run this in Supabase SQL Editor (Dashboard > SQL Editor)
-- This creates the missing tables for the faculty dashboard

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enum types
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_status') THEN
        CREATE TYPE user_status AS ENUM ('pending', 'active', 'rejected');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role') THEN
        CREATE TYPE user_role AS ENUM ('student', 'faculty');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'entry_status') THEN
        CREATE TYPE entry_status AS ENUM ('pending', 'approved', 'rejected');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'activity_type') THEN
        CREATE TYPE activity_type AS ENUM ('hackathon', 'certification', 'research', 'project', 'internship', 'achievement');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'coding_platform') THEN
        CREATE TYPE coding_platform AS ENUM ('leetcode', 'codeforces', 'codechef', 'other');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'coding_type') THEN
        CREATE TYPE coding_type AS ENUM ('milestone', 'contest', 'highValueProblem');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'difficulty') THEN
        CREATE TYPE difficulty AS ENUM ('easy', 'medium', 'hard');
    END IF;
END
$$;

-- Users table
CREATE TABLE IF NOT EXISTS public.users (
  id            UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name          TEXT NOT NULL,
  roll_number   TEXT NOT NULL UNIQUE,
  year          INTEGER NOT NULL CHECK (year BETWEEN 1 AND 4),
  section       TEXT NOT NULL CHECK (section IN ('A', 'B', 'C')),
  role          user_role NOT NULL DEFAULT 'student',
  status        user_status NOT NULL DEFAULT 'pending',
  fcm_token     TEXT,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- User profiles
CREATE TABLE IF NOT EXISTS public.user_profiles (
  user_id               UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
  bio                   TEXT,
  profile_photo_url     TEXT,
  linkedin_url          TEXT,
  github_url            TEXT,
  portfolio_url         TEXT,
  leetcode_url          TEXT,
  codeforces_url        TEXT,
  codechef_url          TEXT,
  profile_completeness  INTEGER NOT NULL DEFAULT 0 CHECK (profile_completeness BETWEEN 0 AND 100),
  updated_at            TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Score cache
CREATE TABLE IF NOT EXISTS public.score_cache (
  user_id          UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
  total_score      NUMERIC(5,2) NOT NULL DEFAULT 0,
  hackathon_score  NUMERIC(5,2) NOT NULL DEFAULT 0,
  project_score    NUMERIC(5,2) NOT NULL DEFAULT 0,
  academic_score   NUMERIC(5,2) NOT NULL DEFAULT 0,
  coding_score     NUMERIC(5,2) NOT NULL DEFAULT 0,
  last_computed    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Activities
CREATE TABLE IF NOT EXISTS public.activities (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id           UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  type              activity_type NOT NULL,
  title             TEXT NOT NULL CHECK (char_length(title) BETWEEN 3 AND 100),
  description       TEXT NOT NULL DEFAULT '',
  date              DATE NOT NULL,
  proof_url         TEXT NOT NULL,
  status            entry_status NOT NULL DEFAULT 'pending',
  rejection_reason  TEXT,
  approved_by       UUID REFERENCES public.users(id),
  is_deleted        BOOLEAN NOT NULL DEFAULT FALSE,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Coding activities
CREATE TABLE IF NOT EXISTS public.coding_activities (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id           UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  platform          coding_platform NOT NULL,
  type              coding_type NOT NULL,
  title             TEXT NOT NULL,
  value             INTEGER,
  contest_name      TEXT,
  difficulty        difficulty,
  proof_url         TEXT NOT NULL,
  status            entry_status NOT NULL DEFAULT 'pending',
  rejection_reason  TEXT,
  approved_by       UUID REFERENCES public.users(id),
  is_deleted        BOOLEAN NOT NULL DEFAULT FALSE,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Semesters
CREATE TABLE IF NOT EXISTS public.semesters (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id     UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  sem_number  INTEGER NOT NULL CHECK (sem_number BETWEEN 1 AND 8),
  cgpa        NUMERIC(4,2) CHECK (cgpa BETWEEN 0 AND 10),
  updated_by  UUID REFERENCES public.users(id),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, sem_number)
);

-- Subjects
CREATE TABLE IF NOT EXISTS public.subjects (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  semester_id UUID NOT NULL REFERENCES public.semesters(id) ON DELETE CASCADE,
  name        TEXT NOT NULL,
  marks       NUMERIC(5,2) NOT NULL DEFAULT 0,
  max_marks   NUMERIC(5,2) NOT NULL DEFAULT 100
);

-- Attendance
CREATE TABLE IF NOT EXISTS public.attendance (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id         UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  semester_id     UUID REFERENCES public.semesters(id) ON DELETE CASCADE,
  total_classes   INTEGER NOT NULL DEFAULT 0,
  attended        INTEGER NOT NULL DEFAULT 0,
  updated_by      UUID REFERENCES public.users(id),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, semester_id)
);

-- Notifications
CREATE TABLE IF NOT EXISTS public.notifications (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id     UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  title       TEXT NOT NULL,
  message     TEXT NOT NULL,
  is_read     BOOLEAN NOT NULL DEFAULT FALSE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.activities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.coding_activities ENABLE ROW LEVEL SECURITY;

-- RLS Policies for users
CREATE POLICY "Allow public read users" ON public.users FOR SELECT USING (true);
CREATE POLICY "Allow insert own user" ON public.users FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "Allow update own user" ON public.users FOR UPDATE USING (auth.uid() = id);

-- RLS Policies for activities
CREATE POLICY "Allow read own activities" ON public.activities FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Allow faculty read all activities" ON public.activities FOR SELECT USING (EXISTS (
  SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'faculty'
));
CREATE POLICY "Allow insert own activities" ON public.activities FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Allow faculty update activities" ON public.activities FOR UPDATE USING (EXISTS (
  SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'faculty'
));

-- RLS Policies for coding activities
CREATE POLICY "Allow read own coding" ON public.coding_activities FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Allow faculty read all coding" ON public.coding_activities FOR SELECT USING (EXISTS (
  SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'faculty'
));
CREATE POLICY "Allow insert own coding" ON public.coding_activities FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Allow faculty update coding" ON public.coding_activities FOR UPDATE USING (EXISTS (
  SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'faculty'
));

-- Indexes
CREATE INDEX IF NOT EXISTS idx_activities_user_id ON public.activities(user_id);
CREATE INDEX IF NOT EXISTS idx_activities_status ON public.activities(status);
CREATE INDEX IF NOT EXISTS idx_coding_user_id ON public.coding_activities(user_id);
CREATE INDEX IF NOT EXISTS idx_coding_status ON public.coding_activities(status);
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON public.notifications(user_id);

-- Updated at function
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Score calculation
CREATE OR REPLACE FUNCTION calculate_score(p_user_id UUID)
RETURNS VOID AS $$
DECLARE
  v_hackathon_score  NUMERIC := 0;
  v_project_score    NUMERIC := 0;
  v_academic_score   NUMERIC := 0;
  v_coding_score     NUMERIC := 0;
  v_total_score      NUMERIC := 0;
  v_cgpa             NUMERIC := 0;
  v_milestone_score  NUMERIC := 0;
  v_contest_score    NUMERIC := 0;
  v_raw_hackathon    NUMERIC := 0;
  v_raw_project      NUMERIC := 0;
BEGIN
  SELECT COALESCE(SUM(weight), 0) INTO v_raw_hackathon
  FROM (
    SELECT CASE type WHEN 'hackathon' THEN 1.0 WHEN 'achievement' THEN 0.7 WHEN 'certification' THEN 0.5 END AS weight,
      ROW_NUMBER() OVER (PARTITION BY type ORDER BY created_at DESC) AS rn
    FROM public.activities WHERE user_id = p_user_id AND status = 'approved' AND is_deleted = FALSE
      AND type IN ('hackathon', 'achievement', 'certification')
  ) sub WHERE rn <= 3;

  v_hackathon_score := LEAST((v_raw_hackathon / 9.0) * 100, 100);

  SELECT COALESCE(SUM(weight), 0) INTO v_raw_project
  FROM (
    SELECT CASE type WHEN 'internship' THEN 1.0 WHEN 'research' THEN 0.9 WHEN 'project' THEN 0.8 END AS weight,
      ROW_NUMBER() OVER (PARTITION BY type ORDER BY created_at DESC) AS rn
    FROM public.activities WHERE user_id = p_user_id AND status = 'approved' AND is_deleted = FALSE
      AND type IN ('internship', 'research', 'project')
  ) sub WHERE rn <= 3;

  v_project_score := LEAST((v_raw_project / 9.0) * 100, 100);

  SELECT COALESCE(cgpa, 0) INTO v_cgpa FROM public.semesters
  WHERE user_id = p_user_id AND cgpa IS NOT NULL ORDER BY updated_at DESC LIMIT 1;

  v_academic_score := (v_cgpa / 10.0) * 100;

  SELECT COALESCE(AVG(platform_max), 0) INTO v_milestone_score
  FROM (
    SELECT platform, LEAST(MAX(value)::NUMERIC / 500.0, 1.0) AS platform_max
    FROM public.coding_activities WHERE user_id = p_user_id AND status = 'approved' AND is_deleted = FALSE
      AND type = 'milestone' AND value IS NOT NULL GROUP BY platform
  ) milestones;

  SELECT LEAST(COUNT(*)::NUMERIC / 10.0, 1.0) INTO v_contest_score
  FROM public.coding_activities WHERE user_id = p_user_id AND status = 'approved' AND is_deleted = FALSE AND type = 'contest';

  v_coding_score := (v_milestone_score * 0.5 + v_contest_score * 0.5) * 100;

  v_total_score := (v_hackathon_score * 0.35) + (v_project_score * 0.25) + (v_academic_score * 0.25) + (v_coding_score * 0.15);

  INSERT INTO public.score_cache (user_id, total_score, hackathon_score, project_score, academic_score, coding_score, last_computed)
  VALUES (p_user_id, v_total_score, v_hackathon_score, v_project_score, v_academic_score, v_coding_score, NOW())
  ON CONFLICT (user_id) DO UPDATE SET
    total_score = EXCLUDED.total_score, hackathon_score = EXCLUDED.hackathon_score,
    project_score = EXCLUDED.project_score, academic_score = EXCLUDED.academic_score,
    coding_score = EXCLUDED.coding_score, last_computed = EXCLUDED.last_computed;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Auto-create profile and score cache on user insert
CREATE OR REPLACE FUNCTION create_user_profile()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.user_profiles (user_id) VALUES (NEW.id) ON CONFLICT DO NOTHING;
  INSERT INTO public.score_cache (user_id) VALUES (NEW.id) ON CONFLICT DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_create_profile ON public.users;
CREATE TRIGGER trg_create_profile AFTER INSERT ON public.users FOR EACH ROW EXECUTE FUNCTION create_user_profile();
