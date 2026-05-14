import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

class PremiumEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionText;
  final VoidCallback? onAction;
  final Widget? customIllustration;

  const PremiumEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionText,
    this.onAction,
    this.customIllustration,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (customIllustration != null)
              customIllustration!
            else
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppTheme.highlight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 48,
                  color: AppTheme.primaryAccent,
                ),
              ).animate().fadeIn(duration: 600.ms).scale(),
            const SizedBox(height: AppTheme.spacingLg),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: AppTheme.spacingLg),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionText!),
              ).animate().fadeIn(delay: 600.ms, duration: 600.ms),
            ],
          ],
        ),
      ),
    );
  }
}

class LoadingSkeleton extends StatelessWidget {
  final double? height;
  final double? width;
  final BorderRadius? borderRadius;

  const LoadingSkeleton({
    super.key,
    this.height,
    this.width,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: AppTheme.border,
        borderRadius: borderRadius ?? BorderRadius.circular(AppTheme.radiusSm),
      ),
    ).animate().shimmer(duration: 1500.ms);
  }
}

class CardSkeleton extends StatelessWidget {
  final double? height;

  const CardSkeleton({super.key, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 120,
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const LoadingSkeleton(width: 40, height: 40),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LoadingSkeleton(width: double.infinity, height: 16),
                    const SizedBox(height: AppTheme.spacingXs),
                    LoadingSkeleton(width: 100, height: 12),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),
          LoadingSkeleton(width: double.infinity, height: 12),
          const SizedBox(height: AppTheme.spacingXs),
          LoadingSkeleton(width: 150, height: 12),
        ],
      ),
    ).animate().shimmer(duration: 1500.ms);
  }
}
