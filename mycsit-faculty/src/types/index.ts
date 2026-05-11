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

export interface Student {
  uid: string;
  name: string;
  rollNumber: string;
  year: number;
  section: string;
  role: UserRole;
  status: UserStatus;
  createdAt: Date;
  fcmToken?: string;
  // from scoreCache
  totalScore?: number;
  academicScore?: number;
  activityScore?: number;
  codingScore?: number;
  cgpa?: number;
  activityCount?: number;
}

export interface Activity {
  id: string;
  userId: string;
  type: ActivityType;
  title: string;
  description: string;
  date: Date;
  proofUrl: string;
  status: EntryStatus;
  rejectionReason?: string;
  approvedBy?: string;
  isDeleted: boolean;
  createdAt: Date;
  updatedAt: Date;
  // joined
  studentName?: string;
  studentRoll?: string;
}

export interface CodingActivity {
  id: string;
  userId: string;
  platform: CodingPlatform;
  type: CodingType;
  title: string;
  value?: number;
  contestName?: string;
  difficulty?: 'easy' | 'medium' | 'hard';
  proofUrl: string;
  status: EntryStatus;
  rejectionReason?: string;
  isDeleted: boolean;
  createdAt: Date;
  // joined
  studentName?: string;
  studentRoll?: string;
}

export interface SemesterData {
  semId: string;
  userId: string;
  subjects: { name: string; marks: number; maxMarks: number }[];
  attendance?: { total: number; attended: number };
  cgpa?: number;
  updatedBy?: string;
  updatedAt?: Date;
}

export interface ScoreCache {
  totalScore: number;
  hackathonScore: number;
  projectScore: number;
  academicScore: number;
  codingScore: number;
  lastComputed: Date;
}

export interface FilterState {
  years: number[];
  sections: string[];
  cgpaMin: number;
  cgpaMax: number;
  scoreMin: number;
  scoreMax: number;
  hasActivities: boolean | null;
  hasCodingEntries: boolean | null;
}
