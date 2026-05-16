class ProfileModel {
  final String userId;
  final String? bio;
  final String? profilePhotoUrl;
  final String? linkedinUrl;
  final String? githubUrl;
  final String? portfolioUrl;
  final String? leetcodeUrl;
  final String? codeforcesUrl;
  final String? codechefUrl;
  final int profileCompleteness;
  final DateTime? updatedAt;

  const ProfileModel({
    required this.userId,
    this.bio,
    this.profilePhotoUrl,
    this.linkedinUrl,
    this.githubUrl,
    this.portfolioUrl,
    this.leetcodeUrl,
    this.codeforcesUrl,
    this.codechefUrl,
    this.profileCompleteness = 0,
    this.updatedAt,
  });

  // ── Hive serialisation (legacy camelCase) ─────────────────────────────────

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'bio': bio,
      'profilePhotoUrl': profilePhotoUrl,
      'linkedinUrl': linkedinUrl,
      'githubUrl': githubUrl,
      'portfolioUrl': portfolioUrl,
      'leetcodeUrl': leetcodeUrl,
      'codeforcesUrl': codeforcesUrl,
      'codechefUrl': codechefUrl,
      'profileCompleteness': profileCompleteness,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      userId: map['userId'] as String? ?? map['user_id'] as String? ?? '',
      bio: map['bio'] as String?,
      profilePhotoUrl:
          map['profilePhotoUrl'] as String? ?? map['profile_photo_url'] as String?,
      linkedinUrl:
          map['linkedinUrl'] as String? ?? map['linkedin_url'] as String?,
      githubUrl: map['githubUrl'] as String? ?? map['github_url'] as String?,
      portfolioUrl:
          map['portfolioUrl'] as String? ?? map['portfolio_url'] as String?,
      leetcodeUrl:
          map['leetcodeUrl'] as String? ?? map['leetcode_url'] as String?,
      codeforcesUrl:
          map['codeforcesUrl'] as String? ?? map['codeforces_url'] as String?,
      codechefUrl:
          map['codechefUrl'] as String? ?? map['codechef_url'] as String?,
      profileCompleteness:
          map['profileCompleteness'] as int? ?? map['profile_completeness'] as int? ?? 0,
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : map['updated_at'] != null
              ? DateTime.parse(map['updated_at'] as String)
              : null,
    );
  }

  // ── Supabase serialisation ────────────────────────────────────────────────

  factory ProfileModel.fromSupabaseMap(Map<String, dynamic> map) {
    return ProfileModel(
      userId: map['user_id'] as String,
      bio: map['bio'] as String?,
      profilePhotoUrl: map['profile_photo_url'] as String?,
      linkedinUrl: map['linkedin_url'] as String?,
      githubUrl: map['github_url'] as String?,
      portfolioUrl: map['portfolio_url'] as String?,
      leetcodeUrl: map['leetcode_url'] as String?,
      codeforcesUrl: map['codeforces_url'] as String?,
      codechefUrl: map['codechef_url'] as String?,
      profileCompleteness: map['profile_completeness'] as int? ?? 0,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toSupabaseMap() {
    return {
      'user_id': userId,
      'bio': bio,
      'profile_photo_url': profilePhotoUrl,
      'linkedin_url': linkedinUrl,
      'github_url': githubUrl,
      'portfolio_url': portfolioUrl,
      'leetcode_url': leetcodeUrl,
      'codeforces_url': codeforcesUrl,
      'codechef_url': codechefUrl,
      'profile_completeness': computedCompleteness,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  int get computedCompleteness {
    int filled = 0;
    const total = 7;
    if (bio?.isNotEmpty == true) filled++;
    if (linkedinUrl?.isNotEmpty == true) filled++;
    if (githubUrl?.isNotEmpty == true) filled++;
    if (leetcodeUrl?.isNotEmpty == true) filled++;
    if (codeforcesUrl?.isNotEmpty == true) filled++;
    if (codechefUrl?.isNotEmpty == true) filled++;
    if (portfolioUrl?.isNotEmpty == true) filled++;
    return ((filled / total) * 100).round();
  }

  ProfileModel copyWith({
    String? userId,
    String? bio,
    String? profilePhotoUrl,
    String? linkedinUrl,
    String? githubUrl,
    String? portfolioUrl,
    String? leetcodeUrl,
    String? codeforcesUrl,
    String? codechefUrl,
    int? profileCompleteness,
    DateTime? updatedAt,
  }) {
    return ProfileModel(
      userId: userId ?? this.userId,
      bio: bio ?? this.bio,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      githubUrl: githubUrl ?? this.githubUrl,
      portfolioUrl: portfolioUrl ?? this.portfolioUrl,
      leetcodeUrl: leetcodeUrl ?? this.leetcodeUrl,
      codeforcesUrl: codeforcesUrl ?? this.codeforcesUrl,
      codechefUrl: codechefUrl ?? this.codechefUrl,
      profileCompleteness: profileCompleteness ?? this.profileCompleteness,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
