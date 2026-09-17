import 'package:flutter/material.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_dimens.dart';
import '../app/theme/app_typography.dart';
import '../l10n/app_localizations.dart';
import 'ayo_badges.dart';
import 'ayo_buttons.dart';
import 'ayo_cards.dart';

/// Reusable Empty State container with subtle Warli geometric motif.
class AyoEmptyState extends StatelessWidget {
  const AyoEmptyState({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.menu_book_rounded,
    this.actionLabel,
    this.onActionPressed,
  });

  final String title;
  final String description;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    return AyoCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xxl,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon container with Warli halo
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.warmGold.withValues(alpha: 0.6),
                  width: 1.2,
                ),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 30,
                  color: AppColors.primaryBurgundy,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Title in DM Serif Display
            Text(
              title,
              style: TextStyle(
                fontFamily: AppTypography.headingFontFamily,
                fontSize: 18.0,
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),

            // Description in Inter
            Text(
              description,
              style: TextStyle(
                fontFamily: AppTypography.bodyFontFamily,
                fontSize: 13.5,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            if (actionLabel != null && onActionPressed != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AyoPrimaryButton(
                label: actionLabel!,
                onPressed: onActionPressed,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Human-in-the-loop Teacher Review Banner for AI translation correction & review.
class AyoReviewBanner extends StatelessWidget {
  const AyoReviewBanner({
    super.key,
    required this.title,
    required this.message,
    this.pendingCount,
    this.actionLabel = 'Review Now',
    this.onReviewTap,
  });

  final String title;
  final String message;
  final int? pendingCount;
  final String actionLabel;
  final VoidCallback? onReviewTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.goldLight,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.warmGold.withValues(alpha: 0.6),
          width: 1.0,
        ),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.warmBrown,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: const Icon(
              Icons.rate_review_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: AppTypography.bodyFontFamily,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (pendingCount != null)
                      AyoBadge(
                        label: '$pendingCount Pending',
                        variant: AyoBadgeVariant.reviewNeeded,
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          if (onReviewTap != null) ...[
            const SizedBox(width: AppSpacing.sm),
            TextButton(
              onPressed: onReviewTap,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.warmBrown,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              ),
              child: Text(
                AppLocalizations.of(context)?.btnReviewNow ?? actionLabel,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Offline Readiness Banner indicating classroom sync & downloaded assets.
class AyoOfflineIndicator extends StatelessWidget {
  const AyoOfflineIndicator({
    super.key,
    this.isOffline = true,
    this.lastSyncedTime = 'Today, 8:30 AM',
    this.downloadedModulesCount = 12,
  });

  final bool isOffline;
  final String lastSyncedTime;
  final int downloadedModulesCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2,
      ),
      decoration: BoxDecoration(
        color: isOffline ? AppColors.oliveGreenLight : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isOffline
              ? AppColors.oliveGreen.withValues(alpha: 0.35)
              : AppColors.borderWarm,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isOffline ? Icons.offline_bolt_rounded : Icons.cloud_done_rounded,
            color: isOffline ? AppColors.oliveGreen : AppColors.textSecondary,
            size: 18,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isOffline
                      ? 'Offline Mode Active'
                      : 'Classroom Connected',
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 13.0,
                    fontWeight: FontWeight.w600,
                    color: isOffline ? AppColors.oliveGreen : AppColors.textPrimary,
                  ),
                ),
                Text(
                  '$downloadedModulesCount modules ready • Last synced: $lastSyncedTime',
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          AyoBadge(
            label: isOffline ? 'Offline 100%' : 'Sync OK',
            variant: AyoBadgeVariant.offline,
          ),
        ],
      ),
    );
  }
}

/// Confirmation and Success state modal / bottom sheet.
class AyoConfirmationSheet extends StatelessWidget {
  const AyoConfirmationSheet({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.onConfirm,
    this.cancelLabel = 'Cancel',
    this.onCancel,
    this.icon = Icons.check_circle_outline_rounded,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final VoidCallback onConfirm;
  final String cancelLabel;
  final VoidCallback? onCancel;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderWarm,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AppColors.oliveGreenLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.oliveGreen, size: 30),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: TextStyle(
              fontFamily: AppTypography.headingFontFamily,
              fontSize: 20.0,
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            message,
            style: TextStyle(
              fontFamily: AppTypography.bodyFontFamily,
              fontSize: 14.0,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: AyoOutlinedButton(
                  label: cancelLabel,
                  onPressed: onCancel ?? () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AyoPrimaryButton(
                  label: confirmLabel,
                  onPressed: onConfirm,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}
