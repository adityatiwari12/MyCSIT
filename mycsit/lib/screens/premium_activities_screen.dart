import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_theme.dart';
import '../core/components/premium_card.dart';
import '../core/components/premium_chip.dart';
import '../core/components/premium_empty_state.dart';
import '../services/mock_data_service.dart';

class PremiumActivitiesScreen extends StatefulWidget {
  const PremiumActivitiesScreen({super.key});

  @override
  State<PremiumActivitiesScreen> createState() => _PremiumActivitiesScreenState();
}

class _PremiumActivitiesScreenState extends State<PremiumActivitiesScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Workshop', 'Seminar', 'Competition', 'Project'];

  @override
  Widget build(BuildContext context) {
    final activities = MockDataService.getActivities();
    final filteredActivities = _selectedFilter == 'All'
        ? activities
        : activities.where((a) => a.type.toLowerCase() == _selectedFilter.toLowerCase()).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            _buildAppBar(context),
            
            // Filter Chips
            _buildFilterChips(),
            
            // Activities List
            Expanded(
              child: filteredActivities.isEmpty
                  ? PremiumEmptyState(
                      icon: Icons.event_busy,
                      title: 'No activities found',
                      subtitle: 'Try changing your filter or check back later',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppTheme.spacingMd),
                      itemCount: filteredActivities.length,
                      itemBuilder: (context, index) {
                        final activity = filteredActivities[index];
                        return _buildActivityCard(context, activity, index);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Add activity feature coming soon!'),
              backgroundColor: AppTheme.warning,
            ),
          );
        },
        backgroundColor: AppTheme.primaryAccent,
        icon: const Icon(Icons.add),
        label: const Text('Add Activity'),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      child: Row(
        children: [
          Text(
            'Activities',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              boxShadow: AppTheme.shadowSm,
            ),
            child: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // Search functionality
              },
            ),
          ),
          const SizedBox(width: AppTheme.spacingSm),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              boxShadow: AppTheme.shadowSm,
            ),
            child: IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () {
                // Advanced filter
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: AppTheme.spacingSm),
            child: PremiumChip(
              label: filter,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  _selectedFilter = filter;
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildActivityCard(BuildContext context, dynamic activity, int index) {
    final color = _getActivityColor(activity.type);
    final icon = _getActivityIcon(activity.type);

    return PremiumCard(
      onTap: () {
        // Navigate to activity detail
      },
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and points
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppTheme.radiusLg),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingSm),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Icon(icon, size: 24, color: color),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: AppTheme.spacingXxs),
                      Text(
                        activity.type,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingSm,
                    vertical: AppTheme.spacingXs,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.add,
                        size: 14,
                        color: AppTheme.primaryAccent,
                      ),
                      const SizedBox(width: AppTheme.spacingXxs),
                      Text(
                        '${activity.points} pts',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: AppTheme.primaryAccent,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                        height: 1.5,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppTheme.spacingMd),
                
                // Metadata row
                Row(
                  children: [
                    _buildMetadataItem(
                      Icons.calendar_today,
                      activity.date,
                      AppTheme.textSecondary,
                    ),
                    const SizedBox(width: AppTheme.spacingLg),
                    _buildMetadataItem(
                      Icons.location_on,
                      'Online',
                      AppTheme.textSecondary,
                    ),
                    const Spacer(),
                    StatusChip(
                      label: 'Approved',
                      status: StatusType.approved,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildMetadataItem(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: AppTheme.spacingXxs),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
              ),
        ),
      ],
    );
  }

  Color _getActivityColor(String type) {
    switch (type.toLowerCase()) {
      case 'workshop':
        return AppTheme.info;
      case 'seminar':
        return AppTheme.warning;
      case 'competition':
        return AppTheme.error;
      case 'project':
        return AppTheme.success;
      default:
        return AppTheme.primaryAccent;
    }
  }

  IconData _getActivityIcon(String type) {
    switch (type.toLowerCase()) {
      case 'workshop':
        return Icons.build;
      case 'seminar':
        return Icons.record_voice_over;
      case 'competition':
        return Icons.emoji_events;
      case 'project':
        return Icons.code;
      default:
        return Icons.event;
    }
  }
}
