import 'package:uuid/uuid.dart';

enum ActivityType {
  hackathon,
  certification,
  research,
  project,
  internship,
  achievement,
}

enum ActivityStatus {
  pending,
  approved,
  rejected,
}

class ActivityModel {
  final String id;
  final String userId;
  final ActivityType type;
  final String title;
  final String description;
  final DateTime date;
  final String? proofUrl;
  final List<String>? proofUrls;
  final ActivityStatus status;
  final String? rejectionReason;
  final String? approvedBy;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  ActivityModel({
    String? id,
    required this.userId,
    required this.type,
    required this.title,
    required this.description,
    required this.date,
    this.proofUrl,
    this.proofUrls,
    this.status = ActivityStatus.pending,
    this.rejectionReason,
    this.approvedBy,
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
      'type': type.name,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'proofUrl': proofUrl,
      'proofUrls': proofUrls,
      'status': status.name,
      'rejectionReason': rejectionReason,
      'approvedBy': approvedBy,
      'isDeleted': isDeleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ActivityModel.fromMap(Map<String, dynamic> map) {
    return ActivityModel(
      id: map['id'] as String,
      userId: map['userId'] as String? ?? map['user_id'] as String? ?? '',
      type: ActivityType.values.firstWhere(
        (e) => e.name == (map['type'] as String),
        orElse: () => ActivityType.achievement,
      ),
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      date: DateTime.parse(map['date'] as String),
      proofUrl: map['proofUrl'] as String? ?? map['proof_url'] as String?,
      proofUrls: map['proofUrls'] != null
          ? List<String>.from(map['proofUrls'] as List)
          : null,
      status: ActivityStatus.values.firstWhere(
        (e) => e.name == (map['status'] as String),
        orElse: () => ActivityStatus.pending,
      ),
      rejectionReason:
          map['rejectionReason'] as String? ?? map['rejection_reason'] as String?,
      approvedBy:
          map['approvedBy'] as String? ?? map['approved_by'] as String?,
      isDeleted: map['isDeleted'] as bool? ?? map['is_deleted'] as bool? ?? false,
      createdAt: DateTime.parse(
          map['createdAt'] as String? ?? map['created_at'] as String),
      updatedAt: DateTime.parse(
          map['updatedAt'] as String? ?? map['updated_at'] as String),
    );
  }

  // ── Supabase serialisation ────────────────────────────────────────────────

  factory ActivityModel.fromSupabaseMap(Map<String, dynamic> map) {
    return ActivityModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      type: ActivityType.values.firstWhere(
        (e) => e.name == (map['type'] as String),
        orElse: () => ActivityType.achievement,
      ),
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      date: DateTime.parse(map['date'] as String),
      proofUrl: map['proof_url'] as String?,
      status: ActivityStatus.values.firstWhere(
        (e) => e.name == (map['status'] as String),
        orElse: () => ActivityStatus.pending,
      ),
      rejectionReason: map['rejection_reason'] as String?,
      approvedBy: map['approved_by'] as String?,
      isDeleted: map['is_deleted'] as bool? ?? false,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toSupabaseMap() {
    return {
      'id': id,
      'user_id': userId,
      'type': type.name,
      'title': title,
      'description': description,
      'date': date.toIso8601String().split('T').first,
      'proof_url': proofUrl ?? '',
      'status': status.name,
      'rejection_reason': rejectionReason,
      'approved_by': approvedBy,
      'is_deleted': isDeleted,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ActivityModel copyWith({
    String? id,
    String? userId,
    ActivityType? type,
    String? title,
    String? description,
    DateTime? date,
    String? proofUrl,
    List<String>? proofUrls,
    ActivityStatus? status,
    String? rejectionReason,
    String? approvedBy,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ActivityModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      proofUrl: proofUrl ?? this.proofUrl,
      proofUrls: proofUrls ?? this.proofUrls,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      approvedBy: approvedBy ?? this.approvedBy,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  int get points {
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
