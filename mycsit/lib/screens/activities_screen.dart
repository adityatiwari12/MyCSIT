import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/data_provider.dart';
import '../models/activity_model.dart';

class ActivitiesScreen extends ConsumerWidget {
  const ActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(activitiesStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text('My Activities'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add Activity',
            onPressed: () => context.go('/home/activities/add'),
          ),
        ],
      ),
      body: activitiesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (activities) {
          if (activities.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.event_note_outlined, size: 64, color: Color(0xFFCCCCCC)),
                  const SizedBox(height: 16),
                  const Text('No activities yet',
                      style: TextStyle(fontSize: 16, color: Color(0xFF9CA3AF))),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/home/activities/add'),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add Activity'),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: activities.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final activity = activities[index];
              return _ActivityCard(activity: activity);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/home/activities/add'),
        backgroundColor: const Color(0xFFFF6B35),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
}

class _ActivityCard extends ConsumerWidget {
  final ActivityModel activity;
  const _ActivityCard({required this.activity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    return GestureDetector(
      onTap: () => context.go('/home/activities/${activity.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF0F0F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3EE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_typeIcon(activity.type), color: const Color(0xFFFF6B35), size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1A1A2E)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(activity.typeLabel,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                  if (activity.status == EntryStatus.rejected && activity.rejectionReason != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        activity.rejectionReason!,
                        style: const TextStyle(fontSize: 11, color: Color(0xFFEF4444)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(20)),
              child: Text(statusText,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor)),
            ),
          ],
        ),
      ),
    );
  }

  IconData _typeIcon(ActivityType type) {
    switch (type) {
      case ActivityType.hackathon:
        return Icons.emoji_events_outlined;
      case ActivityType.achievement:
        return Icons.military_tech_outlined;
      case ActivityType.certification:
        return Icons.verified_outlined;
      case ActivityType.internship:
        return Icons.work_outline_rounded;
      case ActivityType.research:
        return Icons.science_outlined;
      case ActivityType.project:
        return Icons.folder_outlined;
    }
  }
}
