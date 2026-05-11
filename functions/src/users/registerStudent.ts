import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import {
  validateStudentRegistration,
  ValidationError,
} from '../utils/validators';
import { sendFcmToFaculty } from '../utils/firestoreHelpers';
import { RegisterStudentRequest, RegisterStudentResponse } from '../types';

// Student email in Firebase Auth is: {rollNumber}@mycsit.internal
// This allows roll-number + password login without requiring a real email.
const AUTH_EMAIL_DOMAIN = 'mycsit.internal';
const MAX_ACTIVITY_CAP = 20;

export const registerStudent = functions
  .region('asia-south1')
  .https.onCall(async (data: unknown): Promise<RegisterStudentResponse> => {
    let req: RegisterStudentRequest;

    try {
      req = validateStudentRegistration(data);
    } catch (err) {
      if (err instanceof ValidationError) {
        throw new functions.https.HttpsError('invalid-argument', err.message);
      }
      throw new functions.https.HttpsError(
        'internal',
        'Validation failed.'
      );
    }

    const db = admin.firestore();
    const authEmail = `${req.rollNumber}@${AUTH_EMAIL_DOMAIN}`;

    // Check uniqueness of roll number in Firestore
    const existing = await db
      .collection('users')
      .where('rollNumber', '==', req.rollNumber)
      .limit(1)
      .get();

    if (!existing.empty) {
      throw new functions.https.HttpsError(
        'already-exists',
        'This roll number is already registered.'
      );
    }

    // Create Firebase Auth user
    let userRecord: admin.auth.UserRecord;
    try {
      userRecord = await admin.auth().createUser({
        email: authEmail,
        password: req.password,
        displayName: req.name,
        disabled: false,
      });
    } catch (err: unknown) {
      if (
        typeof err === 'object' &&
        err !== null &&
        'code' in err &&
        (err as { code: string }).code === 'auth/email-already-exists'
      ) {
        throw new functions.https.HttpsError(
          'already-exists',
          'This roll number is already registered.'
        );
      }
      functions.logger.error('Auth user creation failed', err);
      throw new functions.https.HttpsError(
        'internal',
        'Account creation failed. Please try again.'
      );
    }

    // Create Firestore user document
    const now = admin.firestore.FieldValue.serverTimestamp();
    try {
      await db.collection('users').doc(userRecord.uid).set({
        name: req.name,
        rollNumber: req.rollNumber,
        year: req.year,
        section: req.section,
        role: 'student',
        status: 'pending',
        email: authEmail,
        fcmToken: null,
        socialLinks: {},
        pendingActivityCount: 0,
        scoreCache: null,
        createdAt: now,
        updatedAt: now,
      });
    } catch (err) {
      // Firestore write failed — clean up the Auth user to avoid orphans
      functions.logger.error(
        `Firestore doc creation failed for ${userRecord.uid}, rolling back Auth user`,
        err
      );
      await admin.auth().deleteUser(userRecord.uid).catch(() => null);
      throw new functions.https.HttpsError(
        'internal',
        'Registration failed. Please try again.'
      );
    }

    // Notify all faculty of the new pending registration (best-effort)
    sendFcmToFaculty(
      'New Student Registration',
      `${req.name} (${req.rollNumber}) is awaiting approval.`
    ).catch((err) =>
      functions.logger.warn('FCM notify faculty failed', err)
    );

    functions.logger.info(
      `Student registered: uid=${userRecord.uid} roll=${req.rollNumber}`
    );

    return { uid: userRecord.uid };
  });
