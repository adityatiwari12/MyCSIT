-- ============================================================
-- MyCSIT — Seed Data (Run After Creating Auth Users)
-- ============================================================

-- ============================================================
-- INSTRUCTIONS:
-- 1. First create users in Supabase Dashboard > Authentication > Users
-- 2. Copy their UUIDs from the Users table
-- 3. Replace the placeholder UUIDs below with actual user IDs
-- 4. Run this script
-- ============================================================

-- Faculty Users to Create (Authentication):
-- Email: faculty@mycsit.edu | Password: Faculty123!
-- Email: hod@mycsit.edu | Password: HOD123!
-- Email: coordinator@mycsit.edu | Password: Coord123!

-- Student Users to Create (Authentication):
-- Email: student1@mycsit.edu | Password: Student123!
-- Email: student2@mycsit.edu | Password: Student123!
-- Email: student3@mycsit.edu | Password: Student123!

-- ============================================================
-- REPLACE THESE PLACEHOLDER UUIDs WITH ACTUAL AUTH USER IDs
-- ============================================================

-- Faculty UUIDs (replace with actual auth.user IDs)
DO $$
DECLARE
  faculty_1 UUID := 'FACULTY_UUID_1_PLACEHOLDER';  -- faculty@mycsit.edu
  faculty_2 UUID := 'FACULTY_UUID_2_PLACEHOLDER';  -- hod@mycsit.edu
  faculty_3 UUID := 'FACULTY_UUID_3_PLACEHOLDER';  -- coordinator@mycsit.edu
  
  -- Student UUIDs (replace with actual auth.user IDs)
  student_1 UUID := 'STUDENT_UUID_1_PLACEHOLDER';  -- student1@mycsit.edu
  student_2 UUID := 'STUDENT_UUID_2_PLACEHOLDER';  -- student2@mycsit.edu
  student_3 UUID := 'STUDENT_UUID_3_PLACEHOLDER';  -- student3@mycsit.edu
BEGIN
  -- Skip if placeholders are not replaced
  IF faculty_1 = 'FACULTY_UUID_1_PLACEHOLDER' THEN
    RAISE EXCEPTION 'Please replace placeholder UUIDs with actual auth.user IDs';
  END IF;

  -- ============================================================
  -- INSERT FACULTY USERS
  -- ============================================================
  INSERT INTO public.users (id, name, roll_number, year, section, role, status)
  VALUES 
    (faculty_1, 'Dr. Rajesh Kumar', 'FAC001', 1, 'A', 'faculty', 'active'),
    (faculty_2, 'Dr. Priya Sharma', 'FAC002', 1, 'A', 'faculty', 'active'),
    (faculty_3, 'Prof. Amit Verma', 'FAC003', 1, 'A', 'faculty', 'active')
  ON CONFLICT (id) DO NOTHING;

  -- Update faculty profiles
  INSERT INTO public.user_profiles (user_id, bio, profile_completeness)
  VALUES 
    (faculty_1, 'HOD - Computer Science Department with 15+ years of experience in AI and Machine Learning', 100),
    (faculty_2, 'Faculty Coordinator - Specialized in Data Structures and Algorithms', 100),
    (faculty_3, 'Associate Professor - Expert in Web Technologies and Mobile Development', 100)
  ON CONFLICT (user_id) DO UPDATE SET 
    bio = EXCLUDED.bio,
    updated_at = NOW();

  -- ============================================================
  -- INSERT STUDENT USERS
  -- ============================================================
  INSERT INTO public.users (id, name, roll_number, year, section, role, status)
  VALUES 
    (student_1, 'Rahul Sharma', 'CSIT2021001', 3, 'A', 'student', 'active'),
    (student_2, 'Priya Patel', 'CSIT2021002', 3, 'A', 'student', 'active'),
    (student_3, 'Amit Kumar', 'CSIT2022001', 2, 'B', 'student', 'pending')
  ON CONFLICT (id) DO NOTHING;

  -- Update student profiles
  INSERT INTO public.user_profiles (user_id, bio, linkedin_url, github_url, leetcode_url, profile_completeness)
  VALUES 
    (student_1, 'Passionate about full-stack development and competitive programming', 
     'https://linkedin.com/in/rahulsharma', 'https://github.com/rahulsharma', 'https://leetcode.com/rahul', 85),
    (student_2, 'Interested in machine learning and data science', 
     'https://linkedin.com/in/priyapatel', 'https://github.com/priyapatel', 'https://leetcode.com/priya', 90),
    (student_3, 'Web development enthusiast', 
     NULL, 'https://github.com/amitkumar', NULL, 60)
  ON CONFLICT (user_id) DO UPDATE SET 
    bio = EXCLUDED.bio,
    linkedin_url = EXCLUDED.linkedin_url,
    github_url = EXCLUDED.github_url,
    leetcode_url = EXCLUDED.leetcode_url,
    profile_completeness = EXCLUDED.profile_completeness,
    updated_at = NOW();

  -- ============================================================
  -- ADD ACADEMIC DATA
  -- ============================================================
  -- Rahul Sharma (3rd year, 5th semester)
  INSERT INTO public.semesters (user_id, sem_number, cgpa, updated_by)
  VALUES 
    (student_1, 5, 8.5, faculty_1),
    (student_1, 4, 8.2, faculty_1),
    (student_1, 3, 7.9, faculty_1)
  ON CONFLICT (user_id, sem_number) DO UPDATE SET
    cgpa = EXCLUDED.cgpa,
    updated_by = EXCLUDED.updated_by,
    updated_at = NOW();

  -- Priya Patel (3rd year, 5th semester)
  INSERT INTO public.semesters (user_id, sem_number, cgpa, updated_by)
  VALUES 
    (student_2, 5, 9.2, faculty_1),
    (student_2, 4, 8.9, faculty_1),
    (student_2, 3, 8.7, faculty_1)
  ON CONFLICT (user_id, sem_number) DO UPDATE SET
    cgpa = EXCLUDED.cgpa,
    updated_by = EXCLUDED.updated_by,
    updated_at = NOW();

  -- Amit Kumar (2nd year, 3rd semester)
  INSERT INTO public.semesters (user_id, sem_number, cgpa, updated_by)
  VALUES 
    (student_3, 3, 7.8, faculty_1),
    (student_3, 2, 7.5, faculty_1),
    (student_3, 1, 7.2, faculty_1)
  ON CONFLICT (user_id, sem_number) DO UPDATE SET
    cgpa = EXCLUDED.cgpa,
    updated_by = EXCLUDED.updated_by,
    updated_at = NOW();

  -- Add subjects for current semester
  INSERT INTO public.subjects (semester_id, name, marks, max_marks)
  SELECT 
    s.id,
    unnest(ARRAY['Data Structures', 'Algorithms', 'Database Systems', 'Web Development', 'Operating Systems']),
    unnest(ARRAY[85, 78, 92, 88, 80]),
    unnest(ARRAY[100, 100, 100, 100, 100])
  FROM public.semesters s
  WHERE s.user_id = student_1 AND s.sem_number = 5;

  INSERT INTO public.subjects (semester_id, name, marks, max_marks)
  SELECT 
    s.id,
    unnest(ARRAY['Data Structures', 'Algorithms', 'Database Systems', 'Web Development', 'Operating Systems']),
    unnest(ARRAY[92, 89, 95, 91, 87]),
    unnest(ARRAY[100, 100, 100, 100, 100])
  FROM public.semesters s
  WHERE s.user_id = student_2 AND s.sem_number = 5;

  -- Add attendance data
  INSERT INTO public.attendance (user_id, semester_id, total_classes, attended, updated_by)
  VALUES 
    (student_1, 
     (SELECT id FROM public.semesters WHERE user_id = student_1 AND sem_number = 5),
     45, 42, faculty_1),
    (student_2,
     (SELECT id FROM public.semesters WHERE user_id = student_2 AND sem_number = 5),
     45, 44, faculty_1),
    (student_3,
     (SELECT id FROM public.semesters WHERE user_id = student_3 AND sem_number = 3),
     40, 35, faculty_1)
  ON CONFLICT (user_id, semester_id) DO UPDATE SET
    total_classes = EXCLUDED.total_classes,
    attended = EXCLUDED.attended,
    updated_by = EXCLUDED.updated_by,
    updated_at = NOW();

  -- ============================================================
  -- ADD ACTIVITIES
  -- ============================================================
  -- Rahul Sharma's activities
  INSERT INTO public.activities (user_id, type, title, description, date, proof_url, status, approved_by)
  VALUES 
    (student_1, 'hackathon', 'Smart India Hackathon 2023', 'Participated in national level hackathon and developed IoT solution for smart agriculture', '2023-03-15', 'https://example.com/sih-proof.pdf', 'approved', faculty_1),
    (student_1, 'project', 'E-commerce Platform', 'Built full-stack e-commerce platform using MERN stack with payment integration', '2023-02-10', 'https://example.com/ecommerce-proof.pdf', 'approved', faculty_1),
    (student_1, 'certification', 'AWS Certified Developer', 'Completed AWS Developer Associate certification with focus on cloud services', '2023-01-20', 'https://example.com/aws-cert.pdf', 'approved', faculty_1),
    (student_1, 'achievement', 'Coding Competition Winner', 'Won 2nd place in inter-college coding competition', '2023-04-10', 'https://example.com/coding-comp.pdf', 'approved', faculty_1);

  -- Priya Patel's activities
  INSERT INTO public.activities (user_id, type, title, description, date, proof_url, status, approved_by)
  VALUES 
    (student_2, 'project', 'Machine Learning Model', 'Developed sentiment analysis model using Python and TensorFlow', '2023-03-20', 'https://example.com/ml-project.pdf', 'approved', faculty_2),
    (student_2, 'internship', 'Data Science Intern', '3-month internship at TechCorp working on data analysis projects', '2023-01-15', 'https://example.com/internship-cert.pdf', 'approved', faculty_2),
    (student_2, 'certification', 'Google Data Analytics', 'Completed Google Data Analytics Professional Certificate', '2023-02-28', 'https://example.com/google-cert.pdf', 'approved', faculty_2),
    (student_2, 'research', 'Research Paper Publication', 'Published paper on "Applications of AI in Healthcare" in international journal', '2023-04-05', 'https://example.com/research-paper.pdf', 'approved', faculty_2);

  -- Amit Kumar's pending activities
  INSERT INTO public.activities (user_id, type, title, description, date, proof_url, status)
  VALUES 
    (student_3, 'project', 'Mobile App Development', 'Developed fitness tracking mobile app using React Native', '2023-04-15', 'https://example.com/mobile-app.pdf', 'pending'),
    (student_3, 'certification', 'Python Certification', 'Completed Python programming certification from Coursera', '2023-03-25', 'https://example.com/python-cert.pdf', 'pending');

  -- ============================================================
  -- ADD CODING ACTIVITIES
  -- ============================================================
  -- Rahul Sharma's coding activities
  INSERT INTO public.coding_activities (user_id, platform, type, title, value, proof_url, status, approved_by)
  VALUES 
    (student_1, 'leetcode', 'milestone', 'Solved 200+ LeetCode problems', 200, 'https://leetcode.com/rahul', 'approved', faculty_1),
    (student_1, 'codeforces', 'contest', 'Codeforces Round #1800', 1200, 'https://codeforces.com/contest/1800', 'approved', faculty_1),
    (student_1, 'codechef', 'milestone', 'Solved 150+ CodeChef problems', 150, 'https://codechef.com/rahul', 'approved', faculty_1),
    (student_1, 'leetcode', 'contest', 'LeetCode Weekly Contest 350', 850, 'https://leetcode.com/contest/350', 'approved', faculty_1);

  -- Priya Patel's coding activities
  INSERT INTO public.coding_activities (user_id, platform, type, title, value, proof_url, status, approved_by)
  VALUES 
    (student_2, 'leetcode', 'milestone', 'Solved 350+ LeetCode problems', 350, 'https://leetcode.com/priya', 'approved', faculty_2),
    (student_2, 'codeforces', 'contest', 'Codeforces Round #1820', 1400, 'https://codeforces.com/contest/1820', 'approved', faculty_2),
    (student_2, 'hackerrank', 'milestone', '5-star HackerRank profile', 5, 'https://hackerrank.com/priya', 'approved', faculty_2);

  -- Amit Kumar's pending coding activities
  INSERT INTO public.coding_activities (user_id, platform, type, title, value, proof_url, status)
  VALUES 
    (student_3, 'leetcode', 'milestone', 'Solved 100+ LeetCode problems', 100, 'https://leetcode.com/amit', 'pending'),
    (student_3, 'codeforces', 'contest', 'Codeforces Round #1750', 950, 'https://codeforces.com/contest/1750', 'pending');

  -- ============================================================
  -- CALCULATE SCORES FOR ALL STUDENTS
  -- ============================================================
  PERFORM calculate_score(student_1);
  PERFORM calculate_score(student_2);
  PERFORM calculate_score(student_3);

  -- ============================================================
  -- ADD NOTIFICATIONS
  -- ============================================================
  INSERT INTO public.notifications (user_id, title, message)
  VALUES 
    (student_1, 'Welcome to MyCSIT!', 'Your account has been activated. Start logging your activities now!'),
    (student_2, 'Activity Approved', 'Your AWS certification has been approved.'),
    (student_3, 'Account Pending', 'Your account is pending faculty approval.'),
    (student_1, 'New Activity Approved', 'Your Smart India Hackathon participation has been approved!'),
    (student_2, 'Score Updated', 'Your total score has been updated based on recent activities.');

END $$;

-- ============================================================
-- VERIFICATION QUERIES
-- ============================================================
SELECT 'Seed data insertion completed!' as status;

-- Check users
SELECT 'Users created:' as info, COUNT(*) as count FROM public.users;

-- Check scores
SELECT 'Scores calculated:' as info, COUNT(*) as count FROM public.score_cache WHERE total_score > 0;

-- Show top scores
SELECT u.name, u.roll_number, sc.total_score, sc.hackathon_score, sc.project_score, sc.academic_score, sc.coding_score
FROM public.users u
JOIN public.score_cache sc ON u.id = sc.user_id
WHERE u.role = 'student' AND u.status = 'active'
ORDER BY sc.total_score DESC;

-- Show pending activities for faculty approval
SELECT u.name as student_name, a.title, a.type, a.status
FROM public.activities a
JOIN public.users u ON a.user_id = u.id
WHERE a.status = 'pending'
ORDER BY a.created_at DESC;
