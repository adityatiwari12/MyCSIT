import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/supabase_providers.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState
    extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // Mark all as read when the screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = ref.read(currentUidProvider);
      if (uid != null) markNotificationsRead(uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(currentUidProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppTheme.surface,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
      ),
      body: uid == null
          ? const SizedBox.shrink()
          : _NotificationList(uid: uid),
    );
  }
}

class _NotificationList extends ConsumerWidget {
  final String uid;
  const _NotificationList({required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifsAsync = ref.watch(notificationsProvider(uid));

    return notifsAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator()),
      error: (_, __) => _Empty(
        icon: Icons.error_outline,
        title: 'Could not load notifications',
        subtitle: 'Check your connection and try again.',
      ),
      data: (notifs) {
        if (notifs.isEmpty) {
          return _Empty(
            icon: Icons.notifications_none,
            title: 'No notifications yet',
            subtitle:
                'Activity approvals, rejections, and account updates will appear here.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          itemCount: notifs.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: AppTheme.spacingSm),
          itemBuilder: (_, i) => _NotificationCard(n: notifs[i]),
        );
      },
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final Map<String, dynamic> n;
  const _NotificationCard({required this.n});

  @override
  Widget build(BuildContext context) {
    final title = n['title'] as String? ?? '';
    final message = n['message'] as String? ?? '';
    final isRead = n['is_read'] as bool? ?? true;
    final createdAt =
        DateTime.tryParse(n['created_at'] as String? ?? '');

    final bool isApproved = title.contains('Approved');
    final bool isRejected = title.contains('Rejected');

    Color accent;
    Color bg;
    IconData icon;
    if (isApproved) {
      accent = AppTheme.success;
      bg = AppTheme.successLight;
      icon = Icons.check_circle_outline;
    } else if (isRejected) {
      accent = AppTheme.error;
      bg = AppTheme.errorLight;
      icon = Icons.cancel_outlined;
    } else {
      accent = AppTheme.primaryAccent;
      bg = AppTheme.highlight;
      icon = Icons.notifications_outlined;
    }

    final dateStr = createdAt != null
        ? '${createdAt.day}/${createdAt.month}/${createdAt.year}'
        : '';

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: isRead ? AppTheme.border : accent.withValues(alpha: 0.4),
          width: isRead ? 1 : 1.5,
        ),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(icon, size: 18, color: accent),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(
                              fontWeight: isRead
                                  ? FontWeight.w500
                                  : FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                      ),
                    ),
                    if (!isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                        height: 1.4,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  dateStr,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.textMuted,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _Empty(
      {required this.icon,
      required this.title,
      required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: AppTheme.textMuted),
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingXs),
            Text(
              subtitle,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppTheme.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
