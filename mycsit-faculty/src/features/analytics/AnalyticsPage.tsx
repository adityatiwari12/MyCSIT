import { useEffect, useState } from 'react';
import {
  BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer,
  PieChart, Pie, Cell, Legend,
} from 'recharts';
import { Users, TrendingUp, BookOpen, Activity } from 'lucide-react';
import { supabase } from '../../lib/supabase';
import { getActiveStudents } from '../../lib/firestore';
import type { Student, CodingPlatform } from '../../types';

const CHART_COLORS = ['#FF6B35', '#FF9F1C', '#3B82F6', '#22C55E'];

const PLATFORM_LABELS: Record<CodingPlatform, string> = {
  leetcode: 'LeetCode',
  codeforces: 'Codeforces',
  codechef: 'CodeChef',
  other: 'Other',
};

export function AnalyticsPage() {
  const [students, setStudents] = useState<Student[]>([]);
  const [platformData, setPlatformData] = useState<{ name: string; value: number }[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    Promise.all([
      getActiveStudents(),
      fetchCodingPlatformDistribution(),
    ]).then(([activeStudents, platforms]) => {
      setStudents(activeStudents);
      setPlatformData(platforms);
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

  // ── Computed stats ──────────────────────────────────────────────────────────

  const avgCgpa =
    students.length > 0
      ? students.reduce((s, st) => s + (st.cgpa ?? 0), 0) / students.length
      : 0;

  const avgScore =
    students.length > 0
      ? students.reduce((s, st) => s + (st.totalScore ?? 0), 0) / students.length
      : 0;

  const withActivities = students.filter((s) => (s.activityCount ?? 0) > 0).length;
  const participationRate =
    students.length > 0 ? (withActivities / students.length) * 100 : 0;

  const cgpaBuckets = buildCgpaBuckets(students);
  const scoreBuckets = buildScoreBuckets(students);

  const top10 = [...students]
    .sort((a, b) => (b.totalScore ?? 0) - (a.totalScore ?? 0))
    .slice(0, 10)
    .map((s) => ({ name: s.name.split(' ')[0], score: +(s.totalScore ?? 0).toFixed(1) }));

  const atRisk = students.filter((s) => (s.activityCount ?? 0) === 0);

  const yearDistribution = [1, 2, 3, 4].map((y) => ({
    name: `Year ${y}`,
    count: students.filter((s) => s.year === y).length,
  }));

  const statCards = [
    { label: 'Total Active Students', value: students.length, icon: Users, color: 'text-primary', bg: 'bg-primary-light' },
    { label: 'Average CGPA', value: avgCgpa.toFixed(2), icon: BookOpen, color: 'text-blue-500', bg: 'bg-blue-50' },
    { label: 'Average Score', value: avgScore.toFixed(1), icon: TrendingUp, color: 'text-success', bg: 'bg-green-50' },
    { label: 'Activity Participation', value: `${participationRate.toFixed(0)}%`, icon: Activity, color: 'text-amber-500', bg: 'bg-yellow-50' },
  ];

  return (
    <div className="space-y-6">
      {/* Stat cards */}
      <div className="grid grid-cols-4 gap-4">
        {statCards.map(({ label, value, icon: Icon, color, bg }) => (
          <div key={label} className="card flex items-center gap-4">
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
        {/* CGPA Distribution */}
        <div className="card">
          <h3 className="font-display font-semibold text-base text-text-primary mb-4">
            CGPA Distribution
          </h3>
          <ResponsiveContainer width="100%" height={220}>
            <BarChart data={cgpaBuckets}>
              <CartesianGrid strokeDasharray="3 3" stroke="#F3F3F3" />
              <XAxis dataKey="range" tick={{ fontSize: 12 }} />
              <YAxis tick={{ fontSize: 12 }} allowDecimals={false} />
              <Tooltip contentStyle={{ borderRadius: 12, border: 'none' }} />
              <Bar dataKey="count" fill="#3B82F6" radius={[6, 6, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </div>

        {/* Score Distribution */}
        <div className="card">
          <h3 className="font-display font-semibold text-base text-text-primary mb-4">
            Score Distribution
          </h3>
          <ResponsiveContainer width="100%" height={220}>
            <BarChart data={scoreBuckets}>
              <CartesianGrid strokeDasharray="3 3" stroke="#F3F3F3" />
              <XAxis dataKey="range" tick={{ fontSize: 12 }} />
              <YAxis tick={{ fontSize: 12 }} allowDecimals={false} />
              <Tooltip contentStyle={{ borderRadius: 12, border: 'none' }} />
              <Bar dataKey="count" fill="#FF6B35" radius={[6, 6, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </div>
      </div>

      <div className="grid grid-cols-2 gap-6">
        {/* Coding platform distribution */}
        <div className="card">
          <h3 className="font-display font-semibold text-base text-text-primary mb-4">
            Coding Platform Activity
          </h3>
          {platformData.length > 0 ? (
            <ResponsiveContainer width="100%" height={220}>
              <PieChart>
                <Pie
                  data={platformData}
                  cx="50%"
                  cy="50%"
                  innerRadius={60}
                  outerRadius={90}
                  paddingAngle={4}
                  dataKey="value"
                >
                  {platformData.map((_, index) => (
                    <Cell key={index} fill={CHART_COLORS[index % CHART_COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip contentStyle={{ borderRadius: 12, border: 'none' }} />
                <Legend
                  iconType="circle"
                  iconSize={8}
                  formatter={(value) => (
                    <span className="text-xs font-body text-text-secondary">{value}</span>
                  )}
                />
              </PieChart>
            </ResponsiveContainer>
          ) : (
            <div className="flex items-center justify-center h-[220px]">
              <p className="text-text-muted font-body text-sm">No coding data yet.</p>
            </div>
          )}
        </div>

        {/* Year distribution */}
        <div className="card">
          <h3 className="font-display font-semibold text-base text-text-primary mb-4">
            Students by Year
          </h3>
          <ResponsiveContainer width="100%" height={220}>
            <BarChart data={yearDistribution}>
              <CartesianGrid strokeDasharray="3 3" stroke="#F3F3F3" />
              <XAxis dataKey="name" tick={{ fontSize: 12 }} />
              <YAxis tick={{ fontSize: 12 }} allowDecimals={false} />
              <Tooltip contentStyle={{ borderRadius: 12, border: 'none' }} />
              <Bar dataKey="count" fill="#22C55E" radius={[6, 6, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </div>
      </div>

      {/* Top 10 Leaderboard */}
      {top10.length > 0 && (
        <div className="card">
          <h3 className="font-display font-semibold text-base text-text-primary mb-4">
            Top 10 Students by Score
          </h3>
          <ResponsiveContainer width="100%" height={280}>
            <BarChart data={top10} layout="vertical">
              <defs>
                <linearGradient id="scoreGradient" x1="0" y1="0" x2="1" y2="0">
                  <stop offset="0%" stopColor="#FF6B35" />
                  <stop offset="100%" stopColor="#FF9F1C" />
                </linearGradient>
              </defs>
              <CartesianGrid strokeDasharray="3 3" stroke="#F3F3F3" horizontal={false} />
              <XAxis type="number" domain={[0, 100]} tick={{ fontSize: 12 }} />
              <YAxis type="category" dataKey="name" tick={{ fontSize: 12 }} width={80} />
              <Tooltip contentStyle={{ borderRadius: 12, border: 'none' }} />
              <Bar dataKey="score" fill="url(#scoreGradient)" radius={[0, 6, 6, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </div>
      )}

      {/* At-risk table */}
      {atRisk.length > 0 && (
        <div className="card">
          <div className="flex items-center gap-2 mb-4">
            <div className="w-2 h-2 rounded-full bg-error" />
            <h3 className="font-display font-semibold text-base text-text-primary">
              Students with 0 Approved Activities
            </h3>
            <span className="badge badge-rejected ml-auto">{atRisk.length} students</span>
          </div>
          <table className="w-full text-sm">
            <thead>
              <tr className="bg-background">
                {['Name', 'Roll No', 'Year', 'Section', 'Total Score'].map((h) => (
                  <th
                    key={h}
                    className="text-left px-4 py-3 text-text-muted font-body font-medium text-xs"
                  >
                    {h}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {atRisk.map((s) => (
                <tr key={s.uid} className="border-t border-border hover:bg-background/50">
                  <td className="px-4 py-3 font-body font-medium text-text-primary">{s.name}</td>
                  <td className="px-4 py-3 text-text-secondary font-body">{s.rollNumber}</td>
                  <td className="px-4 py-3 text-text-secondary font-body">Year {s.year}</td>
                  <td className="px-4 py-3 text-text-secondary font-body">{s.section}</td>
                  <td className="px-4 py-3 text-text-secondary font-body">
                    {(s.totalScore ?? 0).toFixed(1)}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

async function fetchCodingPlatformDistribution(): Promise<
  { name: string; value: number }[]
> {
  const { data } = await supabase
    .from('coding_activities')
    .select('platform')
    .eq('status', 'approved')
    .eq('is_deleted', false);

  const counts: Partial<Record<CodingPlatform, number>> = {};
  for (const row of data ?? []) {
    const platform = row.platform as CodingPlatform;
    counts[platform] = (counts[platform] ?? 0) + 1;
  }

  return (Object.entries(counts) as [CodingPlatform, number][])
    .filter(([, v]) => v > 0)
    .map(([platform, value]) => ({
      name: PLATFORM_LABELS[platform] ?? platform,
      value,
    }))
    .sort((a, b) => b.value - a.value);
}

function buildCgpaBuckets(students: Student[]) {
  const buckets = [
    { range: '0–4', count: 0 },
    { range: '4–5', count: 0 },
    { range: '5–6', count: 0 },
    { range: '6–7', count: 0 },
    { range: '7–8', count: 0 },
    { range: '8–9', count: 0 },
    { range: '9–10', count: 0 },
  ];
  for (const s of students) {
    const cgpa = s.cgpa ?? 0;
    if (cgpa < 4) buckets[0].count++;
    else if (cgpa < 5) buckets[1].count++;
    else if (cgpa < 6) buckets[2].count++;
    else if (cgpa < 7) buckets[3].count++;
    else if (cgpa < 8) buckets[4].count++;
    else if (cgpa < 9) buckets[5].count++;
    else buckets[6].count++;
  }
  return buckets;
}

function buildScoreBuckets(students: Student[]) {
  const buckets = [
    { range: '0–20', count: 0 },
    { range: '20–40', count: 0 },
    { range: '40–60', count: 0 },
    { range: '60–80', count: 0 },
    { range: '80–100', count: 0 },
  ];
  for (const s of students) {
    const score = s.totalScore ?? 0;
    if (score < 20) buckets[0].count++;
    else if (score < 40) buckets[1].count++;
    else if (score < 60) buckets[2].count++;
    else if (score < 80) buckets[3].count++;
    else buckets[4].count++;
  }
  return buckets;
}
