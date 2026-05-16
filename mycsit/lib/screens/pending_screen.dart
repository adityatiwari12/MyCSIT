import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';

class PendingScreen extends ConsumerWidget {
  const PendingScreen({super.key});

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
                  color: AppTheme.warningLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.hourglass_top_rounded,
                  size: 52,
                  color: AppTheme.warning,
                ),
              ),
              const SizedBox(height: AppTheme.spacingXl),
              Text(
                'Account Pending Approval',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingMd),
              Text(
                student != null
                    ? 'Hi ${student.name.split(' ').first}! Your registration for ${student.rollNumber} is being reviewed by faculty.'
                    : 'Your registration is being reviewed by faculty. You will be notified once approved.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingSm),
              Text(
                'This page will automatically update when your account is approved.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textMuted,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacing2xl),
              const CircularProgressIndicator(
                color: AppTheme.warning,
                strokeWidth: 2,
              ),
              const SizedBox(height: AppTheme.spacing2xl),
              TextButton.icon(
                onPressed: () async => AuthService.signOut(),
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Sign out'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
