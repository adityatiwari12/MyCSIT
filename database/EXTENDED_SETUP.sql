-- ============================================================
-- MyCSIT — Extended Setup (Add Missing Tables for React Dashboard)
-- Run this after SIMPLE_SETUP.sql
-- ============================================================

-- Create score_cache table
CREATE TABLE public.score_cache (
  user_id          UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
  total_score      NUMERIC(5,2) NOT NULL DEFAULT 0,
  hackathon_score  NUMERIC(5,2) NOT NULL DEFAULT 0,
  project_score    NUMERIC(5,2) NOT NULL DEFAULT 0,
  academic_score   NUMERIC(5,2) NOT NULL DEFAULT 0,
  coding_score     NUMERIC(5,2) NOT NULL DEFAULT 0,
  last_computed    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create semesters table
CREATE TABLE public.semesters (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id     UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  sem_number  INTEGER NOT NULL CHECK (sem_number BETWEEN 1 AND 8),
  cgpa        NUMERIC(4,2) CHECK (cgpa BETWEEN 0 AND 10),
  updated_by  UUID REFERENCES public.users(id),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, sem_number)
);

-- Create coding_activities table
CREATE TYPE coding_platform AS ENUM ('leetcode', 'codeforces', 'codechef', 'other');
CREATE TYPE coding_type AS ENUM ('milestone', 'contest', 'highValueProblem');

CREATE TABLE public.coding_activities (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id           UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  platform          coding_platform NOT NULL,
  type              coding_type NOT NULL,
  title             TEXT NOT NULL,
  value             INTEGER,
  contest_name      TEXT,
  proof_url         TEXT NOT NULL,
  status            user_status NOT NULL DEFAULT 'pending',
  rejection_reason  TEXT,
  approved_by       UUID REFERENCES public.users(id),
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Enable RLS on new tables
ALTER TABLE public.score_cache ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.semesters ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.coding_activities ENABLE ROW LEVEL SECURITY;

-- RLS policies for score_cache
CREATE POLICY "Users can view own score" ON public.score_cache
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Faculty can view all scores" ON public.score_cache
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.users 
      WHERE id = auth.uid() AND role = 'faculty' AND status = 'active'
    )
  );

-- RLS policies for semesters
CREATE POLICY "Users can view own academics" ON public.semesters
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Faculty can view all academics" ON public.semesters
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.users 
      WHERE id = auth.uid() AND role = 'faculty' AND status = 'active'
    )
  );

-- RLS policies for coding_activities
CREATE POLICY "Users can view own coding activities" ON public.coding_activities
  FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Faculty can view all coding activities" ON public.coding_activities
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.users 
      WHERE id = auth.uid() AND role = 'faculty' AND status = 'active'
    )
  );

-- Update activities table to use proper type
ALTER TABLE public.activities ALTER COLUMN type TYPE TEXT;

-- Insert sample data for testing
INSERT INTO public.score_cache (user_id, total_score, hackathon_score, project_score, academic_score, coding_score)
VALUES 
  ('00000000-0000-0000-0000-000000000002', 78.5, 85.0, 75.0, 80.0, 65.0)
ON CONFLICT (user_id) DO NOTHING;

INSERT INTO public.semesters (user_id, sem_number, cgpa, updated_by)
VALUES 
  ('00000000-0000-0000-0000-000000000002', 5, 8.5, '00000000-0000-0000-0000-000000000001')
ON CONFLICT (user_id, sem_number) DO NOTHING;

-- Verification
SELECT 'Extended setup complete!' as status;
SELECT 'Total tables:' as info, COUNT(*) as count FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE';
