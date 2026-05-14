import 'dart:convert';
import 'package:uuid/uuid.dart';

class ProfileModel {
  final String id;
  final String userId;
  final String name;
  final String? profilePhotoUrl;
  final Map<String, String> socialLinks;
  late final double profileCompleteness;
  final double? cgpa;
  final double? attendance;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProfileModel({
    String? id,
    required this.userId,
    required this.name,
    this.profilePhotoUrl,
    Map<String, String>? socialLinks,
    this.cgpa,
    this.attendance,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        socialLinks = socialLinks ?? {},
        profileCompleteness = _calculateProfileCompleteness(socialLinks ?? {}),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'profilePhotoUrl': profilePhotoUrl,
      'socialLinks': socialLinks,
      'cgpa': cgpa,
      'attendance': attendance,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      id: map['id'],
      userId: map['userId'],
      name: map['name'],
      profilePhotoUrl: map['profilePhotoUrl'],
      socialLinks: Map<String, String>.from(map['socialLinks'] ?? {}),
      cgpa: map['cgpa']?.toDouble(),
      attendance: map['attendance']?.toDouble(),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  ProfileModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? profilePhotoUrl,
    Map<String, String>? socialLinks,
    double? cgpa,
    double? attendance,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      socialLinks: socialLinks ?? this.socialLinks,
      cgpa: cgpa ?? this.cgpa,
      attendance: attendance ?? this.attendance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static double _calculateProfileCompleteness(Map<String, String> socialLinks) {
    int completedFields = 0;
    int totalFields = 7; // name, profilePhoto, and 5 social platforms

    // Name is always considered completed since it's required
    completedFields++;

    final platforms = ['linkedin', 'github', 'leetcode', 'codeforces', 'codechef'];
    for (final platform in platforms) {
      if (socialLinks.containsKey(platform) && socialLinks[platform]!.isNotEmpty) {
        completedFields++;
      }
    }

    return completedFields / totalFields;
  }
}
