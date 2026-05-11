import { NavLink, useNavigate } from 'react-router-dom';
import {
  LayoutDashboard,
  Users,
  ClipboardCheck,
  BookOpen,
  CalendarCheck,
  BarChart2,
  LogOut,
} from 'lucide-react';
import { useAuthStore } from '../../stores/authStore';
import { usePendingCount } from '../../hooks/usePendingCount';

const navItems = [
  { to: '/dashboard', icon: LayoutDashboard, label: 'Dashboard', exact: true },
  { to: '/dashboard/students', icon: Users, label: 'Students' },
  { to: '/dashboard/approvals', icon: ClipboardCheck, label: 'Approvals', badge: true },
  { to: '/dashboard/marks', icon: BookOpen, label: 'Marks' },
  { to: '/dashboard/attendance', icon: CalendarCheck, label: 'Attendance' },
  { to: '/dashboard/analytics', icon: BarChart2, label: 'Analytics' },
];

export function Sidebar() {
  const { facultyName, signOut } = useAuthStore();
  const pendingCount = usePendingCount();
  const navigate = useNavigate();

  const initials = facultyName
    .split(' ')
    .map((n) => n[0])
    .join('')
    .toUpperCase()
    .slice(0, 2);

  return (
    <aside className="fixed left-0 top-0 h-screen w-60 bg-surface border-r border-border flex flex-col z-20">
      {/* Logo */}
      <div className="px-6 py-5 border-b border-border">
        <span className="font-display font-bold text-[22px]">
          <span className="text-primary">My</span>
          <span className="text-text-primary">CSIT</span>
        </span>
        <p className="text-xs text-text-muted font-body mt-0.5">Faculty Dashboard</p>
      </div>

      {/* Nav */}
      <nav className="flex-1 px-3 py-4 space-y-1 overflow-y-auto">
        {navItems.map(({ to, icon: Icon, label, badge, exact }) => (
          <NavLink
            key={to}
            to={to}
            end={exact}
            className={({ isActive }) =>
              isActive ? 'nav-item-active' : 'nav-item'
            }
          >
            <Icon size={18} />
            <span className="flex-1">{label}</span>
            {badge && pendingCount > 0 && (
              <span className="bg-error text-white text-[10px] font-display font-bold w-5 h-5 rounded-full flex items-center justify-center">
                {pendingCount > 99 ? '99+' : pendingCount}
              </span>
            )}
          </NavLink>
        ))}
      </nav>

      {/* Faculty info */}
      <div className="px-4 py-4 border-t border-border flex items-center gap-3">
        <div className="w-9 h-9 rounded-full bg-primary-light flex items-center justify-center">
          <span className="text-primary font-display font-bold text-sm">{initials}</span>
        </div>
        <div className="flex-1 min-w-0">
          <p className="text-sm font-body font-medium text-text-primary truncate">
            {facultyName}
          </p>
          <p className="text-xs text-text-muted">Faculty</p>
        </div>
        <button
          onClick={async () => {
            await signOut();
            navigate('/login');
          }}
          className="text-text-muted hover:text-error transition-colors"
          title="Logout"
        >
          <LogOut size={16} />
        </button>
      </div>
    </aside>
  );
}
