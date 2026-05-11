enum EntryStatus { pending, approved, rejected }
enum ActivityType { hackathon, achievement, certification, internship, research, project }

class ActivityModel {
  final String id;
  final String userId;
  final ActivityType type;
  final EntryStatus status;
  final String title;
  final String? description;
  final String? proofUrl;
  final String? rejectionReason;
  final String? approvedBy;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ActivityModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.status,
    required this.title,
    this.description,
    this.proofUrl,
    this.rejectionReason,
    this.approvedBy,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ActivityModel.fromMap(Map<String, dynamic> map) {
    return ActivityModel(
      id: map['id'] as String? ?? '',
      userId: map['user_id'] as String? ?? '',
      type: _parseType(map['type'] as String?),
      status: _parseStatus(map['status'] as String?),
      title: map['title'] as String? ?? '',
      description: map['description'] as String?,
      proofUrl: map['proof_url'] as String?,
      rejectionReason: map['rejection_reason'] as String?,
      approvedBy: map['approved_by'] as String?,
      isDeleted: map['is_deleted'] as bool? ?? false,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'user_id': userId,
        'type': type.name,
        'status': status.name,
        'title': title,
        'description': description,
        'proof_url': proofUrl,
        'rejection_reason': rejectionReason,
        'approved_by': approvedBy,
        'is_deleted': isDeleted,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
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

  static ActivityType _parseType(String? t) {
    switch (t) {
      case 'hackathon':
        return ActivityType.hackathon;
      case 'achievement':
        return ActivityType.achievement;
      case 'certification':
        return ActivityType.certification;
      case 'internship':
        return ActivityType.internship;
      case 'research':
        return ActivityType.research;
      default:
        return ActivityType.project;
    }
  }

  String get typeLabel {
    switch (type) {
      case ActivityType.hackathon:
        return 'Hackathon';
      case ActivityType.achievement:
        return 'Achievement';
      case ActivityType.certification:
        return 'Certification';
      case ActivityType.internship:
        return 'Internship';
      case ActivityType.research:
        return 'Research';
      case ActivityType.project:
        return 'Project';
    }
  }

  ActivityModel copyWith({
    EntryStatus? status,
    String? proofUrl,
    String? rejectionReason,
    String? approvedBy,
    bool? isDeleted,
  }) =>
      ActivityModel(
        id: id,
        userId: userId,
        type: type,
        status: status ?? this.status,
        title: title,
        description: description,
        proofUrl: proofUrl ?? this.proofUrl,
        rejectionReason: rejectionReason ?? this.rejectionReason,
        approvedBy: approvedBy ?? this.approvedBy,
        isDeleted: isDeleted ?? this.isDeleted,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );
}
