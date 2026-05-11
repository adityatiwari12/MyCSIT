-- ============================================================
-- MyCSIT — Faculty Seed Data
-- Execute this after setting up RLS policies
-- ============================================================

-- Create faculty users (these need to be created in auth.users first)
-- For now, we'll create the records assuming auth users exist
-- In production, create these through Supabase Auth or admin functions

-- Faculty accounts to create (email -> password):
-- 1. faculty@mycsit.edu -> Faculty123!
-- 2. hod@mycsit.edu -> HOD123!
-- 3. coordinator@mycsit.edu -> Coord123!

-- Insert faculty records (these will only work if auth users exist)
-- You can create these users in Supabase Dashboard > Authentication > Users

INSERT INTO public.users (id, name, roll_number, year, section, role, status)
VALUES 
  -- Replace these UUIDs with actual auth.user IDs after creating users
  ('00000000-0000-0000-0000-000000000001', 'Dr. Rajesh Kumar', 'FAC001', 1, 'A', 'faculty', 'active'),
  ('00000000-0000-0000-0000-000000000002', 'Dr. Priya Sharma', 'FAC002', 1, 'A', 'faculty', 'active'),
  ('00000000-0000-0000-0000-000000000003', 'Prof. Amit Verma', 'FAC003', 1, 'A', 'faculty', 'active')
ON CONFLICT (id) DO NOTHING;

-- Update faculty profiles
INSERT INTO public.user_profiles (user_id, bio, profile_completeness)
VALUES 
  ('00000000-0000-0000-0000-000000000001', 'HOD - Computer Science Department with 15+ years of experience', 100),
  ('00000000-0000-0000-0000-000000000002', 'Faculty Coordinator - Specialized in Data Structures and Algorithms', 100),
  ('00000000-0000-0000-0000-000000000003', 'Associate Professor - Expert in Web Technologies and Mobile Development', 100)
ON CONFLICT (user_id) DO UPDATE SET 
  bio = EXCLUDED.bio,
  updated_at = NOW();

-- Create sample student data for testing
-- Note: These students need to be created in auth.users first
INSERT INTO public.users (id, name, roll_number, year, section, role, status)
VALUES 
  ('10000000-0000-0000-0000-000000000001', 'Rahul Sharma', 'CSIT2021001', 3, 'A', 'student', 'active'),
  ('10000000-0000-0000-0000-000000000002', 'Priya Patel', 'CSIT2021002', 3, 'A', 'student', 'active'),
  ('10000000-0000-0000-0000-000000000003', 'Amit Kumar', 'CSIT2022001', 2, 'B', 'student', 'pending'),
  ('10000000-0000-0000-0000-000000000004', 'Neha Singh', 'CSIT2022002', 2, 'B', 'student', 'active')
ON CONFLICT (id) DO NOTHING;

-- Add sample academic data for active students
INSERT INTO public.semesters (user_id, sem_number, cgpa, updated_by)
VALUES 
  ('10000000-0000-0000-0000-000000000001', 5, 8.5, '00000000-0000-0000-0000-000000000001'),
  ('10000000-0000-0000-0000-000000000002', 5, 9.2, '00000000-0000-0000-0000-000000000001'),
  ('10000000-0000-0000-0000-000000000004', 3, 7.8, '00000000-0000-0000-0000-000000000001')
ON CONFLICT (user_id, sem_number) DO NOTHING;

-- Add sample subjects for one semester
INSERT INTO public.subjects (semester_id, name, marks, max_marks)
SELECT 
  s.id,
  unnest(ARRAY['Data Structures', 'Algorithms', 'Database Systems', 'Web Development', 'Operating Systems']),
  unnest(ARRAY[85, 78, 92, 88, 80]),
  unnest(ARRAY[100, 100, 100, 100, 100])
FROM public.semesters s
WHERE s.user_id = '10000000-0000-0000-0000-000000000001' AND s.sem_number = 5;

-- Add sample attendance
INSERT INTO public.attendance (user_id, semester_id, total_classes, attended, updated_by)
VALUES 
  ('10000000-0000-0000-0000-000000000001', 
   (SELECT id FROM public.semesters WHERE user_id = '10000000-0000-0000-0000-000000000001' AND sem_number = 5),
   45, 42, '00000000-0000-0000-0000-000000000001'),
  ('10000000-0000-0000-0000-000000000002',
   (SELECT id FROM public.semesters WHERE user_id = '10000000-0000-0000-0000-000000000002' AND sem_number = 5),
   45, 44, '00000000-0000-0000-0000-000000000001')
ON CONFLICT (user_id, semester_id) DO NOTHING;

-- Add sample activities for testing
INSERT INTO public.activities (user_id, type, title, description, date, proof_url, status, approved_by)
VALUES 
  ('10000000-0000-0000-0000-000000000001', 'hackathon', 'Smart India Hackathon 2023', 'Participated in national level hackathon and developed IoT solution for smart agriculture', '2023-03-15', 'https://example.com/sih-proof.pdf', 'approved', '00000000-0000-0000-0000-000000000001'),
  ('10000000-0000-0000-0000-000000000001', 'project', 'E-commerce Platform', 'Built full-stack e-commerce platform using MERN stack', '2023-02-10', 'https://example.com/ecommerce-proof.pdf', 'approved', '00000000-0000-0000-0000-000000000001'),
  ('10000000-0000-0000-0000-000000000002', 'certification', 'AWS Certified Developer', 'Completed AWS Developer Associate certification', '2023-01-20', 'https://example.com/aws-cert.pdf', 'approved', '00000000-0000-0000-0000-000000000001'),
  ('10000000-0000-0000-0000-000000000003', 'project', 'Mobile App Development', 'Developed fitness tracking mobile app', '2023-04-05', 'https://example.com/mobile-app.pdf', 'pending', NULL);

-- Add sample coding activities
INSERT INTO public.coding_activities (user_id, platform, type, title, value, proof_url, status, approved_by)
VALUES 
  ('10000000-0000-0000-0000-000000000001', 'leetcode', 'milestone', 'Solved 200+ LeetCode problems', 200, 'https://leetcode.com/rahul', 'approved', '00000000-0000-0000-0000-000000000001'),
  ('10000000-0000-0000-0000-000000000001', 'codeforces', 'contest', 'Codeforces Round #1800', 1200, 'https://codeforces.com/contest/1800', 'approved', '00000000-0000-0000-0000-000000000001'),
  ('10000000-0000-0000-0000-000000000002', 'leetcode', 'milestone', 'Solved 350+ LeetCode problems', 350, 'https://leetcode.com/priya', 'approved', '00000000-0000-0000-0000-000000000001');

-- Calculate scores for active students
SELECT calculate_score('10000000-0000-0000-0000-000000000001');
SELECT calculate_score('10000000-0000-0000-0000-000000000002');
SELECT calculate_score('10000000-0000-0000-0000-000000000004');

-- Add some notifications
INSERT INTO public.notifications (user_id, title, message)
VALUES 
  ('10000000-0000-0000-0000-000000000001', 'Welcome to MyCSIT!', 'Your account has been activated. Start logging your activities now!'),
  ('10000000-0000-0000-0000-000000000002', 'Activity Approved', 'Your AWS certification has been approved.'),
  ('10000000-0000-0000-0000-000000000003', 'Account Pending', 'Your account is pending faculty approval.');
