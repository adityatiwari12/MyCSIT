-- ============================================================
-- MyCSIT — Create Authentication Users
-- Note: This creates user records that will be linked to auth users
-- ============================================================

-- First, let's check if we can access auth.users
SELECT 'Checking auth.users table access...' as status;

-- Create user records for testing (these will be linked to auth users)
-- You'll need to create the auth users first in the Supabase Dashboard
-- Then update these UUIDs with the actual auth.user IDs

-- Faculty user record
INSERT INTO public.users (id, name, roll_number, year, section, role, status)
VALUES 
  ('00000000-0000-0000-0000-000000000001', 'Dr. Rajesh Kumar', 'FAC001', 1, 'A', 'faculty', 'active')
ON CONFLICT (id) DO NOTHING;

-- Student user record  
INSERT INTO public.users (id, name, roll_number, year, section, role, status)
VALUES 
  ('00000000-0000-0000-0000-000000000002', 'Rahul Sharma', 'CSIT2021001', 3, 'A', 'student', 'active')
ON CONFLICT (id) DO NOTHING;

-- Create sample profiles
INSERT INTO public.user_profiles (user_id, bio, profile_completeness)
VALUES 
  ('00000000-0000-0000-0000-000000000001', 'HOD - Computer Science Department with 15+ years of experience', 100),
  ('00000000-0000-0000-0000-000000000002', 'Passionate about full-stack development and competitive programming', 85)
ON CONFLICT (user_id) DO NOTHING;

-- Create sample activities for student
INSERT INTO public.activities (user_id, type, title, description, date, proof_url, status, approved_by)
VALUES 
  ('00000000-0000-0000-0000-000000000002', 'hackathon', 'Smart India Hackathon 2023', 'Participated in national level hackathon and developed IoT solution for smart agriculture', '2023-03-15', 'https://example.com/sih-proof.pdf', 'approved', '00000000-0000-0000-0000-000000000001'),
  ('00000000-0000-0000-0000-000000000002', 'project', 'E-commerce Platform', 'Built full-stack e-commerce platform using MERN stack', '2023-02-10', 'https://example.com/ecommerce-proof.pdf', 'approved', '00000000-0000-0000-0000-000000000001')
ON CONFLICT DO NOTHING;

-- Create notifications
INSERT INTO public.notifications (user_id, title, message)
VALUES 
  ('00000000-0000-0000-0000-000000000001', 'Welcome to MyCSIT!', 'Your faculty account has been created successfully.'),
  ('00000000-0000-0000-0000-000000000002', 'Welcome to MyCSIT!', 'Your student account has been created successfully.'),
  ('00000000-0000-0000-0000-000000000002', 'Activity Approved', 'Your Smart India Hackathon participation has been approved!')
ON CONFLICT DO NOTHING;

-- Verification queries
SELECT 'Sample users and data created!' as status;
SELECT 'Users created:' as info, COUNT(*) as count FROM public.users;
SELECT 'Profiles created:' as info, COUNT(*) as count FROM public.user_profiles;
SELECT 'Activities created:' as info, COUNT(*) as count FROM public.activities;
SELECT 'Notifications created:' as info, COUNT(*) as count FROM public.notifications;

-- Instructions for creating auth users:
SELECT 'IMPORTANT: Create these auth users in Supabase Dashboard → Authentication → Users:' as instructions;
SELECT '1. faculty@mycsit.edu / Faculty123!' as user1;
SELECT '2. student1@mycsit.edu / Student123!' as user2;
SELECT '3. After creating auth users, get their UUIDs and update the records above' as next_step;
