import 'package:flutter/material.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_dimens.dart';
import '../app/theme/app_typography.dart';

/// Semantic variants for badges and status indicators in AYOVAANI.
enum AyoBadgeVariant {
  /// Offline ready / local storage (Muted Olive Green #526B4F)
  offline,

  /// Mother-tongue / Regional language (Terracotta #A85B4F)
  motherTongue,

  /// Human-in-the-loop teacher verified (Muted Olive Green #526B4F)
  verified,

  /// Teacher review / correction pending (Warm Brown / Gold #765E49)
  reviewNeeded,

  /// Live real-time mode (Burgundy #671D21)
  live,

  /// Standard neutral badge (Parchment surface)
  neutral,

  /// Primary burgundy badge (Burgundy #671D21)
  primary,
}

/// Centralized badge component for status, tags, and category labels.
class AyoBadge extends StatelessWidget {
  const AyoBadge({
    super.key,
    required this.label,
    this.variant = AyoBadgeVariant.neutral,
    this.icon,
    this.customBgColor,
    this.customTextColor,
  });

  final String label;
  final AyoBadgeVariant variant;
  final IconData? icon;
  final Color? customBgColor;
  final Color? customTextColor;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    Color border;
    IconData? defaultIcon;

    switch (variant) {
      case AyoBadgeVariant.offline:
        bg = AppColors.oliveGreenLight;
        fg = AppColors.oliveGreen;
        border = AppColors.oliveGreen.withValues(alpha: 0.35);
        defaultIcon = Icons.offline_bolt_rounded;
        break;
      case AyoBadgeVariant.motherTongue:
        bg = AppColors.terracottaLight;
        fg = AppColors.secondaryTerracotta;
        border = AppColors.secondaryTerracotta.withValues(alpha: 0.35);
        defaultIcon = Icons.translate_rounded;
        break;
      case AyoBadgeVariant.verified:
        bg = AppColors.oliveGreenLight;
        fg = AppColors.oliveGreen;
        border = AppColors.oliveGreen.withValues(alpha: 0.35);
        defaultIcon = Icons.check_circle_rounded;
        break;
      case AyoBadgeVariant.reviewNeeded:
        bg = AppColors.goldLight;
        fg = AppColors.warmBrown;
        border = AppColors.warmGold.withValues(alpha: 0.5);
        defaultIcon = Icons.info_outline_rounded;
        break;
      case AyoBadgeVariant.live:
        bg = AppColors.burgundyLight;
        fg = AppColors.primaryBurgundy;
        border = AppColors.primaryBurgundy.withValues(alpha: 0.35);
        defaultIcon = Icons.sensors_rounded;
        break;
      case AyoBadgeVariant.primary:
        bg = AppColors.primaryBurgundy;
        fg = AppColors.cardSurface;
        border = Colors.transparent;
        break;
      case AyoBadgeVariant.neutral:
        bg = AppColors.surface;
        fg = AppColors.textSecondary;
        border = AppColors.borderWarm;
        break;
    }

    final effectiveBg = customBgColor ?? bg;
    final effectiveFg = customTextColor ?? fg;
    final effectiveIcon = icon ?? defaultIcon;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: border, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (effectiveIcon != null) ...[
            Icon(effectiveIcon, size: 12, color: effectiveFg),
            const SizedBox(width: AppSpacing.xs),
          ],
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppTypography.bodyFontFamily,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: effectiveFg,
                letterSpacing: 0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Interactive chip with selection state.
class AyoStatusChip extends StatelessWidget {
  const AyoStatusChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBurgundy : AppColors.cardSurface,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryBurgundy
                  : AppColors.borderWarm,
              width: 1.0,
            ),
            boxShadow: isSelected ? AppShadows.cardShadow : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 14,
                  color: isSelected ? AppColors.cardSurface : AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.xs + 2),
              ],
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppTypography.bodyFontFamily,
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppColors.cardSurface : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
