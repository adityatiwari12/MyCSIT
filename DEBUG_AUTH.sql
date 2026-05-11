-- ============================================================
-- MyCSIT — Debug Authentication Issues
-- ============================================================

-- Check if faculty user exists in auth.users table
SELECT 'Checking auth.users table for faculty user...' as status;
SELECT id, email, created_at FROM auth.users WHERE email = 'csitfaculty@acropolis.in';

-- Check if faculty user exists in public.users table
SELECT 'Checking public.users table for faculty user...' as status;
SELECT id, name, roll_number, role, status FROM public.users WHERE roll_number = 'FAC001';

-- Check for any faculty users
SELECT 'All faculty users in public.users:' as status;
SELECT id, name, roll_number, role, status FROM public.users WHERE role = 'faculty';

-- Check for the specific UUID we're trying to update
SELECT 'Checking for specific faculty UUID:' as status;
SELECT id, name, roll_number, role, status FROM public.users WHERE id = '2f4548e0-c2da-4779-9047-b0ddc3bbdaf3';

-- Check placeholder UUIDs
SELECT 'Checking for placeholder UUIDs:' as status;
SELECT id, name, roll_number, role, status FROM public.users WHERE id::text LIKE '00000000-0000-0000-0000-%';

-- Check if there are any authentication issues
SELECT 'Auth users count:' as info, COUNT(*) as count FROM auth.users;
SELECT 'Public users count:' as info, COUNT(*) as count FROM public.users;

-- Check for any RLS policies that might block auth
SELECT 'Checking RLS policies on users table:' as status;
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE tablename = 'users';
