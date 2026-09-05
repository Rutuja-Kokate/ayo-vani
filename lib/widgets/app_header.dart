import 'package:flutter/material.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_dimens.dart';
import 'ayo_badges.dart';
import 'ayo_dividers.dart';

/// Editorial section header with cultural styling, subtitle, and badge.
class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.badgeText,
    this.trailing,
    this.showDivider = true,
  });

  final String title;
  final String subtitle;
  final String? badgeText;
  final Widget? trailing;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.sm,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                if (badgeText != null)
                  AyoBadge(
                    label: badgeText!,
                    variant: AyoBadgeVariant.primary,
                  ),
              ],
            ),
            ?trailing,
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        if (showDivider) ...[
          const SizedBox(height: AppSpacing.md),
          const AyoWarliDivider(height: 5, margin: EdgeInsets.zero),
          const SizedBox(height: AppSpacing.lg),
        ],
      ],
    );
  }
}
