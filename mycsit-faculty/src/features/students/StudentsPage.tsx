import { useEffect, useState, useMemo } from 'react';
import { useNavigate } from 'react-router-dom';
import { Eye, Download, ChevronUp, ChevronDown } from 'lucide-react';
import { getActiveStudents } from '../../lib/firestore';
import type { Student, FilterState } from '../../types';

const DEFAULT_FILTERS: FilterState = {
  years: [],
  sections: [],
  cgpaMin: 0,
  cgpaMax: 10,
  scoreMin: 0,
  scoreMax: 100,
  hasActivities: null,
  hasCodingEntries: null,
};

type SortKey = 'name' | 'totalScore' | 'cgpa' | 'year';
type SortDir = 'asc' | 'desc';

export function StudentsPage() {
  const [students, setStudents] = useState<Student[]>([]);
  const [loading, setLoading] = useState(true);
  const [filters, setFilters] = useState<FilterState>(DEFAULT_FILTERS);
  const [search, setSearch] = useState('');
  const [sortKey, setSortKey] = useState<SortKey>('totalScore');
  const [sortDir, setSortDir] = useState<SortDir>('desc');
  const [page, setPage] = useState(0);
  const PAGE_SIZE = 20;
  const navigate = useNavigate();

  useEffect(() => {
    getActiveStudents().then((s) => {
      setStudents(s);
      setLoading(false);
    });
  }, []);

  const filtered = useMemo(() => {
    let result = students.filter((s) => {
      if (search) {
        const q = search.toLowerCase();
        if (!s.name.toLowerCase().includes(q) && !s.rollNumber.toLowerCase().includes(q))
          return false;
      }
      if (filters.years.length && !filters.years.includes(s.year)) return false;
      if (filters.sections.length && !filters.sections.includes(s.section)) return false;
      if ((s.cgpa ?? 0) < filters.cgpaMin || (s.cgpa ?? 0) > filters.cgpaMax) return false;
      if ((s.totalScore ?? 0) < filters.scoreMin || (s.totalScore ?? 0) > filters.scoreMax)
        return false;
      return true;
    });

    result.sort((a, b) => {
      let av = 0, bv = 0;
      if (sortKey === 'name') {
        return sortDir === 'asc'
          ? a.name.localeCompare(b.name)
          : b.name.localeCompare(a.name);
      }
      if (sortKey === 'totalScore') { av = a.totalScore ?? 0; bv = b.totalScore ?? 0; }
      if (sortKey === 'cgpa') { av = a.cgpa ?? 0; bv = b.cgpa ?? 0; }
      if (sortKey === 'year') { av = a.year; bv = b.year; }
      return sortDir === 'asc' ? av - bv : bv - av;
    });

    return result;
  }, [students, filters, search, sortKey, sortDir]);

  const paginated = filtered.slice(page * PAGE_SIZE, (page + 1) * PAGE_SIZE);
  const totalPages = Math.ceil(filtered.length / PAGE_SIZE);

  const toggleSort = (key: SortKey) => {
    if (sortKey === key) setSortDir((d) => (d === 'asc' ? 'desc' : 'asc'));
    else { setSortKey(key); setSortDir('desc'); }
  };

  const exportCsv = () => {
    const rows = [
      ['Name', 'Roll Number', 'Year', 'Section', 'CGPA', 'Total Score'],
      ...filtered.map((s) => [
        s.name, s.rollNumber, s.year, s.section,
        s.cgpa ?? 0, s.totalScore ?? 0,
      ]),
    ];
    const csv = rows.map((r) => r.join(',')).join('\n');
    const blob = new Blob([csv], { type: 'text/csv' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'students.csv';
    a.click();
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="w-8 h-8 border-4 border-primary border-t-transparent rounded-full animate-spin" />
      </div>
    );
  }

  return (
    <div className="flex gap-6">
      {/* Filter Panel */}
      <aside className="w-64 flex-shrink-0">
        <div className="card space-y-5">
          <h3 className="font-display font-semibold text-sm text-text-primary">Filters</h3>

          {/* Year */}
          <div>
            <p className="text-xs font-body font-medium text-text-muted mb-2">Year</p>
            <div className="space-y-1.5">
              {[1, 2, 3, 4].map((y) => (
                <label key={y} className="flex items-center gap-2 cursor-pointer">
                  <input
                    type="checkbox"
                    checked={filters.years.includes(y)}
                    onChange={(e) =>
                      setFilters((f) => ({
                        ...f,
                        years: e.target.checked
                          ? [...f.years, y]
                          : f.years.filter((x) => x !== y),
                      }))
                    }
                    className="w-4 h-4 accent-primary"
                  />
                  <span className="text-sm font-body text-text-secondary">
                    {y === 1 ? '1st' : y === 2 ? '2nd' : y === 3 ? '3rd' : '4th'} Year
                  </span>
                </label>
              ))}
            </div>
          </div>

          {/* Section */}
          <div>
            <p className="text-xs font-body font-medium text-text-muted mb-2">Section</p>
            <div className="flex gap-2">
              {['A', 'B', 'C'].map((s) => (
                <button
                  key={s}
                  onClick={() =>
                    setFilters((f) => ({
                      ...f,
                      sections: f.sections.includes(s)
                        ? f.sections.filter((x) => x !== s)
                        : [...f.sections, s],
                    }))
                  }
                  className={`w-9 h-9 rounded-lg text-sm font-body font-medium transition-all ${
                    filters.sections.includes(s)
                      ? 'bg-primary text-white'
                      : 'bg-background text-text-secondary hover:bg-primary-light'
                  }`}
                >
                  {s}
                </button>
              ))}
            </div>
          </div>

          {/* CGPA Range */}
          <div>
            <p className="text-xs font-body font-medium text-text-muted mb-2">CGPA Range</p>
            <div className="flex gap-2">
              <input
                type="number"
                min={0} max={10} step={0.1}
                value={filters.cgpaMin}
                onChange={(e) =>
                  setFilters((f) => ({ ...f, cgpaMin: +e.target.value }))
                }
                className="input !py-2 !px-3 text-sm w-full"
                placeholder="Min"
              />
              <input
                type="number"
                min={0} max={10} step={0.1}
                value={filters.cgpaMax}
                onChange={(e) =>
                  setFilters((f) => ({ ...f, cgpaMax: +e.target.value }))
                }
                className="input !py-2 !px-3 text-sm w-full"
                placeholder="Max"
              />
            </div>
          </div>

          <button
            onClick={() => setFilters(DEFAULT_FILTERS)}
            className="text-sm text-primary font-body hover:underline"
          >
            Clear All
          </button>
        </div>
      </aside>

      {/* Table */}
      <div className="flex-1 min-w-0">
        {/* Action bar */}
        <div className="flex items-center justify-between mb-4">
          <p className="text-sm font-body text-text-secondary">
            <span className="font-semibold text-text-primary">{filtered.length}</span> students
          </p>
          <div className="flex gap-3">
            <input
              type="text"
              placeholder="Search by name or roll..."
              value={search}
              onChange={(e) => { setSearch(e.target.value); setPage(0); }}
              className="input !py-2 !px-3 text-sm w-56"
            />
            <button
              onClick={exportCsv}
              className="flex items-center gap-2 btn-outline !py-2 !px-4 text-sm"
            >
              <Download size={14} /> Export CSV
            </button>
          </div>
        </div>

        <div className="card !p-0 overflow-hidden">
          <table className="w-full text-sm">
            <thead>
              <tr className="bg-background">
                {[
                  { key: 'name', label: 'Name' },
                  { key: null, label: 'Roll Number' },
                  { key: 'year', label: 'Year / Section' },
                  { key: 'cgpa', label: 'CGPA' },
                  { key: 'totalScore', label: 'Score' },
                  { key: null, label: 'Actions' },
                ].map(({ key, label }) => (
                  <th
                    key={label}
                    onClick={() => key && toggleSort(key as SortKey)}
                    className={`text-left px-4 py-3 text-text-muted font-body font-medium text-xs
                                first:rounded-tl-card last:rounded-tr-card
                                ${key ? 'cursor-pointer hover:text-text-primary select-none' : ''}`}
                  >
                    <span className="flex items-center gap-1">
                      {label}
                      {key && sortKey === key && (
                        sortDir === 'asc' ? <ChevronUp size={12} /> : <ChevronDown size={12} />
                      )}
                    </span>
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {paginated.map((s) => (
                <tr
                  key={s.uid}
                  onClick={() => navigate(`/dashboard/students/${s.uid}`)}
                  className="border-t border-border hover:bg-[#FFF8F6] cursor-pointer transition-colors"
                >
                  <td className="px-4 py-3">
                    <div className="flex items-center gap-3">
                      <div className="w-8 h-8 rounded-full bg-primary-light flex items-center justify-center flex-shrink-0">
                        <span className="text-primary font-display font-bold text-xs">
                          {s.name.split(' ').map((n) => n[0]).join('').slice(0, 2).toUpperCase()}
                        </span>
                      </div>
                      <span className="font-body font-medium text-text-primary">{s.name}</span>
                    </div>
                  </td>
                  <td className="px-4 py-3 text-text-secondary font-body">{s.rollNumber}</td>
                  <td className="px-4 py-3 text-text-secondary font-body">
                    Year {s.year} · {s.section}
                  </td>
                  <td className="px-4 py-3 font-body font-medium text-text-primary">
                    {s.cgpa?.toFixed(1) ?? '—'}
                  </td>
                  <td className="px-4 py-3">
                    <div className="flex items-center gap-2">
                      <div className="flex-1 h-1.5 bg-border rounded-full overflow-hidden max-w-[80px]">
                        <div
                          className="h-full bg-primary rounded-full"
                          style={{ width: `${s.totalScore ?? 0}%` }}
                        />
                      </div>
                      <span className="text-text-primary font-body font-medium text-xs">
                        {(s.totalScore ?? 0).toFixed(1)}
                      </span>
                    </div>
                  </td>
                  <td className="px-4 py-3">
                    <button
                      onClick={(e) => {
                        e.stopPropagation();
                        navigate(`/dashboard/students/${s.uid}`);
                      }}
                      className="p-1.5 rounded-lg hover:bg-primary-light text-text-muted hover:text-primary transition-colors"
                    >
                      <Eye size={16} />
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>

          {/* Pagination */}
          {totalPages > 1 && (
            <div className="flex items-center justify-between px-4 py-3 border-t border-border">
              <p className="text-xs text-text-muted font-body">
                Page {page + 1} of {totalPages}
              </p>
              <div className="flex gap-2">
                <button
                  onClick={() => setPage((p) => Math.max(0, p - 1))}
                  disabled={page === 0}
                  className="px-3 py-1.5 text-xs font-body border border-border rounded-lg
                             disabled:opacity-40 hover:border-primary hover:text-primary transition-colors"
                >
                  Previous
                </button>
                <button
                  onClick={() => setPage((p) => Math.min(totalPages - 1, p + 1))}
                  disabled={page === totalPages - 1}
                  className="px-3 py-1.5 text-xs font-body border border-border rounded-lg
                             disabled:opacity-40 hover:border-primary hover:text-primary transition-colors"
                >
                  Next
                </button>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
