# Database Setup (Supabase - Currently Paused)

## ⚠️ Important Notice

**Supabase project is currently paused** due to cost/usage considerations. The app is currently running with a mock authentication system and local data storage.

## Current Status

- **Backend**: Supabase (PostgreSQL) - **PAUSED**
- **Authentication**: Mock authentication system (active)
- **Data Storage**: Local mock data services (active)

## Remaining SQL Files

The following SQL files are kept for reference when Supabase is resumed:

### Setup Files
- `setup_supabase.sql` - Main Supabase setup script
- `COMPLETE_SETUP.sql` - Complete database setup with all tables
- `CLEAN_SETUP.sql` - Clean setup without seed data
- `SIMPLE_SETUP.sql` - Simplified setup for quick deployment
- `NEW_PROJECT_SETUP.sql` - Setup for new Supabase project

### Table Creation
- `ENSURE_FLUTTER_TABLES.sql` - Ensure all Flutter-required tables exist
- `CREATE_AUTH_USERS.sql` - Create auth users table
- `CREATE_ADITYA_USER.sql` - Create test user (Aditya)

### Data Seeding
- `SEED_DATA.sql` - Seed data for testing
- `SEED_USERS_FIRST.sql` - Seed users first
- `seed_faculty.sql` - Seed faculty data

### RLS Policies
- `setup_rls_policies.sql` - Row Level Security policies
- `SETUP_ADMIN_APPROVAL.sql` - Admin approval workflow setup

### Registration
- `SIMPLE_REGISTRATION.sql` - Simple registration flow
- `NO_MOCK_DATA_SETUP.sql` - Setup without mock data
- `EXTENDED_SETUP.sql` - Extended setup with additional features

## Database Schema

### Tables (when Supabase is resumed)

1. **auth_users** - Authentication data
   - id (UUID, primary key)
   - email (text, unique)
   - password_hash (text)
   - created_at (timestamp)
   - updated_at (timestamp)

2. **users** - User profiles
   - id (UUID, primary key)
   - auth_user_id (UUID, foreign key)
   - name (text)
   - email (text)
   - roll_number (text, unique)
   - year (integer)
   - section (text)
   - status (text)
   - created_at (timestamp)
   - updated_at (timestamp)

3. **activities** - Activity records
   - id (UUID, primary key)
   - user_id (UUID, foreign key)
   - title (text)
   - description (text)
   - type (text)
   - points (integer)
   - date (date)
   - status (text)
   - created_at (timestamp)
   - updated_at (timestamp)

4. **coding_activities** - Coding problem submissions
   - id (UUID, primary key)
   - user_id (UUID, foreign key)
   - platform (text)
   - problem_id (text)
   - problem_title (text)
   - difficulty (text)
   - solved_at (timestamp)
   - points (integer)
   - created_at (timestamp)

5. **academic_records** - Academic performance
   - id (UUID, primary key)
   - user_id (UUID, foreign key)
   - subject (text)
   - grade (text)
   - credits (integer)
   - semester (integer)
   - cgpa (numeric)
   - attendance (numeric)
   - created_at (timestamp)
   - updated_at (timestamp)

6. **faculty** - Faculty information
   - id (UUID, primary key)
   - name (text)
   - email (text, unique)
   - department (text)
   - is_admin (boolean)
   - created_at (timestamp)

## Row Level Security (RLS)

### Policies
- Users can only read/write their own data
- Faculty can read all user data
- Admin can modify all data
- Public can only read approved activities

## To Resume Supabase Integration

1. **Resume Supabase Project**
   - Log in to Supabase dashboard
   - Resume the paused project
   - Verify database connection

2. **Run Setup Script**
   ```bash
   # Use the appropriate setup script
   psql -h [supabase-host] -U postgres -d postgres -f setup_supabase.sql
   ```

3. **Configure Environment Variables**
   ```dart
   // Update lib/services/auth_service.dart
   const supabaseUrl = 'YOUR_SUPABASE_URL';
   const supabaseKey = 'YOUR_SUPABASE_ANON_KEY';
   ```

4. **Update Authentication Service**
   - Switch from MockAuthService to SupabaseAuthService
   - Update providers to use Supabase

5. **Migrate Local Data**
   - Export local mock data
   - Import to Supabase database
   - Verify data integrity

6. **Test Integration**
   - Test authentication flow
   - Test data fetching
   - Test data submission
   - Verify RLS policies

## Current Mock System

The app currently uses:
- `MockAuthService` - Mock authentication
- `MockDataService` - Mock data provider
- `PremiumMockDataService` - Premium UI mock data

These are located in `lib/services/` and will be replaced with Supabase services when resumed.

## Contact

For questions about Supabase integration or database setup, refer to the main project documentation in `PROJECT_CONTEXT.md`.

---

**Last Updated**: May 2026
**Status**: Supabase Project Paused
