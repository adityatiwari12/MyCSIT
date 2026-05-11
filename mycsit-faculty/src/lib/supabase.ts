import { createClient } from '@supabase/supabase-js';

// Replace with your actual Supabase project credentials
// Dashboard → Settings → API
const SUPABASE_URL = import.meta.env.VITE_SUPABASE_URL ?? 'YOUR_SUPABASE_URL';
const SUPABASE_ANON_KEY = import.meta.env.VITE_SUPABASE_ANON_KEY ?? 'YOUR_SUPABASE_ANON_KEY';

export const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
  auth: {
    persistSession: true,
    autoRefreshToken: true,
  },
  realtime: {
    params: {
      eventsPerSecond: 10,
    },
  },
});

export type Database = {
  public: {
    Tables: {
      users: {
        Row: {
          id: string;
          name: string;
          roll_number: string;
          year: number;
          section: string;
          role: 'student' | 'faculty';
          status: 'pending' | 'active' | 'rejected';
          fcm_token: string | null;
          created_at: string;
          updated_at: string;
        };
      };
      user_profiles: {
        Row: {
          user_id: string;
          bio: string | null;
          profile_photo_url: string | null;
          linkedin_url: string | null;
          github_url: string | null;
          portfolio_url: string | null;
          leetcode_url: string | null;
          codeforces_url: string | null;
          codechef_url: string | null;
          profile_completeness: number;
          updated_at: string;
        };
      };
      score_cache: {
        Row: {
          user_id: string;
          total_score: number;
          hackathon_score: number;
          project_score: number;
          academic_score: number;
          coding_score: number;
          last_computed: string;
        };
      };
      activities: {
        Row: {
          id: string;
          user_id: string;
          type: string;
          title: string;
          description: string;
          date: string;
          proof_url: string;
          status: 'pending' | 'approved' | 'rejected';
          rejection_reason: string | null;
          approved_by: string | null;
          is_deleted: boolean;
          created_at: string;
          updated_at: string;
        };
      };
      coding_activities: {
        Row: {
          id: string;
          user_id: string;
          platform: string;
          type: string;
          title: string;
          value: number | null;
          contest_name: string | null;
          difficulty: string | null;
          proof_url: string;
          status: 'pending' | 'approved' | 'rejected';
          rejection_reason: string | null;
          approved_by: string | null;
          is_deleted: boolean;
          created_at: string;
        };
      };
      semesters: {
        Row: {
          id: string;
          user_id: string;
          sem_number: number;
          cgpa: number | null;
          updated_by: string | null;
          updated_at: string;
        };
      };
      subjects: {
        Row: {
          id: string;
          semester_id: string;
          name: string;
          marks: number;
          max_marks: number;
        };
      };
      attendance: {
        Row: {
          id: string;
          user_id: string;
          semester_id: string | null;
          total_classes: number;
          attended: number;
          updated_by: string | null;
          updated_at: string;
        };
      };
    };
  };
};
