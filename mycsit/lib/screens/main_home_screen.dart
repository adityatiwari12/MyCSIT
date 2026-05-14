import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/mock_auth_provider.dart';
import '../services/mock_auth_service.dart';
import '../services/mock_data_service.dart';
import '../data/models/profile_model.dart';
import '../data/repositories/activity_repository.dart';
import '../data/repositories/coding_repository.dart';
import '../data/repositories/profile_repository.dart';
import '../services/scoring_service.dart';
import 'timeline_screen.dart';
import 'add_entry_screen.dart';
import 'enhanced_profile_screen.dart';
import 'activity_log_screen.dart';
import 'coding_activity_screen.dart';
import 'academic_screen.dart';
import 'notifications_screen.dart';

class MainHomeScreen extends ConsumerStatefulWidget {
  const MainHomeScreen({super.key});

  @override
  ConsumerState<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends ConsumerState<MainHomeScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(mockCurrentUserProvider);
    
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          DashboardTab(user: user),
          const TimelineScreen(),
          const AddEntryScreen(),
          const EnhancedProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFFFF6B35),
          unselectedItemColor: Colors.grey[600],
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.timeline),
              activeIcon: Icon(Icons.timeline),
              label: 'Timeline',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_rounded),
              activeIcon: Icon(Icons.add_circle_rounded),
              label: 'Add',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardTab extends ConsumerWidget {
  final dynamic user;
  
  const DashboardTab({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFFFF6B35),
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Hi, ${user.name.split(' ')[0]} 👋',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications,
              color: Color(0xFFFF6B35),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildScoreCard(context, ref),
            const SizedBox(height: 24),
            _buildQuickActions(context),
            const SizedBox(height: 24),
            _buildRecentActivity(context, ref),
            const SizedBox(height: 24),
            _buildMarksSnapshot(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: Future.wait([
        ActivityRepository.getTotalScore(user.id),
        CodingRepository.getTotalScore(user.id),
        ProfileRepository.getProfile(user.id),
      ]),
      builder: (context, snapshot) {
        final activityScore = (snapshot.data?[0] as int?) ?? 0;
        final codingScore = (snapshot.data?[1] as int?) ?? 0;
        final profile = snapshot.data?[2] as ProfileModel?;
        final totalScore = activityScore + codingScore;
        final profileCompleteness = profile?.profileCompleteness ?? 0.0;

        return Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6B35), Color(0xFFFF9F1C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF6B35).withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Circular progress indicator
                SizedBox(
                  width: 80,
                  height: 80,
                  child: Stack(
                    children: [
                      CircularProgressIndicator(
                        value: profileCompleteness,
                        strokeWidth: 8,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${(profileCompleteness * 100).round()}%',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Profile',
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        totalScore.toString(),
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Total Score',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildMiniStat('Activities', activityScore as int),
                          const SizedBox(width: 16),
                          _buildMiniStat('Coding', codingScore as int),
                          const SizedBox(width: 16),
                          _buildMiniStat('Pending', 0),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMiniStat(String label, int value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildQuickActionCard(
            context,
            'Add Activity',
            Icons.add,
            () {
              Navigator.pushNamed(context, '/add/activity');
            },
          ),
          const SizedBox(width: 12),
          _buildQuickActionCard(
            context,
            'Add Coding',
            Icons.code,
            () {
              Navigator.pushNamed(context, '/add/coding');
            },
          ),
          const SizedBox(width: 12),
          _buildQuickActionCard(
            context,
            'Activity Log',
            Icons.list,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ActivityLogScreen()),
              );
            },
          ),
          const SizedBox(width: 12),
          _buildQuickActionCard(
            context,
            'Academics',
            Icons.school,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AcademicScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(BuildContext context, String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: const Color(0xFFFF6B35),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200, // Fixed height to prevent overflow
          child: FutureBuilder(
            future: Future.wait([
              ActivityRepository.getActivities(user.id),
              CodingRepository.getCodingActivities(user.id),
            ]),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final activities = snapshot.data![0] as List;
              final codingActivities = snapshot.data![1] as List;
              
              // Combine and get last 3
              final allActivities = [...activities, ...codingActivities];
              allActivities.sort((a, b) {
                final dateA = a.createdAt ?? a.date;
                final dateB = b.createdAt ?? b.date;
                return dateB.compareTo(dateA);
              });

              final recentActivities = allActivities.take(3).toList();

              if (recentActivities.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'No recent activities',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentActivities.length,
                itemBuilder: (context, index) {
                  return _buildActivityCard(recentActivities[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActivityCard(dynamic activity) {
    String title = activity.title ?? 'Unknown';
    String date = activity.date?.toString() ?? activity.createdAt?.toString() ?? '';
    String status = activity.status?.name ?? 'pending';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 3,
                  height: 30,
                  decoration: BoxDecoration(
                    color: _getStatusColor(status),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildStatusBadge(status),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              date.isNotEmpty ? DateTime.parse(date).toString().split(' ')[0] : '',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor, textColor;
    
    switch (status.toLowerCase()) {
      case 'pending':
        bgColor = Colors.amber;
        textColor = Colors.amber[700]!;
        break;
      case 'approved':
        bgColor = Colors.green;
        textColor = Colors.green[700]!;
        break;
      case 'rejected':
        bgColor = Colors.red;
        textColor = Colors.red[700]!;
        break;
      default:
        bgColor = Colors.grey;
        textColor = Colors.grey[700]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.amber;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildMarksSnapshot(BuildContext context, WidgetRef ref) {
    // Placeholder for marks snapshot
    return Container(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildSemesterCard('Sem 1', '8.5', 6),
          const SizedBox(width: 12),
          _buildSemesterCard('Sem 2', '8.8', 6),
          const SizedBox(width: 12),
          _buildSemesterCard('Sem 3', '9.2', 7),
        ],
      ),
    );
  }

  Widget _buildSemesterCard(String semester, String cgpa, int subjects) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            semester,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B35).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'CGPA: $cgpa',
              style: const TextStyle(
                color: Color(0xFFFF6B35),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$subjects subjects',
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
