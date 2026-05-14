import '../data/models/activity_model.dart';
import '../data/models/coding_activity_model.dart';
import '../data/models/profile_model.dart';
import '../data/repositories/activity_repository.dart';
import '../data/repositories/coding_repository.dart';
import '../data/repositories/profile_repository.dart';

class ScoringService {
  static const double HACKATHON_WEIGHT = 0.35;
  static const double PROJECTS_WEIGHT = 0.25;
  static const double ACADEMIC_WEIGHT = 0.25;
  static const double CODING_WEIGHT = 0.15;

  static Future<Map<String, dynamic>> calculateComprehensiveScore(String userId) async {
    // Get all activities and coding activities
    final activities = await ActivityRepository.getActivities(userId);
    final codingActivities = await CodingRepository.getCodingActivities(userId);
    final profile = await ProfileRepository.getProfile(userId);

    // Calculate domain scores
    final hackathonScore = _calculateHackathonScore(activities);
    final projectsScore = _calculateProjectsScore(activities);
    final academicScore = _calculateAcademicScore(profile);
    final codingScore = await _calculateCodingScore(codingActivities);

    // Calculate weighted total
    final totalScore = (hackathonScore * HACKATHON_WEIGHT) +
                      (projectsScore * PROJECTS_WEIGHT) +
                      (academicScore * ACADEMIC_WEIGHT) +
                      (codingScore * CODING_WEIGHT);

    return {
      'totalScore': totalScore.round(),
      'domainScores': {
        'hackathons': hackathonScore,
        'projects': projectsScore,
        'academic': academicScore,
        'coding': codingScore,
      },
      'domainStats': {
        'hackathons': _getHackathonStats(activities),
        'projects': _getProjectsStats(activities),
        'coding': _getCodingStats(codingActivities),
        'academic': _getAcademicStats(profile),
      },
      'profileCompleteness': profile?.profileCompleteness ?? 0.0,
    };
  }

  static double _calculateHackathonScore(List<ActivityModel> activities) {
    final hackathonActivities = activities.where((a) => 
      a.type == ActivityType.hackathon || a.type == ActivityType.achievement
    ).where((a) => a.status == ActivityStatus.approved);
    
    double score = 0;
    for (final activity in hackathonActivities) {
      // Base points for hackathons
      score += 50;
      
      // Bonus for achievements
      if (activity.type == ActivityType.achievement) {
        score += 30;
      }
    }
    
    return score;
  }

  static double _calculateProjectsScore(List<ActivityModel> activities) {
    final projectActivities = activities.where((a) => 
      a.type == ActivityType.project || 
      a.type == ActivityType.internship || 
      a.type == ActivityType.research
    ).where((a) => a.status == ActivityStatus.approved);
    
    double score = 0;
    for (final activity in projectActivities) {
      switch (activity.type) {
        case ActivityType.project:
          score += 40;
          break;
        case ActivityType.internship:
          score += 60;
          break;
        case ActivityType.research:
          score += 50;
          break;
        default:
          score += 30;
      }
    }
    
    return score;
  }

  static double _calculateAcademicScore(ProfileModel? profile) {
    if (profile == null) return 0.0;
    
    // Use CGPA if available, otherwise use profile completeness as proxy
    double cgpa = profile.cgpa ?? 0.0;
    if (cgpa == 0.0) {
      cgpa = profile.profileCompleteness * 10; // Convert completeness to CGPA scale
    }
    
    // Normalize CGPA to score (0-10 scale to 0-100 score)
    return cgpa * 10;
  }

  static Future<double> _calculateCodingScore(List<CodingActivityModel> codingActivities) async {
    final approvedActivities = codingActivities.where((a) => a.status == CodingStatus.approved);
    
    double score = 0;
    for (final activity in approvedActivities) {
      switch (activity.type) {
        case CodingType.milestone:
          if (activity.value != null) {
            if (activity.value! >= 1000) score += 50;
            else if (activity.value! >= 500) score += 40;
            else if (activity.value! >= 200) score += 30;
            else if (activity.value! >= 100) score += 20;
            else if (activity.value! >= 50) score += 10;
          }
          break;
        case CodingType.contest:
          if (activity.value != null) {
            if (activity.value! <= 10) score += 50;
            else if (activity.value! <= 100) score += 40;
            else if (activity.value! <= 1000) score += 30;
            else score += 20;
          }
          break;
        case CodingType.highValueProblem:
          score += 15;
          break;
      }
    }
    
    return score;
  }

  static Map<String, dynamic> _getHackathonStats(List<ActivityModel> activities) {
    final hackathonActivities = activities.where((a) => 
      a.type == ActivityType.hackathon || a.type == ActivityType.achievement
    );
    
    final approved = hackathonActivities.where((a) => a.status == ActivityStatus.approved).length;
    final pending = hackathonActivities.where((a) => a.status == ActivityStatus.pending).length;
    final rejected = hackathonActivities.where((a) => a.status == ActivityStatus.rejected).length;
    
    return {
      'total': hackathonActivities.length,
      'approved': approved,
      'pending': pending,
      'rejected': rejected,
      'types': {
        'hackathons': activities.where((a) => a.type == ActivityType.hackathon).length,
        'achievements': activities.where((a) => a.type == ActivityType.achievement).length,
      }
    };
  }

  static Map<String, dynamic> _getProjectsStats(List<ActivityModel> activities) {
    final projectActivities = activities.where((a) => 
      a.type == ActivityType.project || 
      a.type == ActivityType.internship || 
      a.type == ActivityType.research
    );
    
    final approved = projectActivities.where((a) => a.status == ActivityStatus.approved).length;
    final pending = projectActivities.where((a) => a.status == ActivityStatus.pending).length;
    final rejected = projectActivities.where((a) => a.status == ActivityStatus.rejected).length;
    
    return {
      'total': projectActivities.length,
      'approved': approved,
      'pending': pending,
      'rejected': rejected,
      'types': {
        'projects': activities.where((a) => a.type == ActivityType.project).length,
        'internships': activities.where((a) => a.type == ActivityType.internship).length,
        'research': activities.where((a) => a.type == ActivityType.research).length,
      }
    };
  }

  static Map<String, dynamic> _getCodingStats(List<CodingActivityModel> codingActivities) {
    final approved = codingActivities.where((a) => a.status == CodingStatus.approved).length;
    final pending = codingActivities.where((a) => a.status == CodingStatus.pending).length;
    final rejected = codingActivities.where((a) => a.status == CodingStatus.rejected).length;
    
    return {
      'total': codingActivities.length,
      'approved': approved,
      'pending': pending,
      'rejected': rejected,
      'types': {
        'milestones': codingActivities.where((a) => a.type == CodingType.milestone).length,
        'contests': codingActivities.where((a) => a.type == CodingType.contest).length,
        'problems': codingActivities.where((a) => a.type == CodingType.highValueProblem).length,
      }
    };
  }

  static Map<String, dynamic> _getAcademicStats(ProfileModel? profile) {
    if (profile == null) {
      return {
        'cgpa': 0.0,
        'attendance': 0.0,
        'profileCompleteness': 0.0,
      };
    }
    
    return {
      'cgpa': profile.cgpa ?? 0.0,
      'attendance': profile.attendance ?? 0.0,
      'profileCompleteness': profile.profileCompleteness,
    };
  }

  static Future<List<Map<String, dynamic>>> getLeaderboard() async {
    // This is a mock implementation
    // In a real app, you'd fetch all users and calculate their scores
    return [
      {'rank': 1, 'name': 'Alice Johnson', 'score': 850, 'avatar': 'AJ'},
      {'rank': 2, 'name': 'Bob Smith', 'score': 820, 'avatar': 'BS'},
      {'rank': 3, 'name': 'Charlie Brown', 'score': 780, 'avatar': 'CB'},
      {'rank': 4, 'name': 'Diana Prince', 'score': 750, 'avatar': 'DP'},
      {'rank': 5, 'name': 'Edward Norton', 'score': 720, 'avatar': 'EN'},
    ];
  }
}
