import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/activity_model.dart';
import '../models/coding_activity_model.dart';
import '../models/semester_model.dart';

class FirestoreService {
  final _client = Supabase.instance.client;

  // ─── User ────────────────────────────────────────────────────────────────────

  Stream<UserModel?> userStream(String uid) {
    return _client
        .from('users')
        .stream(primaryKey: ['id'])
        .eq('id', uid)
        .asyncMap((rows) async {
          if (rows.isEmpty) return null;
          final row = rows.first;
          final cacheRes = await _client
              .from('score_cache')
              .select()
              .eq('user_id', uid)
              .maybeSingle();
          final profileRes = await _client
              .from('user_profiles')
              .select()
              .eq('user_id', uid)
              .maybeSingle();
          return UserModel.fromMap(
            row,
            scoreCache: cacheRes,
            profile: profileRes,
          );
        });
  }

  Future<UserModel?> getUser(String uid) async {
    final row = await _client
        .from('users')
        .select()
        .eq('id', uid)
        .maybeSingle();
    if (row == null) return null;
    final cacheRes = await _client
        .from('score_cache')
        .select()
        .eq('user_id', uid)
        .maybeSingle();
    final profileRes = await _client
        .from('user_profiles')
        .select()
        .eq('user_id', uid)
        .maybeSingle();
    return UserModel.fromMap(row, scoreCache: cacheRes, profile: profileRes);
  }

  Future<void> updateFcmToken(String uid, String token) => _client
      .from('users')
      .update({'fcm_token': token}).eq('id', uid);

  Future<void> updateSocialLinks(String uid, SocialLinks links) => _client
      .from('user_profiles')
      .upsert({
        'user_id': uid,
        ...links.toMap(),
        'updated_at': DateTime.now().toIso8601String(),
      });

  // ─── Activities ──────────────────────────────────────────────────────────────

  Stream<List<ActivityModel>> activitiesStream(String userId) {
    return _client
        .from('activities')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((rows) => rows
            .where((r) => r['is_deleted'] != true)
            .map(ActivityModel.fromMap)
            .toList());
  }

  Future<void> addActivity({
    required String userId,
    required ActivityType type,
    required String title,
    String? description,
    String? proofUrl,
  }) async {
    final now = DateTime.now().toIso8601String();
    await _client.from('activities').insert({
      'user_id': userId,
      'type': type.name,
      'status': 'pending',
      'title': title,
      'description': description,
      'proof_url': proofUrl,
      'is_deleted': false,
      'created_at': now,
      'updated_at': now,
    });
  }

  Future<void> updateActivity(
    String activityId, {
    String? title,
    String? description,
    String? proofUrl,
  }) async {
    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
      'status': 'pending',
    };
    if (title != null) updates['title'] = title;
    if (description != null) updates['description'] = description;
    if (proofUrl != null) updates['proof_url'] = proofUrl;
    await _client.from('activities').update(updates).eq('id', activityId);
  }

  Future<void> deleteActivity(String activityId) => _client
      .from('activities')
      .update({
        'is_deleted': true,
        'updated_at': DateTime.now().toIso8601String(),
      })
      .eq('id', activityId);

  // ─── Coding Activities ───────────────────────────────────────────────────────

  Stream<List<CodingActivityModel>> codingActivitiesStream(String userId) {
    return _client
        .from('coding_activities')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((rows) => rows
            .where((r) => r['is_deleted'] != true)
            .map(CodingActivityModel.fromMap)
            .toList());
  }

  Future<void> addCodingActivity({
    required String userId,
    required CodingPlatform platform,
    required CodingType codingType,
    required String title,
    required int value,
    String? proofUrl,
  }) async {
    await _client.from('coding_activities').insert({
      'user_id': userId,
      'platform': platform.name,
      'type': codingType.name,
      'status': 'pending',
      'title': title,
      'value': value,
      'proof_url': proofUrl,
      'is_deleted': false,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> deleteCodingActivity(String id) => _client
      .from('coding_activities')
      .update({'is_deleted': true})
      .eq('id', id);

  // ─── Academics ───────────────────────────────────────────────────────────────

  Stream<List<SemesterModel>> semestersStream(String userId) {
    return _client
        .from('semesters')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('sem_number', ascending: true)
        .asyncMap((_) => getSemesters(userId));
  }

  Future<List<SemesterModel>> getSemesters(String userId) async {
    final sems = await _client
        .from('semesters')
        .select('*, subjects(*), attendance(*)')
        .eq('user_id', userId)
        .order('sem_number');

    return sems.map((s) {
      final subjects = (s['subjects'] as List<dynamic>? ?? [])
          .map((sub) => SubjectMark.fromMap(sub as Map<String, dynamic>))
          .toList();
      final attList = s['attendance'] as List<dynamic>? ?? [];
      final att =
          attList.isNotEmpty ? attList.first as Map<String, dynamic> : null;
      final total = (att?['total_classes'] as num?)?.toInt() ?? 0;
      final attended = (att?['attended'] as num?)?.toInt() ?? 0;
      final attPct =
          total > 0 ? (attended / total * 100) : null;

      return SemesterModel(
        id: s['id'] as String? ?? '',
        userId: userId,
        semesterNumber: (s['sem_number'] as num?)?.toInt() ?? 1,
        cgpa: (s['cgpa'] as num?)?.toDouble(),
        subjects: subjects,
        attendance: attPct,
        updatedAt: s['updated_at'] != null
            ? DateTime.parse(s['updated_at'] as String)
            : DateTime.now(),
      );
    }).toList();
  }
}
