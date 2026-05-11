# Fix 500 Error - Dashboard Loading Users

## Problem
The React dashboard is trying to query `users` table with `status=eq.pending` but getting 500 error.

This happens because:
1. No user is logged in (RLS blocks access)
2. Or logged-in user doesn't have faculty role

## Solutions

### Solution 1: Login First
Make sure you login before accessing the dashboard:
1. Go to http://localhost:3001
2. Login with your auth user credentials
3. Then the queries will work

### Solution 2: Check Where Query is Made
Find the component making this query and add auth check:

```typescript
// In your component that queries users
const { user, isLoading } = useAuthStore();

// Only query when user is logged in
useEffect(() => {
  if (user && !isLoading) {
    // Make the query here
    loadPendingUsers();
  }
}, [user, isLoading]);
```

### Solution 3: Temporarily Disable RLS (DEV ONLY)
⚠️ **Security Risk - Only for development**

```sql
-- Run this in SQL Editor (temporary fix)
ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;
```

**Re-enable after testing:**
```sql
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
```

### Solution 4: Create Proper Faculty User
1. Create auth user in Supabase: `faculty@mycsit.edu` / `Faculty123!`
2. Get the UUID: `SELECT id FROM auth.users WHERE email = 'faculty@mycsit.edu';`
3. Update user role: 
```sql
UPDATE public.users 
SET role = 'faculty', status = 'active', name = 'Test Faculty', roll_number = 'FAC001', year = 1, section = 'A'
WHERE id = 'FACULTY_UUID_HERE';
```
4. Login with faculty credentials
5. Dashboard will work properly

## Recommended Approach

**For now, use Solution 4:**
1. Create a faculty user in Supabase Dashboard
2. Set their role to 'faculty' 
3. Login with that user
4. Everything will work properly

The 500 error is RLS protection working - it won't let anyone view user data without proper authentication and faculty role!
