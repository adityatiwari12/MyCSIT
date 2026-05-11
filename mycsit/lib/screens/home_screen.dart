import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/user_provider.dart';
import '../providers/data_provider.dart';
import '../models/activity_model.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final activitiesAsync = ref.watch(activitiesStreamProvider);
    final scoreCache = ref.watch(scoreCacheProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: userAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (user) {
            if (user == null) return const SizedBox.shrink();
            final recentActivities = activitiesAsync.valueOrNull?.take(5).toList() ?? [];

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: const Color(0xFFFFF3EE),
                          child: Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF6B35),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hi, ${user.name.split(' ').first}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1A2E),
                                ),
                              ),
                              Text(
                                '${user.rollNumber} • Year ${user.year} ${user.section}',
                                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                              ),
                            ],
                          ),
                        ),
                        if (user.pendingActivityCount > 0)
                          Badge(
                            label: Text('${user.pendingActivityCount}'),
                            child: const Icon(Icons.notifications_outlined),
                          )
                        else
                          const Icon(Icons.notifications_outlined, color: Color(0xFF9CA3AF)),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Score Card
                      _ScoreCard(scoreCache: scoreCache),
                      const SizedBox(height: 24),

                      // Quick Actions
                      const Text(
                        'Quick Actions',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _QuickAction(
                            icon: Icons.add_circle_outline_rounded,
                            label: 'Activity',
                            color: const Color(0xFFFF6B35),
                            onTap: () => context.go('/home/activities/add'),
                          ),
                          _QuickAction(
                            icon: Icons.code_rounded,
                            label: 'Coding',
                            color: const Color(0xFF22C55E),
                            onTap: () => context.go('/home/coding/add'),
                          ),
                          _QuickAction(
                            icon: Icons.school_outlined,
                            label: 'Academics',
                            color: const Color(0xFF3B82F6),
                            onTap: () => context.go('/home/academics'),
                          ),
                          _QuickAction(
                            icon: Icons.person_outline_rounded,
                            label: 'Profile',
                            color: const Color(0xFFFF9F1C),
                            onTap: () => context.go('/home/profile'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Recent Activities
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Recent Activities',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
                          ),
                          TextButton(
                            onPressed: () => context.go('/home/activities'),
                            child: const Text('View all', style: TextStyle(color: Color(0xFFFF6B35))),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (recentActivities.isEmpty)
                        _EmptyCard(
                          icon: Icons.event_note_outlined,
                          message: 'No activities yet. Add your first one!',
                          actionLabel: 'Add Activity',
                          onAction: () => context.go('/home/activities/add'),
                        )
                      else
                        ...recentActivities.map((a) => _ActivityTile(activity: a)),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: _BottomNav(currentIndex: 0),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final dynamic scoreCache;
  const _ScoreCard({this.scoreCache});

  @override
  Widget build(BuildContext context) {
    final total = scoreCache?.totalScore ?? 0.0;
    final hackathon = scoreCache?.hackathonScore ?? 0.0;
    final project = scoreCache?.projectScore ?? 0.0;
    final academic = scoreCache?.academicScore ?? 0.0;
    final coding = scoreCache?.codingScore ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFFF9F1C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B35).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Score', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 6),
                    Text(
                      total.toStringAsFixed(1),
                      style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 72,
                height: 72,
                child: CircularProgressIndicator(
                  value: total / 100,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                  strokeWidth: 7,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ScorePill('Hackathon', hackathon),
              _ScorePill('Project', project),
              _ScorePill('Academic', academic),
              _ScorePill('Coding', coding),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScorePill extends StatelessWidget {
  final String label;
  final double value;
  const _ScorePill(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final ActivityModel activity;
  const _ActivityTile({required this.activity});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    Color statusBg;
    String statusText;

    switch (activity.status) {
      case EntryStatus.approved:
        statusColor = const Color(0xFF22C55E);
        statusBg = const Color(0xFFDCFCE7);
        statusText = 'Approved';
        break;
      case EntryStatus.rejected:
        statusColor = const Color(0xFFEF4444);
        statusBg = const Color(0xFFFEE2E2);
        statusText = 'Rejected';
        break;
      default:
        statusColor = const Color(0xFFF59E0B);
        statusBg = const Color(0xFFFEF3C7);
        statusText = 'Pending';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3EE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.event_note_outlined, color: Color(0xFFFF6B35), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity.title,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1A1A2E)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(activity.typeLabel, style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(20)),
            child: Text(statusText, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor)),
          ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final IconData icon;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _EmptyCard({
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 44, color: const Color(0xFFCCCCCC)),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          TextButton(
            onPressed: onAction,
            child: Text(actionLabel, style: const TextStyle(color: Color(0xFFFF6B35), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _BottomNav extends ConsumerWidget {
  final int currentIndex;
  const _BottomNav({required this.currentIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (i) {
        switch (i) {
          case 0:
            context.go('/home');
            break;
          case 1:
            context.go('/home/activities');
            break;
          case 2:
            context.go('/home/coding');
            break;
          case 3:
            context.go('/home/profile');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.event_note_outlined), label: 'Activities'),
        BottomNavigationBarItem(icon: Icon(Icons.code_rounded), label: 'Coding'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: 'Profile'),
      ],
    );
  }
}
