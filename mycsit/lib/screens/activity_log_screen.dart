import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/mock_auth_provider.dart';
import '../data/repositories/activity_repository.dart';
import '../data/repositories/coding_repository.dart';
import '../data/models/activity_model.dart';
import '../data/models/coding_activity_model.dart';
import '../screens/functional_activity_detail_screen.dart';
import '../screens/coding_activity_detail_screen.dart';

class ActivityLogScreen extends ConsumerStatefulWidget {
  const ActivityLogScreen({super.key});

  @override
  ConsumerState<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends ConsumerState<ActivityLogScreen> {
  String _selectedFilter = 'All';
  List<Map<String, dynamic>> _allEntries = [];
  List<Map<String, dynamic>> _filteredEntries = [];
  bool _isLoading = true;

  final List<String> _filters = ['All', 'Pending', 'Approved', 'Rejected'];

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    final user = ref.read(mockCurrentUserProvider);
    if (user != null) {
      try {
        final activities = await ActivityRepository.getActivities(user.id);
        final codingActivities = await CodingRepository.getCodingActivities(user.id);

        final allEntries = <Map<String, dynamic>>[];
        
        // Add activities
        for (final activity in activities) {
          allEntries.add({
            'type': 'activity',
            'data': activity,
            'title': activity.title,
            'date': activity.date,
            'status': activity.status.name,
            'category': activity.type.name,
            'createdAt': activity.createdAt,
          });
        }

        // Add coding activities
        for (final codingActivity in codingActivities) {
          allEntries.add({
            'type': 'coding',
            'data': codingActivity,
            'title': codingActivity.title,
            'date': codingActivity.createdAt,
            'status': codingActivity.status.name,
            'category': codingActivity.type.name,
            'createdAt': codingActivity.createdAt,
          });
        }

        // Sort by date (most recent first)
        allEntries.sort((a, b) {
          final dateA = a['createdAt'] as DateTime;
          final dateB = b['createdAt'] as DateTime;
          return dateB.compareTo(dateA);
        });

        setState(() {
          _allEntries = allEntries;
          _filteredEntries = allEntries;
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
        title: const Text('Activity Log'),
        backgroundColor: const Color(0xFFFF6B35),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildFilterTabs(),
          Expanded(child: _buildActivityList()),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: _filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          final count = _getFilterCount(filter);
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilter = filter;
                  _applyFilter();
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFF6B35) : Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      filter,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    if (count > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white.withOpacity(0.3) : Colors.grey[400],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          count.toString(),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActivityList() {
    if (_filteredEntries.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredEntries.length,
      itemBuilder: (context, index) {
        final entry = _filteredEntries[index];
        return _buildActivityCard(entry);
      },
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> entry) {
    final data = entry['data'];
    final type = entry['type'];
    final status = entry['status'];
    final category = entry['category'];
    final date = entry['date'];

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
        onTap: () => _navigateToDetail(entry),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildLeadingIndicator(type, category),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry['title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusBadge(status),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildTypeBadge(type, category),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(date),
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

  Widget _buildLeadingIndicator(String type, String category) {
    Color color;
    IconData icon;

    if (type == 'activity') {
      switch (category.toLowerCase()) {
        case 'hackathon':
          color = Colors.purple;
          icon = Icons.emoji_events;
          break;
        case 'certification':
          color = Colors.blue;
          icon = Icons.school;
          break;
        case 'research':
          color = Colors.pink;
          icon = Icons.science;
          break;
        case 'project':
          color = Colors.green;
          icon = Icons.code;
          break;
        case 'internship':
          color = Colors.orange;
          icon = Icons.work;
          break;
        case 'achievement':
          color = Colors.red;
          icon = Icons.military_tech;
          break;
        default:
          color = Colors.grey;
          icon = Icons.event;
      }
    } else {
      switch (category.toLowerCase()) {
        case 'milestone':
          color = Colors.cyan;
          icon = Icons.flag;
          break;
        case 'contest':
          color = Colors.deepOrange;
          icon = Icons.emoji_events;
          break;
        case 'highvalueproblem':
          color = Colors.indigo;
          icon = Icons.code;
          break;
        default:
          color = Colors.grey;
          icon = Icons.computer;
      }
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(
        icon,
        color: color,
        size: 20,
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

  Widget _buildTypeBadge(String type, String category) {
    Color color;
    
    if (type == 'activity') {
      color = const Color(0xFFFF6B35);
    } else {
      color = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        category.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No $_selectedFilter activities',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start adding activities to see them here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  int _getFilterCount(String filter) {
    if (filter == 'All') return _allEntries.length;
    
    return _allEntries.where((entry) {
      final status = entry['status'];
      return status.toLowerCase() == filter.toLowerCase();
    }).length;
  }

  void _applyFilter() {
    if (_selectedFilter == 'All') {
      setState(() {
        _filteredEntries = _allEntries;
      });
    } else {
      setState(() {
        _filteredEntries = _allEntries.where((entry) {
          final status = entry['status'];
          return status.toLowerCase() == _selectedFilter.toLowerCase();
        }).toList();
      });
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _navigateToDetail(Map<String, dynamic> entry) {
    final type = entry['type'];
    final data = entry['data'];

    if (type == 'activity') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FunctionalActivityDetailScreen(activity: data as ActivityModel),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CodingActivityDetailScreen(activity: data as CodingActivityModel),
        ),
      );
    }
  }
}
