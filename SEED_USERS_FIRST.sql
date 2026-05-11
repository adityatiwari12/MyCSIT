-- ============================================================
-- MyCSIT — Seed Data (Insert Users First, Then Related Data)
-- ============================================================

-- Step 1: NO MOCK USERS - Real users only
-- Users will be created through Supabase Auth signup
-- The trigger automatically creates public.users records
-- Only proceed if you have REAL auth users created in Supabase Dashboard

-- Check if you have auth users first:
-- SELECT id, email FROM auth.users;

-- If you have auth users, get their UUIDs and use those instead of fake ones
-- Uncomment and update with REAL UUIDs below if needed for testing

-- INSERT INTO public.users (id, name, roll_number, year, section, role, status)
-- VALUES 
--   ('REAL_FACULTY_UUID_HERE', 'Dr. Rajesh Kumar', 'FAC001', 1, 'A', 'faculty', 'active'),
--   ('REAL_STUDENT_UUID_HERE', 'Rahul Sharma', 'CSIT2021001', 3, 'A', 'student', 'active')
-- ON CONFLICT (id) DO NOTHING;

-- Step 2: Insert user profiles
INSERT INTO public.user_profiles (user_id, bio, profile_completeness)
VALUES 
  ('00000000-0000-0000-0000-000000000001', 'HOD - Computer Science Department with 15+ years of experience', 100),
  ('00000000-0000-0000-0000-000000000002', 'Passionate about full-stack development and competitive programming', 85),
  ('00000000-0000-0000-0000-000000000003', 'Interested in machine learning and data science', 90)
ON CONFLICT (user_id) DO NOTHING;

-- Step 3: Insert score cache
INSERT INTO public.score_cache (user_id, total_score, hackathon_score, project_score, academic_score, coding_score)
VALUES 
  ('00000000-0000-0000-0000-000000000002', 78.5, 85.0, 75.0, 80.0, 65.0),
  ('00000000-0000-0000-0000-000000000003', 85.2, 90.0, 80.0, 88.0, 75.0)
ON CONFLICT (user_id) DO NOTHING;

-- Step 4: Insert semesters
INSERT INTO public.semesters (user_id, sem_number, cgpa, updated_by)
VALUES 
  ('00000000-0000-0000-0000-000000000002', 5, 8.5, '00000000-0000-0000-0000-000000000001'),
  ('00000000-0000-0000-0000-000000000003', 5, 9.2, '00000000-0000-0000-0000-000000000001')
ON CONFLICT (user_id, sem_number) DO NOTHING;

-- Step 5: Insert activities
INSERT INTO public.activities (user_id, type, title, description, date, proof_url, status, approved_by)
VALUES 
  ('00000000-0000-0000-0000-000000000002', 'hackathon', 'Smart India Hackathon 2023', 'Participated in national level hackathon', '2023-03-15', 'https://example.com/sih-proof.pdf', 'approved', '00000000-0000-0000-0000-000000000001'),
  ('00000000-0000-0000-0000-000000000002', 'project', 'E-commerce Platform', 'Built full-stack e-commerce platform using MERN stack', '2023-02-10', 'https://example.com/ecommerce-proof.pdf', 'approved', '00000000-0000-0000-0000-000000000001'),
  ('00000000-0000-0000-0000-000000000003', 'project', 'Machine Learning Model', 'Developed sentiment analysis model using Python', '2023-03-20', 'https://example.com/ml-project.pdf', 'pending', NULL)
ON CONFLICT DO NOTHING;

-- Step 6: Insert notifications
INSERT INTO public.notifications (user_id, title, message)
VALUES 
  ('00000000-0000-0000-0000-000000000001', 'Welcome to MyCSIT!', 'Your faculty account has been created successfully.'),
  ('00000000-0000-0000-0000-000000000002', 'Welcome to MyCSIT!', 'Your student account has been created successfully.'),
  ('00000000-0000-0000-0000-000000000002', 'Activity Approved', 'Your Smart India Hackathon participation has been approved!'),
  ('00000000-0000-0000-0000-000000000003', 'Activity Pending', 'Your project submission is pending approval.')
ON CONFLICT DO NOTHING;

-- Verification
SELECT 'Sample data created successfully!' as status;
SELECT 'Users:' as table_name, COUNT(*) as count FROM public.users
UNION ALL
SELECT 'Profiles:', COUNT(*) FROM public.user_profiles
UNION ALL
SELECT 'Scores:', COUNT(*) FROM public.score_cache
UNION ALL
SELECT 'Semesters:', COUNT(*) FROM public.semesters
UNION ALL
SELECT 'Activities:', COUNT(*) FROM public.activities
UNION ALL
SELECT 'Notifications:', COUNT(*) FROM public.notifications;
