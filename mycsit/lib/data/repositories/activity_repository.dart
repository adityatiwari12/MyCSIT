import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../database/hive_database.dart';
import '../models/activity_model.dart';
import '../../services/storage_service.dart';

class ActivityRepository {
  static final _client = Supabase.instance.client;
  static final _storage = StorageService();

  static Future<List<ActivityModel>> getActivities(String userId) async {
    try {
      final rows = await _client
          .from('activities')
          .select()
          .eq('user_id', userId)
          .eq('is_deleted', false)
          .order('created_at', ascending: false);
      final list = rows
          .map((r) => ActivityModel.fromSupabaseMap(r))
          .toList();
      // Sync to Hive cache
      for (final a in list) {
        await HiveDatabase.insertActivity(a);
      }
      return list;
    } catch (_) {
      return HiveDatabase.getActivities(userId);
    }
  }

  static Future<List<ActivityModel>> getActivitiesByStatus(
      String userId, String status) async {
    final all = await getActivities(userId);
    return all
        .where((a) => a.status.name.toLowerCase() == status.toLowerCase())
        .toList();
  }

  static Future<void> addActivity(ActivityModel activity) async {
    await HiveDatabase.insertActivity(activity);
    try {
      await _client.from('activities').insert(activity.toSupabaseMap());
    } catch (_) {
      // Stored locally; will sync when online
    }
  }

  // Upload files to Supabase Storage, returns public URLs.
  // Falls back to local file paths if upload fails.
  static Future<List<String>> uploadProofs(
      List<File> files, String userId, String activityId) async {
    final List<String> urls = [];
    for (final file in files) {
      try {
        final url = await _storage.uploadProof(
          userId: userId,
          entryType: 'activities',
          file: file,
        );
        urls.add(url);
      } catch (_) {
        urls.add(file.path);
      }
    }
    return urls;
  }

  static Future<void> updateActivity(ActivityModel activity) async {
    await HiveDatabase.updateActivity(activity);
    try {
      await _client
          .from('activities')
          .update(activity.toSupabaseMap())
          .eq('id', activity.id);
    } catch (_) {}
  }

  static Future<void> deleteActivity(String id) async {
    await HiveDatabase.deleteActivity(id);
    try {
      await _client
          .from('activities')
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
