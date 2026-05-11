-- ============================================================
-- MyCSIT — Setup Admin Approval System for User Registrations
-- ============================================================

-- Create admin role (if not exists)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'admin_role') THEN
        CREATE TYPE admin_role AS ENUM ('admin', 'super_admin');
    END IF;
END $$;

-- Add admin role to users table if not exists
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'users' AND column_name = 'admin_role') THEN
        ALTER TABLE public.users ADD COLUMN admin_role admin_role;
    END IF;
END $$;

-- STEP 1: Create admin user in Supabase Auth Dashboard FIRST:
-- Go to Authentication → Users → Add User
-- Email: admin@mycsit.edu
-- Password: Admin123!
-- Copy the UUID and replace ADMIN_AUTH_UUID below

-- STEP 2: Update this placeholder UUID with the real admin auth UUID
-- Replace 'ADMIN_AUTH_UUID' with the actual UUID from Supabase Auth

-- Create admin user record (uncomment and update UUID after creating auth user)
/*
INSERT INTO public.users (id, name, roll_number, year, section, role, status, admin_role)
VALUES 
  ('ADMIN_AUTH_UUID', 'System Administrator', 'ADMIN001', 1, 'A', 'faculty', 'active', 'admin')
ON CONFLICT (id) DO NOTHING;

-- Create admin profile
INSERT INTO public.user_profiles (user_id, bio, profile_completeness)
VALUES 
  ('ADMIN_AUTH_UUID', 'System Administrator - Manages user approvals and system settings', 100)
ON CONFLICT (user_id) DO NOTHING;
*/

-- Create function to send approval notification
-- Note: Update ADMIN_AUTH_UUID with real admin UUID after creating auth user
CREATE OR REPLACE FUNCTION notify_admin_of_registration(
    p_user_id UUID,
    p_user_name TEXT,
    p_roll_number TEXT
)
RETURNS VOID AS $$
DECLARE
    admin_id UUID := 'ADMIN_AUTH_UUID'; -- Replace with actual admin UUID
BEGIN
    INSERT INTO public.notifications (user_id, title, message)
    VALUES 
      (admin_id, 
       'New User Registration Pending Approval',
       format('User %s (%s) has registered and is waiting for approval.', p_user_name, p_roll_number));
END;
$$ LANGUAGE plpgsql;

-- Create trigger for new user registrations
CREATE OR REPLACE FUNCTION trigger_user_registration_notification()
RETURNS TRIGGER AS $$
BEGIN
    -- Only notify for student registrations (not faculty or admin)
    IF NEW.role = 'student' AND NEW.status = 'pending' THEN
        PERFORM notify_admin_of_registration(NEW.id, NEW.name, NEW.roll_number);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop trigger if exists
DROP TRIGGER IF EXISTS on_user_registration ON public.users;

-- Create trigger
CREATE TRIGGER on_user_registration
    AFTER INSERT ON public.users
    FOR EACH ROW
    EXECUTE FUNCTION trigger_user_registration_notification();

-- Create admin approval function
CREATE OR REPLACE FUNCTION approve_user_registration(
    p_user_id UUID,
    p_admin_id UUID
)
RETURNS BOOLEAN AS $$
BEGIN
    UPDATE public.users 
    SET status = 'active', updated_at = NOW()
    WHERE id = p_user_id AND status = 'pending';
    
    IF FOUND THEN
        -- Send notification to user
        INSERT INTO public.notifications (user_id, title, message)
        VALUES 
          (p_user_id, 'Account Approved', 'Your registration has been approved! You can now access the system.');
        
        -- Send confirmation to admin
        INSERT INTO public.notifications (user_id, title, message)
        VALUES 
          (p_admin_id, 'User Approved', format('User registration for %s has been approved.', p_user_id));
        
        RETURN TRUE;
    END IF;
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

-- Create rejection function
CREATE OR REPLACE FUNCTION reject_user_registration(
    p_user_id UUID,
    p_admin_id UUID,
    p_reason TEXT DEFAULT 'Registration rejected by administrator'
)
RETURNS BOOLEAN AS $$
BEGIN
    UPDATE public.users 
    SET status = 'rejected', updated_at = NOW()
    WHERE id = p_user_id AND status = 'pending';
    
    IF FOUND THEN
        -- Send notification to user
        INSERT INTO public.notifications (user_id, title, message)
        VALUES 
          (p_user_id, 'Account Rejected', p_reason);
        
        -- Send confirmation to admin
        INSERT INTO public.notifications (user_id, title, message)
        VALUES 
          (p_admin_id, 'User Rejected', format('User registration for %s has been rejected.', p_user_id));
        
        RETURN TRUE;
    END IF;
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

-- Verification
SELECT 'Admin approval system setup completed!' as status;
SELECT 'Admin user created (create auth user: admin@mycsit.edu / Admin123!)' as admin_info;
SELECT * FROM public.users WHERE admin_role IS NOT NULL;
