import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

class AnimatedCounter extends StatelessWidget {
  final int value;
  final String? suffix;
  final String? prefix;
  final TextStyle? style;
  final Duration duration;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.suffix,
    this.prefix,
    this.style,
    this.duration = const Duration(milliseconds: 1000),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: duration,
      builder: (context, double value, child) {
        return Text(
          '${prefix ?? ''}${value.toInt()}${suffix ?? ''}',
          style: style,
        );
      },
    );
  }
}

class AnimatedScoreCard extends StatelessWidget {
  final String label;
  final int score;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;

  const AnimatedScoreCard({
    super.key,
    required this.label,
    required this.score,
    required this.icon,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppTheme.primaryAccent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                effectiveColor.withOpacity(0.1),
                effectiveColor.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(
              color: effectiveColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 28,
                color: effectiveColor,
              ),
              const SizedBox(height: AppTheme.spacingSm),
              AnimatedCounter(
                value: score,
                suffix: ' pts',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: effectiveColor,
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
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }
}
