-- ============================================================
-- MyCSIT — Seed Faculty Account
-- Run AFTER creating the faculty user in Supabase Auth Dashboard
-- Replace the UUID below with the actual auth user UUID
-- ============================================================

-- Step 1: Create faculty auth user via Supabase Dashboard:
--   Authentication > Users > Add User
--   Email: faculty@aitr.ac.in
--   Password: (set a strong password)
--   Copy the UUID shown

-- Step 2: Run this SQL replacing 'FACULTY_AUTH_UUID' with actual UUID:

-- INSERT INTO public.users (id, name, roll_number, year, section, role, status)
-- VALUES (
--   'FACULTY_AUTH_UUID',
--   'Dr. Faculty Name',
--   'FACULTY001',
--   1,
--   'A',
--   'faculty',
--   'active'
-- );

-- ============================================================
-- Realtime subscriptions — enable for live updates
-- ============================================================
ALTER PUBLICATION supabase_realtime ADD TABLE public.users;
ALTER PUBLICATION supabase_realtime ADD TABLE public.activities;
ALTER PUBLICATION supabase_realtime ADD TABLE public.coding_activities;
ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;
ALTER PUBLICATION supabase_realtime ADD TABLE public.score_cache;
