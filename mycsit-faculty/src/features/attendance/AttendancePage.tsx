import { useState, useEffect, useCallback } from 'react';
import { Check, Save } from 'lucide-react';
import { supabase } from '../../lib/supabase';
import { getStudentSemesters, upsertSemester } from '../../lib/firestore';
import { useAuthStore } from '../../stores/authStore';
import type { SemesterData } from '../../types';

interface AttendanceRow {
  uid: string;
  name: string;
  rollNumber: string;
  year: number;
  section: string;
  latestSemId: string | null;
  total: number;
  attended: number;
  dirty: boolean;
  saved: boolean;
}

export function AttendancePage() {
  const [rows, setRows] = useState<AttendanceRow[]>([]);
  const [loading, setLoading] = useState(false);
  const [yearFilter, setYearFilter] = useState('');
  const [sectionFilter, setSectionFilter] = useState('');
  const [bulkTotal, setBulkTotal] = useState('');
  const { facultyId } = useAuthStore();

  const loadData = useCallback(async () => {
    setLoading(true);

    let dbQuery = supabase
      .from('users')
      .select('id, name, roll_number, year, section')
      .eq('role', 'student')
      .eq('status', 'active')
      .order('name');
    if (yearFilter) dbQuery = dbQuery.eq('year', parseInt(yearFilter));
    if (sectionFilter) dbQuery = dbQuery.eq('section', sectionFilter);

    const { data: users } = await dbQuery;
    const students = (users ?? []).map((d) => ({
      uid: d.id,
      name: String(d.name ?? ''),
      rollNumber: String(d.roll_number ?? ''),
      year: Number(d.year ?? 0),
      section: String(d.section ?? ''),
    }));

    // Load latest semester attendance for each student in parallel
    const rowsWithAtt = await Promise.all(
      students.map(async (s) => {
        const sems: SemesterData[] = await getStudentSemesters(s.uid);
        const latest =
          sems.length > 0
            ? sems.reduce((a, b) => {
                const aMs = a.updatedAt instanceof Date ? a.updatedAt.getTime() : 0;
                const bMs = b.updatedAt instanceof Date ? b.updatedAt.getTime() : 0;
                return aMs >= bMs ? a : b;
              })
            : null;

        return {
          ...s,
          latestSemId: latest?.semId ?? null,
          total: latest?.attendance?.total ?? 0,
          attended: latest?.attendance?.attended ?? 0,
          dirty: false,
          saved: false,
        } as AttendanceRow;
      })
    );

    setRows(rowsWithAtt);
    setLoading(false);
  }, [yearFilter, sectionFilter]);

  useEffect(() => {
    loadData();
  }, [loadData]);

  const updateRow = (uid: string, field: 'total' | 'attended', value: number) => {
    setRows((prev) =>
      prev.map((r) =>
        r.uid === uid ? { ...r, [field]: Math.max(0, value), dirty: true, saved: false } : r
      )
    );
  };

  const saveRow = async (row: AttendanceRow) => {
    // Save attendance into the latest semester, creating sem1 if none exists
    const semId = row.latestSemId ?? 'sem1';
    try {
      await upsertSemester(row.uid, semId, {
        attendance: { total: row.total, attended: row.attended },
        updatedBy: facultyId,
      });
      setRows((prev) =>
        prev.map((r) =>
          r.uid === row.uid
            ? { ...r, dirty: false, saved: true, latestSemId: semId }
            : r
        )
      );
      setTimeout(() => {
        setRows((prev) =>
          prev.map((r) => (r.uid === row.uid ? { ...r, saved: false } : r))
        );
      }, 2000);
    } catch (err) {
      console.error('Failed to save attendance:', err);
    }
  };

  const applyBulkTotal = () => {
    const val = parseInt(bulkTotal);
    if (isNaN(val) || val <= 0) return;
    setRows((prev) => prev.map((r) => ({ ...r, total: val, dirty: true })));
    setBulkTotal('');
  };

  const getAttPillStyle = (pct: number) => {
    if (pct < 75) return 'text-error bg-red-50';
    if (pct < 85) return 'text-warning bg-yellow-50';
    return 'text-success bg-green-50';
  };

  return (
    <div className="space-y-5">
      {/* Filters + bulk action */}
      <div className="card flex items-center gap-4 flex-wrap">
        <div className="flex gap-3">
          <select
            value={yearFilter}
            onChange={(e) => setYearFilter(e.target.value)}
            className="input !py-2 !px-3 text-sm w-32"
          >
            <option value="">All Years</option>
            {[1, 2, 3, 4].map((y) => (
              <option key={y} value={y}>
                Year {y}
              </option>
            ))}
          </select>
          <select
            value={sectionFilter}
            onChange={(e) => setSectionFilter(e.target.value)}
            className="input !py-2 !px-3 text-sm w-36"
          >
            <option value="">All Sections</option>
            {['A', 'B', 'C'].map((s) => (
              <option key={s} value={s}>
                Section {s}
              </option>
            ))}
          </select>
        </div>

        <div className="flex items-center gap-2 ml-auto">
          <span className="text-sm font-body text-text-secondary whitespace-nowrap">
            Set Total Classes for All:
          </span>
          <input
            type="number"
            value={bulkTotal}
            onChange={(e) => setBulkTotal(e.target.value)}
            placeholder="e.g. 120"
            className="input !py-2 !px-3 text-sm w-24"
          />
          <button onClick={applyBulkTotal} className="btn-primary !py-2 !px-4 text-sm">
            Apply
          </button>
        </div>
      </div>

      {loading ? (
        <div className="flex items-center justify-center h-40">
          <div className="w-8 h-8 border-4 border-primary border-t-transparent rounded-full animate-spin" />
        </div>
      ) : rows.length === 0 ? (
        <div className="card text-center py-12">
          <p className="font-body text-text-muted">
            No students found for the selected filters.
          </p>
        </div>
      ) : (
        <div className="card !p-0 overflow-hidden">
          <table className="w-full text-sm">
            <thead>
              <tr className="bg-background">
                {['Roll No', 'Name', 'Year / Sec', 'Total Classes', 'Attended', 'Attendance %', ''].map(
                  (h) => (
                    <th
                      key={h}
                      className="text-left px-4 py-3 text-text-muted font-body font-medium text-xs"
                    >
                      {h}
                    </th>
                  )
                )}
              </tr>
            </thead>
            <tbody>
              {rows.map((row) => {
                const pct = row.total > 0 ? (row.attended / row.total) * 100 : 0;
                return (
                  <tr key={row.uid} className="border-t border-border hover:bg-background/50">
                    <td className="px-4 py-3 text-text-secondary font-body text-xs">
                      {row.rollNumber}
                    </td>
                    <td className="px-4 py-3 font-body font-medium text-text-primary">
                      {row.name}
                    </td>
                    <td className="px-4 py-3 text-text-secondary font-body text-xs">
                      Y{row.year} / {row.section}
                    </td>
                    <td className="px-4 py-3">
                      <input
                        type="number"
                        value={row.total}
                        onChange={(e) => updateRow(row.uid, 'total', +e.target.value)}
                        min={0}
                        className="input !py-1.5 !px-2 text-sm w-20"
                      />
                    </td>
                    <td className="px-4 py-3">
                      <input
                        type="number"
                        value={row.attended}
                        onChange={(e) => updateRow(row.uid, 'attended', +e.target.value)}
                        min={0}
                        max={row.total}
                        className="input !py-1.5 !px-2 text-sm w-20"
                      />
                    </td>
                    <td className="px-4 py-3">
                      {row.total > 0 ? (
                        <span className={`badge ${getAttPillStyle(pct)}`}>
                          {pct.toFixed(1)}%
                        </span>
                      ) : (
                        <span className="text-text-muted font-body text-xs">—</span>
                      )}
                    </td>
                    <td className="px-4 py-3">
                      <button
                        onClick={() => saveRow(row)}
                        disabled={!row.dirty}
                        title={row.dirty ? 'Save changes' : 'No changes'}
                        className={`p-1.5 rounded-lg transition-colors ${
                          row.saved
                            ? 'bg-green-50 text-success'
                            : row.dirty
                            ? 'bg-primary-light text-primary hover:bg-primary hover:text-white'
                            : 'bg-background text-text-muted cursor-not-allowed'
                        }`}
                      >
                        {row.saved ? <Check size={14} /> : <Save size={14} />}
                      </button>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
