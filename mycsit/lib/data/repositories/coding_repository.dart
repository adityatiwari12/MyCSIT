import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import '../database/hive_database.dart';
import '../models/coding_activity_model.dart';

class CodingRepository {
  static Future<List<CodingActivityModel>> getCodingActivities(String userId) async {
    return await HiveDatabase.getCodingActivities(userId);
  }

  static Future<List<CodingActivityModel>> getCodingActivitiesByStatus(String userId, String status) async {
    return await HiveDatabase.getCodingActivitiesByStatus(userId, status);
  }

  static Future<void> addCodingActivity(CodingActivityModel activity) async {
    await HiveDatabase.insertCodingActivity(activity);
  }

  static Future<List<String>> uploadProofs(List<File> files, String userId, String activityId) async {
    try {
      final documentsDir = Directory.systemTemp;
      List<String> paths = [];
      int index = 0;
      for (final file in files) {
        final fileName = '${userId}_${activityId}_coding_${index}_${path.basename(file.path)}';
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

  static Future<void> updateCodingActivity(CodingActivityModel activity) async {
    await HiveDatabase.updateCodingActivity(activity);
  }

  static Future<void> deleteCodingActivity(String id) async {
    await HiveDatabase.deleteCodingActivity(id);
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
    final activities = await getCodingActivities(userId);
    int totalScore = 0;
    
    for (final activity in activities) {
      if (activity.status == CodingStatus.approved) {
        totalScore += _getActivityPoints(activity.type, activity.value);
      }
    }
    
    return totalScore;
  }

  static int _getActivityPoints(CodingType type, int? value) {
    switch (type) {
      case CodingType.milestone:
        if (value != null) {
          // Points based on milestone (50, 100, 200, 500, 1000)
          if (value >= 1000) return 100;
          if (value >= 500) return 80;
          if (value >= 200) return 60;
          if (value >= 100) return 40;
          if (value >= 50) return 20;
          return 10;
        }
        return 10;
      case CodingType.contest:
        if (value != null) {
          // Points based on rank (1-10: 100, 11-100: 80, 101-1000: 60, 1000+: 40)
          if (value <= 10) return 100;
          if (value <= 100) return 80;
          if (value <= 1000) return 60;
          return 40;
        }
        return 40;
      case CodingType.highValueProblem:
        // Points based on difficulty
        return 30; // Fixed points for notable problems
    }
  }

  static Future<Map<String, int>> getStats(String userId) async {
    final activities = await getCodingActivities(userId);
    
    int totalActivities = activities.length;
    int approvedActivities = activities.where((a) => a.status == CodingStatus.approved).length;
    int pendingActivities = activities.where((a) => a.status == CodingStatus.pending).length;
    int totalScore = await getTotalScore(userId);
    
    return {
      'total': totalActivities,
      'approved': approvedActivities,
      'pending': pendingActivities,
      'score': totalScore,
    };
  }
}
