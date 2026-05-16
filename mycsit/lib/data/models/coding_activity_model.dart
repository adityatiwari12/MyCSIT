import 'package:uuid/uuid.dart';

enum CodingType {
  milestone,
  contest,
  highValueProblem,
}

enum CodingStatus {
  pending,
  approved,
  rejected,
}

class CodingActivityModel {
  final String id;
  final String userId;
  final String platform;
  final CodingType type;
  final String title;
  final int? value;
  final String? contestName;
  final String? difficulty;
  final String? proofUrl;
  final List<String>? proofUrls;
  final CodingStatus status;
  final String? rejectionReason;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  CodingActivityModel({
    String? id,
    required this.userId,
    required this.platform,
    required this.type,
    required this.title,
    this.value,
    this.contestName,
    this.difficulty,
    this.proofUrl,
    this.proofUrls,
    this.status = CodingStatus.pending,
    this.rejectionReason,
    this.isDeleted = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // ── Hive serialisation ────────────────────────────────────────────────────

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'platform': platform,
      'type': type.name,
      'title': title,
      'value': value,
      'contestName': contestName,
      'difficulty': difficulty,
      'proofUrl': proofUrl,
      'proofUrls': proofUrls,
      'status': status.name,
      'rejectionReason': rejectionReason,
      'isDeleted': isDeleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory CodingActivityModel.fromMap(Map<String, dynamic> map) {
    return CodingActivityModel(
      id: map['id'] as String,
      userId: map['userId'] as String? ?? map['user_id'] as String? ?? '',
      platform: map['platform'] as String,
      type: CodingType.values.firstWhere(
        (e) => e.name == (map['type'] as String),
        orElse: () => CodingType.milestone,
      ),
      title: map['title'] as String,
      value: map['value'] as int?,
      contestName:
          map['contestName'] as String? ?? map['contest_name'] as String?,
      difficulty: map['difficulty'] as String?,
      proofUrl: map['proofUrl'] as String? ?? map['proof_url'] as String?,
      proofUrls: map['proofUrls'] != null
          ? List<String>.from(map['proofUrls'] as List)
          : null,
      status: CodingStatus.values.firstWhere(
        (e) => e.name == (map['status'] as String),
        orElse: () => CodingStatus.pending,
      ),
      rejectionReason:
          map['rejectionReason'] as String? ?? map['rejection_reason'] as String?,
      isDeleted: map['isDeleted'] as bool? ?? map['is_deleted'] as bool? ?? false,
      createdAt: DateTime.parse(
          map['createdAt'] as String? ?? map['created_at'] as String),
      updatedAt: DateTime.parse(
          map['updatedAt'] as String? ?? map['updated_at'] as String? ??
              map['createdAt'] as String? ?? map['created_at'] as String),
    );
  }

  // ── Supabase serialisation ────────────────────────────────────────────────

  factory CodingActivityModel.fromSupabaseMap(Map<String, dynamic> map) {
    return CodingActivityModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      platform: map['platform'] as String,
      type: CodingType.values.firstWhere(
        (e) => e.name == (map['type'] as String),
        orElse: () => CodingType.milestone,
      ),
      title: map['title'] as String,
      value: map['value'] as int?,
      contestName: map['contest_name'] as String?,
      difficulty: map['difficulty'] as String?,
      proofUrl: map['proof_url'] as String?,
      status: CodingStatus.values.firstWhere(
        (e) => e.name == (map['status'] as String),
        orElse: () => CodingStatus.pending,
      ),
      rejectionReason: map['rejection_reason'] as String?,
      isDeleted: map['is_deleted'] as bool? ?? false,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toSupabaseMap() {
    return {
      'id': id,
      'user_id': userId,
      'platform': platform.toLowerCase(),
      'type': type.name,
      'title': title,
      'value': value,
      'contest_name': contestName,
      'difficulty': difficulty,
      'proof_url': proofUrl ?? '',
      'status': status.name,
      'rejection_reason': rejectionReason,
      'is_deleted': isDeleted,
      'created_at': createdAt.toIso8601String(),
    };
  }

  CodingActivityModel copyWith({
    String? id,
    String? userId,
    String? platform,
    CodingType? type,
    String? title,
    int? value,
    String? contestName,
    String? difficulty,
    String? proofUrl,
    List<String>? proofUrls,
    CodingStatus? status,
    String? rejectionReason,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CodingActivityModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      platform: platform ?? this.platform,
      type: type ?? this.type,
      title: title ?? this.title,
      value: value ?? this.value,
      contestName: contestName ?? this.contestName,
      difficulty: difficulty ?? this.difficulty,
      proofUrl: proofUrl ?? this.proofUrl,
      proofUrls: proofUrls ?? this.proofUrls,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
