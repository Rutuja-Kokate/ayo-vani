import 'package:flutter/material.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_dimens.dart';
import 'app_card.dart';
import 'ayo_badges.dart';

/// Standardized section card used for sub-features across modules.
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.tag,
    this.isCoreFeature = false,
    this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final String? tag;
  final bool isCoreFeature;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      backgroundColor: AppColors.surface,
      borderColor: isCoreFeature
          ? AppColors.primaryBurgundy.withValues(alpha: 0.35)
          : AppColors.borderWarm,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Badge
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isCoreFeature
                  ? AppColors.primaryBurgundy
                  : AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: isCoreFeature
                    ? AppColors.warmAmber.withValues(alpha: 0.5)
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

          // Title and Tag
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    if (tag != null)
                      AyoBadge(
                        label: tag!,
                        variant: isCoreFeature
                            ? AyoBadgeVariant.primary
                            : AyoBadgeVariant.neutral,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Trailing arrow indicator
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: AppColors.textMuted.withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }
}
