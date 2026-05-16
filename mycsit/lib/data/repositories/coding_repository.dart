import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../database/hive_database.dart';
import '../models/coding_activity_model.dart';
import '../../services/storage_service.dart';

class CodingRepository {
  static final _client = Supabase.instance.client;
  static final _storage = StorageService();

  static Future<List<CodingActivityModel>> getCodingActivities(
      String userId) async {
    try {
      final rows = await _client
          .from('coding_activities')
          .select()
          .eq('user_id', userId)
          .eq('is_deleted', false)
          .order('created_at', ascending: false);
      final list = rows
          .map((r) => CodingActivityModel.fromSupabaseMap(r))
          .toList();
      for (final a in list) {
        await HiveDatabase.insertCodingActivity(a);
      }
      return list;
    } catch (_) {
      return HiveDatabase.getCodingActivities(userId);
    }
  }

  static Future<List<CodingActivityModel>> getCodingActivitiesByStatus(
      String userId, String status) async {
    final all = await getCodingActivities(userId);
    return all
        .where((a) => a.status.name.toLowerCase() == status.toLowerCase())
        .toList();
  }

  static Future<void> addCodingActivity(CodingActivityModel activity) async {
    await HiveDatabase.insertCodingActivity(activity);
    try {
      await _client.from('coding_activities').insert(activity.toSupabaseMap());
    } catch (_) {}
  }

  static Future<List<String>> uploadProofs(
      List<File> files, String userId, String activityId) async {
    final List<String> urls = [];
    for (final file in files) {
      try {
        final url = await _storage.uploadProof(
          userId: userId,
          entryType: 'coding',
          file: file,
        );
        urls.add(url);
      } catch (_) {
        urls.add(file.path);
      }
    }
    return urls;
  }

  static Future<void> updateCodingActivity(CodingActivityModel activity) async {
    await HiveDatabase.updateCodingActivity(activity);
    try {
      await _client
          .from('coding_activities')
          .update(activity.toSupabaseMap())
          .eq('id', activity.id);
    } catch (_) {}
  }

  static Future<void> deleteCodingActivity(String id) async {
    await HiveDatabase.deleteCodingActivity(id);
    try {
      await _client
          .from('coding_activities')
          .update({'is_deleted': true}).eq('id', id);
    } catch (_) {}
  }

  static Future<List<File>> pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: true,
      );
      if (result != null && result.files.isNotEmpty) {
        return result.files.map((e) => File(e.path!)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to pick files: $e');
    }
  }
}
