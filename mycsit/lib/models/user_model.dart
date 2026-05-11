enum UserStatus { pending, active, rejected }
enum UserRole { student, faculty }

class SocialLinks {
  final String? linkedin;
  final String? github;
  final String? portfolio;
  final String? leetcode;
  final String? codeforces;
  final String? codechef;

  const SocialLinks({
    this.linkedin,
    this.github,
    this.portfolio,
    this.leetcode,
    this.codeforces,
    this.codechef,
  });

  factory SocialLinks.fromMap(Map<String, dynamic> map) => SocialLinks(
        linkedin: map['linkedin_url'] as String?,
        github: map['github_url'] as String?,
        portfolio: map['portfolio_url'] as String?,
        leetcode: map['leetcode_url'] as String?,
        codeforces: map['codeforces_url'] as String?,
        codechef: map['codechef_url'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'linkedin_url': linkedin,
        'github_url': github,
        'portfolio_url': portfolio,
        'leetcode_url': leetcode,
        'codeforces_url': codeforces,
        'codechef_url': codechef,
      };

  int get completedCount => [
        linkedin, github, portfolio, leetcode, codeforces, codechef,
      ].where((v) => v != null && v.isNotEmpty).length;
}

class ScoreCacheModel {
  final double totalScore;
  final double hackathonScore;
  final double projectScore;
  final double academicScore;
  final double codingScore;
  final DateTime lastComputed;

  const ScoreCacheModel({
    required this.totalScore,
    required this.hackathonScore,
    required this.projectScore,
    required this.academicScore,
    required this.codingScore,
    required this.lastComputed,
  });

  factory ScoreCacheModel.fromMap(Map<String, dynamic> map) => ScoreCacheModel(
        totalScore: (map['total_score'] as num?)?.toDouble() ?? 0,
        hackathonScore: (map['hackathon_score'] as num?)?.toDouble() ?? 0,
        projectScore: (map['project_score'] as num?)?.toDouble() ?? 0,
        academicScore: (map['academic_score'] as num?)?.toDouble() ?? 0,
        codingScore: (map['coding_score'] as num?)?.toDouble() ?? 0,
        lastComputed: map['last_computed'] != null
            ? DateTime.parse(map['last_computed'] as String)
            : DateTime(0),
      );

  static final ScoreCacheModel zero = ScoreCacheModel(
    totalScore: 0,
    hackathonScore: 0,
    projectScore: 0,
    academicScore: 0,
    codingScore: 0,
    lastComputed: DateTime(0),
  );
}

class UserModel {
  final String uid;
  final String name;
  final String rollNumber;
  final int year;
  final String section;
  final UserRole role;
  final UserStatus status;
  final String? rejectionReason;
  final String email;
  final String? fcmToken;
  final SocialLinks socialLinks;
  final int pendingActivityCount;
  final ScoreCacheModel? scoreCache;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.rollNumber,
    required this.year,
    required this.section,
    required this.role,
    required this.status,
    this.rejectionReason,
    required this.email,
    this.fcmToken,
    required this.socialLinks,
    required this.pendingActivityCount,
    this.scoreCache,
    required this.createdAt,
  });

  factory UserModel.fromMap(
    Map<String, dynamic> map, {
    Map<String, dynamic>? scoreCache,
    Map<String, dynamic>? profile,
  }) {
    final rollNumber = map['roll_number'] as String? ?? '';
    return UserModel(
      uid: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      rollNumber: rollNumber,
      year: (map['year'] as num?)?.toInt() ?? 1,
      section: map['section'] as String? ?? '',
      role: _parseRole(map['role'] as String?),
      status: _parseStatus(map['status'] as String?),
      rejectionReason: map['rejection_reason'] as String?,
      email: '$rollNumber@mycsit.internal',
      fcmToken: map['fcm_token'] as String?,
      socialLinks: profile != null
          ? SocialLinks.fromMap(profile)
          : const SocialLinks(),
      pendingActivityCount:
          (map['pending_activity_count'] as num?)?.toInt() ?? 0,
      scoreCache:
          scoreCache != null ? ScoreCacheModel.fromMap(scoreCache) : null,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
    );
  }

  static UserStatus _parseStatus(String? s) {
    switch (s) {
      case 'active':
        return UserStatus.active;
      case 'rejected':
        return UserStatus.rejected;
      default:
        return UserStatus.pending;
    }
  }

  static UserRole _parseRole(String? r) {
    return r == 'faculty' ? UserRole.faculty : UserRole.student;
  }

  UserModel copyWith({
    String? fcmToken,
    SocialLinks? socialLinks,
    int? pendingActivityCount,
    ScoreCacheModel? scoreCache,
  }) =>
      UserModel(
        uid: uid,
        name: name,
        rollNumber: rollNumber,
        year: year,
        section: section,
        role: role,
        status: status,
        rejectionReason: rejectionReason,
        email: email,
        fcmToken: fcmToken ?? this.fcmToken,
        socialLinks: socialLinks ?? this.socialLinks,
        pendingActivityCount:
            pendingActivityCount ?? this.pendingActivityCount,
        scoreCache: scoreCache ?? this.scoreCache,
        createdAt: createdAt,
      );
}
