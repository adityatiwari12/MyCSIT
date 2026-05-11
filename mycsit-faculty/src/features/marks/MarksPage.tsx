import { useState, useEffect, useCallback } from 'react';
import { Save, Plus, Search } from 'lucide-react';
import { supabase } from '../../lib/supabase';
import { getStudentSemesters, upsertSemester } from '../../lib/firestore';
import { useAuthStore } from '../../stores/authStore';
import type { SemesterData } from '../../types';

interface StudentOption {
  uid: string;
  name: string;
  rollNumber: string;
  year: number;
  section: string;
}

interface SubjectRow {
  name: string;
  marks: number;
  maxMarks: number;
}

export function MarksPage() {
  const [searchQuery, setSearchQuery] = useState('');
  const [searchResults, setSearchResults] = useState<StudentOption[]>([]);
  const [selectedStudent, setSelectedStudent] = useState<StudentOption | null>(null);
  const [semesters, setSemesters] = useState<SemesterData[]>([]);
  const [activeSemId, setActiveSemId] = useState('');
  const [editSubjects, setEditSubjects] = useState<SubjectRow[]>([]);
  const [editCgpa, setEditCgpa] = useState('');
  const [saving, setSaving] = useState(false);
  const [saveMsg, setSaveMsg] = useState<{ text: string; ok: boolean } | null>(null);
  const { facultyId } = useAuthStore();

  // Debounced student search
  useEffect(() => {
    if (searchQuery.length < 2) {
      setSearchResults([]);
      return;
    }
    const timer = setTimeout(async () => {
      const lower = searchQuery.toLowerCase();
      const { data: users } = await supabase
        .from('users')
        .select('id, name, roll_number, year, section')
        .eq('role', 'student')
        .eq('status', 'active')
        .or(`name.ilike.%${lower}%,roll_number.ilike.%${lower}%`)
        .order('name')
        .limit(8);
      const results: StudentOption[] = (users ?? []).map((u) => ({
        uid: u.id,
        name: String(u.name ?? ''),
        rollNumber: String(u.roll_number ?? ''),
        year: Number(u.year ?? 0),
        section: String(u.section ?? ''),
      }));
      setSearchResults(results);
    }, 300);
    return () => clearTimeout(timer);
  }, [searchQuery]);

  const loadSemIntoEdit = useCallback((sem: SemesterData) => {
    setEditSubjects(
      sem.subjects && sem.subjects.length > 0
        ? sem.subjects.map((s) => ({ name: s.name, marks: s.marks, maxMarks: s.maxMarks }))
        : [{ name: '', marks: 0, maxMarks: 100 }]
    );
    setEditCgpa(sem.cgpa?.toString() ?? '');
  }, []);

  const selectStudent = async (student: StudentOption) => {
    setSelectedStudent(student);
    setSearchQuery('');
    setSearchResults([]);
    const sems = await getStudentSemesters(student.uid);
    setSemesters(sems);
    if (sems.length > 0) {
      setActiveSemId(sems[0].semId);
      loadSemIntoEdit(sems[0]);
    } else {
      const defaultSemId = 'sem1';
      setActiveSemId(defaultSemId);
      setEditSubjects([{ name: '', marks: 0, maxMarks: 100 }]);
      setEditCgpa('');
    }
  };

  const switchSem = (sem: SemesterData) => {
    setActiveSemId(sem.semId);
    loadSemIntoEdit(sem);
  };

  const addSemester = () => {
    const nextNum = semesters.length + 1;
    const newSemId = `sem${nextNum}`;
    const newSem: SemesterData = {
      semId: newSemId,
      userId: selectedStudent!.uid,
      subjects: [],
      updatedAt: new Date(),
    };
    setSemesters((prev) => [...prev, newSem]);
    setActiveSemId(newSemId);
    setEditSubjects([{ name: '', marks: 0, maxMarks: 100 }]);
    setEditCgpa('');
  };

  const handleSave = async () => {
    if (!selectedStudent || !activeSemId) return;
    setSaving(true);
    setSaveMsg(null);
    try {
      await upsertSemester(selectedStudent.uid, activeSemId, {
        cgpa: editCgpa ? parseFloat(editCgpa) : undefined,
        subjects: editSubjects.filter((s) => s.name.trim()),
        updatedBy: facultyId,
      });
      const updated = await getStudentSemesters(selectedStudent.uid);
      setSemesters(updated);
      setSaveMsg({ text: 'Saved successfully!', ok: true });
      setTimeout(() => setSaveMsg(null), 3000);
    } catch (err) {
      setSaveMsg({ text: `Error: ${err instanceof Error ? err.message : String(err)}`, ok: false });
    } finally {
      setSaving(false);
    }
  };

  const activeSem = semesters.find((s) => s.semId === activeSemId);

  return (
    <div className="space-y-6">
      {/* Student selector */}
      <div className="card">
        <h3 className="font-display font-semibold text-sm text-text-primary mb-3">
          Select Student
        </h3>
        <div className="relative">
          <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-text-muted" />
          <input
            type="text"
            placeholder="Search by name or roll number..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="input pl-9"
          />
          {searchResults.length > 0 && (
            <div className="absolute top-full left-0 right-0 bg-surface border border-border rounded-xl shadow-elevated z-10 mt-1 overflow-hidden">
              {searchResults.map((s) => (
                <button
                  key={s.uid}
                  onClick={() => selectStudent(s)}
                  className="w-full text-left px-4 py-3 hover:bg-background transition-colors border-b border-border last:border-0"
                >
                  <p className="font-body font-medium text-text-primary text-sm">{s.name}</p>
                  <p className="text-xs text-text-muted font-body">
                    {s.rollNumber} · Year {s.year} · Section {s.section}
                  </p>
                </button>
              ))}
            </div>
          )}
        </div>

        {selectedStudent && (
          <div className="mt-3 flex items-center gap-3 p-3 bg-primary-light rounded-xl">
            <div className="w-9 h-9 rounded-full bg-primary flex items-center justify-center">
              <span className="text-white font-display font-bold text-sm">
                {selectedStudent.name
                  .split(' ')
                  .map((n) => n[0])
                  .join('')
                  .slice(0, 2)
                  .toUpperCase()}
              </span>
            </div>
            <div>
              <p className="font-body font-medium text-text-primary text-sm">
                {selectedStudent.name}
              </p>
              <p className="text-xs text-text-muted font-body">
                {selectedStudent.rollNumber} · Year {selectedStudent.year} · Section{' '}
                {selectedStudent.section}
              </p>
            </div>
          </div>
        )}
      </div>

      {selectedStudent && (
        <>
          {/* Semester tabs */}
          <div className="flex items-center gap-2 flex-wrap">
            {semesters.map((s) => (
              <button
                key={s.semId}
                onClick={() => switchSem(s)}
                className={`px-4 py-2 rounded-xl text-sm font-body font-medium transition-all ${
                  activeSemId === s.semId
                    ? 'bg-primary text-white'
                    : 'bg-surface border border-border text-text-secondary hover:border-primary hover:text-primary'
                }`}
              >
                Sem {s.semId.replace('sem', '')}
              </button>
            ))}
            {semesters.length < 8 && (
              <button
                onClick={addSemester}
                className="flex items-center gap-1.5 px-4 py-2 rounded-xl text-sm font-body font-medium
                           border border-dashed border-border text-text-muted
                           hover:border-primary hover:text-primary transition-all"
              >
                <Plus size={14} /> Add Semester
              </button>
            )}
          </div>

          {/* Subjects editor */}
          <div className="card">
            <div className="flex items-center justify-between mb-4">
              <h3 className="font-display font-semibold text-base text-text-primary">
                Semester {activeSemId.replace('sem', '')} — Subjects
              </h3>
              <div className="flex items-center gap-3">
                {saveMsg && (
                  <span
                    className={`text-sm font-body ${saveMsg.ok ? 'text-success' : 'text-error'}`}
                  >
                    {saveMsg.text}
                  </span>
                )}
                <button
                  onClick={handleSave}
                  disabled={saving}
                  className="flex items-center gap-2 btn-primary !py-2 !px-4 text-sm disabled:opacity-50"
                >
                  <Save size={14} />
                  {saving ? 'Saving...' : 'Save'}
                </button>
              </div>
            </div>

            {activeSem?.updatedAt && (
              <p className="text-xs text-text-muted font-body mb-3">
                Last saved:{' '}
                {activeSem.updatedAt instanceof Date
                  ? activeSem.updatedAt.toLocaleString()
                  : '—'}
                {activeSem.updatedBy ? ` by ${activeSem.updatedBy}` : ''}
              </p>
            )}

            <table className="w-full text-sm mb-4">
              <thead>
                <tr className="bg-background">
                  {['Subject Name', 'Marks', 'Max Marks', 'Percentage', ''].map((h) => (
                    <th
                      key={h}
                      className="text-left px-3 py-2.5 text-text-muted font-body font-medium text-xs"
                    >
                      {h}
                    </th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {editSubjects.map((sub, i) => (
                  <tr key={i} className="border-t border-border">
                    <td className="px-3 py-2">
                      <input
                        type="text"
                        value={sub.name}
                        onChange={(e) =>
                          setEditSubjects((prev) =>
                            prev.map((s, j) =>
                              j === i ? { ...s, name: e.target.value } : s
                            )
                          )
                        }
                        placeholder="Subject name"
                        className="input !py-1.5 !px-2 text-sm"
                      />
                    </td>
                    <td className="px-3 py-2">
                      <input
                        type="number"
                        value={sub.marks}
                        onChange={(e) =>
                          setEditSubjects((prev) =>
                            prev.map((s, j) =>
                              j === i ? { ...s, marks: Math.max(0, +e.target.value) } : s
                            )
                          )
                        }
                        min={0}
                        max={sub.maxMarks}
                        className="input !py-1.5 !px-2 text-sm w-20"
                      />
                    </td>
                    <td className="px-3 py-2">
                      <input
                        type="number"
                        value={sub.maxMarks}
                        onChange={(e) =>
                          setEditSubjects((prev) =>
                            prev.map((s, j) =>
                              j === i ? { ...s, maxMarks: Math.max(1, +e.target.value) } : s
                            )
                          )
                        }
                        min={1}
                        className="input !py-1.5 !px-2 text-sm w-20"
                      />
                    </td>
                    <td className="px-3 py-2 font-body font-medium text-text-primary">
                      {sub.maxMarks > 0
                        ? `${((sub.marks / sub.maxMarks) * 100).toFixed(1)}%`
                        : '—'}
                    </td>
                    <td className="px-3 py-2">
                      {editSubjects.length > 1 && (
                        <button
                          onClick={() =>
                            setEditSubjects((prev) => prev.filter((_, j) => j !== i))
                          }
                          className="text-xs text-error hover:underline font-body"
                        >
                          Remove
                        </button>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>

            <button
              onClick={() =>
                setEditSubjects((prev) => [...prev, { name: '', marks: 0, maxMarks: 100 }])
              }
              className="flex items-center gap-2 text-sm text-primary font-body hover:underline mb-4"
            >
              <Plus size={14} /> Add Subject
            </button>

            <div className="pt-4 border-t border-border flex items-center gap-4">
              <label className="text-sm font-body font-medium text-text-secondary whitespace-nowrap">
                CGPA (this semester)
              </label>
              <input
                type="number"
                value={editCgpa}
                onChange={(e) => setEditCgpa(e.target.value)}
                min={0}
                max={10}
                step={0.01}
                placeholder="e.g. 8.50"
                className="input !py-1.5 !px-3 text-sm w-28"
              />
              <p className="text-xs text-text-muted font-body">
                Used for score calculation. Range: 0.00 – 10.00
              </p>
            </div>
          </div>
        </>
      )}

      {!selectedStudent && (
        <div className="card flex flex-col items-center py-16 text-center">
          <div className="w-14 h-14 rounded-full bg-primary-light flex items-center justify-center mb-3">
            <Search size={24} className="text-primary" />
          </div>
          <p className="font-display font-semibold text-text-primary">
            Search for a student to manage marks
          </p>
          <p className="text-sm text-text-muted font-body mt-1">
            Enter at least 2 characters to search by name or roll number.
          </p>
        </div>
      )}
    </div>
  );
}
