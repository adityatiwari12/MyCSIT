import '../data/models/activity_model.dart';
import '../data/models/coding_activity_model.dart';

/// Weights: hackathon=35%, project=25%, academic=25%, coding=15%
class ScoringService {
  static const double _wHackathon = 0.35;
  static const double _wProject = 0.25;
  static const double _wAcademic = 0.25;
  static const double _wCoding = 0.15;

  // ── Public API ─────────────────────────────────────────────────────────────

  static Map<String, double> compute({
    required List<ActivityModel> activities,
    required List<CodingActivityModel> codingActivities,
    double? cgpa,
  }) {
    final approved =
        activities.where((a) => a.status == ActivityStatus.approved).toList();
    final approvedCoding =
        codingActivities.where((c) => c.status == CodingStatus.approved).toList();

    final hackathon = _hackathonBucket(approved);
    final project = _projectBucket(approved);
    final academic = _academicBucket(cgpa);
    final coding = _codingBucket(approvedCoding);

    final total = hackathon * _wHackathon +
        project * _wProject +
        academic * _wAcademic +
        coding * _wCoding;

    return {
      'total': double.parse(total.toStringAsFixed(2)),
      'hackathon': double.parse(hackathon.toStringAsFixed(2)),
      'project': double.parse(project.toStringAsFixed(2)),
      'academic': double.parse(academic.toStringAsFixed(2)),
      'coding': double.parse(coding.toStringAsFixed(2)),
    };
  }

  // ── Bucket computations ────────────────────────────────────────────────────

  /// Hackathon bucket: hackathon(1.0), achievement(0.7), certification(0.5).
  /// Top 3 per sub-type, capped at 100.
  static double _hackathonBucket(List<ActivityModel> approved) {
    const weights = {
      ActivityType.hackathon: 1.0,
      ActivityType.achievement: 0.7,
      ActivityType.certification: 0.5,
    };

    double score = 0;
    for (final entry in weights.entries) {
      final items = approved
          .where((a) => a.type == entry.key)
          .take(3)
          .toList();
      for (int i = 0; i < items.length; i++) {
        // Diminishing returns: 1st=full, 2nd=0.7, 3rd=0.5
        final multiplier = i == 0
            ? 1.0
            : i == 1
                ? 0.7
                : 0.5;
        score += 30.0 * entry.value * multiplier;
      }
    }
    return score.clamp(0, 100);
  }

  /// Project bucket: project(40), internship(60), research(50), top 3 each.
  static double _projectBucket(List<ActivityModel> approved) {
    const basePoints = {
      ActivityType.project: 40.0,
      ActivityType.internship: 60.0,
      ActivityType.research: 50.0,
    };

    double score = 0;
    for (final entry in basePoints.entries) {
      final items = approved.where((a) => a.type == entry.key).take(3);
      for (final _ in items) {
        score += entry.value;
      }
    }
    return score.clamp(0, 100);
  }

  /// Academic bucket: CGPA on 10-point scale → 0..100
  static double _academicBucket(double? cgpa) {
    if (cgpa == null || cgpa <= 0) return 0;
    return (cgpa * 10).clamp(0, 100);
  }

  /// Coding bucket: milestones + contest ranks + notable problems.
  static double _codingBucket(List<CodingActivityModel> approved) {
    double score = 0;
    for (final c in approved) {
      switch (c.type) {
        case CodingType.milestone:
          final v = c.value ?? 0;
          if (v >= 1000) score += 50;
          else if (v >= 500) score += 40;
          else if (v >= 200) score += 30;
          else if (v >= 100) score += 20;
          else if (v >= 50) score += 10;
          break;
        case CodingType.contest:
          final rank = c.value ?? 9999;
          if (rank <= 10) score += 50;
          else if (rank <= 100) score += 40;
          else if (rank <= 1000) score += 30;
          else score += 20;
          break;
        case CodingType.highValueProblem:
          score += 15;
          break;
      }
    }
    return score.clamp(0, 100);
  }
}
