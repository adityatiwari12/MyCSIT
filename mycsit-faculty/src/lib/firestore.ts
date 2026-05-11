import { supabase } from './supabase';
import type {
  Student,
  Activity,
  CodingActivity,
  SemesterData,
  ScoreCache,
} from '../types';

export type Unsubscribe = () => void;

// ─── Type Converters ──────────────────────────────────────────────────────────

function rowToStudent(
  row: Record<string, unknown>,
  cache?: Record<string, unknown> | null,
  latestCgpa?: number | null
): Student {
  return {
    uid: String(row.id ?? ''),
    name: String(row.name ?? ''),
    rollNumber: String(row.roll_number ?? ''),
    year: Number(row.year ?? 0),
    section: String(row.section ?? ''),
    role: row.role as Student['role'],
    status: row.status as Student['status'],
    createdAt: row.created_at ? new Date(String(row.created_at)) : new Date(0),
    totalScore: cache ? Number(cache.total_score) : undefined,
    academicScore: cache ? Number(cache.academic_score) : undefined,
    activityScore: cache ? Number(cache.hackathon_score) : undefined,
    codingScore: cache ? Number(cache.coding_score) : undefined,
    cgpa: latestCgpa ?? undefined,
  };
}

function rowToActivity(row: Record<string, unknown>): Activity {
  const user = row.users as { name: string; roll_number: string } | null;
  return {
    id: String(row.id ?? ''),
    userId: String(row.user_id ?? ''),
    type: row.type as Activity['type'],
    title: String(row.title ?? ''),
    description: String(row.description ?? ''),
    date: row.date ? new Date(String(row.date)) : new Date(0),
    proofUrl: String(row.proof_url ?? ''),
    status: row.status as Activity['status'],
    rejectionReason: row.rejection_reason as string | undefined,
    approvedBy: row.approved_by as string | undefined,
    isDeleted: Boolean(row.is_deleted),
    createdAt: row.created_at ? new Date(String(row.created_at)) : new Date(0),
    updatedAt: row.updated_at ? new Date(String(row.updated_at)) : new Date(0),
    studentName: user?.name,
    studentRoll: user?.roll_number,
  };
}

function rowToCoding(row: Record<string, unknown>): CodingActivity {
  const user = row.users as { name: string; roll_number: string } | null;
  return {
    id: String(row.id ?? ''),
    userId: String(row.user_id ?? ''),
    platform: row.platform as CodingActivity['platform'],
    type: row.type as CodingActivity['type'],
    title: String(row.title ?? ''),
    value: row.value as number | undefined,
    contestName: row.contest_name as string | undefined,
    difficulty: row.difficulty as CodingActivity['difficulty'],
    proofUrl: String(row.proof_url ?? ''),
    status: row.status as CodingActivity['status'],
    rejectionReason: row.rejection_reason as string | undefined,
    isDeleted: Boolean(row.is_deleted),
    createdAt: row.created_at ? new Date(String(row.created_at)) : new Date(0),
    studentName: user?.name,
    studentRoll: user?.roll_number,
  };
}

// ─── Student Queries ──────────────────────────────────────────────────────────

export async function getPendingStudents(): Promise<Student[]> {
  const { data, error } = await supabase
    .from('users')
    .select('*')
    .eq('role', 'student')
    .eq('status', 'pending')
    .order('created_at', { ascending: false });
  if (error) throw error;
  return (data ?? []).map((r) => rowToStudent(r as Record<string, unknown>));
}

export async function getActiveStudents(): Promise<Student[]> {
  // First get all active students
  const { data, error } = await supabase
    .from('users')
    .select('*')
    .eq('role', 'student')
    .eq('status', 'active')
    .order('created_at', { ascending: false });
  
  if (error) {
    console.error('Error fetching active students:', error);
    return [];
  }

  if (!data || data.length === 0) return [];

  // Get student IDs for fetching related data
  const studentIds = data.map((r) => r.id);

  // Fetch score cache separately
  let scoreCacheData: Record<string, Record<string, unknown>> = {};
  try {
    const { data: cacheData, error: cacheError } = await supabase
      .from('score_cache')
      .select('*')
      .in('user_id', studentIds);
    
    if (!cacheError && cacheData) {
      cacheData.forEach((cache) => {
        scoreCacheData[cache.user_id as string] = cache as Record<string, unknown>;
      });
    }
  } catch (e) {
    console.error('Error fetching score cache:', e);
  }

  // Fetch semesters separately
  let semesterData: Record<string, Array<{ cgpa: number | null; updated_at: string }>> = {};
  try {
    const { data: semData, error: semError } = await supabase
      .from('semesters')
      .select('user_id, cgpa, updated_at')
      .in('user_id', studentIds);
    
    if (!semError && semData) {
      semData.forEach((sem) => {
        const uid = sem.user_id as string;
        if (!semesterData[uid]) semesterData[uid] = [];
        semesterData[uid].push({ cgpa: sem.cgpa as number | null, updated_at: sem.updated_at as string });
      });
    }
  } catch (e) {
    console.error('Error fetching semesters:', e);
  }

  return data.map((r) => {
    const row = r as Record<string, unknown>;
    const cache = scoreCacheData[row.id as string] ?? null;
    const sems = semesterData[row.id as string] ?? [];
    const latestSem =
      sems.length > 0
        ? sems.sort(
            (a, b) => new Date(b.updated_at).getTime() - new Date(a.updated_at).getTime()
          )[0]
        : null;
    return rowToStudent(row, cache, latestSem?.cgpa ?? null);
  });
}

export async function getStudentById(uid: string): Promise<Student | null> {
  const { data, error } = await supabase
    .from('users')
    .select('*')
    .eq('id', uid)
    .single();
  if (error || !data) return null;

  const row = data as Record<string, unknown>;
  
  // Fetch score cache separately
  let cache: Record<string, unknown> | null = null;
  try {
    const { data: cacheData, error: cacheError } = await supabase
      .from('score_cache')
      .select('*')
      .eq('user_id', uid)
      .single();
    if (!cacheError && cacheData) {
      cache = cacheData as Record<string, unknown>;
    }
  } catch (e) {
    console.error('Error fetching score cache:', e);
  }

  // Fetch semesters separately
  let latestCgpa: number | null = null;
  try {
    const { data: semData, error: semError } = await supabase
      .from('semesters')
      .select('cgpa, updated_at')
      .eq('user_id', uid)
      .order('updated_at', { ascending: false })
      .limit(1);
    
    if (!semError && semData && semData.length > 0) {
      latestCgpa = semData[0].cgpa as number | null;
    }
  } catch (e) {
    console.error('Error fetching semesters:', e);
  }

  return rowToStudent(row, cache, latestCgpa);
}

export function subscribeToStudent(
  uid: string,
  cb: (s: Student | null) => void
): Unsubscribe {
  getStudentById(uid).then(cb);

  const channel = supabase
    .channel(`student-${uid}`)
    .on(
      'postgres_changes',
      { event: '*', schema: 'public', table: 'users', filter: `id=eq.${uid}` },
      () => getStudentById(uid).then(cb)
    )
    .subscribe();

  return () => { supabase.removeChannel(channel); };
}

// ─── Student Approval ─────────────────────────────────────────────────────────

export async function updateStudentStatus(
  uid: string,
  status: 'active' | 'rejected',
  reason?: string
): Promise<void> {
  const payload: Record<string, unknown> = { status };
  if (status === 'rejected' && reason?.trim()) {
    payload.rejection_reason = reason.trim();
  } else if (status === 'active') {
    payload.rejection_reason = null;
  }
  const { error } = await supabase.from('users').update(payload).eq('id', uid);
  if (error) throw error;
}

// ─── Activity Queries ─────────────────────────────────────────────────────────

export async function getPendingActivities(): Promise<Activity[]> {
  try {
    const { data, error } = await supabase
      .from('activities')
      .select('*, users(name, roll_number)')
      .eq('status', 'pending')
      .eq('is_deleted', false)
      .order('created_at', { ascending: false });
    if (error) throw error;
    return (data ?? []).map((r) => rowToActivity(r as Record<string, unknown>));
  } catch (error) {
    console.error('Error fetching pending activities:', error);
    return [];
  }
}

export async function getStudentActivities(uid: string): Promise<Activity[]> {
  const { data, error } = await supabase
    .from('activities')
    .select('*')
    .eq('user_id', uid)
    .eq('is_deleted', false)
    .order('created_at', { ascending: false });
  if (error) throw error;
  return (data ?? []).map((r) => rowToActivity(r as Record<string, unknown>));
}

export async function updateActivityStatus(
  id: string,
  status: 'approved' | 'rejected',
  approvedBy: string,
  reason?: string
): Promise<void> {
  const payload: Record<string, unknown> = {
    status,
    approved_by: approvedBy,
    updated_at: new Date().toISOString(),
  };
  if (status === 'rejected' && reason?.trim()) {
    payload.rejection_reason = reason.trim();
  } else if (status === 'approved') {
    payload.rejection_reason = null;
  }
  const { error } = await supabase.from('activities').update(payload).eq('id', id);
  if (error) throw error;
}

export async function bulkUpdateActivityStatus(
  ids: string[],
  status: 'approved' | 'rejected',
  approvedBy: string
): Promise<void> {
  const { error } = await supabase
    .from('activities')
    .update({
      status,
      approved_by: approvedBy,
      rejection_reason: status === 'approved' ? null : undefined,
      updated_at: new Date().toISOString(),
    })
    .in('id', ids);
  if (error) throw error;
}

// ─── Coding Activity Queries ──────────────────────────────────────────────────

export async function getPendingCodingActivities(): Promise<CodingActivity[]> {
  try {
    const { data, error } = await supabase
      .from('coding_activities')
      .select('*, users(name, roll_number)')
      .eq('status', 'pending')
      .eq('is_deleted', false)
      .order('created_at', { ascending: false });
    if (error) throw error;
    return (data ?? []).map((r) => rowToCoding(r as Record<string, unknown>));
  } catch (error) {
    console.error('Error fetching pending coding activities:', error);
    return [];
  }
}

export async function getStudentCodingActivities(uid: string): Promise<CodingActivity[]> {
  const { data, error } = await supabase
    .from('coding_activities')
    .select('*')
    .eq('user_id', uid)
    .eq('is_deleted', false)
    .order('created_at', { ascending: false });
  if (error) throw error;
  return (data ?? []).map((r) => rowToCoding(r as Record<string, unknown>));
}

export async function updateCodingStatus(
  id: string,
  status: 'approved' | 'rejected',
  approvedBy: string,
  reason?: string
): Promise<void> {
  const payload: Record<string, unknown> = {
    status,
    approved_by: approvedBy,
  };
  if (status === 'rejected' && reason?.trim()) {
    payload.rejection_reason = reason.trim();
  } else if (status === 'approved') {
    payload.rejection_reason = null;
  }
  const { error } = await supabase.from('coding_activities').update(payload).eq('id', id);
  if (error) throw error;
}

// ─── Academics ────────────────────────────────────────────────────────────────

export async function getStudentSemesters(uid: string): Promise<SemesterData[]> {
  const { data: sems, error } = await supabase
    .from('semesters')
    .select('*, subjects(*), attendance(*)')
    .eq('user_id', uid)
    .order('sem_number', { ascending: true });
  if (error) throw error;

  return (sems ?? []).map((s) => {
    const subjects = (s.subjects as Array<{
      name: string;
      marks: number;
      max_marks: number;
    }>) ?? [];
    const attRows = (s.attendance as Array<{
      total_classes: number;
      attended: number;
    }>) ?? [];
    const att = attRows[0];
    return {
      semId: `sem${s.sem_number}`,
      userId: uid,
      subjects: subjects.map((sub) => ({
        name: sub.name,
        marks: sub.marks,
        maxMarks: sub.max_marks,
      })),
      attendance: att ? { total: att.total_classes, attended: att.attended } : undefined,
      cgpa: s.cgpa ?? undefined,
      updatedBy: s.updated_by ?? undefined,
      updatedAt: s.updated_at ? new Date(s.updated_at) : undefined,
    } as SemesterData;
  });
}

export async function upsertSemester(
  userId: string,
  semId: string,
  data: Partial<SemesterData> & { updatedBy: string }
): Promise<void> {
  const semNumber = Number(semId.replace('sem', ''));

  const { data: semRow, error: semErr } = await supabase
    .from('semesters')
    .upsert(
      {
        user_id: userId,
        sem_number: semNumber,
        cgpa: data.cgpa ?? null,
        updated_by: data.updatedBy,
        updated_at: new Date().toISOString(),
      },
      { onConflict: 'user_id,sem_number' }
    )
    .select('id')
    .single();
  if (semErr) throw semErr;

  const semRowId = (semRow as { id: string }).id;

  if (data.subjects !== undefined) {
    const { error: delErr } = await supabase
      .from('subjects')
      .delete()
      .eq('semester_id', semRowId);
    if (delErr) throw delErr;

    const filtered = data.subjects.filter((s) => s.name.trim());
    if (filtered.length > 0) {
      const { error: insErr } = await supabase.from('subjects').insert(
        filtered.map((s) => ({
          semester_id: semRowId,
          name: s.name,
          marks: s.marks,
          max_marks: s.maxMarks,
        }))
      );
      if (insErr) throw insErr;
    }
  }

  if (data.attendance !== undefined) {
    const { error: attErr } = await supabase.from('attendance').upsert(
      {
        user_id: userId,
        semester_id: semRowId,
        total_classes: data.attendance.total,
        attended: data.attendance.attended,
        updated_by: data.updatedBy,
        updated_at: new Date().toISOString(),
      },
      { onConflict: 'user_id,semester_id' }
    );
    if (attErr) throw attErr;
  }
}

// ─── Score Cache ──────────────────────────────────────────────────────────────

export async function getStudentScoreCache(uid: string): Promise<ScoreCache | null> {
  const { data, error } = await supabase
    .from('score_cache')
    .select('*')
    .eq('user_id', uid)
    .single();
  if (error || !data) return null;
  const row = data as Record<string, unknown>;
  return {
    totalScore: Number(row.total_score),
    hackathonScore: Number(row.hackathon_score),
    projectScore: Number(row.project_score),
    academicScore: Number(row.academic_score),
    codingScore: Number(row.coding_score),
    lastComputed: row.last_computed ? new Date(String(row.last_computed)) : new Date(0),
  };
}

// ─── Real-time Pending Count ──────────────────────────────────────────────────

export function subscribeToPendingCount(callback: (count: number) => void): Unsubscribe {
  let pendingStudents = 0;
  let pendingActivities = 0;
  let pendingCoding = 0;
  const notify = () => callback(pendingStudents + pendingActivities + pendingCoding);

  const fetchCounts = async () => {
    const [usersRes, actsRes, codingRes] = await Promise.all([
      supabase
        .from('users')
        .select('id', { count: 'exact', head: true })
        .eq('role', 'student')
        .eq('status', 'pending'),
      supabase
        .from('activities')
        .select('id', { count: 'exact', head: true })
        .eq('status', 'pending')
        .eq('is_deleted', false),
      supabase
        .from('coding_activities')
        .select('id', { count: 'exact', head: true })
        .eq('status', 'pending')
        .eq('is_deleted', false),
    ]);
    pendingStudents = usersRes.count ?? 0;
    pendingActivities = actsRes.count ?? 0;
    pendingCoding = codingRes.count ?? 0;
    notify();
  };

  fetchCounts();

  const channel = supabase
    .channel('pending-counts')
    .on('postgres_changes', { event: '*', schema: 'public', table: 'users' }, fetchCounts)
    .on('postgres_changes', { event: '*', schema: 'public', table: 'activities' }, fetchCounts)
    .on('postgres_changes', { event: '*', schema: 'public', table: 'coding_activities' }, fetchCounts)
    .subscribe();

  return () => { supabase.removeChannel(channel); };
}

// ─── Audit Log ────────────────────────────────────────────────────────────────

export interface AuditEntry {
  id: string;
  action: string;
  targetId: string;
  targetType: string;
  performedBy: string;
  reason?: string;
  timestamp: Date;
}

export async function getAuditLog(_targetId: string): Promise<AuditEntry[]> {
  return [];
}

// ─── Analytics Helpers ────────────────────────────────────────────────────────

export async function getAllStudentsWithScores(): Promise<Student[]> {
  return getActiveStudents();
}
