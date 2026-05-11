import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { computeAndCacheScore } from '../scoring/scoreEngine';

export const onAcademicsWrite = functions
  .region('asia-south1')
  .firestore.document('academics/{userId}/semesters/{semId}')
  .onWrite(async (change, context) => {
    const userId = context.params.userId;
    if (!userId) return;

    const before = change.before.exists ? change.before.data() : null;
    const after = change.after.exists ? change.after.data() : null;

    // Only recalculate if CGPA actually changed
    if (before?.cgpa === after?.cgpa) return;

    const db = admin.firestore();
    await computeAndCacheScore(userId, db);
  });
