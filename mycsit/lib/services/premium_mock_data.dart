import 'package:flutter/material.dart';
import '../models/user_model.dart';

class PremiumMockDataService {
  static UserModel getMockUser() {
    return UserModel(
      id: 'user_001',
      name: 'Aditya Tiwari',
      email: 'aditya.tiwari@aitr.edu',
      rollNumber: 'CSIT2024001',
      year: 2,
      section: 'A',
      status: 'Active',
    );
  }

  static Map<String, dynamic> getMockDashboardData() {
    return {
      'profileStrength': 85,
      'streak': 12,
      'totalScore': 2450,
      'activitiesCount': 24,
      'codingScore': 156,
      'academicScore': 89,
      'rank': 15,
      'cgpa': 8.5,
      'attendance': 92,
      'credits': 120,
      'semester': 6,
    };
  }

  static List<Map<String, dynamic>> getMockActivities() {
    return [
      {
        'id': 'act_001',
        'title': 'AI/ML Workshop',
        'type': 'Workshop',
        'description': 'Hands-on workshop on machine learning fundamentals and neural networks',
        'points': 50,
        'date': 'Dec 10, 2024',
        'status': 'approved',
        'icon': Icons.build,
        'color': 0xFF3B82F6,
      },
      {
        'id': 'act_002',
        'title': 'Web Development Hackathon',
        'type': 'Competition',
        'description': '48-hour web development challenge with prizes',
        'points': 150,
        'date': 'Dec 5, 2024',
        'status': 'approved',
        'icon': Icons.emoji_events,
        'color': 0xFFEF4444,
      },
      {
        'id': 'act_003',
        'title': 'Cloud Computing Seminar',
        'type': 'Seminar',
        'description': 'Expert talk on AWS and cloud architecture',
        'points': 30,
        'date': 'Nov 28, 2024',
        'status': 'approved',
        'icon': Icons.record_voice_over,
        'color': 0xFFF59E0B,
      },
      {
        'id': 'act_004',
        'title': 'Open Source Contribution',
        'type': 'Project',
        'description': 'Contributed to Flutter open source project',
        'points': 100,
        'date': 'Nov 20, 2024',
        'status': 'approved',
        'icon': Icons.code,
        'color': 0xFF22C55E,
      },
      {
        'id': 'act_005',
        'title': 'Data Science Bootcamp',
        'type': 'Workshop',
        'description': 'Intensive bootcamp on data analysis and visualization',
        'points': 75,
        'date': 'Nov 15, 2024',
        'status': 'pending',
        'icon': Icons.build,
        'color': 0xFF3B82F6,
      },
    ];
  }

  static List<Map<String, dynamic>> getMockCodingStats() {
    return [
      {
        'platform': 'LeetCode',
        'problems': 350,
        'rating': 1650,
        'icon': Icons.laptop,
        'color': 0xFFF59E0B,
      },
      {
        'platform': 'Codeforces',
        'problems': 120,
        'rating': 1450,
        'icon': Icons.computer,
        'color': 0xFF3B82F6,
      },
      {
        'platform': 'CodeChef',
        'problems': 80,
        'rating': '3 stars',
        'icon': Icons.restaurant,
        'color': 0xFF22C55E,
      },
    ];
  }

  static List<Map<String, dynamic>> getMockAchievements() {
    return [
      {
        'icon': Icons.emoji_events,
        'title': 'First Activity',
        'color': 0xFFFF6B35,
        'earned': true,
      },
      {
        'icon': Icons.code,
        'title': 'Code Warrior',
        'color': 0xFF22C55E,
        'earned': true,
      },
      {
        'icon': Icons.star,
        'title': 'Top Performer',
        'color': 0xFFF59E0B,
        'earned': true,
      },
      {
        'icon': Icons.local_fire_department,
        'title': '7-Day Streak',
        'color': 0xFFEF4444,
        'earned': true,
      },
      {
        'icon': Icons.school,
        'title': 'Scholar',
        'color': 0xFF3B82F6,
        'earned': true,
      },
      {
        'icon': Icons.psychology,
        'title': 'Problem Solver',
        'color': 0xFFFF6B35,
        'earned': true,
      },
      {
        'icon': Icons.workspace_premium,
        'title': 'Profile Master',
        'color': 0xFF8B5CF6,
        'earned': false,
      },
      {
        'icon': Icons.speed,
        'title': 'Fast Learner',
        'color': 0xFFEC4899,
        'earned': false,
      },
    ];
  }

  static List<Map<String, dynamic>> getMockOpportunities() {
    return [
      {
        'title': 'Hackathon 2024',
        'description': '48-hour coding challenge',
        'points': '+150 pts',
        'icon': Icons.emoji_events,
        'color': 0xFFFF6B35,
        'deadline': 'Dec 20, 2024',
      },
      {
        'title': 'Research Internship',
        'description': 'Apply for summer research program',
        'points': '+200 pts',
        'icon': Icons.science,
        'color': 0xFF22C55E,
        'deadline': 'Dec 25, 2024',
      },
      {
        'title': 'Tech Talk Series',
        'description': 'Industry expert sessions',
        'points': '+50 pts',
        'icon': Icons.mic,
        'color': 0xFF3B82F6,
        'deadline': 'Dec 30, 2024',
      },
    ];
  }

  static List<Map<String, dynamic>> getMockDeadlines() {
    return [
      {
        'title': 'Activity Report',
        'subtitle': 'Due in 2 days',
        'date': 'Dec 15',
        'color': 0xFFF59E0B,
      },
      {
        'title': 'Coding Submission',
        'subtitle': 'Due in 5 days',
        'date': 'Dec 18',
        'color': 0xFF3B82F6,
      },
      {
        'title': 'Project Proposal',
        'subtitle': 'Due in 1 week',
        'date': 'Dec 22',
        'color': 0xFF22C55E,
      },
    ];
  }

  static List<String> getMockSkills() {
    return [
      'Flutter',
      'Dart',
      'Python',
      'JavaScript',
      'React',
      'Node.js',
      'Machine Learning',
      'UI/UX',
      'Git',
      'SQL',
    ];
  }

  static List<List<double>> getMockActivityHeatmap() {
    return [
      [0.2, 0.5, 0.8, 0.3, 0.9, 0.1, 0.4], // Week 1
      [0.6, 0.7, 0.4, 0.8, 0.5, 0.3, 0.2], // Week 2
      [0.9, 0.3, 0.6, 0.7, 0.8, 0.5, 0.1], // Week 3
      [0.4, 0.8, 0.2, 0.9, 0.6, 0.7, 0.3], // Week 4
    ];
  }
}
