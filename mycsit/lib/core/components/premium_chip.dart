import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PremiumChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;
  final VoidCallback? onTap;
  final bool isSelected;
  final EdgeInsetsGeometry? padding;

  const PremiumChip({
    super.key,
    required this.label,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
    this.onTap,
    this.isSelected = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = backgroundColor ??
        (isSelected ? AppTheme.primaryAccent : AppTheme.background);
    final effectiveTextColor = textColor ??
        (isSelected ? AppTheme.textInverse : AppTheme.textSecondary);
    final effectiveIconColor = iconColor ??
        (isSelected ? AppTheme.textInverse : AppTheme.textSecondary);

    final chip = Container(
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMd,
            vertical: AppTheme.spacingSm,
          ),
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: !isSelected
            ? Border.all(color: AppTheme.border, width: 1)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: effectiveIconColor,
            ),
            const SizedBox(width: AppTheme.spacingXs),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: effectiveTextColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          child: chip,
        ),
      );
    }

    return chip;
  }
}

class StatusChip extends StatelessWidget {
  final String label;
  final StatusType status;

  const StatusChip({
    super.key,
    required this.label,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case StatusType.approved:
        backgroundColor = AppTheme.approvedBackground;
        textColor = AppTheme.approvedColor;
        break;
      case StatusType.pending:
        backgroundColor = AppTheme.pendingBackground;
        textColor = AppTheme.pendingColor;
        break;
      case StatusType.rejected:
        backgroundColor = AppTheme.rejectedBackground;
        textColor = AppTheme.rejectedColor;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSm,
        vertical: AppTheme.spacingXs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

enum StatusType { approved, pending, rejected }
