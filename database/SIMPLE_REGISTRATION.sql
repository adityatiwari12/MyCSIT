-- Simple Registration Setup
-- No validation, just store data and show in faculty dashboard

-- Ensure users table allows all inserts
DROP POLICY IF EXISTS "Users can read all users" ON public.users;
DROP POLICY IF EXISTS "Users can insert own user" ON public.users;
DROP POLICY IF EXISTS "Users can update own user" ON public.users;

-- Create simple permissive policies
CREATE POLICY "Allow all operations on users" ON public.users
    FOR ALL USING (true);

-- Verify faculty can see all students
SELECT 
    'Testing faculty view' as test_type,
    id,
    name,
    roll_number,
    year,
    section,
    role,
    status,
    created_at
FROM public.users 
WHERE role = 'student'
ORDER BY created_at DESC
LIMIT 10;

-- Check if students can be inserted (test)
SELECT 
    'Ready for simple registration' as status,
    COUNT(*) as current_students
FROM public.users 
WHERE role = 'student';
