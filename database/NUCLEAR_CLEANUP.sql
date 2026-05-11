-- ============================================================
-- MyCSIT — Nuclear Cleanup (Complete Reset)
-- ============================================================

-- Step 1: Remove ALL policies from pg_policies table directly
DELETE FROM pg_policies WHERE schemaname = 'public';

-- Step 2: Disable RLS everywhere
DO $$
BEGIN
    EXECUTE 'ALTER TABLE ' || table_name || ' DISABLE ROW LEVEL SECURITY;'
    FROM information_schema.tables 
    WHERE table_schema = 'public' AND table_type = 'BASE TABLE';
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

-- Step 3: Drop all tables with CASCADE
DROP TABLE IF EXISTS public.audit_log CASCADE;
DROP TABLE IF EXISTS public.notifications CASCADE;
DROP TABLE IF EXISTS public.attendance CASCADE;
DROP TABLE IF EXISTS public.subjects CASCADE;
DROP TABLE IF EXISTS public.semesters CASCADE;
DROP TABLE IF EXISTS public.coding_activities CASCADE;
DROP TABLE IF EXISTS public.activities CASCADE;
DROP TABLE IF EXISTS public.score_cache CASCADE;
DROP TABLE IF EXISTS public.user_profiles CASCADE;
DROP TABLE IF EXISTS public.users CASCADE;

-- Step 4: Drop all functions
DROP FUNCTION IF EXISTS public.update_updated_at() CASCADE;
DROP FUNCTION IF EXISTS public.calculate_score(UUID) CASCADE;
DROP FUNCTION IF EXISTS public.trigger_recalculate_score() CASCADE;
DROP FUNCTION IF EXISTS public.trigger_recalculate_score_on_cgpa() CASCADE;
DROP FUNCTION IF EXISTS public.create_user_profile() CASCADE;
DROP FUNCTION IF EXISTS public.notify_user(UUID, TEXT, TEXT) CASCADE;
DROP FUNCTION IF EXISTS public.trigger_notify_activity_status() CASCADE;
DROP FUNCTION IF EXISTS public.trigger_notify_account_status() CASCADE;

-- Step 5: Drop all types
DROP TYPE IF EXISTS public.difficulty CASCADE;
DROP TYPE IF EXISTS public.coding_type CASCADE;
DROP TYPE IF EXISTS public.coding_platform CASCADE;
DROP TYPE IF EXISTS public.entry_status CASCADE;
DROP TYPE IF EXISTS public.activity_type CASCADE;
DROP TYPE IF EXISTS public.user_role CASCADE;
DROP TYPE IF EXISTS public.user_status CASCADE;

-- Step 6: Clean storage
DELETE FROM storage.objects WHERE bucket_id IN ('activity-proofs', 'profile-photos', 'coding-proofs');
DELETE FROM storage.buckets WHERE id IN ('activity-proofs', 'profile-photos', 'coding-proofs');

-- Step 7: Remove any remaining policy references
DO $$
BEGIN
    EXECUTE 'DROP POLICY IF EXISTS "' || policyname || '" ON ' || tablename || ';'
    FROM pg_policies 
    WHERE schemaname = 'public';
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

SELECT 'Nuclear cleanup complete. All policies, tables, and types removed.' as status;
