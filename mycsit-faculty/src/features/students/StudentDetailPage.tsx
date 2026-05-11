import { useEffect, useState } from 'react';
import { useParams } from 'react-router-dom';
import { ExternalLink, Check, X } from 'lucide-react';
import {
  BarChart, Bar, XAxis, YAxis, CartesianGrid,
  Tooltip, ResponsiveContainer, Cell,
} from 'recharts';
import {
  getStudentById,
  getStudentActivities,
  getStudentCodingActivities,
  getStudentSemesters,
  updateActivityStatus,
  updateCodingStatus,
} from '../../lib/firestore';
import { useAuthStore } from '../../stores/authStore';
import type { Student, ScoreCache, Activity, CodingActivity, SemesterData } from '../../types';

type Tab = 'overview' | 'activities' | 'coding' | 'academics' | 'score';

const TYPE_COLORS: Record<string, string> = {
  hackathon: 'bg-purple-100 text-purple-700',
  certification: 'bg-blue-100 text-blue-700',
  research: 'bg-pink-100 text-pink-700',
  project: 'bg-green-100 text-green-700',
  internship: 'bg-yellow-100 text-yellow-700',
  achievement: 'bg-red-100 text-red-700',
};

export function StudentDetailPage() {
  const { id } = useParams<{ id: string }>();
  const [student, setStudent] = useState<Student | null>(null);
  const [activities, setActivities] = useState<Activity[]>([]);
  const [coding, setCoding] = useState<CodingActivity[]>([]);
  const [semesters, setSemesters] = useState<SemesterData[]>([]);
  const [activeTab, setActiveTab] = useState<Tab>('overview');
  const [loading, setLoading] = useState(true);
  const [rejectModal, setRejectModal] = useState<{
    id: string; type: 'activity' | 'coding';
  } | null>(null);
  const [rejectReason, setRejectReason] = useState('');
  const { facultyId } = useAuthStore();

  useEffect(() => {
    if (!id) return;
    Promise.all([
      getStudentById(id),
      getStudentActivities(id),
      getStudentCodingActivities(id),
      getStudentSemesters(id),
    ]).then(([s, a, c, sem]) => {
      setStudent(s);
      setActivities(a);
      setCoding(c);
      setSemesters(sem);
      setLoading(false);
    });
  }, [id]);

  const handleApproveActivity = async (actId: string) => {
    await updateActivityStatus(actId, 'approved', facultyId);
    setActivities((prev) =>
      prev.map((x) => (x.id === actId ? { ...x, status: 'approved' } : x))
    );
  };

  const handleApproveCoding = async (codingId: string) => {
    await updateCodingStatus(codingId, 'approved', facultyId);
    setCoding((prev) =>
      prev.map((x) => (x.id === codingId ? { ...x, status: 'approved' } : x))
    );
  };

  const handleConfirmReject = async () => {
    if (!rejectModal) return;
    if (rejectModal.type === 'activity') {
      await updateActivityStatus(rejectModal.id, 'rejected', facultyId, rejectReason);
      setActivities((prev) =>
        prev.map((x) =>
          x.id === rejectModal.id
            ? { ...x, status: 'rejected', rejectionReason: rejectReason }
            : x
        )
      );
    } else {
      await updateCodingStatus(rejectModal.id, 'rejected', facultyId, rejectReason);
      setCoding((prev) =>
        prev.map((x) =>
          x.id === rejectModal.id
            ? { ...x, status: 'rejected', rejectionReason: rejectReason }
            : x
        )
      );
    }
    setRejectModal(null);
    setRejectReason('');
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="w-8 h-8 border-4 border-primary border-t-transparent rounded-full animate-spin" />
      </div>
    );
  }

  if (!student) {
    return <div className="card text-text-muted text-sm font-body">Student not found.</div>;
  }

  const score = student.totalScore != null
    ? {
        totalScore: student.totalScore,
        hackathonScore: student.activityScore ?? 0,
        projectScore: 0,
        academicScore: student.academicScore ?? 0,
        codingScore: student.codingScore ?? 0,
        lastComputed: new Date(),
      } as ScoreCache
    : null;

  const initials = student.name
    .split(' ')
    .map((n) => n[0])
    .join('')
    .slice(0, 2)
    .toUpperCase();

  const scoreBreakdown = [
    { name: 'Hackathons', value: score?.hackathonScore ?? 0, color: '#8B5CF6' },
    { name: 'Projects', value: score?.projectScore ?? 0, color: '#10B981' },
    { name: 'Academic', value: score?.academicScore ?? 0, color: '#3B82F6' },
    { name: 'Coding', value: score?.codingScore ?? 0, color: '#FF6B35' },
  ];

  const TABS: { id: Tab; label: string }[] = [
    { id: 'overview', label: 'Overview' },
    { id: 'activities', label: `Activities (${activities.length})` },
    { id: 'coding', label: `Coding (${coding.length})` },
    { id: 'academics', label: 'Academics' },
    { id: 'score', label: 'Score Breakdown' },
  ];

  return (
    <div className="flex gap-6">
      {/* Left sidebar */}
      <aside className="w-72 flex-shrink-0 space-y-4">
        <div className="card text-center">
          <div className="w-20 h-20 rounded-full bg-primary-light flex items-center justify-center mx-auto mb-3">
            <span className="font-display font-bold text-2xl text-primary">{initials}</span>
          </div>
          <h2 className="font-display font-bold text-xl text-text-primary">{student.name}</h2>
          <p className="text-sm text-text-muted font-body mt-1">{student.rollNumber}</p>
          <p className="text-sm text-text-muted font-body">
            Year {student.year} · Section {student.section}
          </p>
          <div className="mt-3 pt-3 border-t border-border flex justify-around text-center">
            <div>
              <p className="font-display font-bold text-lg text-text-primary">
                {student.cgpa?.toFixed(1) ?? '—'}
              </p>
              <p className="text-xs text-text-muted font-body">CGPA</p>
            </div>
            <div>
              <p className="font-display font-bold text-lg text-text-primary">
                {activities.filter((a) => a.status === 'approved').length}
              </p>
              <p className="text-xs text-text-muted font-body">Activities</p>
            </div>
            <div>
              <p className="font-display font-bold text-lg text-text-primary">
                {coding.filter((c) => c.status === 'approved').length}
              </p>
              <p className="text-xs text-text-muted font-body">Coding</p>
            </div>
          </div>
        </div>

        <div
          className="rounded-card p-5 text-white"
          style={{ background: 'linear-gradient(135deg, #FF6B35, #FF9F1C)' }}
        >
          <p className="text-white/70 text-xs font-body mb-1">Total Score</p>
          <p className="font-display font-bold text-4xl">
            {(score?.totalScore ?? 0).toFixed(1)}
          </p>
          <div className="flex gap-2 mt-3 flex-wrap">
            {[
              { label: 'Academic', val: score?.academicScore ?? 0 },
              { label: 'Events', val: score?.hackathonScore ?? 0 },
              { label: 'Coding', val: score?.codingScore ?? 0 },
            ].map(({ label, val }) => (
              <span
                key={label}
                className="bg-white/20 text-white text-xs font-body px-2.5 py-1 rounded-pill"
              >
                {label}: {val.toFixed(0)}
              </span>
            ))}
          </div>
        </div>
      </aside>

      {/* Main content */}
      <div className="flex-1 min-w-0">
        <div className="flex gap-1 bg-background rounded-xl p-1 w-fit mb-5 flex-wrap">
          {TABS.map((tab) => (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id)}
              className={`px-4 py-2 rounded-lg text-sm font-body font-medium transition-all ${
                activeTab === tab.id
                  ? 'bg-surface text-primary shadow-card'
                  : 'text-text-secondary hover:text-text-primary'
              }`}
            >
              {tab.label}
            </button>
          ))}
        </div>

        {/* ── Overview ─── */}
        {activeTab === 'overview' && (
          <div className="space-y-5">
            <div className="grid grid-cols-4 gap-4">
              {[
                { label: 'Total Activities', value: activities.length },
                { label: 'Approved', value: activities.filter((a) => a.status === 'approved').length },
                { label: 'Pending', value: activities.filter((a) => a.status === 'pending').length },
                { label: 'Coding Entries', value: coding.filter((c) => c.status === 'approved').length },
              ].map(({ label, value }) => (
                <div key={label} className="card text-center">
                  <p className="font-display font-bold text-2xl text-text-primary">{value}</p>
                  <p className="text-xs text-text-muted font-body mt-1">{label}</p>
                </div>
              ))}
            </div>
            <div className="card">
              <h3 className="font-display font-semibold text-sm text-text-primary mb-4">
                Score Overview
              </h3>
              <ResponsiveContainer width="100%" height={180}>
                <BarChart data={scoreBreakdown} layout="vertical">
                  <CartesianGrid strokeDasharray="3 3" stroke="#F3F3F3" horizontal={false} />
                  <XAxis type="number" domain={[0, 100]} tick={{ fontSize: 11 }} />
                  <YAxis type="category" dataKey="name" tick={{ fontSize: 11 }} width={70} />
                  <Tooltip contentStyle={{ borderRadius: 12, border: 'none' }} />
                  <Bar dataKey="value" radius={[0, 6, 6, 0]}>
                    {scoreBreakdown.map((entry, i) => (
                      <Cell key={i} fill={entry.color} />
                    ))}
                  </Bar>
                </BarChart>
              </ResponsiveContainer>
            </div>
          </div>
        )}

        {/* ── Activities ─── */}
        {activeTab === 'activities' && (
          <div className="card !p-0 overflow-hidden">
            {activities.length === 0 ? (
              <p className="p-8 text-center text-text-muted font-body text-sm">
                No activity entries yet.
              </p>
            ) : (
              <table className="w-full text-sm">
                <thead>
                  <tr className="bg-background">
                    {['Type', 'Title', 'Date', 'Status', 'Proof', 'Actions'].map((h) => (
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
                  {activities.map((a) => (
                    <tr key={a.id} className="border-t border-border hover:bg-background/50">
                      <td className="px-4 py-3">
                        <span className={`badge text-xs ${TYPE_COLORS[a.type] ?? 'bg-gray-100 text-gray-700'}`}>
                          {a.type}
                        </span>
                      </td>
                      <td className="px-4 py-3 font-body text-text-primary max-w-[200px]">
                        <p className="truncate">{a.title}</p>
                        {a.status === 'rejected' && a.rejectionReason && (
                          <p className="text-xs text-error mt-0.5 truncate">
                            Reason: {a.rejectionReason}
                          </p>
                        )}
                      </td>
                      <td className="px-4 py-3 text-text-muted font-body text-xs">
                        {a.date instanceof Date ? a.date.toLocaleDateString() : '—'}
                      </td>
                      <td className="px-4 py-3">
                        <span
                          className={`badge ${
                            a.status === 'approved'
                              ? 'badge-approved'
                              : a.status === 'rejected'
                              ? 'badge-rejected'
                              : 'badge-pending'
                          }`}
                        >
                          {a.status}
                        </span>
                      </td>
                      <td className="px-4 py-3">
                        {a.proofUrl && (
                          <a
                            href={a.proofUrl}
                            target="_blank"
                            rel="noopener noreferrer"
                            className="text-primary hover:underline text-xs flex items-center gap-1"
                          >
                            <ExternalLink size={12} /> View
                          </a>
                        )}
                      </td>
                      <td className="px-4 py-3">
                        {a.status === 'pending' && (
                          <div className="flex gap-1">
                            <button
                              onClick={() => handleApproveActivity(a.id)}
                              className="p-1.5 rounded-lg bg-green-50 text-success hover:bg-green-100"
                              title="Approve"
                            >
                              <Check size={14} />
                            </button>
                            <button
                              onClick={() => setRejectModal({ id: a.id, type: 'activity' })}
                              className="p-1.5 rounded-lg bg-red-50 text-error hover:bg-red-100"
                              title="Reject"
                            >
                              <X size={14} />
                            </button>
                          </div>
                        )}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            )}
          </div>
        )}

        {/* ── Coding ─── */}
        {activeTab === 'coding' && (
          <div className="card !p-0 overflow-hidden">
            {coding.length === 0 ? (
              <p className="p-8 text-center text-text-muted font-body text-sm">
                No coding entries yet.
              </p>
            ) : (
              <table className="w-full text-sm">
                <thead>
                  <tr className="bg-background">
                    {['Platform', 'Type', 'Title', 'Value', 'Status', 'Proof', 'Actions'].map((h) => (
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
                  {coding.map((c) => (
                    <tr key={c.id} className="border-t border-border hover:bg-background/50">
                      <td className="px-4 py-3">
                        <span className="badge bg-primary-light text-primary text-xs">{c.platform}</span>
                      </td>
                      <td className="px-4 py-3 text-text-secondary font-body text-xs">{c.type}</td>
                      <td className="px-4 py-3 font-body text-text-primary max-w-[160px] truncate">
                        {c.title}
                      </td>
                      <td className="px-4 py-3 font-body text-text-secondary text-xs">
                        {c.type === 'milestone' ? c.value : c.contestName ?? '—'}
                      </td>
                      <td className="px-4 py-3">
                        <span
                          className={`badge ${
                            c.status === 'approved'
                              ? 'badge-approved'
                              : c.status === 'rejected'
                              ? 'badge-rejected'
                              : 'badge-pending'
                          }`}
                        >
                          {c.status}
                        </span>
                      </td>
                      <td className="px-4 py-3">
                        {c.proofUrl && (
                          <a
                            href={c.proofUrl}
                            target="_blank"
                            rel="noopener noreferrer"
                            className="text-primary hover:underline text-xs flex items-center gap-1"
                          >
                            <ExternalLink size={12} /> View
                          </a>
                        )}
                      </td>
                      <td className="px-4 py-3">
                        {c.status === 'pending' && (
                          <div className="flex gap-1">
                            <button
                              onClick={() => handleApproveCoding(c.id)}
                              className="p-1.5 rounded-lg bg-green-50 text-success hover:bg-green-100"
                              title="Approve"
                            >
                              <Check size={14} />
                            </button>
                            <button
                              onClick={() => setRejectModal({ id: c.id, type: 'coding' })}
                              className="p-1.5 rounded-lg bg-red-50 text-error hover:bg-red-100"
                              title="Reject"
                            >
                              <X size={14} />
                            </button>
                          </div>
                        )}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            )}
          </div>
        )}

        {/* ── Academics ─── */}
        {activeTab === 'academics' && (
          <div className="space-y-4">
            {semesters.length === 0 ? (
              <div className="card text-center py-12 text-text-muted font-body text-sm">
                No academic data entered yet. Use the Marks page to add semester data.
              </div>
            ) : (
              semesters.map((sem) => {
                const attended = sem.attendance?.attended ?? 0;
                const total = sem.attendance?.total ?? 0;
                const pct = total > 0 ? Math.round((attended / total) * 100) : null;
                const pctColor =
                  pct == null ? 'text-text-muted' :
                  pct < 75 ? 'text-error' :
                  pct < 85 ? 'text-amber-600' : 'text-success';
                return (
                  <div key={sem.semId} className="card space-y-3">
                    <div className="flex justify-between items-center">
                      <h3 className="font-display font-semibold text-text-primary">
                        Semester {sem.semId.replace('sem', '')}
                      </h3>
                      <div className="flex gap-3 items-center">
                        {pct !== null && (
                          <span className={`text-sm font-body font-medium ${pctColor}`}>
                            {pct}% attendance
                          </span>
                        )}
                        {sem.cgpa && (
                          <span className="badge bg-blue-50 text-blue-700 text-sm">
                            CGPA: {sem.cgpa.toFixed(2)}
                          </span>
                        )}
                      </div>
                    </div>
                    {(sem.subjects ?? []).length > 0 && (
                      <table className="w-full text-sm">
                        <thead>
                          <tr>
                            <th className="text-left text-xs text-text-muted font-body pb-2">Subject</th>
                            <th className="text-right text-xs text-text-muted font-body pb-2">Marks</th>
                            <th className="text-right text-xs text-text-muted font-body pb-2">Max</th>
                            <th className="text-right text-xs text-text-muted font-body pb-2">%</th>
                          </tr>
                        </thead>
                        <tbody>
                          {(sem.subjects ?? []).map((sub, i) => (
                            <tr key={i} className="border-t border-border">
                              <td className="py-2 font-body text-text-primary">{sub.name}</td>
                              <td className="py-2 text-right font-body">{sub.marks}</td>
                              <td className="py-2 text-right font-body text-text-muted">{sub.maxMarks}</td>
                              <td className="py-2 text-right font-body">
                                {Math.round((sub.marks / sub.maxMarks) * 100)}%
                              </td>
                            </tr>
                          ))}
                        </tbody>
                      </table>
                    )}
                  </div>
                );
              })
            )}
          </div>
        )}

        {/* ── Score Breakdown ─── */}
        {activeTab === 'score' && (
          <div className="card space-y-4">
            <h3 className="font-display font-semibold text-base text-text-primary">
              Detailed Score Computation
            </h3>
            {[
              { label: 'Hackathons & Events', score: score?.hackathonScore ?? 0, weight: '35%', color: 'bg-purple-500' },
              { label: 'Projects & Internships', score: score?.projectScore ?? 0, weight: '25%', color: 'bg-green-500' },
              { label: 'Academic (CGPA)', score: score?.academicScore ?? 0, weight: '25%', color: 'bg-blue-500' },
              { label: 'Coding Activity', score: score?.codingScore ?? 0, weight: '15%', color: 'bg-primary' },
            ].map(({ label, score: s, weight, color }) => (
              <div key={label}>
                <div className="flex justify-between text-sm mb-1.5">
                  <span className="font-body font-medium text-text-primary">{label}</span>
                  <div className="flex gap-3">
                    <span className="text-text-muted font-body text-xs">{weight}</span>
                    <span className="font-display font-semibold text-text-primary">
                      {s.toFixed(1)}
                    </span>
                  </div>
                </div>
                <div className="h-2 bg-border rounded-full overflow-hidden">
                  <div
                    className={`h-full ${color} rounded-full transition-all`}
                    style={{ width: `${s}%` }}
                  />
                </div>
              </div>
            ))}
            <div className="border-t border-border pt-4 flex justify-between items-center">
              <span className="font-display font-semibold text-text-primary">Total Score</span>
              <div
                className="px-4 py-2 rounded-pill text-white font-display font-bold text-lg"
                style={{ background: 'linear-gradient(135deg, #FF6B35, #FF9F1C)' }}
              >
                {(score?.totalScore ?? 0).toFixed(1)}
              </div>
            </div>
            {score && (
              <p className="text-xs text-text-muted font-body">
                Last computed:{' '}
                {score.lastComputed instanceof Date
                  ? score.lastComputed.toLocaleString()
                  : 'Unknown'}
              </p>
            )}
          </div>
        )}
      </div>

      {/* Reject modal */}
      {rejectModal && (
        <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50 p-4">
          <div className="bg-surface rounded-card shadow-elevated w-full max-w-md p-6">
            <h3 className="font-display font-bold text-lg text-text-primary mb-4">
              Reject Entry
            </h3>
            <textarea
              value={rejectReason}
              onChange={(e) => setRejectReason(e.target.value)}
              placeholder="Reason for rejection (required)..."
              rows={3}
              className="input resize-none mb-4"
            />
            <div className="flex gap-3">
              <button
                onClick={handleConfirmReject}
                disabled={!rejectReason.trim()}
                className="btn-primary flex-1 !py-2.5 disabled:opacity-50"
              >
                Confirm Reject
              </button>
              <button
                onClick={() => { setRejectModal(null); setRejectReason(''); }}
                className="btn-outline flex-1 !py-2.5"
              >
                Cancel
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
