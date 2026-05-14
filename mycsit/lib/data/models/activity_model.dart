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
  final List<String>? proofUrls;
  final ActivityStatus status;
  final String? rejectionReason;
  final String? approvedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  ActivityModel({
    String? id,
    required this.userId,
    required this.type,
    required this.title,
    required this.description,
    required this.date,
    this.proofUrls,
    this.status = ActivityStatus.pending,
    this.rejectionReason,
    this.approvedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type.name,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'proofUrls': proofUrls,
      'status': status.name,
      'rejectionReason': rejectionReason,
      'approvedBy': approvedBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ActivityModel.fromMap(Map<String, dynamic> map) {
    return ActivityModel(
      id: map['id'],
      userId: map['userId'],
      type: ActivityType.values.firstWhere((e) => e.name == map['type']),
      title: map['title'],
      description: map['description'],
      date: DateTime.parse(map['date']),
      proofUrls: map['proofUrls'] != null ? List<String>.from(map['proofUrls']) : null,
      status: ActivityStatus.values.firstWhere((e) => e.name == map['status']),
      rejectionReason: map['rejectionReason'],
      approvedBy: map['approvedBy'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  ActivityModel copyWith({
    String? id,
    String? userId,
    ActivityType? type,
    String? title,
    String? description,
    DateTime? date,
    List<String>? proofUrls,
    ActivityStatus? status,
    String? rejectionReason,
    String? approvedBy,
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
      proofUrls: proofUrls ?? this.proofUrls,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      approvedBy: approvedBy ?? this.approvedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
