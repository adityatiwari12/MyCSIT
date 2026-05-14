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
  final int? value; // for milestones: problem count; for contests: rank
  final String? contestName;
  final String? difficulty; // for highValueProblem
  final List<String>? proofUrls;
  final CodingStatus status;
  final String? rejectionReason;
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
    this.proofUrls,
    this.status = CodingStatus.pending,
    this.rejectionReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

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
      'proofUrls': proofUrls,
      'status': status.name,
      'rejectionReason': rejectionReason,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory CodingActivityModel.fromMap(Map<String, dynamic> map) {
    return CodingActivityModel(
      id: map['id'],
      userId: map['userId'],
      platform: map['platform'],
      type: CodingType.values.firstWhere((e) => e.name == map['type']),
      title: map['title'],
      value: map['value'],
      contestName: map['contestName'],
      difficulty: map['difficulty'],
      proofUrls: map['proofUrls'] != null ? List<String>.from(map['proofUrls']) : null,
      status: CodingStatus.values.firstWhere((e) => e.name == map['status']),
      rejectionReason: map['rejectionReason'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
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
    List<String>? proofUrls,
    CodingStatus? status,
    String? rejectionReason,
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
      proofUrls: proofUrls ?? this.proofUrls,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
