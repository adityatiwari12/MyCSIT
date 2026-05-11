import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/activity_model.dart';
import '../models/coding_activity_model.dart';
import '../models/semester_model.dart';
import 'auth_provider.dart';
import 'user_provider.dart';

// ─── Activities ───────────────────────────────────────────────────────────────

final activitiesStreamProvider = StreamProvider<List<ActivityModel>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return const Stream.empty();
  return ref.watch(firestoreServiceProvider).activitiesStream(uid);
});

// ─── Coding Activities ────────────────────────────────────────────────────────

final codingActivitiesStreamProvider = StreamProvider<List<CodingActivityModel>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return const Stream.empty();
  return ref.watch(firestoreServiceProvider).codingActivitiesStream(uid);
});

// ─── Academics ────────────────────────────────────────────────────────────────

final semestersStreamProvider = StreamProvider<List<SemesterModel>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return const Stream.empty();
  return ref.watch(firestoreServiceProvider).semestersStream(uid);
});

// ─── Score shortcut ───────────────────────────────────────────────────────────

final scoreCacheProvider = Provider((ref) {
  return ref.watch(currentUserProvider).valueOrNull?.scoreCache;
});
