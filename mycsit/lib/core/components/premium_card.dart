import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final bool isElevated;
  final bool hasGradient;
  final Color? backgroundColor;
  final double? borderRadius;
  final List<BoxShadow>? customShadow;

  const PremiumCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.isElevated = true,
    this.hasGradient = false,
    this.backgroundColor,
    this.borderRadius,
    this.customShadow,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: margin ?? const EdgeInsets.all(AppTheme.spacingSm),
      padding: padding ?? const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        gradient: hasGradient ? AppTheme.cardGradient : null,
        color: hasGradient ? null : (backgroundColor ?? AppTheme.surface),
        borderRadius: BorderRadius.circular(borderRadius ?? AppTheme.radiusLg),
        boxShadow: isElevated
            ? (customShadow ?? AppTheme.shadowMd)
            : null,
        border: !isElevated
            ? Border.all(color: AppTheme.border, width: 1)
            : null,
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius ?? AppTheme.radiusLg),
          child: card,
        ),
      );
    }

    return card;
  }
}

class PremiumCardHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final IconData? icon;
  final Color? iconColor;

  const PremiumCardHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 20,
              color: iconColor ?? AppTheme.primaryAccent,
            ),
            const SizedBox(width: AppTheme.spacingSm),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppTheme.spacingXs),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
