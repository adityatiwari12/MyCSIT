import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { computeAndCacheScore } from '../scoring/scoreEngine';
import { incrementPendingActivityCount, sendFcmToStudent } from '../utils/firestoreHelpers';

export const onActivityWrite = functions
  .region('asia-south1')
  .firestore.document('activities/{activityId}')
  .onWrite(async (change) => {
    const before = change.before.exists ? change.before.data() : null;
    const after = change.after.exists ? change.after.data() : null;

    if (!after) return; // Document deleted (shouldn't happen, but guard)

    const userId: string = after.userId;
    if (!userId) return;

    const db = admin.firestore();
    const statusChanged =
      !before ||
      before.status !== after.status ||
      before.isDeleted !== after.isDeleted;

    if (!statusChanged) return;

    // Handle pending activity count badge
    if (!before && after.status === 'pending') {
      // New submission: increment pending count
      await incrementPendingActivityCount(userId, 1).catch(() => null);
    } else if (before?.status === 'pending' && after.status !== 'pending') {
      // Left pending state: decrement pending count
      await incrementPendingActivityCount(userId, -1).catch(() => null);
    }

    // Recalculate score when status becomes approved or rejected
    if (
      after.status === 'approved' ||
      (after.status === 'rejected' && before?.status === 'approved')
    ) {
      await computeAndCacheScore(userId, db);
    }

    // Notify student of approval or rejection
    if (!before || before.status === 'pending') {
      if (after.status === 'approved') {
        sendFcmToStudent(
          userId,
          'Activity Approved',
          `"${after.title}" has been approved ✓`
        ).catch(() => null);
      } else if (after.status === 'rejected') {
        const reason = after.rejectionReason
          ? `: ${after.rejectionReason}`
          : '';
        sendFcmToStudent(
          userId,
          'Activity Rejected',
          `"${after.title}" was not approved${reason}`
        ).catch(() => null);
      }
    }
  });
