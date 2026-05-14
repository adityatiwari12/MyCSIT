import 'package:flutter/foundation.dart';

class MockActivity {
  final String id;
  final String title;
  final String description;
  final String date;
  final String type;
  final int points;

  MockActivity({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.type,
    required this.points,
  });
}

class MockCodingProblem {
  final String id;
  final String title;
  final String difficulty;
  final String topic;
  final int points;
  final bool solved;

  MockCodingProblem({
    required this.id,
    required this.title,
    required this.difficulty,
    required this.topic,
    required this.points,
    this.solved = false,
  });
}

class MockAcademic {
  final String id;
  final String subject;
  final String grade;
  final String attendance;
  final List<String> topics;

  MockAcademic({
    required this.id,
    required this.subject,
    required this.grade,
    required this.attendance,
    required this.topics,
  });
}

class MockDataService {
  static final List<MockActivity> _activities = [
    MockActivity(
      id: '1',
      title: 'Flutter Workshop',
      description: 'Learn Flutter basics and build your first app',
      date: '2024-01-15',
      type: 'workshop',
      points: 50,
    ),
    MockActivity(
      id: '2',
      title: 'Web Development Seminar',
      description: 'Modern web technologies and best practices',
      date: '2024-01-20',
      type: 'seminar',
      points: 30,
    ),
  ];

  static final List<MockCodingProblem> _codingProblems = [
    MockCodingProblem(
      id: '1',
      title: 'Two Sum Problem',
      difficulty: 'Easy',
      topic: 'Arrays',
      points: 10,
    ),
    MockCodingProblem(
      id: '2',
      title: 'Binary Search',
      difficulty: 'Medium',
      topic: 'Algorithms',
      points: 20,
    ),
  ];

  static final List<MockAcademic> _academics = [
    MockAcademic(
      id: '1',
      subject: 'Data Structures',
      grade: 'A',
      attendance: '95%',
      topics: ['Arrays', 'Linked Lists', 'Trees', 'Graphs'],
    ),
    MockAcademic(
      id: '2',
      subject: 'Algorithms',
      grade: 'B+',
      attendance: '92%',
      topics: ['Sorting', 'Searching', 'Dynamic Programming'],
    ),
  ];

  static List<MockActivity> getActivities() => _activities;
  static List<MockCodingProblem> getCodingProblems() => _codingProblems;
  static List<MockAcademic> getAcademics() => _academics;
}
