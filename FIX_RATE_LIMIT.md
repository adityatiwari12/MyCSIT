# Fix Email Rate Limit Error

## Problem
Registration fails with: "email rate limit exceeded (429)"

This happens because Supabase sends a confirmation email for each signup, and you've hit the rate limit.

## Solution: Disable Email Confirmation

### Step 1: Go to Supabase Dashboard
1. Open your Supabase project: https://supabase.com/dashboard/project/znhipxtgjileabyrooxf
2. Navigate to: **Authentication** → **Settings**
3. Scroll to: **Email Confirmation**

### Step 2: Disable Email Confirmation
1. Toggle OFF "Confirm email"
2. Click **Save**

### Step 3: Update Signup Settings
1. Still in Authentication → Settings
2. Scroll to: **Site URL**
3. Ensure it's set to your app's URL (or leave as default for development)

### Step 4: Test Registration
After disabling email confirmation:
- Users can register without email verification
- No rate limit errors
- Registration will work immediately

## Alternative: Use Different Email
If you can't disable email confirmation, use a different email address for testing.

## Rebuild APK
After making the Supabase setting change, rebuild the APK with the updated error handling.
