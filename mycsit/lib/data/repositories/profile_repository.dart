import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../database/hive_database.dart';
import '../models/profile_model.dart';
import '../../services/storage_service.dart';

class ProfileRepository {
  static final _client = Supabase.instance.client;
  static final _storage = StorageService();

  static Future<ProfileModel?> getProfile(String userId) async {
    try {
      final row = await _client
          .from('user_profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      if (row == null) return null;
      final profile = ProfileModel.fromSupabaseMap(row);
      await HiveDatabase.insertProfile(profile);
      return profile;
    } catch (_) {
      return HiveDatabase.getProfile(userId);
    }
  }

  static Future<void> upsertProfile(ProfileModel profile) async {
    final updated = profile.copyWith(updatedAt: DateTime.now());
    await HiveDatabase.updateProfile(updated);
    try {
      await _client
          .from('user_profiles')
          .upsert(updated.toSupabaseMap(), onConflict: 'user_id');
    } catch (_) {}
  }

  static Future<String?> uploadProfilePhoto(
      File imageFile, String userId) async {
    try {
      return await _storage.uploadProof(
        userId: userId,
        entryType: 'profile',
        file: imageFile,
      );
    } catch (_) {
      return null;
    }
  }
}
