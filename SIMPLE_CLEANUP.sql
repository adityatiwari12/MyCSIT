-- ============================================================
-- MyCSIT — Simple Working Cleanup
-- ============================================================

-- Step 1: Complete schema reset (this always works)
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;

-- Step 2: Grant permissions
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO public;
GRANT ALL ON SCHEMA public TO authenticated;
GRANT ALL ON SCHEMA public TO anon;

-- Step 3: Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

SELECT 'Simple cleanup complete. Schema reset and ready for fresh setup.' as status;
