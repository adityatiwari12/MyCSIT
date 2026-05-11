import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/activity_model.dart';
import '../providers/data_provider.dart';
import '../providers/user_provider.dart';

class ActivityDetailScreen extends ConsumerWidget {
  final String activityId;
  const ActivityDetailScreen({super.key, required this.activityId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(activitiesStreamProvider);

    final activity = activitiesAsync.valueOrNull
        ?.where((a) => a.id == activityId)
        .firstOrNull;

    if (activitiesAsync.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (activity == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Activity'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/home/activities'),
          ),
        ),
        body: const Center(child: Text('Activity not found')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text('Activity Details'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home/activities'),
        ),
        actions: [
          if (activity.status == EntryStatus.rejected)
            TextButton(
              onPressed: () => _confirmDelete(context, ref, activity),
              child: const Text('Delete', style: TextStyle(color: Color(0xFFEF4444))),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status banner
            _StatusBanner(status: activity.status, reason: activity.rejectionReason),
            const SizedBox(height: 16),

            // Title & Type
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF0F0F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Chip(
                    label: Text(activity.typeLabel),
                    backgroundColor: const Color(0xFFFFF3EE),
                    labelStyle: const TextStyle(color: Color(0xFFFF6B35), fontWeight: FontWeight.w600, fontSize: 12),
                    side: BorderSide.none,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    activity.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
                  ),
                  if (activity.description != null && activity.description!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(activity.description!,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280), height: 1.5)),
                  ],
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF9CA3AF)),
                      const SizedBox(width: 6),
                      Text(
                        'Submitted on ${_formatDate(activity.createdAt)}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Proof
            if (activity.proofUrl != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF0F0F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Proof',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1A1A2E))),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () async {
                        final uri = Uri.parse(activity.proofUrl!);
                        if (await canLaunchUrl(uri)) {
                          launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F7FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.open_in_new_rounded, color: Color(0xFF3B82F6), size: 18),
                            SizedBox(width: 10),
                            Text('View Proof Document',
                                style: TextStyle(
                                    color: Color(0xFF3B82F6), fontSize: 14, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, ActivityModel activity) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Activity'),
        content: const Text('This will permanently delete the activity.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(firestoreServiceProvider).deleteActivity(activity.id);
      if (context.mounted) context.go('/home/activities');
    }
  }

  String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}

class _StatusBanner extends StatelessWidget {
  final EntryStatus status;
  final String? reason;
  const _StatusBanner({required this.status, this.reason});

  @override
  Widget build(BuildContext context) {
    late Color color;
    late Color bg;
    late String text;
    late IconData icon;

    switch (status) {
      case EntryStatus.approved:
        color = const Color(0xFF22C55E);
        bg = const Color(0xFFDCFCE7);
        text = 'Approved';
        icon = Icons.check_circle_rounded;
        break;
      case EntryStatus.rejected:
        color = const Color(0xFFEF4444);
        bg = const Color(0xFFFEE2E2);
        text = 'Rejected';
        icon = Icons.cancel_rounded;
        break;
      default:
        color = const Color(0xFFF59E0B);
        bg = const Color(0xFFFEF3C7);
        text = 'Pending Review';
        icon = Icons.hourglass_top_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14)),
                if (status == EntryStatus.rejected && reason != null)
                  Text(reason!, style: TextStyle(fontSize: 12, color: color.withOpacity(0.8))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
