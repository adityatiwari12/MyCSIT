import { useEffect, useState, useMemo } from 'react';
import { Trophy, Medal, Search, Download } from 'lucide-react';
import { getAllStudentsWithScores } from '../../lib/firestore';
import type { Student } from '../../types';

type SortKey = 'rank' | 'name' | 'roll' | 'total' | 'hackathon' | 'project' | 'coding' | 'academic' | 'cgpa';
type SortDir = 'asc' | 'desc';

export function LeaderboardPage() {
  const [students, setStudents] = useState<Student[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [yearFilter, setYearFilter] = useState<number | null>(null);
  const [sectionFilter, setSectionFilter] = useState<string | null>(null);
  const [sortKey, setSortKey] = useState<SortKey>('total');
  const [sortDir, setSortDir] = useState<SortDir>('desc');

  useEffect(() => {
    getAllStudentsWithScores()
      .then(setStudents)
      .finally(() => setLoading(false));
  }, []);

  const years = useMemo(
    () => [...new Set(students.map((s) => s.year))].sort(),
    [students]
  );
  const sections = useMemo(
    () => [...new Set(students.map((s) => s.section))].sort(),
    [students]
  );

  const ranked = useMemo(() => {
    const base = [...students].sort(
      (a, b) => (b.totalScore ?? 0) - (a.totalScore ?? 0)
    );
    return base.map((s, i) => ({ ...s, rank: i + 1 }));
  }, [students]);

  const filtered = useMemo(() => {
    let list = ranked;
    if (yearFilter !== null) list = list.filter((s) => s.year === yearFilter);
    if (sectionFilter !== null) list = list.filter((s) => s.section === sectionFilter);
    if (search.trim()) {
      const q = search.toLowerCase();
      list = list.filter(
        (s) =>
          s.name.toLowerCase().includes(q) ||
          s.rollNumber.toLowerCase().includes(q)
      );
    }
    return [...list].sort((a, b) => {
      let va: number | string = 0;
      let vb: number | string = 0;
      switch (sortKey) {
        case 'rank':
          va = a.rank;
          vb = b.rank;
          break;
        case 'name':
          va = a.name;
          vb = b.name;
          break;
        case 'roll':
          va = a.rollNumber;
          vb = b.rollNumber;
          break;
        case 'total':
          va = a.totalScore ?? 0;
          vb = b.totalScore ?? 0;
          break;
        case 'hackathon':
          va = a.activityScore ?? 0;
          vb = b.activityScore ?? 0;
          break;
        case 'project':
          va = 0;
          vb = 0;
          break;
        case 'coding':
          va = a.codingScore ?? 0;
          vb = b.codingScore ?? 0;
          break;
        case 'academic':
          va = a.academicScore ?? 0;
          vb = b.academicScore ?? 0;
          break;
        case 'cgpa':
          va = a.cgpa ?? 0;
          vb = b.cgpa ?? 0;
          break;
      }
      if (typeof va === 'string') {
        return sortDir === 'asc'
          ? va.localeCompare(vb as string)
          : (vb as string).localeCompare(va);
      }
      return sortDir === 'asc'
        ? (va as number) - (vb as number)
        : (vb as number) - (va as number);
    });
  }, [ranked, yearFilter, sectionFilter, search, sortKey, sortDir]);

  function toggleSort(key: SortKey) {
    if (sortKey === key) {
      setSortDir((d) => (d === 'asc' ? 'desc' : 'asc'));
    } else {
      setSortKey(key);
      setSortDir('desc');
    }
  }

  function exportCsv() {
    const header = 'Rank,Name,Roll,Year,Section,Total,Hackathon,Academic,Coding,CGPA';
    const rows = filtered.map(
      (s) =>
        `${s.rank},"${s.name}",${s.rollNumber},${s.year},${s.section},${s.totalScore?.toFixed(1) ?? ''},${s.activityScore?.toFixed(1) ?? ''},${s.academicScore?.toFixed(1) ?? ''},${s.codingScore?.toFixed(1) ?? ''},${s.cgpa ?? ''}`
    );
    const csv = [header, ...rows].join('\n');
    const blob = new Blob([csv], { type: 'text/csv' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'leaderboard.csv';
    a.click();
    URL.revokeObjectURL(url);
  }

  const rankIcon = (rank: number) => {
    if (rank === 1) return <Trophy size={16} className="text-yellow-500" />;
    if (rank === 2) return <Medal size={16} className="text-gray-400" />;
    if (rank === 3) return <Medal size={16} className="text-amber-600" />;
    return null;
  };

  const th = (key: SortKey, label: string, align = 'left') => (
    <th
      key={key}
      onClick={() => toggleSort(key)}
      className={`px-3 py-3 text-xs font-semibold text-text-muted cursor-pointer select-none hover:text-text-primary transition-colors text-${align}`}
    >
      {label}
      {sortKey === key && (
        <span className="ml-1 opacity-70">{sortDir === 'asc' ? '↑' : '↓'}</span>
      )}
    </th>
  );

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-display font-bold text-text-primary flex items-center gap-2">
            <Trophy size={24} className="text-yellow-500" />
            Leaderboard
          </h1>
          <p className="text-sm text-text-muted mt-1">
            Ranked by total score across all buckets
          </p>
        </div>
        <button
          onClick={exportCsv}
          className="btn-outline flex items-center gap-2 text-sm"
          disabled={loading || filtered.length === 0}
        >
          <Download size={14} />
          Export CSV
        </button>
      </div>

      {/* Filters */}
      <div className="card p-4 flex flex-wrap gap-3 items-center">
        <div className="relative flex-1 min-w-48">
          <Search
            size={14}
            className="absolute left-3 top-1/2 -translate-y-1/2 text-text-muted"
          />
          <input
            className="input pl-9 w-full h-9 text-sm"
            placeholder="Search by name or roll number…"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
        </div>
        <select
          className="input h-9 text-sm w-32"
          value={yearFilter ?? ''}
          onChange={(e) =>
            setYearFilter(e.target.value ? Number(e.target.value) : null)
          }
        >
          <option value="">All Years</option>
          {years.map((y) => (
            <option key={y} value={y}>
              Year {y}
            </option>
          ))}
        </select>
        <select
          className="input h-9 text-sm w-36"
          value={sectionFilter ?? ''}
          onChange={(e) => setSectionFilter(e.target.value || null)}
        >
          <option value="">All Sections</option>
          {sections.map((s) => (
            <option key={s} value={s}>
              Section {s}
            </option>
          ))}
        </select>
        <span className="text-sm text-text-muted ml-auto">
          {filtered.length} student{filtered.length !== 1 ? 's' : ''}
        </span>
      </div>

      {/* Table */}
      <div className="card overflow-hidden">
        {loading ? (
          <div className="flex items-center justify-center h-40">
            <div className="w-8 h-8 border-4 border-primary border-t-transparent rounded-full animate-spin" />
          </div>
        ) : filtered.length === 0 ? (
          <div className="flex flex-col items-center justify-center h-40 text-text-muted">
            <Trophy size={32} className="mb-2 opacity-30" />
            <p className="text-sm">No students found</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead className="border-b border-border">
                <tr>
                  {th('rank', '#', 'center')}
                  {th('name', 'Name')}
                  {th('roll', 'Roll No.')}
                  <th className="px-3 py-3 text-xs font-semibold text-text-muted text-left">
                    Yr/Sec
                  </th>
                  {th('total', 'Total ↕', 'right')}
                  {th('hackathon', 'Hackathon', 'right')}
                  {th('academic', 'Academic', 'right')}
                  {th('coding', 'Coding', 'right')}
                  {th('cgpa', 'CGPA', 'right')}
                </tr>
              </thead>
              <tbody className="divide-y divide-border">
                {filtered.map((s) => {
                  const isPodium = s.rank <= 3;
                  return (
                    <tr
                      key={s.uid}
                      className={`transition-colors ${
                        isPodium
                          ? 'bg-yellow-50/50 dark:bg-yellow-900/5'
                          : 'hover:bg-surface/50'
                      }`}
                    >
                      <td className="px-3 py-3 text-center">
                        <div className="flex items-center justify-center gap-1">
                          {rankIcon(s.rank)}
                          <span
                            className={`font-display font-bold ${
                              s.rank === 1
                                ? 'text-yellow-500'
                                : s.rank === 2
                                ? 'text-gray-400'
                                : s.rank === 3
                                ? 'text-amber-600'
                                : 'text-text-muted'
                            }`}
                          >
                            {s.rank}
                          </span>
                        </div>
                      </td>
                      <td className="px-3 py-3 font-medium text-text-primary">
                        {s.name}
                      </td>
                      <td className="px-3 py-3 text-text-secondary font-mono text-xs">
                        {s.rollNumber}
                      </td>
                      <td className="px-3 py-3 text-text-muted">
                        Y{s.year}/{s.section}
                      </td>
                      <td className="px-3 py-3 text-right font-display font-bold text-primary">
                        {s.totalScore?.toFixed(1) ?? '—'}
                      </td>
                      <td className="px-3 py-3 text-right text-text-secondary">
                        {s.activityScore?.toFixed(1) ?? '—'}
                      </td>
                      <td className="px-3 py-3 text-right text-text-secondary">
                        {s.academicScore?.toFixed(1) ?? '—'}
                      </td>
                      <td className="px-3 py-3 text-right text-text-secondary">
                        {s.codingScore?.toFixed(1) ?? '—'}
                      </td>
                      <td className="px-3 py-3 text-right text-text-secondary">
                        {s.cgpa?.toFixed(2) ?? '—'}
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
}
