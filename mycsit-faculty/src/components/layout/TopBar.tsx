import { Bell, Search } from 'lucide-react';
import { useLocation } from 'react-router-dom';

const pageTitles: Record<string, string> = {
  '/dashboard': 'Dashboard',
  '/dashboard/students': 'Student Directory',
  '/dashboard/approvals': 'Approval Queue',
  '/dashboard/marks': 'Marks Management',
  '/dashboard/attendance': 'Attendance',
  '/dashboard/analytics': 'Analytics',
};

interface TopBarProps {
  onSearch?: (q: string) => void;
}

export function TopBar({ onSearch }: TopBarProps) {
  const location = useLocation();
  const title = pageTitles[location.pathname] ?? 'MyCSIT';

  return (
    <header className="h-16 bg-surface border-b border-border flex items-center px-6 gap-4 sticky top-0 z-10">
      <h1 className="font-display font-semibold text-xl text-text-primary flex-1">
        {title}
      </h1>

      {/* Search */}
      <div className="relative">
        <Search
          size={16}
          className="absolute left-3 top-1/2 -translate-y-1/2 text-text-muted"
        />
        <input
          type="text"
          placeholder="Search students..."
          onChange={(e) => onSearch?.(e.target.value)}
          className="pl-9 pr-4 py-2 text-sm border border-border rounded-xl bg-background
                     focus:outline-none focus:border-primary focus:ring-2 focus:ring-primary/20
                     w-56 transition-all"
        />
      </div>

      {/* Bell */}
      <button className="relative p-2 rounded-xl hover:bg-background transition-colors">
        <Bell size={20} className="text-text-secondary" />
      </button>
    </header>
  );
}
