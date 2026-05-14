import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../theme/app_theme.dart';

class PremiumProgressBar extends StatelessWidget {
  final double progress;
  final String? label;
  final Color? progressColor;
  final Color? backgroundColor;
  final double height;
  final BorderRadius? borderRadius;

  const PremiumProgressBar({
    super.key,
    required this.progress,
    this.label,
    this.progressColor,
    this.backgroundColor,
    this.height = 8,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingXs),
        ],
        LinearPercentIndicator(
          padding: EdgeInsets.zero,
          animation: true,
          animationDuration: 1000,
          lineHeight: height,
          percent: progress.clamp(0.0, 1.0),
          backgroundColor: backgroundColor ?? AppTheme.border,
          progressColor: progressColor ?? AppTheme.primaryAccent,
          barRadius: borderRadius?.topLeft ?? Radius.circular(height / 2),
          alignment: MainAxisAlignment.center,
        ),
      ],
    );
  }
}

class PremiumCircularProgress extends StatelessWidget {
  final double progress;
  final String? centerText;
  final double size;
  final double strokeWidth;
  final Color? progressColor;
  final Color? backgroundColor;

  const PremiumCircularProgress({
    super.key,
    required this.progress,
    this.centerText,
    this.size = 80,
    this.strokeWidth = 8,
    this.progressColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return CircularPercentIndicator(
      radius: size / 2,
      lineWidth: strokeWidth,
      animation: true,
      animationDuration: 1200,
      percent: progress.clamp(0.0, 1.0),
      center: centerText != null
          ? Text(
              centerText!,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: progressColor ?? AppTheme.primaryAccent,
                  ),
            )
          : null,
      circularStrokeCap: CircularStrokeCap.round,
      backgroundColor: backgroundColor ?? AppTheme.border,
      progressColor: progressColor ?? AppTheme.primaryAccent,
    );
  }
}

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = backgroundColor ?? AppTheme.background;
    final effectiveIconColor = iconColor ?? AppTheme.primaryAccent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          decoration: BoxDecoration(
            color: effectiveBackgroundColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: AppTheme.border, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 24,
                color: effectiveIconColor,
              ),
              const SizedBox(height: AppTheme.spacingSm),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: effectiveIconColor,
                    ),
              ),
              const SizedBox(height: AppTheme.spacingXs),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
