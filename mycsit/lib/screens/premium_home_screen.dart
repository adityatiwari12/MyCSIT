import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_theme.dart';
import '../core/components/premium_card.dart';
import '../core/components/premium_chip.dart';
import '../core/components/premium_progress.dart';
import '../core/components/animated_counter.dart';
import '../providers/mock_auth_provider.dart';
import '../services/mock_auth_service.dart';
import '../services/mock_data_service.dart';

class PremiumHomeScreen extends ConsumerWidget {
  const PremiumHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(mockCurrentUserProvider);
    
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Custom App Bar
            SliverToBoxAdapter(
              child: _buildAppBar(context, user),
            ),
            
            // Content
            SliverPadding(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: AppTheme.spacingMd),
                  
                  // Hero Profile Card
                  _buildHeroProfileCard(context, user),
                  
                  const SizedBox(height: AppTheme.spacingLg),
                  
                  // Quick Stats Row
                  _buildQuickStatsRow(context),
                  
                  const SizedBox(height: AppTheme.spacingLg),
                  
                  // Progress Section
                  _buildProgressSection(context),
                  
                  const SizedBox(height: AppTheme.spacingLg),
                  
                  // Weekly Activity Heatmap
                  _buildActivityHeatmap(context),
                  
                  const SizedBox(height: AppTheme.spacingLg),
                  
                  // Next Recommended Actions
                  _buildRecommendedActions(context),
                  
                  const SizedBox(height: AppTheme.spacingLg),
                  
                  // Active Opportunities
                  _buildActiveOpportunities(context),
                  
                  const SizedBox(height: AppTheme.spacingLg),
                  
                  // Upcoming Deadlines
                  _buildUpcomingDeadlines(context),
                  
                  const SizedBox(height: AppTheme.spacing2xl),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, dynamic user) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good morning,',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              const SizedBox(height: AppTheme.spacingXxs),
              Text(
                user.name.split(' ')[0],
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              shape: BoxShape.circle,
              boxShadow: AppTheme.shadowSm,
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                // Navigate to notifications
              },
            ),
          ),
          const SizedBox(width: AppTheme.spacingSm),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              shape: BoxShape.circle,
              boxShadow: AppTheme.shadowSm,
            ),
            child: IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await MockAuthService.signOut();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroProfileCard(BuildContext context, dynamic user) {
    return PremiumCard(
      isElevated: true,
      hasGradient: true,
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: AppTheme.shadowColored,
                ),
                child: Center(
                  child: Text(
                    user.name.split(' ').map((e) => e[0]).take(2).join(),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppTheme.textInverse,
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
                      user.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppTheme.spacingXs),
                    Text(
                      'Year ${user.year} • ${user.section}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                    const SizedBox(height: AppTheme.spacingSm),
                    Row(
                      children: [
                        _buildProfileStrengthBadge(context, 85),
                        const SizedBox(width: AppTheme.spacingSm),
                        _buildStreakBadge(context, 12),
                      ],
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
              _buildProfileStat(context, 'Total Score', '2,450', Icons.star),
              _buildProfileStat(context, 'Activities', '24', Icons.event),
              _buildProfileStat(context, 'Rank', '#15', Icons.emoji_events),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildProfileStrengthBadge(BuildContext context, int strength) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSm,
        vertical: AppTheme.spacingXs,
      ),
      decoration: BoxDecoration(
        color: AppTheme.successLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.bolt,
            size: 14,
            color: AppTheme.success,
          ),
          const SizedBox(width: AppTheme.spacingXxs),
          Text(
            'Strength $strength%',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.success,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakBadge(BuildContext context, int days) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSm,
        vertical: AppTheme.spacingXs,
      ),
      decoration: BoxDecoration(
        color: AppTheme.warningLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_fire_department,
            size: 14,
            color: AppTheme.warning,
          ),
          const SizedBox(width: AppTheme.spacingXxs),
          Text(
            '$days day streak',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.warning,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStat(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppTheme.primaryAccent,
        ),
        const SizedBox(height: AppTheme.spacingXs),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppTheme.spacingXxs),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildQuickStatsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AnimatedScoreCard(
            label: 'Activities',
            score: 24,
            icon: Icons.event,
            color: AppTheme.info,
          ),
        ),
        const SizedBox(width: AppTheme.spacingMd),
        Expanded(
          child: AnimatedScoreCard(
            label: 'Coding',
            score: 156,
            icon: Icons.code,
            color: AppTheme.success,
          ),
        ),
        const SizedBox(width: AppTheme.spacingMd),
        Expanded(
          child: AnimatedScoreCard(
            label: 'Academics',
            score: 89,
            icon: Icons.school,
            color: AppTheme.warning,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildProgressSection(BuildContext context) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PremiumCardHeader(
            title: 'Your Progress',
            subtitle: 'Track your achievements',
            icon: Icons.trending_up,
            iconColor: AppTheme.primaryAccent,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Row(
            children: [
              Expanded(
                child: PremiumCircularProgress(
                  progress: 0.75,
                  centerText: '75%',
                  size: 100,
                  progressColor: AppTheme.primaryAccent,
                ),
              ),
              const SizedBox(width: AppTheme.spacingLg),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProgressItem(context, 'Activities', 0.8, AppTheme.info),
                    const SizedBox(height: AppTheme.spacingMd),
                    _buildProgressItem(context, 'Coding', 0.65, AppTheme.success),
                    const SizedBox(height: AppTheme.spacingMd),
                    _buildProgressItem(context, 'Academics', 0.9, AppTheme.warning),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildProgressItem(BuildContext context, String label, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingXs),
        PremiumProgressBar(
          progress: progress,
          progressColor: color,
          height: 6,
        ),
      ],
    );
  }

  Widget _buildActivityHeatmap(BuildContext context) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PremiumCardHeader(
            title: 'Weekly Activity',
            subtitle: 'Your engagement this week',
            icon: Icons.calendar_today,
            iconColor: AppTheme.primaryAccent,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          _buildHeatmapGrid(context),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildHeatmapGrid(BuildContext context) {
    // Mock data for heatmap
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final activityLevels = [
      [0.2, 0.5, 0.8, 0.3, 0.9, 0.1, 0.4], // Week 1
      [0.6, 0.7, 0.4, 0.8, 0.5, 0.3, 0.2], // Week 2
      [0.9, 0.3, 0.6, 0.7, 0.8, 0.5, 0.1], // Week 3
      [0.4, 0.8, 0.2, 0.9, 0.6, 0.7, 0.3], // Week 4
    ];

    return Column(
      children: [
        // Day labels
        Padding(
          padding: const EdgeInsets.only(left: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: days.map((day) {
              return Text(
                day.substring(0, 1),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.textMuted,
                    ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        // Heatmap rows
        ...activityLevels.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Text(
                    'W${entry.key + 1}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.textMuted,
                        ),
                  ),
                ),
                ...entry.value.map((level) {
                  return Expanded(
                    child: Container(
                      height: 24,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: _getHeatmapColor(level),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        }),
      ],
    );
  }

  Color _getHeatmapColor(double level) {
    if (level == 0) return AppTheme.border;
    if (level < 0.3) return AppTheme.primaryAccent.withOpacity(0.2);
    if (level < 0.6) return AppTheme.primaryAccent.withOpacity(0.5);
    if (level < 0.8) return AppTheme.primaryAccent.withOpacity(0.7);
    return AppTheme.primaryAccent;
  }

  Widget _buildRecommendedActions(BuildContext context) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PremiumCardHeader(
            title: 'Recommended Actions',
            subtitle: 'Boost your profile',
            icon: Icons.lightbulb,
            iconColor: AppTheme.warning,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          _buildActionItem(
            context,
            'Complete your GitHub profile',
            'Add your GitHub username to showcase your projects',
            Icons.code,
            AppTheme.info,
          ),
          const SizedBox(height: AppTheme.spacingSm),
          _buildActionItem(
            context,
            'Submit 3 coding problems',
            'Earn 45 points and improve your ranking',
            Icons.psychology,
            AppTheme.success,
          ),
          const SizedBox(height: AppTheme.spacingSm),
          _buildActionItem(
            context,
            'Register for upcoming workshop',
            'AI/ML Workshop - limited seats available',
            Icons.event,
            AppTheme.primaryAccent,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _buildActionItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingSm),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: AppTheme.spacingXxs),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppTheme.textMuted,
          ),
        ],
      ),
    );
  }

  Widget _buildActiveOpportunities(BuildContext context) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PremiumCardHeader(
            title: 'Active Opportunities',
            subtitle: 'Don\'t miss out',
            icon: Icons.star,
            iconColor: AppTheme.primaryAccent,
            trailing: TextButton(
              onPressed: () {},
              child: const Text('View all'),
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          _buildOpportunityCard(
            context,
            'Hackathon 2024',
            '48-hour coding challenge',
            '+150 pts',
            AppTheme.primaryAccent,
          ),
          const SizedBox(height: AppTheme.spacingSm),
          _buildOpportunityCard(
            context,
            'Research Internship',
            'Apply for summer research program',
            '+200 pts',
            AppTheme.success,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms);
  }

  Widget _buildOpportunityCard(
    BuildContext context,
    String title,
    String subtitle,
    String points,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingSm),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Icon(Icons.emoji_events, size: 20, color: color),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: AppTheme.spacingXxs),
                Text(
                  subtitle,
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
            child: Text(
              points,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingDeadlines(BuildContext context) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PremiumCardHeader(
          title: 'Upcoming Deadlines',
          subtitle: 'Stay on track',
          icon: Icons.schedule,
          iconColor: AppTheme.error,
        ),
        const SizedBox(height: AppTheme.spacingMd),
        _buildDeadlineItem(
          context,
          'Activity Report',
          'Due in 2 days',
          'Dec 15',
          AppTheme.warning,
        ),
        const SizedBox(height: AppTheme.spacingSm),
        _buildDeadlineItem(
          context,
          'Coding Submission',
          'Due in 5 days',
          'Dec 18',
          AppTheme.info,
        ),
      ],
    ),
    ).animate().fadeIn(delay: 700.ms);
  }

  Widget _buildDeadlineItem(
    BuildContext context,
    String title,
    String subtitle,
    String date,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          child: Center(
            child: Text(
              date.split(' ')[1],
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: color,
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
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: AppTheme.spacingXxs),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.chevron_right,
          color: AppTheme.textMuted,
        ),
      ],
    );
  }
}
