-- ============================================================
-- Check What Tables Actually Exist
-- ============================================================

SELECT 'Tables in public schema:' as info;
SELECT table_name, table_type 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;
