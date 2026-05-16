class StudentModel {
  final String id;
  final String name;
  final String rollNumber;
  final int year;
  final String section;
  final String role;
  final String status;
  final String? rejectionReason;
  final DateTime createdAt;

  const StudentModel({
    required this.id,
    required this.name,
    required this.rollNumber,
    required this.year,
    required this.section,
    required this.role,
    required this.status,
    this.rejectionReason,
    required this.createdAt,
  });

  bool get isActive => status == 'active';
  bool get isPending => status == 'pending';
  bool get isRejected => status == 'rejected';
  bool get isFaculty => role == 'faculty';

  factory StudentModel.fromMap(Map<String, dynamic> map) {
    return StudentModel(
      id: map['id'] as String,
      name: map['name'] as String,
      rollNumber: map['roll_number'] as String,
      year: map['year'] as int,
      section: map['section'] as String,
      role: map['role'] as String? ?? 'student',
      status: map['status'] as String? ?? 'pending',
      rejectionReason: map['rejection_reason'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'roll_number': rollNumber,
      'year': year,
      'section': section,
      'role': role,
      'status': status,
      'rejection_reason': rejectionReason,
      'created_at': createdAt.toIso8601String(),
    };
  }

  StudentModel copyWith({
    String? id,
    String? name,
    String? rollNumber,
    int? year,
    String? section,
    String? role,
    String? status,
    String? rejectionReason,
    DateTime? createdAt,
  }) {
    return StudentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      rollNumber: rollNumber ?? this.rollNumber,
      year: year ?? this.year,
      section: section ?? this.section,
      role: role ?? this.role,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
