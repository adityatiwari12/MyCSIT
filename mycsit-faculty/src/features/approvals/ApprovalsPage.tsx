import { useEffect, useRef, useState } from 'react';
import { formatDistanceToNow } from 'date-fns';
import { Eye, Check, X } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { supabase } from '../../lib/supabase';
import {
  getPendingStudents,
  getPendingActivities,
  getPendingCodingActivities,
  updateStudentStatus,
  updateActivityStatus,
  updateCodingStatus,
  bulkUpdateActivityStatus,
} from '../../lib/firestore';
import { useAuthStore } from '../../stores/authStore';
import type { Student, Activity, CodingActivity } from '../../types';

type Tab = 'registrations' | 'activities' | 'coding';

export function ApprovalsPage() {
  const [activeTab, setActiveTab] = useState<Tab>('registrations');
  const [students, setStudents] = useState<Student[]>([]);
  const [activities, setActivities] = useState<Activity[]>([]);
  const [coding, setCoding] = useState<CodingActivity[]>([]);
  const [loading, setLoading] = useState(true);
  const [selected, setSelected] = useState<Set<string>>(new Set());
  const [rejectModal, setRejectModal] = useState<{
    id: string; type: 'student' | 'activity' | 'coding';
  } | null>(null);
  const [rejectReason, setRejectReason] = useState('');
  const { user } = useAuthStore();
  const navigate = useNavigate();
  const channelRef = useRef<ReturnType<typeof supabase.channel> | null>(null);

  const loadData = async () => {
    setLoading(true);
    try {
      const [s, a, c] = await Promise.allSettled([
        getPendingStudents(),
        getPendingActivities(),
        getPendingCodingActivities(),
      ]);
      
      if (s.status === 'fulfilled') setStudents(s.value);
      else console.error('Failed to load students:', s.reason);
      
      if (a.status === 'fulfilled') setActivities(a.value);
      else console.error('Failed to load activities:', a.reason);
      
      if (c.status === 'fulfilled') setCoding(c.value);
      else console.error('Failed to load coding activities:', c.reason);
    } catch (e) {
      console.error('Approvals load error:', e);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadData();

    // Realtime: refresh whenever pending items change
    channelRef.current = supabase
      .channel('approvals-realtime')
      .on('postgres_changes', {
        event: 'INSERT', schema: 'public', table: 'activities',
      }, loadData)
      .on('postgres_changes', {
        event: 'INSERT', schema: 'public', table: 'coding_activities',
      }, loadData)
      .on('postgres_changes', {
        event: 'INSERT', schema: 'public', table: 'users',
      }, loadData)
      .subscribe();

    return () => {
      if (channelRef.current) {
        supabase.removeChannel(channelRef.current);
      }
    };
  }, []);

  const tabs = [
    { id: 'registrations' as Tab, label: 'Student Registrations', count: students.length },
    { id: 'activities' as Tab, label: 'Activity Entries', count: activities.length },
    { id: 'coding' as Tab, label: 'Coding Entries', count: coding.length },
  ];

  const handleApproveStudent = async (uid: string) => {
    await updateStudentStatus(uid, 'active');
    setStudents((prev) => prev.filter((s) => s.uid !== uid));
  };

  const handleRejectStudent = async () => {
    if (!rejectModal) return;
    await updateStudentStatus(rejectModal.id, 'rejected', rejectReason);
    setStudents((prev) => prev.filter((s) => s.uid !== rejectModal.id));
    setRejectModal(null);
    setRejectReason('');
  };

  const handleApproveActivity = async (id: string) => {
    await updateActivityStatus(id, 'approved', user!.id);
    setActivities((prev) => prev.filter((a) => a.id !== id));
  };

  const handleRejectActivity = async () => {
    if (!rejectModal) return;
    await updateActivityStatus(rejectModal.id, 'rejected', user!.id, rejectReason);
    setActivities((prev) => prev.filter((a) => a.id !== rejectModal.id));
    setRejectModal(null);
    setRejectReason('');
  };

  const handleBulkApprove = async () => {
    const ids = Array.from(selected);
    await bulkUpdateActivityStatus(ids, 'approved', user!.id);
    setActivities((prev) => prev.filter((a) => !selected.has(a.id)));
    setSelected(new Set());
  };

  const toggleSelect = (id: string) => {
    setSelected((prev) => {
      const next = new Set(prev);
      next.has(id) ? next.delete(id) : next.add(id);
      return next;
    });
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="w-8 h-8 border-4 border-primary border-t-transparent rounded-full animate-spin" />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Tabs */}
      <div className="flex gap-1 bg-background rounded-xl p-1 w-fit">
        {tabs.map((tab) => (
          <button
            key={tab.id}
            onClick={() => { setActiveTab(tab.id); setSelected(new Set()); }}
            className={`flex items-center gap-2 px-4 py-2 rounded-lg text-sm font-body font-medium transition-all ${
              activeTab === tab.id
                ? 'bg-surface text-primary shadow-card'
                : 'text-text-secondary hover:text-text-primary'
            }`}
          >
            {tab.label}
            {tab.count > 0 && (
              <span className={`text-xs px-2 py-0.5 rounded-full font-display font-bold ${
                activeTab === tab.id ? 'bg-primary text-white' : 'bg-border text-text-muted'
              }`}>
                {tab.count}
              </span>
            )}
          </button>
        ))}
      </div>

      {/* Student Registrations */}
      {activeTab === 'registrations' && (
        <div className="space-y-3">
          {students.length === 0 ? (
            <EmptyState message="All caught up! No pending registrations." />
          ) : (
            students.map((s) => (
              <div key={s.uid} className="card flex items-center gap-4">
                <div className="w-12 h-12 rounded-full bg-primary-light flex items-center justify-center flex-shrink-0">
                  <span className="font-display font-bold text-primary text-sm">
                    {s.name.split(' ').map((n) => n[0]).join('').slice(0, 2).toUpperCase()}
                  </span>
                </div>
                <div className="flex-1 min-w-0">
                  <p className="font-display font-semibold text-[15px] text-text-primary">
                    {s.name}
                  </p>
                  <p className="text-sm text-text-muted font-body">
                    {s.rollNumber} • Year {s.year} • Section {s.section}
                  </p>
                  <p className="text-xs text-text-muted font-body mt-0.5">
                    Submitted {formatDistanceToNow(s.createdAt, { addSuffix: true })}
                  </p>
                </div>
                <div className="flex gap-2">
                  <button
                    onClick={() => handleApproveStudent(s.uid)}
                    className="flex items-center gap-1.5 px-4 py-2 bg-success text-white text-sm font-body font-medium rounded-pill hover:bg-green-600 transition-colors"
                  >
                    <Check size={14} /> Approve
                  </button>
                  <button
                    onClick={() => setRejectModal({ id: s.uid, type: 'student' })}
                    className="flex items-center gap-1.5 px-4 py-2 border border-error text-error text-sm font-body font-medium rounded-pill hover:bg-red-50 transition-colors"
                  >
                    <X size={14} /> Reject
                  </button>
                </div>
              </div>
            ))
          )}
        </div>
      )}

      {/* Activity Entries */}
      {activeTab === 'activities' && (
        <div className="space-y-3">
          {activities.length === 0 ? (
            <EmptyState message="All caught up! No pending activity entries." />
          ) : (
            <>
              {/* Select all */}
              <div className="flex items-center gap-3">
                <input
                  type="checkbox"
                  checked={selected.size === activities.length}
                  onChange={(e) =>
                    setSelected(
                      e.target.checked
                        ? new Set(activities.map((a) => a.id))
                        : new Set()
                    )
                  }
                  className="w-4 h-4 accent-primary"
                />
                <span className="text-sm text-text-secondary font-body">
                  Select All ({activities.length})
                </span>
              </div>

              {activities.map((a) => (
                <ActivityEntryCard
                  key={a.id}
                  activity={a}
                  isSelected={selected.has(a.id)}
                  onToggle={() => toggleSelect(a.id)}
                  onApprove={() => handleApproveActivity(a.id)}
                  onReject={() => setRejectModal({ id: a.id, type: 'activity' })}
                  onViewStudent={() => navigate(`/dashboard/students/${a.userId}`)}
                />
              ))}
            </>
          )}
        </div>
      )}

      {/* Coding Entries */}
      {activeTab === 'coding' && (
        <div className="space-y-3">
          {coding.length === 0 ? (
            <EmptyState message="All caught up! No pending coding entries." />
          ) : (
            coding.map((c) => (
              <CodingEntryCard
                key={c.id}
                entry={c}
                onApprove={async () => {
                  await updateCodingStatus(c.id, 'approved', user!.id);
                  setCoding((prev) => prev.filter((x) => x.id !== c.id));
                }}
                onReject={() => setRejectModal({ id: c.id, type: 'coding' })}
              />
            ))
          )}
        </div>
      )}

      {/* Bulk action bar */}
      {selected.size > 0 && (
        <div className="fixed bottom-6 left-1/2 -translate-x-1/2 bg-text-primary text-white
                        px-6 py-3 rounded-pill shadow-elevated flex items-center gap-4 z-50">
          <span className="text-sm font-body">{selected.size} selected</span>
          <button
            onClick={handleBulkApprove}
            className="bg-success text-white text-sm font-body font-medium px-4 py-1.5 rounded-pill hover:bg-green-600 transition-colors"
          >
            Approve All
          </button>
          <button
            onClick={() => setSelected(new Set())}
            className="text-sm text-white/70 hover:text-white transition-colors"
          >
            Cancel
          </button>
        </div>
      )}

      {/* Reject Modal */}
      {rejectModal && (
        <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50 p-4">
          <div className="bg-surface rounded-card shadow-elevated w-full max-w-md p-6">
            <h3 className="font-display font-bold text-lg text-text-primary mb-1">
              Reject Entry
            </h3>
            <p className="text-sm text-text-muted font-body mb-4">
              {rejectModal.type === 'student'
                ? 'Optionally provide a reason for rejection.'
                : 'Please provide a reason for rejection.'}
            </p>
            <textarea
              value={rejectReason}
              onChange={(e) => setRejectReason(e.target.value)}
              placeholder="Reason for rejection..."
              rows={3}
              className="input resize-none mb-4"
            />
            <div className="flex gap-3">
              <button
                onClick={() => {
                  if (rejectModal.type === 'student') handleRejectStudent();
                  else if (rejectModal.type === 'activity') handleRejectActivity();
                  else {
                    updateCodingStatus(rejectModal.id, 'rejected', user!.id, rejectReason);
                    setCoding((prev) => prev.filter((c) => c.id !== rejectModal.id));
                    setRejectModal(null);
                    setRejectReason('');
                  }
                }}
                className="btn-primary flex-1 !py-2.5"
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

function EmptyState({ message }: { message: string }) {
  return (
    <div className="card flex flex-col items-center py-12 text-center">
      <div className="w-14 h-14 rounded-full bg-green-50 flex items-center justify-center mb-3">
        <Check size={28} className="text-success" />
      </div>
      <p className="font-display font-semibold text-text-primary">{message}</p>
    </div>
  );
}

function ActivityEntryCard({
  activity, isSelected, onToggle, onApprove, onReject, onViewStudent,
}: {
  activity: Activity;
  isSelected: boolean;
  onToggle: () => void;
  onApprove: () => void;
  onReject: () => void;
  onViewStudent: () => void;
}) {
  const typeColors: Record<string, string> = {
    hackathon: 'bg-purple-100 text-purple-700',
    certification: 'bg-blue-100 text-blue-700',
    research: 'bg-pink-100 text-pink-700',
    project: 'bg-green-100 text-green-700',
    internship: 'bg-yellow-100 text-yellow-700',
    achievement: 'bg-red-100 text-red-700',
  };

  return (
    <div className={`card flex items-start gap-4 transition-all ${isSelected ? 'ring-2 ring-primary' : ''}`}>
      <input
        type="checkbox"
        checked={isSelected}
        onChange={onToggle}
        className="w-4 h-4 accent-primary mt-1"
      />
      <div className="flex-1 min-w-0">
        <div className="flex items-center gap-2 mb-1">
          <span className={`badge text-xs ${typeColors[activity.type] ?? 'bg-gray-100 text-gray-700'}`}>
            {activity.type}
          </span>
          <button
            onClick={onViewStudent}
            className="text-xs text-primary font-body hover:underline"
          >
            {activity.studentName ?? activity.userId}
          </button>
        </div>
        <p className="font-body font-medium text-text-primary text-sm">{activity.title}</p>
        <p className="text-xs text-text-muted font-body mt-0.5">
          {activity.date instanceof Date
            ? activity.date.toLocaleDateString()
            : 'Unknown date'}
          {' · '}
          {formatDistanceToNow(activity.createdAt, { addSuffix: true })}
        </p>
      </div>
      <div className="flex items-center gap-2 flex-shrink-0">
        {activity.proofUrl && (
          <a
            href={activity.proofUrl}
            target="_blank"
            rel="noopener noreferrer"
            className="flex items-center gap-1 text-xs text-primary font-body hover:underline"
          >
            <Eye size={13} /> Proof
          </a>
        )}
        <button
          onClick={onApprove}
          className="p-2 rounded-lg bg-green-50 text-success hover:bg-green-100 transition-colors"
          title="Approve"
        >
          <Check size={16} />
        </button>
        <button
          onClick={onReject}
          className="p-2 rounded-lg bg-red-50 text-error hover:bg-red-100 transition-colors"
          title="Reject"
        >
          <X size={16} />
        </button>
      </div>
    </div>
  );
}

function CodingEntryCard({
  entry, onApprove, onReject,
}: {
  entry: CodingActivity;
  onApprove: () => void;
  onReject: () => void;
}) {
  return (
    <div className="card flex items-center gap-4">
      <div className="flex-1 min-w-0">
        <div className="flex items-center gap-2 mb-1">
          <span className="badge bg-primary-light text-primary text-xs">{entry.type}</span>
          <span className="text-xs text-text-muted font-body">{entry.platform}</span>
        </div>
        <p className="font-body font-medium text-text-primary text-sm">{entry.title}</p>
        <p className="text-xs text-text-muted font-body mt-0.5">
          {entry.studentName ?? entry.userId} ·{' '}
          {formatDistanceToNow(entry.createdAt, { addSuffix: true })}
        </p>
      </div>
      <div className="flex items-center gap-2">
        {entry.proofUrl && (
          <a
            href={entry.proofUrl}
            target="_blank"
            rel="noopener noreferrer"
            className="flex items-center gap-1 text-xs text-primary font-body hover:underline"
          >
            <Eye size={13} /> Proof
          </a>
        )}
        <button
          onClick={onApprove}
          className="p-2 rounded-lg bg-green-50 text-success hover:bg-green-100 transition-colors"
        >
          <Check size={16} />
        </button>
        <button
          onClick={onReject}
          className="p-2 rounded-lg bg-red-50 text-error hover:bg-red-100 transition-colors"
        >
          <X size={16} />
        </button>
      </div>
    </div>
  );
}
