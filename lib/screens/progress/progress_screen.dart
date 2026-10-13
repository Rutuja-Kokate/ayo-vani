import 'package:flutter/material.dart';
import '../../app/responsive/responsive.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_typography.dart';
import '../../services/activity_database_service.dart';
import '../../services/teacher_profile_service.dart';
import '../../widgets/ayo_badges.dart';
import '../../widgets/ayo_cards.dart';
import '../../widgets/ayo_dividers.dart';
import '../../widgets/ayo_progress.dart';
import '../../widgets/ayo_screen_background.dart';
import '../../widgets/ayo_top_header.dart';
import '../settings/settings_screen.dart';

/// Progress Screen for AYOVAANI.
///
/// Houses:
/// - Real classroom mastery analytics aggregated from SQLite activity events
/// - Learning gap diagnostic insights (weak and strong areas)
/// - Mother-tongue vocabulary retention tracking
/// - Offline student activity logs with an empty state on fresh install
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  ClassroomProgressStats _stats = ClassroomProgressStats.empty();
  TeacherProfile? _profile;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final stats = await ActivityDatabaseService.instance.getProgressStats();
      final profile = await TeacherProfileService.instance.getProfile();
      if (mounted) {
        setState(() {
          _stats = stats;
          _profile = profile;
        });
      }
    } catch (e) {
      debugPrint('[ProgressScreen] Error loading progress data: $e');
      if (mounted) {
        setState(() {
          _stats = ClassroomProgressStats.empty();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final stats = _stats;
    final profile = _profile;

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

                  if (stats.isEmpty)
                    _buildEmptyState(context)
                  else ...[
                    // Overall Classroom Mastery Card
                    AyoCard(
                      child: Row(
                        children: [
                          AyoCircularProgress(
                            progress: stats.overallAccuracy,
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
                                    AyoBadge(
                                      label: profile?.className ?? 'Class 1',
                                      variant: AyoBadgeVariant.verified,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${stats.totalCorrect} / ${stats.totalQuestions} items correct across ${stats.totalEvents} activities',
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
                      subtitle: 'Areas identified from student performance for teacher reinforcement',
                    ),
                    const SizedBox(height: AppSpacing.md),

                    _buildInsightsGrid(context, stats),
                  ],

                  const SizedBox(height: AppSpacing.xxxl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return AyoCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primaryBurgundy.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.analytics_outlined,
                  size: 38,
                  color: AppColors.primaryBurgundy,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'No Classroom Activity Yet',
                style: TextStyle(
                  fontFamily: AppTypography.headingFontFamily,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Text(
                  'Complete quizzes, flashcard reviews, worksheets, or teacher practice sessions to view real-time mastery analytics and learning-gap diagnostics.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 13.5,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInsightsGrid(BuildContext context, ClassroomProgressStats stats) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= Responsive.phoneBreakpoint;

        final cards = <Widget>[];

        for (final weak in stats.weakAreas) {
          cards.add(
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
                          '${weak.topic} (${weak.activityType})',
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
                    '${weak.correct} / ${weak.total} correct. Targeted review recommended in Mundari.',
                    style: TextStyle(
                      fontFamily: AppTypography.sansFontFamily,
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AyoLinearProgress(
                    progress: weak.accuracy,
                    showLabel: true,
                    label: 'Classroom Accuracy',
                  ),
                ],
              ),
            ),
          );
        }

        for (final strong in stats.strongAreas) {
          cards.add(
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
                          '${strong.topic} (${strong.activityType})',
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
                    '${strong.correct} / ${strong.total} completed successfully.',
                    style: TextStyle(
                      fontFamily: AppTypography.sansFontFamily,
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AyoLinearProgress(
                    progress: strong.accuracy,
                    showLabel: true,
                    label: 'Retention Score',
                  ),
                ],
              ),
            ),
          );
        }

        if (cards.isEmpty) {
          return const SizedBox.shrink();
        }

        if (!isWide) {
          return Column(
            children: [
              for (int i = 0; i < cards.length; i++) ...[
                cards[i],
                if (i < cards.length - 1) const SizedBox(height: AppSpacing.md),
              ],
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < cards.length; i++) ...[
              Expanded(child: cards[i]),
              if (i < cards.length - 1) const SizedBox(width: AppSpacing.md),
            ],
          ],
        );
      },
    );
  }
}
