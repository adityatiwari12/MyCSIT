import * as admin from 'firebase-admin';
import { AuditAction, AuditEntry } from '../types';

const db = () => admin.firestore();

export async function writeAuditLog(entry: Omit<AuditEntry, 'timestamp'>): Promise<void> {
  await db().collection('auditLog').add({
    ...entry,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
  });
}

export async function getUserDoc(uid: string) {
  const snap = await db().collection('users').doc(uid).get();
  if (!snap.exists) return null;
  return snap.data() as import('../types').UserDoc;
}

export async function incrementPendingActivityCount(
  userId: string,
  delta: number
): Promise<void> {
  await db()
    .collection('users')
    .doc(userId)
    .update({
      pendingActivityCount: admin.firestore.FieldValue.increment(delta),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
}

export async function sendFcmToFaculty(
  title: string,
  body: string
): Promise<void> {
  const facultySnap = await db()
    .collection('users')
    .where('role', '==', 'faculty')
    .where('status', '==', 'active')
    .get();

  const tokens: string[] = [];
  for (const doc of facultySnap.docs) {
    const token = doc.data().fcmToken;
    if (token) tokens.push(token);
  }

  if (tokens.length === 0) return;

  await admin.messaging().sendEachForMulticast({
    tokens,
    notification: { title, body },
  });
}

export async function sendFcmToStudent(
  uid: string,
  title: string,
  body: string
): Promise<void> {
  const user = await getUserDoc(uid);
  if (!user?.fcmToken) return;

  await admin.messaging().send({
    token: user.fcmToken,
    notification: { title, body },
  });
}

export async function verifyFacultyAuth(
  context: { auth?: { uid: string; token: admin.auth.DecodedIdToken } }
): Promise<string> {
  if (!context.auth) {
    throw new Error('Authentication required.');
  }
  if (context.auth.token.role !== 'faculty') {
    throw new Error('Faculty access required.');
  }
  return context.auth.uid;
}
