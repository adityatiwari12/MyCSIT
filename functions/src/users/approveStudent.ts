import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { verifyFacultyAuth, writeAuditLog, sendFcmToStudent } from '../utils/firestoreHelpers';
import { ApproveStudentRequest } from '../types';

export const approveStudent = functions
  .region('asia-south1')
  .https.onCall(
    async (
      data: ApproveStudentRequest,
      context: functions.https.CallableContext
    ) => {
      const facultyUid = await verifyFacultyAuth(context).catch(() => {
        throw new functions.https.HttpsError(
          'unauthenticated',
          'Faculty authentication required.'
        );
      });

      const { uid } = data;
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
      if (userData.status === 'active') {
        throw new functions.https.HttpsError(
          'failed-precondition',
          'Student is already approved.'
        );
      }

      // 1. Set custom claims so the student gains access after token refresh
      await admin.auth().setCustomUserClaims(uid, { role: 'student' });

      // 2. Update Firestore status
      await userRef.update({
        status: 'active',
        rejectionReason: admin.firestore.FieldValue.delete(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // 3. Write audit log
      await writeAuditLog({
        action: 'account_approved',
        targetId: uid,
        targetType: 'user',
        performedBy: facultyUid,
      });

      // 4. Notify student (best-effort)
      sendFcmToStudent(
        uid,
        'Account Approved',
        'Your MyCSIT account has been approved. Welcome!'
      ).catch((err) =>
        functions.logger.warn('FCM notify student failed', err)
      );

      functions.logger.info(`Student approved: uid=${uid} by faculty=${facultyUid}`);

      return { success: true };
    }
  );
