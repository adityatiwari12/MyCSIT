import 'activity_model.dart';

enum CodingPlatform { leetcode, codeforces, codechef, other }
enum CodingType { milestone, contest }

class CodingActivityModel {
  final String id;
  final String userId;
  final CodingPlatform platform;
  final CodingType codingType;
  final EntryStatus status;
  final String title;
  final int value;
  final String? proofUrl;
  final String? rejectionReason;
  final String? approvedBy;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CodingActivityModel({
    required this.id,
    required this.userId,
    required this.platform,
    required this.codingType,
    required this.status,
    required this.title,
    required this.value,
    this.proofUrl,
    this.rejectionReason,
    this.approvedBy,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CodingActivityModel.fromMap(Map<String, dynamic> map) {
    return CodingActivityModel(
      id: map['id'] as String? ?? '',
      userId: map['user_id'] as String? ?? '',
      platform: _parsePlatform(map['platform'] as String?),
      codingType: _parseCodingType(map['type'] as String?),
      status: _parseStatus(map['status'] as String?),
      title: map['title'] as String? ?? '',
      value: (map['value'] as num?)?.toInt() ?? 0,
      proofUrl: map['proof_url'] as String?,
      rejectionReason: map['rejection_reason'] as String?,
      approvedBy: map['approved_by'] as String?,
      isDeleted: map['is_deleted'] as bool? ?? false,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'user_id': userId,
        'platform': platform.name,
        'type': codingType.name,
        'status': status.name,
        'title': title,
        'value': value,
        'proof_url': proofUrl,
        'rejection_reason': rejectionReason,
        'approved_by': approvedBy,
        'is_deleted': isDeleted,
        'created_at': createdAt.toIso8601String(),
      };

  static EntryStatus _parseStatus(String? s) {
    switch (s) {
      case 'approved':
        return EntryStatus.approved;
      case 'rejected':
        return EntryStatus.rejected;
      default:
        return EntryStatus.pending;
    }
  }

  static CodingPlatform _parsePlatform(String? p) {
    switch (p) {
      case 'leetcode':
        return CodingPlatform.leetcode;
      case 'codeforces':
        return CodingPlatform.codeforces;
      case 'codechef':
        return CodingPlatform.codechef;
      default:
        return CodingPlatform.other;
    }
  }

  static CodingType _parseCodingType(String? t) {
    return t == 'contest' ? CodingType.contest : CodingType.milestone;
  }

  String get platformLabel {
    switch (platform) {
      case CodingPlatform.leetcode:
        return 'LeetCode';
      case CodingPlatform.codeforces:
        return 'Codeforces';
      case CodingPlatform.codechef:
        return 'CodeChef';
      case CodingPlatform.other:
        return 'Other';
    }
  }

  CodingActivityModel copyWith({
    EntryStatus? status,
    String? proofUrl,
    String? rejectionReason,
    String? approvedBy,
    bool? isDeleted,
  }) =>
      CodingActivityModel(
        id: id,
        userId: userId,
        platform: platform,
        codingType: codingType,
        status: status ?? this.status,
        title: title,
        value: value,
        proofUrl: proofUrl ?? this.proofUrl,
        rejectionReason: rejectionReason ?? this.rejectionReason,
        approvedBy: approvedBy ?? this.approvedBy,
        isDeleted: isDeleted ?? this.isDeleted,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );
}
