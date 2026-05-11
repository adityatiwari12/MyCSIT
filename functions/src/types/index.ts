import * as admin from 'firebase-admin';

export type UserStatus = 'pending' | 'active' | 'rejected';
export type UserRole = 'student' | 'faculty';
export type EntryStatus = 'pending' | 'approved' | 'rejected';
export type ActivityType =
  | 'hackathon'
  | 'certification'
  | 'research'
  | 'project'
  | 'internship'
  | 'achievement';
export type CodingPlatform = 'leetcode' | 'codeforces' | 'codechef' | 'other';
export type CodingType = 'milestone' | 'contest' | 'highValueProblem';
export type AuditAction =
  | 'account_approved'
  | 'account_rejected'
  | 'activity_approved'
  | 'activity_rejected'
  | 'activity_deleted'
  | 'coding_approved'
  | 'coding_rejected';

export interface UserDoc {
  name: string;
  rollNumber: string;
  year: number;
  section: string;
  role: UserRole;
  status: UserStatus;
  rejectionReason?: string;
  email: string;
  fcmToken?: string;
  socialLinks?: {
    linkedin?: string;
    github?: string;
    portfolio?: string;
    leetcode?: string;
    codeforces?: string;
    codechef?: string;
  };
  pendingActivityCount: number;
  scoreCache?: ScoreCache;
  createdAt: admin.firestore.Timestamp;
  updatedAt: admin.firestore.Timestamp;
}

export interface ActivityDoc {
  userId: string;
  type: ActivityType;
  title: string;
  description: string;
  date: admin.firestore.Timestamp;
  proofUrl: string;
  status: EntryStatus;
  rejectionReason?: string;
  approvedBy?: string;
  isDeleted: boolean;
  createdAt: admin.firestore.Timestamp;
  updatedAt: admin.firestore.Timestamp;
}

export interface CodingActivityDoc {
  userId: string;
  platform: CodingPlatform;
  type: CodingType;
  title: string;
  value?: number;
  contestName?: string;
  rank?: number;
  difficulty?: 'easy' | 'medium' | 'hard';
  proofUrl: string;
  status: EntryStatus;
  rejectionReason?: string;
  approvedBy?: string;
  isDeleted: boolean;
  createdAt: admin.firestore.Timestamp;
  updatedAt: admin.firestore.Timestamp;
}

export interface SemesterDoc {
  userId: string;
  semNumber: number;
  cgpa?: number;
  subjects?: { name: string; marks: number; maxMarks: number }[];
  attendance?: { total: number; attended: number };
  updatedBy?: string;
  updatedAt: admin.firestore.Timestamp;
}

export interface ScoreCache {
  totalScore: number;
  hackathonScore: number;
  projectScore: number;
  academicScore: number;
  codingScore: number;
  lastComputed: admin.firestore.Timestamp;
}

export interface AuditEntry {
  action: AuditAction;
  targetId: string;
  targetType: 'activity' | 'coding' | 'user';
  performedBy: string;
  reason?: string;
  timestamp: admin.firestore.Timestamp;
}

// Callable function request/response shapes
export interface RegisterStudentRequest {
  rollNumber: string;
  name: string;
  year: number;
  section: string;
  password: string;
}

export interface RegisterStudentResponse {
  uid: string;
}

export interface ApproveStudentRequest {
  uid: string;
}

export interface RejectStudentRequest {
  uid: string;
  reason?: string;
}
