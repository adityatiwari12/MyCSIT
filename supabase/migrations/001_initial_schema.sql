-- ============================================================
-- MyCSIT — Supabase Schema
-- Run this in Supabase SQL Editor (Dashboard > SQL Editor)
-- ============================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- ENUMS
-- ============================================================
CREATE TYPE user_status AS ENUM ('pending', 'active', 'rejected');
CREATE TYPE user_role AS ENUM ('student', 'faculty');
CREATE TYPE entry_status AS ENUM ('pending', 'approved', 'rejected');
CREATE TYPE activity_type AS ENUM (
  'hackathon', 'certification', 'research',
  'project', 'internship', 'achievement'
);
CREATE TYPE coding_platform AS ENUM ('leetcode', 'codeforces', 'codechef', 'other');
CREATE TYPE coding_type AS ENUM ('milestone', 'contest', 'highValueProblem');
CREATE TYPE difficulty AS ENUM ('easy', 'medium', 'hard');

-- ============================================================
-- USERS (extends auth.users)
-- ============================================================
CREATE TABLE public.users (
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

-- ============================================================
-- USER PROFILES
-- ============================================================
CREATE TABLE public.user_profiles (
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

-- ============================================================
-- SCORE CACHE
-- ============================================================
CREATE TABLE public.score_cache (
  user_id          UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
  total_score      NUMERIC(5,2) NOT NULL DEFAULT 0,
  hackathon_score  NUMERIC(5,2) NOT NULL DEFAULT 0,
  project_score    NUMERIC(5,2) NOT NULL DEFAULT 0,
  academic_score   NUMERIC(5,2) NOT NULL DEFAULT 0,
  coding_score     NUMERIC(5,2) NOT NULL DEFAULT 0,
  last_computed    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- ACTIVITIES
-- ============================================================
CREATE TABLE public.activities (
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

CREATE INDEX idx_activities_user_id ON public.activities(user_id);
CREATE INDEX idx_activities_status ON public.activities(status);
CREATE INDEX idx_activities_created_at ON public.activities(created_at DESC);

-- ============================================================
-- CODING ACTIVITIES
-- ============================================================
CREATE TABLE public.coding_activities (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id           UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  platform          coding_platform NOT NULL,
  type              coding_type NOT NULL,
  title             TEXT NOT NULL,
  value             INTEGER,  -- problem count for milestone, rank for contest
  contest_name      TEXT,
  difficulty        difficulty,
  proof_url         TEXT NOT NULL,
  status            entry_status NOT NULL DEFAULT 'pending',
  rejection_reason  TEXT,
  approved_by       UUID REFERENCES public.users(id),
  is_deleted        BOOLEAN NOT NULL DEFAULT FALSE,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_coding_user_id ON public.coding_activities(user_id);
CREATE INDEX idx_coding_status ON public.coding_activities(status);

-- ============================================================
-- ACADEMICS
-- ============================================================
CREATE TABLE public.semesters (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id     UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  sem_number  INTEGER NOT NULL CHECK (sem_number BETWEEN 1 AND 8),
  cgpa        NUMERIC(4,2) CHECK (cgpa BETWEEN 0 AND 10),
  updated_by  UUID REFERENCES public.users(id),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, sem_number)
);

CREATE TABLE public.subjects (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  semester_id UUID NOT NULL REFERENCES public.semesters(id) ON DELETE CASCADE,
  name        TEXT NOT NULL,
  marks       NUMERIC(5,2) NOT NULL DEFAULT 0,
  max_marks   NUMERIC(5,2) NOT NULL DEFAULT 100
);

CREATE TABLE public.attendance (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id         UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  semester_id     UUID REFERENCES public.semesters(id) ON DELETE CASCADE,
  total_classes   INTEGER NOT NULL DEFAULT 0,
  attended        INTEGER NOT NULL DEFAULT 0,
  updated_by      UUID REFERENCES public.users(id),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, semester_id)
);

-- ============================================================
-- AUDIT LOG
-- ============================================================
CREATE TABLE public.audit_log (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  action        TEXT NOT NULL,
  target_id     UUID NOT NULL,
  target_type   TEXT NOT NULL,
  performed_by  UUID NOT NULL REFERENCES public.users(id),
  reason        TEXT,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- NOTIFICATIONS
-- ============================================================
CREATE TABLE public.notifications (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id     UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  title       TEXT NOT NULL,
  message     TEXT NOT NULL,
  is_read     BOOLEAN NOT NULL DEFAULT FALSE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_notifications_user_id ON public.notifications(user_id);

-- ============================================================
-- UPDATED_AT TRIGGER
-- ============================================================
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_updated_at
  BEFORE UPDATE ON public.users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_activities_updated_at
  BEFORE UPDATE ON public.activities
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ============================================================
-- SCORE CALCULATION FUNCTION (runs in DB)
-- ============================================================
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
  -- ── Hackathon/Events Score (35%) ──────────────────────────
  SELECT COALESCE(SUM(weight), 0) INTO v_raw_hackathon
  FROM (
    SELECT
      CASE type
        WHEN 'hackathon'    THEN 1.0
        WHEN 'achievement'  THEN 0.7
        WHEN 'certification' THEN 0.5
      END AS weight,
      ROW_NUMBER() OVER (PARTITION BY type ORDER BY created_at DESC) AS rn
    FROM public.activities
    WHERE user_id = p_user_id
      AND status = 'approved'
      AND is_deleted = FALSE
      AND type IN ('hackathon', 'achievement', 'certification')
  ) sub
  WHERE rn <= 3;

  v_hackathon_score := LEAST((v_raw_hackathon / 9.0) * 100, 100);

  -- ── Projects/Internships Score (25%) ──────────────────────
  SELECT COALESCE(SUM(weight), 0) INTO v_raw_project
  FROM (
    SELECT
      CASE type
        WHEN 'internship' THEN 1.0
        WHEN 'research'   THEN 0.9
        WHEN 'project'    THEN 0.8
      END AS weight,
      ROW_NUMBER() OVER (PARTITION BY type ORDER BY created_at DESC) AS rn
    FROM public.activities
    WHERE user_id = p_user_id
      AND status = 'approved'
      AND is_deleted = FALSE
      AND type IN ('internship', 'research', 'project')
  ) sub
  WHERE rn <= 3;

  v_project_score := LEAST((v_raw_project / 9.0) * 100, 100);

  -- ── Academic Score (25%) ──────────────────────────────────
  SELECT COALESCE(cgpa, 0) INTO v_cgpa
  FROM public.semesters
  WHERE user_id = p_user_id AND cgpa IS NOT NULL
  ORDER BY updated_at DESC
  LIMIT 1;

  v_academic_score := (v_cgpa / 10.0) * 100;

  -- ── Coding Score (15%) ────────────────────────────────────
  -- Milestone: highest per platform, normalized to 500
  SELECT COALESCE(AVG(platform_max), 0) INTO v_milestone_score
  FROM (
    SELECT platform, LEAST(MAX(value)::NUMERIC / 500.0, 1.0) AS platform_max
    FROM public.coding_activities
    WHERE user_id = p_user_id
      AND status = 'approved'
      AND is_deleted = FALSE
      AND type = 'milestone'
      AND value IS NOT NULL
    GROUP BY platform
  ) milestones;

  -- Contest: count capped at 10
  SELECT LEAST(COUNT(*)::NUMERIC / 10.0, 1.0) INTO v_contest_score
  FROM public.coding_activities
  WHERE user_id = p_user_id
    AND status = 'approved'
    AND is_deleted = FALSE
    AND type = 'contest';

  v_coding_score := (v_milestone_score * 0.5 + v_contest_score * 0.5) * 100;

  -- ── Total ─────────────────────────────────────────────────
  v_total_score := (v_hackathon_score * 0.35)
                 + (v_project_score   * 0.25)
                 + (v_academic_score  * 0.25)
                 + (v_coding_score    * 0.15);

  -- ── Upsert score cache ────────────────────────────────────
  INSERT INTO public.score_cache
    (user_id, total_score, hackathon_score, project_score, academic_score, coding_score, last_computed)
  VALUES
    (p_user_id, v_total_score, v_hackathon_score, v_project_score, v_academic_score, v_coding_score, NOW())
  ON CONFLICT (user_id) DO UPDATE SET
    total_score     = EXCLUDED.total_score,
    hackathon_score = EXCLUDED.hackathon_score,
    project_score   = EXCLUDED.project_score,
    academic_score  = EXCLUDED.academic_score,
    coding_score    = EXCLUDED.coding_score,
    last_computed   = EXCLUDED.last_computed;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- TRIGGER: recalculate score on activity status change
-- ============================================================
CREATE OR REPLACE FUNCTION trigger_recalculate_score()
RETURNS TRIGGER AS $$
BEGIN
  IF OLD.status IS DISTINCT FROM NEW.status THEN
    PERFORM calculate_score(NEW.user_id);
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trg_activity_score
  AFTER UPDATE ON public.activities
  FOR EACH ROW EXECUTE FUNCTION trigger_recalculate_score();

CREATE TRIGGER trg_coding_score
  AFTER UPDATE ON public.coding_activities
  FOR EACH ROW EXECUTE FUNCTION trigger_recalculate_score();

CREATE OR REPLACE FUNCTION trigger_recalculate_score_on_cgpa()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM calculate_score(NEW.user_id);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trg_semester_score
  AFTER INSERT OR UPDATE ON public.semesters
  FOR EACH ROW EXECUTE FUNCTION trigger_recalculate_score_on_cgpa();

-- ============================================================
-- TRIGGER: create user profile on user insert
-- ============================================================
CREATE OR REPLACE FUNCTION create_user_profile()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.user_profiles (user_id) VALUES (NEW.id)
  ON CONFLICT DO NOTHING;
  INSERT INTO public.score_cache (user_id) VALUES (NEW.id)
  ON CONFLICT DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trg_create_profile
  AFTER INSERT ON public.users
  FOR EACH ROW EXECUTE FUNCTION create_user_profile();

-- ============================================================
-- TRIGGER: create notification helper
-- ============================================================
CREATE OR REPLACE FUNCTION notify_user(
  p_user_id UUID,
  p_title TEXT,
  p_message TEXT
) RETURNS VOID AS $$
BEGIN
  INSERT INTO public.notifications (user_id, title, message)
  VALUES (p_user_id, p_title, p_message);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Notify student when activity status changes
CREATE OR REPLACE FUNCTION trigger_notify_activity_status()
RETURNS TRIGGER AS $$
DECLARE
  v_title TEXT;
  v_message TEXT;
BEGIN
  IF OLD.status IS DISTINCT FROM NEW.status THEN
    IF NEW.status = 'approved' THEN
      v_title := 'Activity Approved ✓';
      v_message := '"' || NEW.title || '" has been approved.';
    ELSIF NEW.status = 'rejected' THEN
      v_title := 'Activity Not Approved';
      v_message := '"' || NEW.title || '" was not approved' ||
        CASE WHEN NEW.rejection_reason IS NOT NULL
          THEN ': ' || NEW.rejection_reason
          ELSE '.'
        END;
    END IF;
    IF v_title IS NOT NULL THEN
      PERFORM notify_user(NEW.user_id, v_title, v_message);
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trg_notify_activity
  AFTER UPDATE ON public.activities
  FOR EACH ROW EXECUTE FUNCTION trigger_notify_activity_status();

CREATE TRIGGER trg_notify_coding
  AFTER UPDATE ON public.coding_activities
  FOR EACH ROW EXECUTE FUNCTION trigger_notify_activity_status();

-- Notify student when account status changes
CREATE OR REPLACE FUNCTION trigger_notify_account_status()
RETURNS TRIGGER AS $$
BEGIN
  IF OLD.status IS DISTINCT FROM NEW.status THEN
    IF NEW.status = 'active' THEN
      PERFORM notify_user(NEW.id, 'Account Approved 🎉',
        'Your MyCSIT account has been approved. Welcome!');
    ELSIF NEW.status = 'rejected' THEN
      PERFORM notify_user(NEW.id, 'Account Not Approved',
        'Your registration was not approved. Please contact your faculty coordinator.');
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trg_notify_account
  AFTER UPDATE ON public.users
  FOR EACH ROW EXECUTE FUNCTION trigger_notify_account_status();
