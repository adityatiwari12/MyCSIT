-- ============================================================
-- MyCSIT — Ensure All Tables Exist for Flutter App
-- ============================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create ENUM types if they don't exist
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
        CREATE TYPE activity_type AS ENUM (
            'hackathon', 'certification', 'research',
            'project', 'internship', 'achievement'
        );
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
END $$;

-- Create users table
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    roll_number TEXT NOT NULL UNIQUE,
    year INTEGER NOT NULL CHECK (year BETWEEN 1 AND 4),
    section TEXT NOT NULL CHECK (section IN ('A', 'B', 'C', 'D')),
    role user_role NOT NULL DEFAULT 'student',
    status user_status NOT NULL DEFAULT 'pending',
    fcm_token TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create user_profiles table
CREATE TABLE IF NOT EXISTS public.user_profiles (
    user_id UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
    bio TEXT,
    profile_photo_url TEXT,
    linkedin_url TEXT,
    github_url TEXT,
    portfolio_url TEXT,
    leetcode_url TEXT,
    codeforces_url TEXT,
    profile_completeness INTEGER DEFAULT 0,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create activities table
CREATE TABLE IF NOT EXISTS public.activities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    type activity_type NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    date DATE,
    proof_url TEXT,
    status entry_status NOT NULL DEFAULT 'pending',
    rejection_reason TEXT,
    approved_by UUID REFERENCES public.users(id),
    is_deleted BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create coding_activities table
CREATE TABLE IF NOT EXISTS public.coding_activities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    platform coding_platform NOT NULL,
    type coding_type NOT NULL,
    title TEXT NOT NULL,
    value INTEGER,
    contest_name TEXT,
    difficulty difficulty,
    proof_url TEXT,
    status entry_status NOT NULL DEFAULT 'pending',
    rejection_reason TEXT,
    approved_by UUID REFERENCES public.users(id),
    is_deleted BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create semesters table
CREATE TABLE IF NOT EXISTS public.semesters (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    sem_number INTEGER NOT NULL CHECK (sem_number BETWEEN 1 AND 8),
    cgpa NUMERIC(3, 2),
    updated_by UUID REFERENCES public.users(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, sem_number)
);

-- Create subjects table
CREATE TABLE IF NOT EXISTS public.subjects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    semester_id UUID NOT NULL REFERENCES public.semesters(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    marks NUMERIC(5, 2),
    max_marks NUMERIC(5, 2) DEFAULT 100,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create attendance table
CREATE TABLE IF NOT EXISTS public.attendance (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    semester_id UUID NOT NULL REFERENCES public.semesters(id) ON DELETE CASCADE,
    total_classes INTEGER NOT NULL DEFAULT 0,
    attended INTEGER NOT NULL DEFAULT 0,
    updated_by UUID REFERENCES public.users(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, semester_id)
);

-- Create score_cache table
CREATE TABLE IF NOT EXISTS public.score_cache (
    user_id UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
    total_score NUMERIC(5, 2) DEFAULT 0,
    hackathon_score NUMERIC(5, 2) DEFAULT 0,
    project_score NUMERIC(5, 2) DEFAULT 0,
    academic_score NUMERIC(5, 2) DEFAULT 0,
    coding_score NUMERIC(5, 2) DEFAULT 0,
    last_computed TIMESTAMPTZ,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create notifications table
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_users_role ON public.users(role);
CREATE INDEX IF NOT EXISTS idx_users_status ON public.users(status);
CREATE INDEX IF NOT EXISTS idx_activities_user_id ON public.activities(user_id);
CREATE INDEX IF NOT EXISTS idx_activities_status ON public.activities(status);
CREATE INDEX IF NOT EXISTS idx_activities_deleted ON public.activities(is_deleted);
CREATE INDEX IF NOT EXISTS idx_coding_activities_user_id ON public.coding_activities(user_id);
CREATE INDEX IF NOT EXISTS idx_coding_activities_status ON public.coding_activities(status);
CREATE INDEX IF NOT EXISTS idx_coding_activities_deleted ON public.coding_activities(is_deleted);
CREATE INDEX IF NOT EXISTS idx_semesters_user_id ON public.semesters(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_read ON public.notifications(is_read);

-- Enable Row Level Security
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.activities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.coding_activities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.semesters ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subjects ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attendance ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.score_cache ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Basic RLS policies (allow all for now, can be tightened later)
CREATE POLICY "Users can read all users" ON public.users FOR SELECT USING (true);
CREATE POLICY "Users can insert own user" ON public.users FOR INSERT WITH CHECK (true);
CREATE POLICY "Users can update own user" ON public.users FOR UPDATE USING (true);

CREATE POLICY "Users can read all profiles" ON public.user_profiles FOR SELECT USING (true);
CREATE POLICY "Users can insert own profile" ON public.user_profiles FOR INSERT WITH CHECK (true);
CREATE POLICY "Users can update own profile" ON public.user_profiles FOR UPDATE USING (true);

CREATE POLICY "Users can read all activities" ON public.activities FOR SELECT USING (true);
CREATE POLICY "Users can insert own activities" ON public.activities FOR INSERT WITH CHECK (true);
CREATE POLICY "Users can update own activities" ON public.activities FOR UPDATE USING (true);

CREATE POLICY "Users can read all coding activities" ON public.coding_activities FOR SELECT USING (true);
CREATE POLICY "Users can insert own coding activities" ON public.coding_activities FOR INSERT WITH CHECK (true);
CREATE POLICY "Users can update own coding activities" ON public.coding_activities FOR UPDATE USING (true);

CREATE POLICY "Users can read all semesters" ON public.semesters FOR SELECT USING (true);
CREATE POLICY "Users can insert own semesters" ON public.semesters FOR INSERT WITH CHECK (true);
CREATE POLICY "Users can update own semesters" ON public.semesters FOR UPDATE USING (true);

CREATE POLICY "Users can read all subjects" ON public.subjects FOR SELECT USING (true);
CREATE POLICY "Users can insert own subjects" ON public.subjects FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can read all attendance" ON public.attendance FOR SELECT USING (true);
CREATE POLICY "Users can insert own attendance" ON public.attendance FOR INSERT WITH CHECK (true);
CREATE POLICY "Users can update own attendance" ON public.attendance FOR UPDATE USING (true);

CREATE POLICY "Users can read all score cache" ON public.score_cache FOR SELECT USING (true);
CREATE POLICY "Users can insert own score cache" ON public.score_cache FOR INSERT WITH CHECK (true);
CREATE POLICY "Users can update own score cache" ON public.score_cache FOR UPDATE USING (true);

CREATE POLICY "Users can read all notifications" ON public.notifications FOR SELECT USING (true);
CREATE POLICY "Users can insert own notifications" ON public.notifications FOR INSERT WITH CHECK (true);
CREATE POLICY "Users can update own notifications" ON public.notifications FOR UPDATE USING (true);

-- Verification
SELECT 'All tables created successfully!' as status;
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public'
ORDER BY table_name;
