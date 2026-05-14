import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import '../database/hive_database.dart';
import '../models/activity_model.dart';

class ActivityRepository {
  static Future<List<ActivityModel>> getActivities(String userId) async {
    return await HiveDatabase.getActivities(userId);
  }

  static Future<List<ActivityModel>> getActivitiesByStatus(String userId, String status) async {
    return await HiveDatabase.getActivitiesByStatus(userId, status);
  }

  static Future<void> addActivity(ActivityModel activity) async {
    await HiveDatabase.insertActivity(activity);
  }

  static Future<List<String>> uploadProofs(List<File> files, String userId, String activityId) async {
    try {
      final documentsDir = Directory.systemTemp;
      List<String> paths = [];
      int index = 0;
      for (final file in files) {
        final fileName = '${userId}_${activityId}_${index}_${path.basename(file.path)}';
        final savedFile = File(path.join(documentsDir.path, fileName));
        
        if (file.path.toLowerCase().endsWith('.jpg') || 
            file.path.toLowerCase().endsWith('.jpeg') || 
            file.path.toLowerCase().endsWith('.png')) {
          
          final compressedFile = await FlutterImageCompress.compressAndGetFile(
            file.absolute.path,
            savedFile.absolute.path,
            quality: 80,
          );
          
          if (compressedFile != null) {
            paths.add(compressedFile.path);
            index++;
            continue;
          }
        }
        
        await file.copy(savedFile.path);
        paths.add(savedFile.path);
        index++;
      }
      return paths;
    } catch (e) {
      throw Exception('Failed to upload proofs: $e');
    }
  }

  static Future<void> updateActivity(ActivityModel activity) async {
    await HiveDatabase.updateActivity(activity);
  }

  static Future<void> deleteActivity(String id) async {
    await HiveDatabase.deleteActivity(id);
  }

  static Future<void> resubmitActivity(String id, ActivityModel updatedData) async {
    // Only allow resubmission if status is rejected
    final activities = await HiveDatabase.getActivities(updatedData.userId);
    final existingActivity = activities.firstWhere((a) => a.id == id);
    
    if (existingActivity.status != ActivityStatus.rejected) {
      throw Exception('Only rejected activities can be resubmitted');
    }
    
    final resubmittedActivity = existingActivity.copyWith(
      title: updatedData.title,
      description: updatedData.description,
      date: updatedData.date,
      proofUrls: updatedData.proofUrls,
      status: ActivityStatus.pending,
      rejectionReason: null,
      updatedAt: DateTime.now(),
    );
    
    await HiveDatabase.updateActivity(resubmittedActivity);
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

  static Future<int> getTotalScore(String userId) async {
    final activities = await getActivities(userId);
    int totalScore = 0;
    
    for (final activity in activities) {
      if (activity.status == ActivityStatus.approved) {
        totalScore += _getActivityPoints(activity.type);
      }
    }
    
    return totalScore;
  }

  static int _getActivityPoints(ActivityType type) {
    switch (type) {
      case ActivityType.hackathon:
        return 100;
      case ActivityType.certification:
        return 50;
      case ActivityType.research:
        return 80;
      case ActivityType.project:
        return 60;
      case ActivityType.internship:
        return 120;
      case ActivityType.achievement:
        return 40;
    }
  }
}
