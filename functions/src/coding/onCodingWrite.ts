import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { computeAndCacheScore } from '../scoring/scoreEngine';
import { sendFcmToStudent } from '../utils/firestoreHelpers';

export const onCodingWrite = functions
  .region('asia-south1')
  .firestore.document('codingActivities/{activityId}')
  .onWrite(async (change) => {
    const before = change.before.exists ? change.before.data() : null;
    const after = change.after.exists ? change.after.data() : null;

    if (!after) return;

    const userId: string = after.userId;
    if (!userId) return;

    const statusChanged = !before || before.status !== after.status;
    if (!statusChanged) return;

    const db = admin.firestore();

    if (
      after.status === 'approved' ||
      (after.status === 'rejected' && before?.status === 'approved')
    ) {
      await computeAndCacheScore(userId, db);
    }

    if (!before || before.status === 'pending') {
      if (after.status === 'approved') {
        sendFcmToStudent(
          userId,
          'Coding Entry Approved',
          `"${after.title}" has been approved ✓`
        ).catch(() => null);
      } else if (after.status === 'rejected') {
        const reason = after.rejectionReason
          ? `: ${after.rejectionReason}`
          : '';
        sendFcmToStudent(
          userId,
          'Coding Entry Rejected',
          `"${after.title}" was not approved${reason}`
        ).catch(() => null);
      }
    }
  });
