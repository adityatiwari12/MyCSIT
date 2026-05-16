import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';
import '../core/components/premium_card.dart';
import '../core/components/premium_progress.dart';
import '../core/components/animated_counter.dart';
import '../providers/auth_provider.dart';
import '../providers/supabase_providers.dart';
import '../services/auth_service.dart';

class PremiumHomeScreen extends ConsumerWidget {
  const PremiumHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentAsync = ref.watch(currentStudentProvider);
    final student = studentAsync.valueOrNull;
    final uid = ref.watch(currentUidProvider);

    if (uid == null || student == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final scoreAsync = ref.watch(scoreCacheProvider(uid));
    final activitiesAsync = ref.watch(activitiesProvider(uid));
    final codingAsync = ref.watch(codingActivitiesProvider(uid));
    final rankAsync = ref.watch(studentRankProvider(uid));

    final score = scoreAsync.valueOrNull ?? {};
    final activities = activitiesAsync.valueOrNull ?? [];
    final codingActivities = codingAsync.valueOrNull ?? [];
    final rank = rankAsync.valueOrNull;

    final totalScore = score['total'] ?? 0.0;
    final activityCount = activities.length;
    final codingCount = codingActivities.length;
    final approvedCount =
        activities.where((a) => a.status.name == 'approved').length;

    final firstName = student.name.split(' ').first;
    final initials = student.name
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0])
        .join();

    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _buildAppBar(context, greeting, firstName, uid),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: AppTheme.spacingMd),
                  _buildProfileCard(
                    context, initials, student.name,
                    student.year, student.section,
                    totalScore, activityCount, rank,
                  ),
                  const SizedBox(height: AppTheme.spacingLg),
                  _buildStatsRow(context, activityCount, codingCount, approvedCount),
                  const SizedBox(height: AppTheme.spacingLg),
                  _buildScoreBreakdown(context, score),
                  const SizedBox(height: AppTheme.spacingLg),
                  _buildActivityHeatmap(context, activities, codingActivities),
                  const SizedBox(height: AppTheme.spacingLg),
                  _buildRecentActivity(context, activities, codingActivities, uid),
                  const SizedBox(height: AppTheme.spacing2xl),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(
      BuildContext context, String greeting, String firstName, String uid) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppTheme.spacingMd, AppTheme.spacingMd,
          AppTheme.spacingMd, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting,',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                Text(
                  firstName,
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          _NotificationBell(uid: uid),
          IconButton(
            icon: const Icon(Icons.logout, color: AppTheme.textSecondary),
            onPressed: () async => AuthService.signOut(),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(
    BuildContext context,
    String initials,
    String name,
    int year,
    String section,
    double totalScore,
    int activityCount,
    int? rank,
  ) {
    return PremiumCard(
      isElevated: true,
      hasGradient: true,
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: AppTheme.shadowColored,
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Year $year · Section $section',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),
          const Divider(),
          const SizedBox(height: AppTheme.spacingMd),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _stat(context, 'Total Score',
                  totalScore > 0 ? totalScore.toStringAsFixed(1) : '—',
                  Icons.star),
              _stat(context, 'Activities', '$activityCount', Icons.event),
              _stat(context, 'Rank',
                  rank != null ? '#$rank' : '—', Icons.emoji_events),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.08, end: 0);
  }

  Widget _stat(
      BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryAccent),
        const SizedBox(height: AppTheme.spacingXs),
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _buildStatsRow(
      BuildContext context, int activityCount, int codingCount, int approvedCount) {
    return Row(
      children: [
        Expanded(
          child: AnimatedScoreCard(
            label: 'Activities',
            score: activityCount,
            icon: Icons.event,
            color: AppTheme.info,
          ),
        ),
        const SizedBox(width: AppTheme.spacingMd),
        Expanded(
          child: AnimatedScoreCard(
            label: 'Coding',
            score: codingCount,
            icon: Icons.code,
            color: AppTheme.success,
          ),
        ),
        const SizedBox(width: AppTheme.spacingMd),
        Expanded(
          child: AnimatedScoreCard(
            label: 'Approved',
            score: approvedCount,
            icon: Icons.check_circle_outline,
            color: AppTheme.warning,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 150.ms);
  }

  Widget _buildScoreBreakdown(
      BuildContext context, Map<String, double> score) {
    if (score.isEmpty) return const SizedBox.shrink();

    final buckets = [
      ('Hackathon', score['hackathon'] ?? 0, AppTheme.warning, 0.35),
      ('Project', score['project'] ?? 0, AppTheme.info, 0.25),
      ('Academic', score['academic'] ?? 0, AppTheme.success, 0.25),
      ('Coding', score['coding'] ?? 0, AppTheme.primaryAccent, 0.15),
    ];

    final total = score['total'] ?? 0;

    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PremiumCardHeader(
            title: 'Score Breakdown',
            subtitle: 'Total: ${total.toStringAsFixed(1)} pts',
            icon: Icons.bar_chart,
            iconColor: AppTheme.primaryAccent,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          ...buckets.map((b) {
            final (label, val, color, weight) = b;
            final maxPossible = 100.0 * weight;
            final progress = maxPossible > 0
                ? (val / maxPossible).clamp(0.0, 1.0)
                : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(label,
                          style: Theme.of(context).textTheme.bodySmall),
                      Text('${val.toStringAsFixed(1)} / ${(maxPossible).toStringAsFixed(0)}',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(color: color, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingXs),
                  PremiumProgressBar(
                      progress: progress.toDouble(),
                      progressColor: color,
                      height: 6),
                ],
              ),
            );
          }),
        ],
      ),
    ).animate().fadeIn(delay: 250.ms);
  }

  Widget _buildActivityHeatmap(BuildContext context, List activities,
      List codingActivities) {
    // Build a 7-week heatmap of activity counts per day
    final now = DateTime.now();
    final Map<String, int> countByDay = {};

    void mark(DateTime d) {
      final key =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      countByDay[key] = (countByDay[key] ?? 0) + 1;
    }

    for (final a in activities) {
      mark(a.date as DateTime);
    }
    for (final c in codingActivities) {
      mark(c.createdAt as DateTime);
    }

    // 7 weeks × 7 days grid
    final weeks = <List<DateTime>>[];
    DateTime cursor = now.subtract(Duration(days: now.weekday - 1 + 6 * 7));
    for (int w = 0; w < 7; w++) {
      final week = <DateTime>[];
      for (int d = 0; d < 7; d++) {
        week.add(cursor);
        cursor = cursor.add(const Duration(days: 1));
      }
      weeks.add(week);
    }

    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PremiumCardHeader(
            title: 'Activity Heatmap',
            subtitle: 'Last 7 weeks',
            icon: Icons.calendar_today,
            iconColor: AppTheme.primaryAccent,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day labels column
              Column(
                children: days
                    .map((d) => SizedBox(
                          height: 14,
                          child: Text(d,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(color: AppTheme.textMuted)),
                        ))
                    .toList(),
              ),
              const SizedBox(width: AppTheme.spacingXs),
              Expanded(
                child: Row(
                  children: weeks.map((week) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1),
                        child: Column(
                          children: week.map((day) {
                            final key =
                                '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
                            final count = countByDay[key] ?? 0;
                            final isFuture = day.isAfter(now);
                            return Container(
                              height: 12,
                              margin: const EdgeInsets.symmetric(vertical: 1),
                              decoration: BoxDecoration(
                                color: isFuture
                                    ? Colors.transparent
                                    : _heatColor(count),
                                borderRadius: BorderRadius.circular(2),
                                border: isFuture
                                    ? null
                                    : Border.all(
                                        color: AppTheme.border, width: 0.5),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 350.ms);
  }

  Color _heatColor(int count) {
    if (count == 0) return AppTheme.border;
    if (count == 1) return AppTheme.primaryAccent.withOpacity(0.3);
    if (count == 2) return AppTheme.primaryAccent.withOpacity(0.55);
    if (count == 3) return AppTheme.primaryAccent.withOpacity(0.75);
    return AppTheme.primaryAccent;
  }

  Widget _buildRecentActivity(BuildContext context, List activities,
      List codingActivities, String uid) {
    // Merge and sort last 5 entries
    final entries = <Map<String, dynamic>>[];
    for (final a in activities) {
      entries.add({'type': 'activity', 'title': a.title, 'status': a.status.name, 'date': a.date as DateTime, 'id': a.id});
    }
    for (final c in codingActivities) {
      entries.add({'type': 'coding', 'title': c.title, 'status': c.status.name, 'date': c.createdAt as DateTime, 'id': c.id});
    }
    entries.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
    final recent = entries.take(5).toList();

    if (recent.isEmpty) return const SizedBox.shrink();

    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PremiumCardHeader(
            title: 'Recent Activity',
            subtitle: 'Your latest entries',
            icon: Icons.history,
            iconColor: AppTheme.info,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          ...recent.map((e) {
            final isCoding = e['type'] == 'coding';
            final status = e['status'] as String;
            Color statusColor;
            switch (status) {
              case 'approved':
                statusColor = AppTheme.success;
                break;
              case 'rejected':
                statusColor = AppTheme.error;
                break;
              default:
                statusColor = AppTheme.warning;
            }
            final date = e['date'] as DateTime;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                radius: 18,
                backgroundColor: isCoding
                    ? AppTheme.info.withOpacity(0.15)
                    : AppTheme.primaryAccent.withOpacity(0.15),
                child: Icon(
                  isCoding ? Icons.code : Icons.event,
                  size: 18,
                  color: isCoding ? AppTheme.info : AppTheme.primaryAccent,
                ),
              ),
              title: Text(
                e['title'] as String,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                '${date.day}/${date.month}/${date.year}',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppTheme.textMuted),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 9,
                      ),
                ),
              ),
            );
          }),
        ],
      ),
    ).animate().fadeIn(delay: 450.ms);
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
