import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/activity_model.dart';
import '../data/models/coding_activity_model.dart';
import '../data/models/profile_model.dart';
import '../data/database/hive_database.dart';

final _client = Supabase.instance.client;

// ── Activities (realtime stream) ─────────────────────────────────────────────

final activitiesProvider =
    StreamProvider.family<List<ActivityModel>, String>((ref, userId) {
  return _client
      .from('activities')
      .stream(primaryKey: ['id'])
      .eq('user_id', userId)
      .order('created_at', ascending: false)
      .map((rows) => rows
          .where((r) => r['is_deleted'] != true)
          .map((r) => ActivityModel.fromSupabaseMap(r))
          .toList());
});

// ── Coding Activities (realtime stream) ──────────────────────────────────────

final codingActivitiesProvider =
    StreamProvider.family<List<CodingActivityModel>, String>((ref, userId) {
  return _client
      .from('coding_activities')
      .stream(primaryKey: ['id'])
      .eq('user_id', userId)
      .order('created_at', ascending: false)
      .map((rows) => rows
          .where((r) => r['is_deleted'] != true)
          .map((r) => CodingActivityModel.fromSupabaseMap(r))
          .toList());
});

// ── Timeline (merged, derived from realtime streams) ─────────────────────────

final timelineProvider =
    Provider.family<List<Map<String, dynamic>>, String>((ref, userId) {
  final activities =
      ref.watch(activitiesProvider(userId)).valueOrNull ?? [];
  final codingActivities =
      ref.watch(codingActivitiesProvider(userId)).valueOrNull ?? [];

  final List<Map<String, dynamic>> entries = [];

  for (final a in activities) {
    entries.add({
      ...a.toMap(),
      'entryType': 'activity',
      'sortDate': a.date.toIso8601String(),
    });
  }
  for (final c in codingActivities) {
    entries.add({
      ...c.toMap(),
      'entryType': 'coding',
      'sortDate': c.createdAt.toIso8601String(),
    });
  }

  entries.sort((a, b) {
    final da = DateTime.parse(a['sortDate'] as String);
    final db = DateTime.parse(b['sortDate'] as String);
    return db.compareTo(da);
  });

  return entries;
});

// ── Score Cache (realtime stream — updates when DB trigger fires) ─────────────

final scoreCacheProvider =
    StreamProvider.family<Map<String, double>, String>((ref, userId) {
  return _client
      .from('score_cache')
      .stream(primaryKey: ['user_id'])
      .eq('user_id', userId)
      .limit(1)
      .map((rows) {
    if (rows.isEmpty) return <String, double>{};
    final row = rows.first;
    return {
      'total': (row['total_score'] as num?)?.toDouble() ?? 0,
      'hackathon': (row['hackathon_score'] as num?)?.toDouble() ?? 0,
      'project': (row['project_score'] as num?)?.toDouble() ?? 0,
      'academic': (row['academic_score'] as num?)?.toDouble() ?? 0,
      'coding': (row['coding_score'] as num?)?.toDouble() ?? 0,
    };
  });
});

// ── Profile ─────────────────────────────────────────────────────────────────

final profileProvider =
    FutureProvider.family<ProfileModel?, String>((ref, userId) async {
  try {
    final row = await _client
        .from('user_profiles')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    if (row == null) return null;
    return ProfileModel.fromSupabaseMap(row);
  } catch (_) {
    return HiveDatabase.getProfile(userId);
  }
});

// ── Semesters/CGPA ──────────────────────────────────────────────────────────

final latestCgpaProvider =
    FutureProvider.family<double?, String>((ref, userId) async {
  try {
    final rows = await _client
        .from('semesters')
        .select('cgpa, updated_at')
        .eq('user_id', userId)
        .order('updated_at', ascending: false)
        .limit(1);
    if (rows.isEmpty) return null;
    final cgpa = rows.first['cgpa'];
    return cgpa != null ? (cgpa as num).toDouble() : null;
  } catch (_) {
    return null;
  }
});

// ── Leaderboard rank ─────────────────────────────────────────────────────────
// Re-fetches whenever the student's own score stream updates.

final studentRankProvider =
    FutureProvider.family<int?, String>((ref, userId) async {
  ref.watch(scoreCacheProvider(userId)); // invalidate when own score changes
  try {
    final rows = await _client
        .from('score_cache')
        .select('user_id, total_score')
        .order('total_score', ascending: false);
    final idx = rows.indexWhere((r) => r['user_id'] == userId);
    return idx >= 0 ? idx + 1 : null;
  } catch (_) {
    return null;
  }
});

// ── Notifications ────────────────────────────────────────────────────────────

final notificationsProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((ref, userId) {
  return _client
      .from('notifications')
      .stream(primaryKey: ['id'])
      .eq('user_id', userId)
      .order('created_at', ascending: false)
      .limit(50)
      .map((rows) => rows.cast<Map<String, dynamic>>());
});

final unreadNotificationCountProvider =
    Provider.family<int, String>((ref, userId) {
  final notifs = ref.watch(notificationsProvider(userId));
  return notifs.valueOrNull
          ?.where((n) => n['is_read'] == false)
          .length ??
      0;
});

Future<void> markNotificationsRead(String userId) async {
  try {
    await Supabase.instance.client
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', userId)
        .eq('is_read', false);
  } catch (_) {}
}
