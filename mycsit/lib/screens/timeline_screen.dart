import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/mock_auth_provider.dart';
import '../data/database/local_database.dart';
import '../data/models/activity_model.dart';
import '../data/models/coding_activity_model.dart';
import 'package:go_router/go_router.dart';
import '../screens/functional_activity_detail_screen.dart';
import '../screens/coding_activity_detail_screen.dart';

class TimelineScreen extends ConsumerStatefulWidget {
  const TimelineScreen({super.key});

  @override
  ConsumerState<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends ConsumerState<TimelineScreen> {
  String _selectedFilter = 'All';
  String _selectedStatus = 'All';

  final List<String> _filters = [
    'All', 'Hackathon', 'Certification', 'Research', 'Project', 'Internship', 
    'Achievement', 'Milestone', 'Contest'
  ];

  final List<String> _statusFilters = ['All', 'Pending', 'Approved', 'Rejected'];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(mockCurrentUserProvider);
    
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timeline'),
        backgroundColor: const Color(0xFFFF6B35),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          _buildStatusToggle(),
          Expanded(child: _buildTimelineList(user.id)),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: _filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              backgroundColor: Colors.grey[200],
              selectedColor: const Color(0xFFFF6B35).withOpacity(0.2),
              labelStyle: TextStyle(
                color: isSelected ? const Color(0xFFFF6B35) : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatusToggle() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: _statusFilters.map((status) {
          final isSelected = _selectedStatus == status;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedStatus = status;
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFF6B35) : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    status,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTimelineList(String userId) {
    return FutureBuilder(
      future: _getFilteredTimelineEntries(userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final entries = snapshot.data!;
        
        if (entries.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            return _buildTimelineEntryCard(entry);
          },
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _getFilteredTimelineEntries(String userId) async {
    final allEntries = await LocalDatabase.getTimelineEntries(userId);
    
    // Filter by type
    List<Map<String, dynamic>> filteredEntries = allEntries.where((entry) {
      if (_selectedFilter == 'All') return true;
      
      final entryType = entry['entryType'];
      final type = entry['type'];
      
      if (entryType == 'activity') {
        return type.toString().toLowerCase() == _selectedFilter.toLowerCase();
      } else if (entryType == 'coding') {
        if (_selectedFilter == 'Milestone' && type == 'milestone') return true;
        if (_selectedFilter == 'Contest' && type == 'contest') return true;
      }
      
      return false;
    }).toList();

    // Filter by status
    if (_selectedStatus != 'All') {
      filteredEntries = filteredEntries.where((entry) {
        final status = entry['status'];
        return status.toString().toLowerCase() == _selectedStatus.toLowerCase();
      }).toList();
    }

    return filteredEntries;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timeline_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Your journey starts here',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Log your first activity or coding milestone',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.go('/add-entry');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Add Entry'),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineEntryCard(Map<String, dynamic> entry) {
    final entryType = entry['entryType'];
    final type = entry['type'];
    final title = entry['title'];
    final date = entryType == 'activity' ? entry['date'] : entry['createdAt'];
    final status = entry['status'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: InkWell(
        onTap: () {
          _navigateToDetail(entry);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 4,
          decoration: BoxDecoration(
            color: _getTypeColor(entryType, type),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildTypeBadge(entryType, type),
                    const Spacer(),
                    _buildStatusBadge(status),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateTime.parse(date).toString().split(' ')[0],
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(String entryType, String type) {
    switch (entryType) {
      case 'activity':
        switch (type) {
          case 'hackathon': return const Color(0xFF8B5CF6);
          case 'certification': return const Color(0xFF3B82F6);
          case 'research': return const Color(0xFFEC4899);
          case 'project': return const Color(0xFF10B981);
          case 'internship': return const Color(0xFFF59E0B);
          case 'achievement': return const Color(0xFFEF4444);
        }
        break;
      case 'coding':
        switch (type) {
          case 'milestone': return const Color(0xFF06B6D4);
          case 'contest': return const Color(0xFFFF6B35);
          case 'highValueProblem': return const Color(0xFF8B5CF6);
        }
        break;
    }
    return Colors.grey;
  }

  Widget _buildTypeBadge(String entryType, String type) {
    String label;
    Color color = _getTypeColor(entryType, type);
    
    if (entryType == 'activity') {
      label = type.toString().split('.').last.toUpperCase();
    } else {
      label = type.toString().split('.').last.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
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

  void _navigateToDetail(Map<String, dynamic> entry) {
    final entryType = entry['entryType'];
    
    if (entryType == 'activity') {
      final activity = ActivityModel.fromMap(entry);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const FunctionalActivityDetailScreen(activity: null),
        ),
      );
    } else if (entryType == 'coding') {
      final codingActivity = CodingActivityModel.fromMap(entry);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CodingActivityDetailScreen(activity: codingActivity),
        ),
      );
    }
  }
}
