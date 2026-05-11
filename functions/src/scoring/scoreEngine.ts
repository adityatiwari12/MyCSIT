import * as admin from 'firebase-admin';
import { ActivityDoc, CodingActivityDoc, SemesterDoc, ScoreCache } from '../types';

// ─── Scoring Weights ───────────────────────────────────────────────────────────

const HACKATHON_TYPE_WEIGHT: Record<string, number> = {
  hackathon: 1.0,
  achievement: 0.7,
  certification: 0.5,
};

const PROJECT_TYPE_WEIGHT: Record<string, number> = {
  internship: 1.0,
  research: 0.9,
  project: 0.8,
};

// Maximum entries counted per activity type per bucket
const MAX_ENTRIES_PER_TYPE = 3;
// Maximum milestone value for normalisation (500 problems = 100%)
const MAX_MILESTONE_VALUE = 500;
// Maximum contest count for full coding score
const MAX_CONTESTS = 10;

// ─── Bucket Calculations ───────────────────────────────────────────────────────

function computeHackathonScore(activities: ActivityDoc[]): number {
  const eligible = activities.filter(
    (a) =>
      !a.isDeleted &&
      a.status === 'approved' &&
      Object.prototype.hasOwnProperty.call(HACKATHON_TYPE_WEIGHT, a.type)
  );

  const byType: Record<string, ActivityDoc[]> = {};
  for (const act of eligible) {
    if (!byType[act.type]) byType[act.type] = [];
    byType[act.type].push(act);
  }

  let raw = 0;
  for (const [type, acts] of Object.entries(byType)) {
    // Sort by createdAt descending so most recent entries are counted
    const sorted = acts.sort(
      (a, b) => b.createdAt.toMillis() - a.createdAt.toMillis()
    );
    const counted = sorted.slice(0, MAX_ENTRIES_PER_TYPE);
    raw += counted.length * (HACKATHON_TYPE_WEIGHT[type] ?? 0);
  }

  // maxRaw = 3 types × highest type weight (1.0) × MAX_ENTRIES_PER_TYPE = 9
  const maxRaw =
    Object.keys(HACKATHON_TYPE_WEIGHT).length *
    Math.max(...Object.values(HACKATHON_TYPE_WEIGHT)) *
    MAX_ENTRIES_PER_TYPE;

  return Math.min((raw / maxRaw) * 100, 100);
}

function computeProjectScore(activities: ActivityDoc[]): number {
  const eligible = activities.filter(
    (a) =>
      !a.isDeleted &&
      a.status === 'approved' &&
      Object.prototype.hasOwnProperty.call(PROJECT_TYPE_WEIGHT, a.type)
  );

  const byType: Record<string, ActivityDoc[]> = {};
  for (const act of eligible) {
    if (!byType[act.type]) byType[act.type] = [];
    byType[act.type].push(act);
  }

  let raw = 0;
  for (const [type, acts] of Object.entries(byType)) {
    const sorted = acts.sort(
      (a, b) => b.createdAt.toMillis() - a.createdAt.toMillis()
    );
    const counted = sorted.slice(0, MAX_ENTRIES_PER_TYPE);
    raw += counted.length * (PROJECT_TYPE_WEIGHT[type] ?? 0);
  }

  const maxRaw =
    Object.keys(PROJECT_TYPE_WEIGHT).length *
    Math.max(...Object.values(PROJECT_TYPE_WEIGHT)) *
    MAX_ENTRIES_PER_TYPE;

  return Math.min((raw / maxRaw) * 100, 100);
}

function computeCodingScore(coding: CodingActivityDoc[]): number {
  const approved = coding.filter((c) => !c.isDeleted && c.status === 'approved');

  const PLATFORMS: string[] = ['leetcode', 'codeforces', 'codechef', 'other'];

  // Per platform: only the highest approved milestone value counts
  const platformMaxMilestone: Record<string, number> = {};
  for (const entry of approved.filter((c) => c.type === 'milestone')) {
    const curr = platformMaxMilestone[entry.platform] ?? 0;
    platformMaxMilestone[entry.platform] = Math.max(curr, entry.value ?? 0);
  }

  const platformsWithMilestones = PLATFORMS.filter(
    (p) => platformMaxMilestone[p] !== undefined
  );

  let avgNormMilestone = 0;
  if (platformsWithMilestones.length > 0) {
    const normalizedValues = platformsWithMilestones.map(
      (p) => Math.min((platformMaxMilestone[p] ?? 0) / MAX_MILESTONE_VALUE, 1)
    );
    avgNormMilestone =
      normalizedValues.reduce((a, b) => a + b, 0) / platformsWithMilestones.length;
  }

  // Contest participation across all platforms (capped at MAX_CONTESTS)
  const contestCount = approved.filter((c) => c.type === 'contest').length;
  const normContestScore = Math.min(contestCount / MAX_CONTESTS, 1);

  return (avgNormMilestone * 0.5 + normContestScore * 0.5) * 100;
}

function computeAcademicScore(semesters: SemesterDoc[]): number {
  if (semesters.length === 0) return 0;

  // Use the most recently updated semester's CGPA
  const latest = semesters.reduce((a, b) => {
    const aMs = a.updatedAt?.toMillis?.() ?? 0;
    const bMs = b.updatedAt?.toMillis?.() ?? 0;
    return aMs >= bMs ? a : b;
  });

  if (typeof latest.cgpa !== 'number' || latest.cgpa <= 0) return 0;
  return Math.min((latest.cgpa / 10) * 100, 100);
}

function round2(n: number): number {
  return Math.round(n * 100) / 100;
}

// ─── Public API ────────────────────────────────────────────────────────────────

export async function computeAndCacheScore(
  userId: string,
  db: admin.firestore.Firestore
): Promise<ScoreCache> {
  const [activitiesSnap, codingSnap, semestersSnap] = await Promise.all([
    db
      .collection('activities')
      .where('userId', '==', userId)
      .where('isDeleted', '==', false)
      .get(),
    db
      .collection('codingActivities')
      .where('userId', '==', userId)
      .where('isDeleted', '==', false)
      .get(),
    db.collection('academics').doc(userId).collection('semesters').get(),
  ]);

  const activities = activitiesSnap.docs.map((d) => d.data() as ActivityDoc);
  const coding = codingSnap.docs.map((d) => d.data() as CodingActivityDoc);
  const semesters = semestersSnap.docs.map((d) => d.data() as SemesterDoc);

  const hackathonScore = computeHackathonScore(activities);
  const projectScore = computeProjectScore(activities);
  const codingScore = computeCodingScore(coding);
  const academicScore = computeAcademicScore(semesters);

  const totalScore =
    hackathonScore * 0.35 +
    projectScore * 0.25 +
    academicScore * 0.25 +
    codingScore * 0.15;

  const cache: ScoreCache = {
    totalScore: round2(totalScore),
    hackathonScore: round2(hackathonScore),
    projectScore: round2(projectScore),
    academicScore: round2(academicScore),
    codingScore: round2(codingScore),
    lastComputed: admin.firestore.Timestamp.now(),
  };

  // Write to the user document's scoreCache field.
  // Admin SDK bypasses Firestore security rules, so this is always allowed.
  await db
    .collection('users')
    .doc(userId)
    .update({
      scoreCache: cache,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

  return cache;
}
