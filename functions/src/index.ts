import * as admin from 'firebase-admin';

// Initialize Firebase Admin SDK once
admin.initializeApp();

// Callable functions
export { registerStudent } from './users/registerStudent';
export { approveStudent } from './users/approveStudent';
export { rejectStudent } from './users/rejectStudent';

// Firestore triggers
export { onActivityWrite } from './activities/onActivityWrite';
export { onCodingWrite } from './coding/onCodingWrite';
export { onAcademicsWrite } from './academics/onAcademicsWrite';
