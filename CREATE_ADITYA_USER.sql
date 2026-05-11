-- Create Aditya User Account
-- Run this in Supabase SQL Editor

-- Step 1: Create auth user
INSERT INTO auth.users (
  id,
  email,
  encrypted_password,
  email_confirmed_at,
  created_at,
  updated_at,
  last_sign_in_at,
  raw_user_meta_data
) VALUES (
  gen_random_uuid(),
  'aditya@mycsit.com',
  crypt('aditya123', gen_salt('bf')),
  NOW(),
  NOW(),
  NOW(),
  NOW(),
  '{"name": "Aditya", "role": "student"}'
);

-- Step 2: Get the UUID from the user you just created and create the user record
-- Replace 'UUID_FROM_STEP_1' with the actual UUID returned from the first query

INSERT INTO public.users (
  id,
  name,
  roll_number,
  year,
  section,
  role,
  status,
  created_at,
  updated_at
) VALUES (
  'UUID_FROM_STEP_1',  -- <-- IMPORTANT: Replace this with the actual UUID from step 1
  'Aditya',
  'CSIT2024002',
  3,
  'A',
  'student',
  'active',  -- Set to active so Aditya can login immediately
  NOW(),
  NOW()
);

-- Step 3: Verify the user was created
SELECT 
  u.id,
  u.email,
  u.name,
  u.roll_number,
  u.year,
  u.section,
  u.status
FROM public.users u 
WHERE u.email = 'aditya@mycsit.com';
