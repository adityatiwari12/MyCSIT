import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/mock_auth_provider.dart';
import '../data/repositories/coding_repository.dart';
import '../data/models/coding_activity_model.dart';
import '../screens/coding_activity_detail_screen.dart';
import '../screens/add_coding_sheet.dart';

class CodingActivityScreen extends ConsumerStatefulWidget {
  const CodingActivityScreen({super.key});

  @override
  ConsumerState<CodingActivityScreen> createState() => _CodingActivityScreenState();
}

class _CodingActivityScreenState extends ConsumerState<CodingActivityScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<CodingActivityModel> _allActivities = [];
  List<CodingActivityModel> _milestones = [];
  List<CodingActivityModel> _contests = [];
  List<CodingActivityModel> _problems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCodingActivities();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCodingActivities() async {
    final user = ref.read(mockCurrentUserProvider);
    if (user != null) {
      try {
        final activities = await CodingRepository.getCodingActivities(user.id);
        
        setState(() {
          _allActivities = activities;
          _milestones = activities.where((a) => a.type == CodingType.milestone).toList();
          _contests = activities.where((a) => a.type == CodingType.contest).toList();
          _problems = activities.where((a) => a.type == CodingType.highValueProblem).toList();
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
        title: const Text('Coding Activities'),
        backgroundColor: const Color(0xFFFF6B35),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          tabs: const [
            Tab(text: 'Milestones'),
            Tab(text: 'Contests'),
            Tab(text: 'Problems'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCodingList(_milestones, 'milestone'),
          _buildCodingList(_contests, 'contest'),
          _buildCodingList(_problems, 'problem'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCodingSheet,
        backgroundColor: const Color(0xFFFF6B35),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCodingList(List<CodingActivityModel> activities, String type) {
    if (activities.isEmpty) {
      return _buildEmptyState(type);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        return _buildCodingCard(activity);
      },
    );
  }

  Widget _buildCodingCard(CodingActivityModel activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CodingActivityDetailScreen(activity: activity),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildPlatformLogo(activity.platform),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      activity.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusBadge(activity.status.name),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildValueDisplay(activity),
                  const Spacer(),
                  Text(
                    activity.platform,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlatformLogo(String platform) {
    Color color;
    IconData icon;
    String initial;

    switch (platform.toLowerCase()) {
      case 'leetcode':
        color = Colors.yellow;
        icon = Icons.code;
        initial = 'L';
        break;
      case 'codeforces':
        color = Colors.blue;
        icon = Icons.computer;
        initial = 'C';
        break;
      case 'codechef':
        color = Colors.brown;
        icon = Icons.restaurant;
        initial = 'C';
        break;
      default:
        color = Colors.grey;
        icon = Icons.code;
        initial = platform.isNotEmpty ? platform[0].toUpperCase() : 'O';
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildValueDisplay(CodingActivityModel activity) {
    String valueText;
    Color color;

    switch (activity.type) {
      case CodingType.milestone:
        valueText = '${activity.value} problems';
        color = Colors.cyan;
        break;
      case CodingType.contest:
        valueText = 'Rank ${activity.value}';
        color = Colors.deepOrange;
        break;
      case CodingType.highValueProblem:
        valueText = activity.title;
        color = Colors.indigo;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        valueText,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
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
        color: bgColor.withOpacity(0.1),
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

  Widget _buildEmptyState(String type) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getEmptyIcon(type),
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No ${type}s yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start adding your coding achievements',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _showAddCodingSheet,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
              foregroundColor: Colors.white,
            ),
            child: Text('Add ${type.capitalize()}'),
          ),
        ],
      ),
    );
  }

  IconData _getEmptyIcon(String type) {
    switch (type) {
      case 'milestone':
        return Icons.flag;
      case 'contest':
        return Icons.emoji_events;
      case 'problem':
        return Icons.code;
      default:
        return Icons.computer;
    }
  }

  void _showAddCodingSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddCodingSheet(),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
