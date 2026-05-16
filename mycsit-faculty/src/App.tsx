import { useEffect } from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { useAuthStore } from './stores/authStore';
import { AppShell } from './components/layout/AppShell';
import { LoginPage } from './features/auth/LoginPage';
import { DashboardOverview } from './features/analytics/DashboardOverview';
import { StudentsPage } from './features/students/StudentsPage';
import { StudentDetailPage } from './features/students/StudentDetailPage';
import { ApprovalsPage } from './features/approvals/ApprovalsPage';
import { MarksPage } from './features/marks/MarksPage';
import { AttendancePage } from './features/attendance/AttendancePage';
import { AnalyticsPage } from './features/analytics/AnalyticsPage';
import { LeaderboardPage } from './features/leaderboard/LeaderboardPage';

function ProtectedRoute({ children }: { children: React.ReactNode }) {
  const { user, isLoading } = useAuthStore();
  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-background">
        <div className="w-10 h-10 border-4 border-primary border-t-transparent rounded-full animate-spin" />
      </div>
    );
  }
  if (!user) return <Navigate to="/login" replace />;
  return <>{children}</>;
}

export default function App() {
  const init = useAuthStore((s) => s.init);

  useEffect(() => {
    const unsub = init();
    return unsub;
  }, [init]);

  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={<LoginPage />} />
        <Route path="/" element={<Navigate to="/dashboard" replace />} />

        <Route
          path="/dashboard"
          element={
            <ProtectedRoute>
              <AppShell />
            </ProtectedRoute>
          }
        >
          <Route index element={<DashboardOverview />} />
          <Route path="students" element={<StudentsPage />} />
          <Route path="students/:id" element={<StudentDetailPage />} />
          <Route path="approvals" element={<ApprovalsPage />} />
          <Route path="marks" element={<MarksPage />} />
          <Route path="attendance" element={<AttendancePage />} />
          <Route path="analytics" element={<AnalyticsPage />} />
          <Route path="leaderboard" element={<LeaderboardPage />} />
        </Route>

        <Route path="*" element={<Navigate to="/dashboard" replace />} />
      </Routes>
    </BrowserRouter>
  );
}
