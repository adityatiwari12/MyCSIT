-- ============================================================
-- MyCSIT — Update Faculty User with Real Auth UUID
-- ============================================================

-- Update the faculty user record with the real Supabase Auth UUID
UPDATE public.users 
SET 
    id = '2f4548e0-c2da-4779-9047-b0ddc3bbdaf3',
    name = 'Faculty User',
    roll_number = 'FAC001',
    role = 'faculty',
    status = 'active'
WHERE id = '00000000-0000-0000-0000-000000000001';

-- Update related records with the new UUID
UPDATE public.user_profiles 
SET user_id = '2f4548e0-c2da-4779-9047-b0ddc3bbdaf3'
WHERE user_id = '00000000-0000-0000-0000-000000000001';

UPDATE public.activities 
SET approved_by = '2f4548e0-c2da-4779-9047-b0ddc3bbdaf3'
WHERE approved_by = '00000000-0000-0000-0000-000000000001';

UPDATE public.coding_activities 
SET approved_by = '2f4548e0-c2da-4779-9047-b0ddc3bbdaf3'
WHERE approved_by = '00000000-0000-0000-0000-000000000001';

UPDATE public.notifications 
SET user_id = '2f4548e0-c2da-4779-9047-b0ddc3bbdaf3'
WHERE user_id = '00000000-0000-0000-0000-000000000001';

-- Verification
SELECT 'Faculty user updated with real UUID!' as status;
SELECT * FROM public.users WHERE id = '2f4548e0-c2da-4779-9047-b0ddc3bbdaf3';
