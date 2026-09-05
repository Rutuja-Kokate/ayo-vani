import 'package:flutter/material.dart';
import '../../app/responsive/responsive.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_typography.dart';
import '../../widgets/ayo_badges.dart';
import '../../widgets/ayo_cards.dart';
import '../../widgets/ayo_dividers.dart';
import '../../widgets/ayo_progress.dart';
import '../../widgets/ayo_screen_background.dart';
import '../../widgets/ayo_top_header.dart';
import '../settings/settings_screen.dart';

/// Progress Screen Foundation for AYOVAANI.
///
/// Houses:
/// - Classroom mastery analytics
/// - Learning gap diagnostic insights
/// - Mother-tongue vocabulary retention tracking
/// - Offline student activity logs
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AyoScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: Responsive.screenPadding(context),
          child: ResponsiveContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header with brand mark & Profile/Settings action
                AyoTopHeader(
                  title: 'Classroom Progress',
                  subtitle: 'Mastery analytics, learning-gap diagnostics, and offline logs',
                  onSettingsTap: () => SettingsScreen.show(context),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Overall Classroom Mastery Card
                AyoCard(
                  child: Row(
                    children: [
                      const AyoCircularProgress(
                        progress: 0.78,
                        size: 64,
                        strokeWidth: 6,
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Overall Language Mastery',
                                    style: TextStyle(
                                      fontFamily: AppTypography.serifFontFamily,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                const AyoBadge(
                                  label: 'Grade 4',
                                  variant: AyoBadgeVariant.verified,
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '32 / 38 Students proficient in Hindi ↔ Gondi fundamentals',
                              style: TextStyle(
                                fontFamily: AppTypography.sansFontFamily,
                                fontSize: 13.0,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                const AyoSectionHeader(
                  title: 'Learning Gap Insights',
                  subtitle: 'Areas identified for human-in-the-loop teacher reinforcement',
                ),
                const SizedBox(height: AppSpacing.md),

                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= Responsive.phoneBreakpoint;

                    final gapCards = [
                      AyoCard(
                        borderColor: AppColors.warmAmber.withValues(alpha: 0.4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Verbal Pronunciation',
                                    style: TextStyle(
                                      fontFamily: AppTypography.sansFontFamily,
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                const AyoBadge(
                                  label: 'Needs Practice',
                                  variant: AyoBadgeVariant.reviewNeeded,
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              '6 students struggled with complex numeral sounds in Gondi.',
                              style: TextStyle(
                                fontFamily: AppTypography.sansFontFamily,
                                fontSize: 12.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            const AyoLinearProgress(
                              progress: 0.52,
                              showLabel: true,
                              label: 'Classroom Accuracy',
                            ),
                          ],
                        ),
                      ),
                      AyoCard(
                        borderColor: AppColors.oliveGreen.withValues(alpha: 0.4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Vocabulary Retention',
                                    style: TextStyle(
                                      fontFamily: AppTypography.sansFontFamily,
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                const AyoBadge(
                                  label: 'High Mastery',
                                  variant: AyoBadgeVariant.offline,
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Fauna & flora flashcards completed with 92% retention rate.',
                              style: TextStyle(
                                fontFamily: AppTypography.sansFontFamily,
                                fontSize: 12.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            const AyoLinearProgress(
                              progress: 0.92,
                              showLabel: true,
                              label: 'Retention Score',
                            ),
                          ],
                        ),
                      ),
                    ];

                    if (!isWide) {
                      return Column(
                        children: [
                          for (int i = 0; i < gapCards.length; i++) ...[
                            gapCards[i],
                            if (i < gapCards.length - 1)
                              const SizedBox(height: AppSpacing.md),
                          ],
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (int i = 0; i < gapCards.length; i++) ...[
                          Expanded(child: gapCards[i]),
                          if (i < gapCards.length - 1)
                            const SizedBox(width: AppSpacing.md),
                        ],
                      ],
                    );
                  },
                ),

                const SizedBox(height: AppSpacing.xxxl),
              ],
            ),
          ),
        ),
      ),
    ),
    );
  }
}
