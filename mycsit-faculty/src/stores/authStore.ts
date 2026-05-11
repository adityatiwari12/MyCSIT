import { create } from 'zustand';

// Hardcoded faculty credentials
const HARDCODED_EMAIL = 'csitfaculty@acropolis.in';
const HARDCODED_PASSWORD = '123456';

interface AuthStore {
  user: { id: string; email: string } | null;
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
  facultyName: '',
  facultyId: '',
  isLoading: false,
  error: null,

  init: () => {
    // Auto-login on app start if needed, or just set loading to false
    set({ isLoading: false });
    return () => {};
  },

  signIn: async (email, password) => {
    set({ isLoading: true, error: null });
    
    // Simulate network delay
    await new Promise(resolve => setTimeout(resolve, 500));
    
    // Check hardcoded credentials
    if (email === HARDCODED_EMAIL && password === HARDCODED_PASSWORD) {
      set({
        user: { id: 'faculty-user-id', email: HARDCODED_EMAIL },
        facultyName: 'Faculty User',
        facultyId: 'faculty-user-id',
        isLoading: false,
        error: null,
      });
    } else {
      set({
        user: null,
        error: 'Incorrect email or password.',
        isLoading: false,
      });
    }
  },

  signOut: async () => {
    set({ 
      user: null, 
      facultyName: '',
      facultyId: '',
      isLoading: false,
      error: null,
    });
  },
}));
