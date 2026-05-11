import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuthStore } from '../../stores/authStore';

export function LoginPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const { signIn, isLoading, error } = useAuthStore();
  const navigate = useNavigate();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    await signIn(email, password);
    if (!useAuthStore.getState().error) {
      navigate('/dashboard');
    }
  };

  return (
    <div className="min-h-screen bg-background flex items-center justify-center p-4">
      <div className="w-full max-w-md">
        {/* Logo */}
        <div className="text-center mb-8">
          <h1 className="font-display font-bold text-3xl">
            <span className="text-primary">My</span>
            <span className="text-text-primary">CSIT</span>
          </h1>
          <p className="text-text-muted text-sm mt-1 font-body">Faculty Portal</p>
        </div>

        <div className="card">
          <h2 className="font-display font-bold text-2xl text-text-primary mb-1">
            Welcome Back 👋
          </h2>
          <p className="text-text-muted text-sm font-body mb-6">
            Sign in to your faculty account
          </p>

          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label className="block text-sm font-body font-medium text-text-secondary mb-1.5">
                Email Address
              </label>
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="input"
                placeholder="faculty@aitr.ac.in"
                required
              />
            </div>

            <div>
              <label className="block text-sm font-body font-medium text-text-secondary mb-1.5">
                Password
              </label>
              <input
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="input"
                placeholder="••••••••"
                required
              />
            </div>

            {error && (
              <div className="bg-red-50 border border-red-200 rounded-xl p-3 text-sm text-error font-body">
                {error}
              </div>
            )}

            <button
              type="submit"
              disabled={isLoading}
              className="btn-primary w-full mt-2"
            >
              {isLoading ? 'Signing in...' : 'Sign In'}
            </button>
          </form>
        </div>

        <p className="text-center text-xs text-text-muted mt-6 font-body">
          Faculty accounts are managed by the system administrator.
        </p>
      </div>
    </div>
  );
}
