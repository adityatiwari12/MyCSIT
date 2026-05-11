# Add Existing User to Supabase Guide

## Quick Method: Direct SQL Insert

### 1. Go to Supabase Dashboard
- Visit: https://app.supabase.com/project/znhipxtgjileabyrooxf
- Click **SQL Editor** (left sidebar)

### 2. Create User with SQL

#### For Student User:
```sql
-- Step 1: Create auth user (replace with your details)
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
  gen_random_uuid(),  -- Auto-generate UUID
  'student@example.com',  -- Replace with email
  crypt('password123', gen_salt('bf')),  -- Replace with password
  NOW(),
  NOW(),
  NOW(),
  NOW(),
  '{"name": "John Doe", "role": "student"}'
);

-- Step 2: Create user record (get the ID from step 1)
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
  'UUID_FROM_STEP_1',  -- Replace with actual UUID from auth.users
  'John Doe',
  'CSIT2024001',
  3,
  'A',
  'student',
  'active',  -- Set to 'active' to skip approval
  NOW(),
  NOW()
);
```

#### For Faculty User:
```sql
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
  'faculty@example.com',  -- Replace with email
  crypt('password123', gen_salt('bf')),  -- Replace with password
  NOW(),
  NOW(),
  NOW(),
  NOW(),
  '{"name": "Dr. Smith", "role": "faculty"}'
);

-- Step 2: Create user record
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
  'UUID_FROM_STEP_1',  -- Replace with actual UUID
  'Dr. Smith',
  'FAC001',
  NULL,  -- Faculty doesn't need year
  NULL,  -- Faculty doesn't need section
  'faculty',
  'active',
  NOW(),
  NOW()
);
```

---

## Alternative Method: Use Flutter App Registration

### 1. Register via App
1. Run the Flutter APK on device/emulator
2. Click **Register**
3. Fill in details
4. Submit

### 2. Approve in Faculty Dashboard
1. Go to: http://localhost:3001
2. Login as faculty
3. Go to **Approvals** tab
4. Find pending registration
5. Click **Approve**

---

## Method 3: Direct Auth API (Advanced)

### Using Supabase Auth API
```bash
curl -X POST 'https://znhipxtgjileabyrooxf.supabase.co/auth/v1/signup' \
  -H 'apikey: your-anon-key' \
  -H 'Content-Type: application/json' \
  -d '{
    "email": "user@example.com",
    "password": "password123",
    "data": {
      "name": "User Name"
    }
  }'
```

Then manually update status in database:
```sql
UPDATE public.users 
SET status = 'active' 
WHERE email = 'user@example.com';
```

---

## Quick Test User Setup

### Pre-configured Test Users (Ready to Use)

Copy and paste these SQL commands in Supabase SQL Editor:

```sql
-- Test Student 1
INSERT INTO auth.users (id, email, encrypted_password, email_confirmed_at, created_at, updated_at, last_sign_in_at, raw_user_meta_data)
VALUES ('550e8400-e29b-41d4-a716-446655440001', 'student1@test.com', crypt('test123', gen_salt('bf')), NOW(), NOW(), NOW(), NOW(), '{"name": "Test Student 1"}');

INSERT INTO public.users (id, name, roll_number, year, section, role, status, created_at, updated_at)
VALUES ('550e8400-e29b-41d4-a716-446655440001', 'Test Student 1', 'CSIT2024001', 3, 'A', 'student', 'active', NOW(), NOW());

-- Test Faculty
INSERT INTO auth.users (id, email, encrypted_password, email_confirmed_at, created_at, updated_at, last_sign_in_at, raw_user_meta_data)
VALUES ('550e8400-e29b-41d4-a716-446655440002', 'faculty@test.com', crypt('test123', gen_salt('bf')), NOW(), NOW(), NOW(), NOW(), '{"name": "Test Faculty"}');

INSERT INTO public.users (id, name, roll_number, year, section, role, status, created_at, updated_at)
VALUES ('550e8400-e29b-41d4-a716-446655440002', 'Test Faculty', 'FAC001', NULL, NULL, 'faculty', 'active', NOW(), NOW());
```

### Login Credentials:
- **Student**: `student1@test.com` / `test123`
- **Faculty**: `faculty@test.com` / `test123`

---

## Important Notes

### Password Hashing
- Uses PostgreSQL `crypt()` function with Blowfish
- Passwords are securely hashed
- Never store plain text passwords

### User Status
- `pending`: Needs faculty approval
- `active`: Can login immediately
- `rejected`: Cannot login

### Required Fields
- **Students**: roll_number, year, section (1-4), section (A/B/C)
- **Faculty**: roll_number can be faculty ID, year/section can be NULL

### Auto-creation
When you insert into `auth.users`, triggers automatically create:
- `user_profiles` record
- `score_cache` record

---

## Verification

After creating users:

1. **Test Login**: Try logging into the Flutter app
2. **Check Faculty Dashboard**: Verify users appear in student list
3. **Test Registration**: New registrations should still work

---

## Troubleshooting

### User Not Found
- Check if UUID matches between `auth.users` and `public.users`
- Verify email_confirmed_at is not NULL

### Login Failed
- Ensure password is correctly hashed
- Check user status is 'active'
- Verify email exists in both tables

### Faculty Access Issues
- Ensure role = 'faculty' in both tables
- Check faculty has proper permissions

---

## Best Practice

For production, create a **user management function** or **admin panel** instead of direct SQL for better security and audit trail.
