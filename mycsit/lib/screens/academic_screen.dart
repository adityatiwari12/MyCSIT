import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/mock_auth_provider.dart';
import '../data/repositories/profile_repository.dart';

class AcademicScreen extends ConsumerStatefulWidget {
  const AcademicScreen({super.key});

  @override
  ConsumerState<AcademicScreen> createState() => _AcademicScreenState();
}

class _AcademicScreenState extends ConsumerState<AcademicScreen> {
  Map<String, dynamic>? _academicData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAcademicData();
  }

  Future<void> _loadAcademicData() async {
    final user = ref.read(mockCurrentUserProvider);
    if (user != null) {
      try {
        final profile = await ProfileRepository.getProfile(user.id);
        
        // Mock academic data - in real app this would come from database
        final mockAcademicData = {
          'cgpa': profile?.cgpa ?? 8.5,
          'attendance': profile?.attendance ?? 85.0,
          'semesters': [
            {
              'semester': 'Semester 1',
              'sgpa': 8.2,
              'subjects': [
                {'name': 'Mathematics I', 'grade': 'A', 'marks': 85},
                {'name': 'Physics I', 'grade': 'B+', 'marks': 78},
                {'name': 'Chemistry I', 'grade': 'A-', 'marks': 82},
                {'name': 'Programming Fundamentals', 'grade': 'A', 'marks': 88},
                {'name': 'English Communication', 'grade': 'B', 'marks': 75},
              ]
            },
            {
              'semester': 'Semester 2',
              'sgpa': 8.8,
              'subjects': [
                {'name': 'Mathematics II', 'grade': 'A', 'marks': 87},
                {'name': 'Physics II', 'grade': 'A-', 'marks': 83},
                {'name': 'Digital Logic', 'grade': 'A', 'marks': 86},
                {'name': 'Data Structures', 'grade': 'A+', 'marks': 92},
                {'name': 'Computer Organization', 'grade': 'B+', 'marks': 79},
              ]
            },
            {
              'semester': 'Semester 3',
              'sgpa': 9.2,
              'subjects': [
                {'name': 'Mathematics III', 'grade': 'A+', 'marks': 91},
                {'name': 'Database Systems', 'grade': 'A', 'marks': 89},
                {'name': 'Operating Systems', 'grade': 'A', 'marks': 85},
                {'name': 'Computer Networks', 'grade': 'A-', 'marks': 84},
                {'name': 'Web Development', 'grade': 'A+', 'marks': 93},
              ]
            },
          ]
        };
        
        setState(() {
          _academicData = mockAcademicData;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(mockCurrentUserProvider);
    
    if (user == null || _isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic Performance'),
        backgroundColor: const Color(0xFFFF6B35),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCGPABadge(),
            const SizedBox(height: 20),
            _buildAttendanceGauge(),
            const SizedBox(height: 20),
            _buildSemesterAccordion(),
          ],
        ),
      ),
    );
  }

  Widget _buildCGPABadge() {
    final cgpa = _academicData?['cgpa'] ?? 0.0;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFFF9F1C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B35).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Cumulative GPA',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            cgpa.toStringAsFixed(2),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getGradeCategory(cgpa),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceGauge() {
    final attendance = _academicData?['attendance'] ?? 0.0;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Attendance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: SizedBox(
              width: 150,
              height: 150,
              child: Stack(
                children: [
                  // Background circle
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                  ),
                  // Progress circle
                  Positioned.fill(
                    child: CircularProgressIndicator(
                      value: attendance / 100,
                      backgroundColor: Colors.transparent,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF6B35)),
                      strokeWidth: 15,
                    ),
                  ),
                  // Center text
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${attendance.round()}%',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF6B35),
                          ),
                        ),
                        const Text(
                          'Present',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAttendanceStat('Present', '${(attendance * 0.9).round()} days', Colors.green),
              _buildAttendanceStat('Absent', '${((100 - attendance) * 0.9).round()} days', Colors.red),
              _buildAttendanceStat('Total', '90 days', Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceStat(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildSemesterAccordion() {
    final semesters = _academicData?['semesters'] as List? ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Semester Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300, // Fixed height to prevent overflow
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: semesters.length,
            itemBuilder: (context, index) {
              return _buildSemesterCard(semesters[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSemesterCard(Map<String, dynamic> semester) {
    final isExpanded = false; // You can manage expansion state
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            Text(
              semester['semester'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B35).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'SGPA: ${semester['sgpa']}',
                style: const TextStyle(
                  color: Color(0xFFFF6B35),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Divider(),
                const SizedBox(height: 8),
                ...semester['subjects'].map((subject) => _buildSubjectRow(subject)).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectRow(Map<String, dynamic> subject) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              subject['name'],
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: Text(
              subject['grade'],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: _getGradeColor(subject['grade']),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: Text(
              '${subject['marks']}%',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  String _getGradeCategory(double cgpa) {
    if (cgpa >= 9.0) return 'Excellent';
    if (cgpa >= 8.0) return 'Very Good';
    if (cgpa >= 7.0) return 'Good';
    if (cgpa >= 6.0) return 'Average';
    return 'Needs Improvement';
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A+': return const Color(0xFF4CAF50);
      case 'A': return const Color(0xFF66BB6A);
      case 'A-': return const Color(0xFF81C784);
      case 'B+': return const Color(0xFF29B6F6);
      case 'B': return const Color(0xFF4FC3F7);
      case 'B-': return const Color(0xFF81D4FA);
      case 'C+': return const Color(0xFFFFB74D);
      case 'C': return const Color(0xFFFFCC80);
      case 'C-': return const Color(0xFFFFE082);
      case 'D': return const Color(0xFFFF7043);
      case 'F': return const Color(0xFFEF5350);
      default: return Colors.grey;
    }
  }
}
