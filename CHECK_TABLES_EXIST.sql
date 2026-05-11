-- ============================================================
-- MyCSIT — Check if required tables exist
-- ============================================================

-- Check if all required tables exist
SELECT 'Checking table existence...' as status;

SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public'
AND table_name IN (
    'users',
    'user_profiles',
    'activities',
    'coding_activities',
    'semesters',
    'subjects',
    'attendance',
    'score_cache',
    'notifications'
)
ORDER BY table_name;

-- Check if coding_activities table exists specifically
SELECT 'Checking coding_activities table...' as status;
SELECT EXISTS (
    SELECT FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name = 'coding_activities'
) as coding_activities_exists;

-- If coding_activities doesn't exist, create it
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'coding_activities') THEN
        CREATE TABLE public.coding_activities (
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
            is_deleted BOOLEAN NOT NULL DEFAULT false,
            created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
            updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
        );
        
        CREATE INDEX idx_coding_activities_user_id ON public.coding_activities(user_id);
        CREATE INDEX idx_coding_activities_status ON public.coding_activities(status);
        CREATE INDEX idx_coding_activities_deleted ON public.coding_activities(is_deleted);
        
        RAISE NOTICE 'Created coding_activities table';
    ELSE
        RAISE NOTICE 'coding_activities table already exists';
    END IF;
END $$;

-- Verify tables
SELECT 'Final table check:' as status;
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public'
AND table_name IN ('coding_activities', 'activities', 'users');
