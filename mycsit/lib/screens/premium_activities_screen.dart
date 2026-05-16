import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';
import '../data/models/activity_model.dart';
import '../data/models/coding_activity_model.dart';
import '../providers/auth_provider.dart';
import '../providers/supabase_providers.dart';
import 'add_activity_sheet.dart';
import 'add_coding_sheet.dart';

class PremiumActivitiesScreen extends ConsumerStatefulWidget {
  const PremiumActivitiesScreen({super.key});

  @override
  ConsumerState<PremiumActivitiesScreen> createState() =>
      _PremiumActivitiesScreenState();
}

class _PremiumActivitiesScreenState
    extends ConsumerState<PremiumActivitiesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String _activityFilter = 'All';

  static const _activityFilters = [
    'All',
    'Hackathon',
    'Certification',
    'Research',
    'Project',
    'Internship',
    'Achievement',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(currentUidProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, uid),
            TabBar(
              controller: _tabController,
              labelColor: AppTheme.primaryAccent,
              unselectedLabelColor: AppTheme.textMuted,
              indicatorColor: AppTheme.primaryAccent,
              tabs: const [
                Tab(text: 'Activities'),
                Tab(text: 'Coding'),
              ],
            ),
            Expanded(
              child: uid == null
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildActivitiesTab(uid),
                        _buildCodingTab(uid),
                      ],
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context),
        backgroundColor: AppTheme.primaryAccent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Entry',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String? uid) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppTheme.spacingMd, AppTheme.spacingMd,
          AppTheme.spacingMd, AppTheme.spacingXs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'My Activities',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          if (uid != null) _NotificationBell(uid: uid),
        ],
      ),
    );
  }

  Widget _buildActivitiesTab(String uid) {
    final activitiesAsync = ref.watch(activitiesProvider(uid));

    return activitiesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
          child: Text('Error loading activities.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppTheme.textMuted))),
      data: (activities) {
        final filtered = _activityFilter == 'All'
            ? activities
            : activities
                .where((a) =>
                    a.type.name.toLowerCase() ==
                    _activityFilter.toLowerCase())
                .toList();

        return Column(
          children: [
            _buildActivityFilters(),
            Expanded(
              child: filtered.isEmpty
                  ? _buildEmpty('No activities yet',
                      'Add your first activity to get started.')
                  : ListView.builder(
                      padding:
                          const EdgeInsets.all(AppTheme.spacingMd),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) =>
                          _buildActivityCard(filtered[i]),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActivityFilters() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
        itemCount: _activityFilters.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppTheme.spacingXs),
        itemBuilder: (_, i) {
          final f = _activityFilters[i];
          final isSelected = _activityFilter == f;
          return ChoiceChip(
            label: Text(f),
            selected: isSelected,
            onSelected: (_) => setState(() => _activityFilter = f),
            selectedColor: AppTheme.primaryAccent,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          );
        },
      ),
    );
  }

  Widget _buildCodingTab(String uid) {
    final codingAsync = ref.watch(codingActivitiesProvider(uid));

    return codingAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Center(
          child: Text('Error loading coding activities.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppTheme.textMuted))),
      data: (activities) {
        if (activities.isEmpty) {
          return _buildEmpty('No coding activities yet',
              'Add your first coding achievement to get started.');
        }
        return ListView.builder(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          itemCount: activities.length,
          itemBuilder: (_, i) => _buildCodingCard(activities[i]),
        );
      },
    );
  }

  Widget _buildActivityCard(ActivityModel a) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      child: InkWell(
        onTap: () => context.push('/app/activity/${a.id}'),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: AppTheme.border),
            boxShadow: AppTheme.shadowSm,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _activityColor(a.type).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Icon(_activityIcon(a.type),
                    color: _activityColor(a.type), size: 24),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_activityTypeName(a.type)} · ${a.date.day}/${a.date.month}/${a.date.year}',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
              _statusBadge(a.status.name),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCodingCard(CodingActivityModel a) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      child: InkWell(
        onTap: () => context.push('/app/coding/${a.id}'),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: AppTheme.border),
            boxShadow: AppTheme.shadowSm,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.info.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: const Icon(Icons.code, color: AppTheme.info, size: 24),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${a.platform} · ${_codingTypeName(a.type)}',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
              _statusBadge(a.status.name),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    Color bg;
    switch (status) {
      case 'approved':
        color = AppTheme.success;
        bg = AppTheme.successLight;
        break;
      case 'rejected':
        color = AppTheme.error;
        bg = AppTheme.errorLight;
        break;
      default:
        color = AppTheme.warning;
        bg = AppTheme.warningLight;
    }
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingXs, vertical: 4),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
      child: Text(
        status.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
      ),
    );
  }

  Widget _buildEmpty(String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: AppTheme.textMuted),
            const SizedBox(height: AppTheme.spacingMd),
            Text(title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: AppTheme.spacingXs),
            Text(subtitle,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppTheme.textMuted),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    final tab = _tabController.index;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          tab == 0 ? const AddActivitySheet() : const AddCodingSheet(),
    );
  }

  Color _activityColor(ActivityType type) {
    switch (type) {
      case ActivityType.hackathon:
        return AppTheme.warning;
      case ActivityType.certification:
        return AppTheme.success;
      case ActivityType.research:
        return AppTheme.info;
      case ActivityType.project:
        return AppTheme.primaryAccent;
      case ActivityType.internship:
        return const Color(0xFF9C27B0);
      case ActivityType.achievement:
        return const Color(0xFFFF9800);
    }
  }

  IconData _activityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.hackathon:
        return Icons.emoji_events;
      case ActivityType.certification:
        return Icons.workspace_premium;
      case ActivityType.research:
        return Icons.science;
      case ActivityType.project:
        return Icons.code;
      case ActivityType.internship:
        return Icons.work_outline;
      case ActivityType.achievement:
        return Icons.military_tech;
    }
  }

  String _activityTypeName(ActivityType type) {
    switch (type) {
      case ActivityType.hackathon:
        return 'Hackathon';
      case ActivityType.certification:
        return 'Certification';
      case ActivityType.research:
        return 'Research';
      case ActivityType.project:
        return 'Project';
      case ActivityType.internship:
        return 'Internship';
      case ActivityType.achievement:
        return 'Achievement';
    }
  }

  String _codingTypeName(CodingType type) {
    switch (type) {
      case CodingType.milestone:
        return 'Milestone';
      case CodingType.contest:
        return 'Contest';
      case CodingType.highValueProblem:
        return 'Notable Problem';
    }
  }
}

class _NotificationBell extends ConsumerWidget {
  final String uid;
  const _NotificationBell({required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(unreadNotificationCountProvider(uid));
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined,
              color: AppTheme.textSecondary),
          onPressed: () => context.push('/app/notifications'),
        ),
        if (count > 0)
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: AppTheme.error,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  count > 9 ? '9+' : '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
