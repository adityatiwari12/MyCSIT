import { create } from 'zustand';
import { supabase } from '../lib/supabase';
import type { User, Session } from '@supabase/supabase-js';

interface AuthStore {
  user: User | null;
  session: Session | null;
  facultyName: string;
  facultyId: string;
  isLoading: boolean;
  error: string | null;
  signIn: (email: string, password: string) => Promise<void>;
  signOut: () => Promise<void>;
  init: () => () => void;
}

export const useAuthStore = create<AuthStore>((set) => ({
  user: null,
  session: null,
  facultyName: '',
  facultyId: '',
  isLoading: true,
  error: null,

  init: () => {
    // Restore session on mount
    supabase.auth.getSession().then(async ({ data: { session } }) => {
      if (session?.user) {
        await resolveProfile(session.user, set);
      } else {
        set({ isLoading: false });
      }
    });

    // Listen for auth changes
    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      async (_event, session) => {
        if (session?.user) {
          await resolveProfile(session.user, set);
        } else {
          set({ user: null, session: null, facultyName: '', facultyId: '', isLoading: false });
        }
      }
    );

    return () => subscription.unsubscribe();
  },

  signIn: async (email, password) => {
    set({ isLoading: true, error: null });
    try {
      const { data, error } = await supabase.auth.signInWithPassword({
        email,
        password,
      });
      if (error) throw error;

      if (data.user) {
        // Verify the user is a faculty member
        const { data: profile, error: profileError } = await supabase
          .from('users')
          .select('name, role')
          .eq('id', data.user.id)
          .single();

        if (profileError || !profile) {
          await supabase.auth.signOut();
          throw new Error('Account not found in the system.');
        }

        if (profile.role !== 'faculty') {
          await supabase.auth.signOut();
          throw new Error('This account does not have faculty access.');
        }

        set({
          user: data.user,
          session: data.session,
          facultyName: profile.name as string,
          facultyId: data.user.id,
          isLoading: false,
          error: null,
        });
      }
    } catch (err) {
      const message = err instanceof Error ? err.message : 'Sign in failed.';
      set({ user: null, isLoading: false, error: message });
      throw err;
    }
  },

  signOut: async () => {
    await supabase.auth.signOut();
    set({ user: null, session: null, facultyName: '', facultyId: '', error: null });
  },
}));

async function resolveProfile(
  user: User,
  set: (partial: Partial<AuthStore>) => void
) {
  try {
    const { data } = await supabase
      .from('users')
      .select('name, role')
      .eq('id', user.id)
      .single();

    if (data && (data as { role: string }).role === 'faculty') {
      set({
        user,
        facultyName: (data as { name: string }).name,
        facultyId: user.id,
        isLoading: false,
        error: null,
      });
    } else {
      // Not a faculty account — sign out silently
      await supabase.auth.signOut();
      set({ user: null, isLoading: false });
    }
  } catch {
    set({ user: null, isLoading: false });
  }
}
