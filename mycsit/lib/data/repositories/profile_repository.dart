import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import '../database/local_database.dart';
import '../models/profile_model.dart';

class ProfileRepository {
  static Future<ProfileModel?> getProfile(String userId) async {
    return await LocalDatabase.getProfile(userId);
  }

  static Future<void> createOrUpdateProfile(ProfileModel profile) async {
    final existingProfile = await getProfile(profile.userId);
    if (existingProfile == null) {
      await LocalDatabase.insertProfile(profile);
    } else {
      await LocalDatabase.updateProfile(profile);
    }
  }

  static Future<String> uploadProfilePhoto(File imageFile, String userId) async {
    try {
      // For local storage, we'll save to app's documents directory
      final documentsDir = Directory.systemTemp;
      final fileName = '${userId}_profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedFile = File(path.join(documentsDir.path, fileName));
      
      // Compress image
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        savedFile.absolute.path,
        quality: 80,
        minWidth: 200,
        minHeight: 200,
      );
      
      if (compressedFile != null) {
          return compressedFile.path;
        }
      
      // Fallback to original file
      await imageFile.copy(savedFile.path);
      return savedFile.path;
    } catch (e) {
      throw Exception('Failed to upload profile photo: $e');
    }
  }

  static Future<File?> pickProfilePhoto() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick profile photo: $e');
    }
  }

  static Future<void> updateSocialLink(String userId, String platform, String url) async {
    final profile = await getProfile(userId);
    if (profile == null) {
      throw Exception('Profile not found');
    }
    
    final updatedSocialLinks = Map<String, String>.from(profile.socialLinks);
    updatedSocialLinks[platform] = url;
    
    final updatedProfile = profile.copyWith(
      socialLinks: updatedSocialLinks,
      updatedAt: DateTime.now(),
    );
    
    await LocalDatabase.updateProfile(updatedProfile);
  }

  static Future<void> removeSocialLink(String userId, String platform) async {
    final profile = await getProfile(userId);
    if (profile == null) {
      throw Exception('Profile not found');
    }
    
    final updatedSocialLinks = Map<String, String>.from(profile.socialLinks);
    updatedSocialLinks.remove(platform);
    
    final updatedProfile = profile.copyWith(
      socialLinks: updatedSocialLinks,
      updatedAt: DateTime.now(),
    );
    
    await LocalDatabase.updateProfile(updatedProfile);
  }

  static bool validateSocialLink(String platform, String url) {
    if (url.isEmpty) return false;
    
    switch (platform.toLowerCase()) {
      case 'linkedin':
        return url.contains('linkedin.com');
      case 'github':
        return url.contains('github.com');
      case 'leetcode':
        return url.contains('leetcode.com');
      case 'codeforces':
        return url.contains('codeforces.com');
      case 'codechef':
        return url.contains('codechef.com');
      case 'portfolio':
        // Basic URL validation for portfolio
        return Uri.tryParse(url)?.hasAbsolutePath ?? false;
      default:
        return false;
    }
  }

  static Future<Map<String, int>> getProfileStats(String userId) async {
    final profile = await getProfile(userId);
    if (profile == null) {
      return {
        'completeness': 0,
        'socialLinks': 0,
      };
    }
    
    int socialLinksCount = profile.socialLinks.values.where((url) => url.isNotEmpty).length;
    int completeness = (profile.profileCompleteness * 100).round();
    
    return {
      'completeness': completeness,
      'socialLinks': socialLinksCount,
    };
  }
}
