import 'package:flutter/material.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_dimens.dart';
import '../app/theme/app_typography.dart';
import 'ayo_badges.dart';
import 'ayo_buttons.dart';
import 'ayo_progress.dart';

/// Reusable AYOVAANI Paper Panel Card.
///
/// Features:
/// - Warm parchment surface (#F5E7CC)
/// - Subtle warm sand border (#D8C6AC)
/// - 16px rounded corners
/// - Soft warm shadow
/// - Generous internal padding
class AyoCard extends StatelessWidget {
  const AyoCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = AppRadius.lg,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.onTap,
    this.hasShadow = true,
  });

  final Widget child;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool hasShadow;

  @override
  Widget build(BuildContext context) {
    final cardWidget = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.cardSurface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? AppColors.borderWarm,
          width: AppBorders.thin,
        ),
        boxShadow: hasShadow ? AppShadows.cardShadow : null,
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: AppColors.primaryBurgundy.withValues(alpha: 0.08),
          highlightColor: AppColors.surface.withValues(alpha: 0.3),
          child: cardWidget,
        ),
      );
    }

    return cardWidget;
  }
}

/// Standardized Feature / Action Card with rich burgundy badge and clean typography.
class AyoActionCard extends StatelessWidget {
  const AyoActionCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.tag,
    this.badgeVariant,
    this.isCoreFeature = false,
    this.onTap,
    this.trailing,
  });

  final String title;
  final String description;
  final IconData icon;
  final String? tag;
  final AyoBadgeVariant? badgeVariant;
  final bool isCoreFeature;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return AyoCard(
      onTap: onTap,
      borderColor: isCoreFeature
          ? AppColors.primaryBurgundy.withValues(alpha: 0.45)
          : AppColors.borderWarm,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Container in Burgundy or Terracotta
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isCoreFeature
                  ? AppColors.primaryBurgundy
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: isCoreFeature
                    ? AppColors.primaryBurgundy
                    : AppColors.borderWarm,
                width: 1.0,
              ),
            ),
            child: Icon(
              icon,
              color: isCoreFeature ? Colors.white : AppColors.primaryBurgundy,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontFamily: AppTypography.bodyFontFamily,
                          fontSize: 15.0,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (tag != null) ...[
                      const SizedBox(width: AppSpacing.xs),
                      AyoBadge(
                        label: tag!,
                        variant: badgeVariant ??
                            (isCoreFeature
                                ? AyoBadgeVariant.primary
                                : AyoBadgeVariant.neutral),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 13.0,
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),

          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.sm),
            trailing!,
          ] else if (onTap != null) ...[
            const SizedBox(width: AppSpacing.sm),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.textMuted,
            ),
          ],
        ],
      ),
    );
  }
}

/// Specialized Lesson Card for multilingual curriculum.
class AyoLessonCard extends StatelessWidget {
  const AyoLessonCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.sourceLanguage,
    required this.targetLanguage,
    this.progress = 0.0,
    this.isCompleted = false,
    this.isOffline = true,
    this.onTap,
    this.onPlayAudio,
  });

  final String title;
  final String subtitle;
  final String sourceLanguage;
  final String targetLanguage;
  final double progress;
  final bool isCompleted;
  final bool isOffline;
  final VoidCallback? onTap;
  final VoidCallback? onPlayAudio;

  @override
  Widget build(BuildContext context) {
    return AyoCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Language Pair & Offline Status
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  AyoBadge(
                    label: '$sourceLanguage → $targetLanguage',
                    variant: AyoBadgeVariant.motherTongue,
                  ),
                  if (isOffline)
                    const AyoBadge(
                      label: 'Offline Ready',
                      variant: AyoBadgeVariant.offline,
                    ),
                ],
              ),
              if (isCompleted)
                const AyoBadge(
                  label: 'Completed',
                  variant: AyoBadgeVariant.verified,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Title & Audio Action
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: AppTypography.headingFontFamily,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: AppTypography.bodyFontFamily,
                        fontSize: 13.0,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (onPlayAudio != null)
                AyoAudioButton(
                  onPressed: onPlayAudio,
                  size: 36,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Progress Bar
          AyoLinearProgress(
            progress: progress,
            showLabel: true,
            label: '${(progress * 100).toInt()}% Classroom Mastery',
          ),
        ],
      ),
    );
  }
}
