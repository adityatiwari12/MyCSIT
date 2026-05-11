import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Users, ClipboardCheck, BookOpen, TrendingUp } from 'lucide-react';
import {
  BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer,
  PieChart, Pie, Cell,
} from 'recharts';
import { getActiveStudents, getPendingStudents, getPendingActivities } from '../../lib/firestore';
import type { Student } from '../../types';

export function DashboardOverview() {
  const [students, setStudents] = useState<Student[]>([]);
  const [pendingCount, setPendingCount] = useState(0);
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();

  useEffect(() => {
    Promise.all([
      getActiveStudents(),
      getPendingStudents(),
      getPendingActivities(),
    ]).then(([active, pending, activities]) => {
      setStudents(active);
      setPendingCount(pending.length + activities.length);
      setLoading(false);
    }).catch((error) => {
      console.error('Dashboard data loading error:', error);
      setStudents([]);
      setPendingCount(0);
      setLoading(false);
    });
  }, []);

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="w-8 h-8 border-4 border-primary border-t-transparent rounded-full animate-spin" />
      </div>
    );
  }

  const avgCgpa =
    students.length > 0
      ? students.reduce((s, st) => s + (st.cgpa ?? 0), 0) / students.length
      : 0;
  const avgScore =
    students.length > 0
      ? students.reduce((s, st) => s + (st.totalScore ?? 0), 0) / students.length
      : 0;

  const statCards = [
    { label: 'Active Students', value: students.length, icon: Users, color: 'text-primary', bg: 'bg-primary-light', link: '/dashboard/students' },
    { label: 'Pending Approvals', value: pendingCount, icon: ClipboardCheck, color: 'text-error', bg: 'bg-red-50', link: '/dashboard/approvals' },
    { label: 'Average CGPA', value: avgCgpa.toFixed(1), icon: BookOpen, color: 'text-blue-500', bg: 'bg-blue-50', link: null },
    { label: 'Avg Score', value: avgScore.toFixed(1), icon: TrendingUp, color: 'text-success', bg: 'bg-green-50', link: null },
  ];

  // Score distribution
  const scoreBuckets = [
    { range: '0–20', count: 0 },
    { range: '20–40', count: 0 },
    { range: '40–60', count: 0 },
    { range: '60–80', count: 0 },
    { range: '80–100', count: 0 },
  ];
  students.forEach((s) => {
    const score = s.totalScore ?? 0;
    if (score < 20) scoreBuckets[0].count++;
    else if (score < 40) scoreBuckets[1].count++;
    else if (score < 60) scoreBuckets[2].count++;
    else if (score < 80) scoreBuckets[3].count++;
    else scoreBuckets[4].count++;
  });

  const activityPie = [
    { name: 'With Activities', value: students.filter((s) => (s.activityCount ?? 0) > 0).length },
    { name: 'No Activities', value: students.filter((s) => (s.activityCount ?? 0) === 0).length },
  ];

  const atRisk = students.filter((s) => (s.activityCount ?? 0) === 0).slice(0, 5);

  return (
    <div className="space-y-6">
      {/* Stat cards */}
      <div className="grid grid-cols-4 gap-4">
        {statCards.map(({ label, value, icon: Icon, color, bg, link }) => (
          <div
            key={label}
            onClick={() => link && navigate(link)}
            className={`card flex items-center gap-4 ${link ? 'cursor-pointer hover:shadow-elevated transition-shadow' : ''}`}
          >
            <div className={`w-12 h-12 rounded-xl ${bg} flex items-center justify-center`}>
              <Icon size={22} className={color} />
            </div>
            <div>
              <p className="font-display font-bold text-2xl text-text-primary">{value}</p>
              <p className="text-xs text-text-muted font-body">{label}</p>
            </div>
          </div>
        ))}
      </div>

      <div className="grid grid-cols-2 gap-6">
        {/* Score distribution */}
        <div className="card">
          <h3 className="font-display font-semibold text-base text-text-primary mb-4">
            Score Distribution
          </h3>
          <ResponsiveContainer width="100%" height={200}>
            <BarChart data={scoreBuckets}>
              <CartesianGrid strokeDasharray="3 3" stroke="#F3F3F3" />
              <XAxis dataKey="range" tick={{ fontSize: 11 }} />
              <YAxis tick={{ fontSize: 11 }} />
              <Tooltip contentStyle={{ borderRadius: 12, border: 'none' }} />
              <Bar dataKey="count" fill="#FF6B35" radius={[6, 6, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </div>

        {/* Activity participation */}
        <div className="card">
          <h3 className="font-display font-semibold text-base text-text-primary mb-4">
            Activity Participation
          </h3>
          <ResponsiveContainer width="100%" height={200}>
            <PieChart>
              <Pie data={activityPie} cx="50%" cy="50%" innerRadius={55} outerRadius={80} paddingAngle={4} dataKey="value">
                <Cell fill="#FF6B35" />
                <Cell fill="#EEEEEE" />
              </Pie>
              <Tooltip contentStyle={{ borderRadius: 12, border: 'none' }} />
            </PieChart>
          </ResponsiveContainer>
          <div className="flex justify-center gap-4 mt-2">
            {activityPie.map((p, i) => (
              <div key={p.name} className="flex items-center gap-1.5">
                <div className={`w-2.5 h-2.5 rounded-full ${i === 0 ? 'bg-primary' : 'bg-border'}`} />
                <span className="text-xs font-body text-text-secondary">{p.name} ({p.value})</span>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* At-risk students */}
      {atRisk.length > 0 && (
        <div className="card">
          <div className="flex items-center justify-between mb-4">
            <div className="flex items-center gap-2">
              <div className="w-2 h-2 rounded-full bg-error" />
              <h3 className="font-display font-semibold text-base text-text-primary">
                Students with 0 Activities
              </h3>
            </div>
            <button
              onClick={() => navigate('/dashboard/analytics')}
              className="text-sm text-primary font-body hover:underline"
            >
              View All →
            </button>
          </div>
          <div className="space-y-2">
            {atRisk.map((s) => (
              <div
                key={s.uid}
                onClick={() => navigate(`/dashboard/students/${s.uid}`)}
                className="flex items-center gap-3 p-3 rounded-xl hover:bg-background cursor-pointer transition-colors"
              >
                <div className="w-8 h-8 rounded-full bg-primary-light flex items-center justify-center">
                  <span className="text-primary font-display font-bold text-xs">
                    {s.name.split(' ').map((n) => n[0]).join('').slice(0, 2).toUpperCase()}
                  </span>
                </div>
                <div className="flex-1">
                  <p className="text-sm font-body font-medium text-text-primary">{s.name}</p>
                  <p className="text-xs text-text-muted font-body">{s.rollNumber} · Year {s.year}</p>
                </div>
                <span className="text-xs font-body text-text-muted">
                  Score: {(s.totalScore ?? 0).toFixed(1)}
                </span>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
