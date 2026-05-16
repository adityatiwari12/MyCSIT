import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';

class RejectedScreen extends ConsumerWidget {
  const RejectedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentAsync = ref.watch(currentStudentProvider);
    final student = studentAsync.valueOrNull;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.errorLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cancel_rounded,
                  size: 52,
                  color: AppTheme.error,
                ),
              ),
              const SizedBox(height: AppTheme.spacingXl),
              Text(
                'Registration Not Approved',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingMd),
              Text(
                'Your account registration was not approved by faculty.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
                textAlign: TextAlign.center,
              ),
              if (student?.rejectionReason?.isNotEmpty == true) ...[
                const SizedBox(height: AppTheme.spacingMd),
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  decoration: BoxDecoration(
                    color: AppTheme.errorLight,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    border: Border.all(color: AppTheme.error.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reason:',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: AppTheme.error,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: AppTheme.spacingXs),
                      Text(
                        student!.rejectionReason!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.error,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppTheme.spacingMd),
              Text(
                'Please contact your faculty for assistance.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textMuted,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacing2xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async => AuthService.signOut(),
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign out'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.error,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
