import 'package:flutter/material.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_dimens.dart';
import '../app/theme/app_typography.dart';
import '../screens/settings/settings_screen.dart';
import 'ayo_badges.dart';
import 'ayo_buttons.dart';
import 'ayo_logo.dart';

/// Top app header for AYOVAANI screens.
///
/// Features:
/// - Screen title in DM Serif Display & subtitle in Inter
/// - Real AYOVAANI logo brand mark in header corner
/// - Offline status badge
/// - Direct access to Teacher Profile / Settings in the top-right area
/// - Optional back button
class AyoTopHeader extends StatelessWidget {
  const AyoTopHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showBrandMark = true,
    this.showBackButton = false,
    this.showOfflineBadge = true,
    this.isOfflineReady = true,
    this.onBackTap,
    this.onSettingsTap,
    this.actions,
  });

  final String title;
  final String? subtitle;
  final bool showBrandMark;
  final bool showBackButton;
  final bool showOfflineBadge;
  final bool isOfflineReady;
  final VoidCallback? onBackTap;
  final VoidCallback? onSettingsTap;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Top Action Bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left: Back button OR Brand Mark
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showBackButton) ...[
                    AyoBackButton(onPressed: onBackTap),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  if (showBrandMark)
                    const AyoLogo(
                      variant: AyoLogoVariant.compact,
                      height: 38,
                    ),
                ],
              ),
            ),

            // Right: Offline Indicator & Profile/Settings Button
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showOfflineBadge) ...[
                  AyoBadge(
                    label: isOfflineReady ? 'Offline Ready' : 'Sync OK',
                    variant: isOfflineReady
                        ? AyoBadgeVariant.offline
                        : AyoBadgeVariant.neutral,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
                if (actions != null) ...actions!,
                // Teacher Profile / Settings Button in Top-Right
                _buildSettingsButton(context),
              ],
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.md),

        // Title and Optional Subtitle
        Text(
          title,
          style: TextStyle(
            fontFamily: AppTypography.headingFontFamily,
            fontSize: 24.0,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
            letterSpacing: -0.2,
            height: 1.25,
          ),
        ),

        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle!,
            style: TextStyle(
              fontFamily: AppTypography.bodyFontFamily,
              fontSize: 13.5,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSettingsButton(BuildContext context) {
    return Tooltip(
      message: 'Teacher Profile & Classroom Settings',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onSettingsTap ?? () => SettingsScreen.show(context),
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.borderWarm,
                width: 1.0,
              ),
              boxShadow: AppShadows.cardShadow,
            ),
            child: const Center(
              child: Icon(
                Icons.settings_outlined,
                color: AppColors.primaryBurgundy,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
