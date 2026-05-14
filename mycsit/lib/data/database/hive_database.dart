import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/activity_model.dart';
import '../models/coding_activity_model.dart';
import '../models/profile_model.dart';

class HiveDatabase {
  static const String activitiesBoxName = 'activities';
  static const String codingActivitiesBoxName = 'coding_activities';
  static const String profilesBoxName = 'profiles';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<String>(activitiesBoxName);
    await Hive.openBox<String>(codingActivitiesBoxName);
    await Hive.openBox<String>(profilesBoxName);
  }

  // Activity Operations
  static Future<void> insertActivity(ActivityModel activity) async {
    final box = Hive.box<String>(activitiesBoxName);
    await box.put(activity.id, jsonEncode(activity.toMap()));
  }

  static Future<List<ActivityModel>> getActivities(String userId) async {
    final box = Hive.box<String>(activitiesBoxName);
    final activities = box.values
        .map((jsonStr) => ActivityModel.fromMap(jsonDecode(jsonStr)))
        .where((activity) => activity.userId == userId)
        .toList();
    activities.sort((a, b) => b.date.compareTo(a.date));
    return activities;
  }

  static Future<List<ActivityModel>> getActivitiesByStatus(String userId, String status) async {
    final activities = await getActivities(userId);
    return activities.where((a) => a.status.name.toLowerCase() == status.toLowerCase()).toList();
  }

  static Future<void> updateActivity(ActivityModel activity) async {
    final box = Hive.box<String>(activitiesBoxName);
    await box.put(activity.id, jsonEncode(activity.toMap()));
  }

  static Future<void> deleteActivity(String id) async {
    final box = Hive.box<String>(activitiesBoxName);
    await box.delete(id);
  }

  // Coding Activity Operations
  static Future<void> insertCodingActivity(CodingActivityModel activity) async {
    final box = Hive.box<String>(codingActivitiesBoxName);
    await box.put(activity.id, jsonEncode(activity.toMap()));
  }

  static Future<List<CodingActivityModel>> getCodingActivities(String userId) async {
    final box = Hive.box<String>(codingActivitiesBoxName);
    final activities = box.values
        .map((jsonStr) => CodingActivityModel.fromMap(jsonDecode(jsonStr)))
        .where((activity) => activity.userId == userId)
        .toList();
    activities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return activities;
  }

  static Future<List<CodingActivityModel>> getCodingActivitiesByStatus(String userId, String status) async {
    final activities = await getCodingActivities(userId);
    return activities.where((a) => a.status.name.toLowerCase() == status.toLowerCase()).toList();
  }

  static Future<void> updateCodingActivity(CodingActivityModel activity) async {
    final box = Hive.box<String>(codingActivitiesBoxName);
    await box.put(activity.id, jsonEncode(activity.toMap()));
  }

  static Future<void> deleteCodingActivity(String id) async {
    final box = Hive.box<String>(codingActivitiesBoxName);
    await box.delete(id);
  }

  // Profile Operations
  static Future<void> insertProfile(ProfileModel profile) async {
    final box = Hive.box<String>(profilesBoxName);
    await box.put(profile.userId, jsonEncode(profile.toMap()));
  }

  static Future<ProfileModel?> getProfile(String userId) async {
    final box = Hive.box<String>(profilesBoxName);
    final jsonStr = box.get(userId);
    if (jsonStr != null) {
      return ProfileModel.fromMap(jsonDecode(jsonStr));
    }
    return null;
  }

  static Future<void> updateProfile(ProfileModel profile) async {
    await insertProfile(profile);
  }

  // Timeline Operations
  static Future<List<Map<String, dynamic>>> getTimelineEntries(String userId) async {
    final activities = await getActivities(userId);
    final codingActivities = await getCodingActivities(userId);

    final List<Map<String, dynamic>> allEntries = [];

    for (final activity in activities) {
      final map = activity.toMap();
      allEntries.add({
        ...map,
        'entryType': 'activity',
        'sortDate': map['date'],
      });
    }

    for (final codingActivity in codingActivities) {
      final map = codingActivity.toMap();
      allEntries.add({
        ...map,
        'entryType': 'coding',
        'sortDate': map['createdAt'],
      });
    }

    // Sort by date descending
    allEntries.sort((a, b) {
      final dateA = DateTime.parse(a['sortDate']);
      final dateB = DateTime.parse(b['sortDate']);
      return dateB.compareTo(dateA);
    });

    return allEntries;
  }
}
