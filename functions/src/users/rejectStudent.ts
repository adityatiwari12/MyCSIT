import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { verifyFacultyAuth, writeAuditLog, sendFcmToStudent } from '../utils/firestoreHelpers';
import { RejectStudentRequest } from '../types';

export const rejectStudent = functions
  .region('asia-south1')
  .https.onCall(
    async (
      data: RejectStudentRequest,
      context: functions.https.CallableContext
    ) => {
      const facultyUid = await verifyFacultyAuth(context).catch(() => {
        throw new functions.https.HttpsError(
          'unauthenticated',
          'Faculty authentication required.'
        );
      });

      const { uid, reason } = data;
      if (!uid || typeof uid !== 'string') {
        throw new functions.https.HttpsError(
          'invalid-argument',
          'Student UID is required.'
        );
      }

      const db = admin.firestore();
      const userRef = db.collection('users').doc(uid);
      const userSnap = await userRef.get();

      if (!userSnap.exists) {
        throw new functions.https.HttpsError(
          'not-found',
          'Student account not found.'
        );
      }

      const userData = userSnap.data()!;
      if (userData.role !== 'student') {
        throw new functions.https.HttpsError(
          'failed-precondition',
          'Target account is not a student.'
        );
      }

      const updateData: Record<string, unknown> = {
        status: 'rejected',
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      };
      if (reason && reason.trim()) {
        updateData.rejectionReason = reason.trim();
      }

      await userRef.update(updateData);

      // Revoke any existing custom claims so the session is invalidated
      await admin.auth().setCustomUserClaims(uid, {});

      await writeAuditLog({
        action: 'account_rejected',
        targetId: uid,
        targetType: 'user',
        performedBy: facultyUid,
        reason: reason?.trim(),
      });

      sendFcmToStudent(
        uid,
        'Registration Not Approved',
        'Your registration was not approved. Please contact the faculty.'
      ).catch((err) =>
        functions.logger.warn('FCM notify student failed', err)
      );

      functions.logger.info(`Student rejected: uid=${uid} by faculty=${facultyUid}`);

      return { success: true };
    }
  );
