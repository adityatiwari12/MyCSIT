class SubjectMark {
  final String name;
  final double marks;
  final double maxMarks;

  const SubjectMark({
    required this.name,
    required this.marks,
    required this.maxMarks,
  });

  factory SubjectMark.fromMap(Map<String, dynamic> map) => SubjectMark(
        name: map['name'] as String? ?? '',
        marks: (map['marks'] as num?)?.toDouble() ?? 0,
        maxMarks: (map['max_marks'] as num?)?.toDouble() ?? 100,
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'marks': marks,
        'max_marks': maxMarks,
      };
}

class SemesterModel {
  final String id;
  final String userId;
  final int semesterNumber;
  final double? cgpa;
  final List<SubjectMark> subjects;
  final double? attendance;
  final DateTime updatedAt;

  const SemesterModel({
    required this.id,
    required this.userId,
    required this.semesterNumber,
    this.cgpa,
    required this.subjects,
    this.attendance,
    required this.updatedAt,
  });
}
