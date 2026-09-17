import 'package:flutter/material.dart';
import '../../app/responsive/responsive.dart';
import '../../app/theme/app_dimens.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/ayo_badges.dart';
import '../../widgets/ayo_cards.dart';
import '../../widgets/ayo_dividers.dart';
import '../../widgets/ayo_inputs.dart';
import '../../widgets/ayo_screen_background.dart';
import '../../widgets/ayo_states.dart';
import '../../widgets/ayo_top_header.dart';
import '../settings/settings_screen.dart';

/// Tools Screen Foundation for AYOVAANI.
class ToolsScreen extends StatefulWidget {
  const ToolsScreen({
    super.key,
    this.onNavigateToLiveTranslate,
  });

  final VoidCallback? onNavigateToLiveTranslate;

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  String _sourceLang = 'Hindi';
  String _targetLang = 'Gondi';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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
                  AyoTopHeader(
                    title: l10n?.toolsTitle ?? 'Teacher Tools',
                    subtitle: l10n?.toolsSubtitle ?? 'Utilities & resources for the classroom',
                    onSettingsTap: () => SettingsScreen.show(context),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  AyoLanguageSelector(
                    sourceLanguage: _sourceLang,
                    targetLanguage: _targetLang,
                    onSourceTap: () {},
                    onTargetTap: () {},
                    onSwapTap: () {
                      setState(() {
                        final temp = _sourceLang;
                        _sourceLang = _targetLang;
                        _targetLang = temp;
                      });
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  AyoReviewBanner(
                    title: l10n?.toolsReviewTitle ?? 'Human-in-the-Loop Translation Notice',
                    message: l10n?.toolsReviewNoticeMsg ?? '2 AI-suggested Gondi translations require teacher confirmation before printing.',
                    pendingCount: 2,
                    onReviewTap: () {},
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  AyoSectionHeader(
                    title: l10n?.toolsTitle ?? 'Classroom Creation & Pedagogy Tools',
                    subtitle: l10n?.toolsSubtitle ?? 'Generate customized materials and initiate real-time dialogue',
                  ),
                  const SizedBox(height: AppSpacing.md),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= Responsive.phoneBreakpoint;

                      final tools = [
                        AyoActionCard(
                          title: l10n?.toolsLiveTranslate ?? 'Live Two-Way Voice Translation',
                          description: l10n?.toolsLiveTranslateDesc ?? 'Real-time teacher-student dialogue with mother-tongue audio & text display.',
                          icon: Icons.record_voice_over_rounded,
                          tag: l10n?.badgeRealTime ?? 'Real-Time',
                          badgeVariant: AyoBadgeVariant.live,
                          isCoreFeature: true,
                          onTap: () {
                            widget.onNavigateToLiveTranslate?.call();
                          },
                        ),
                        AyoActionCard(
                          title: l10n?.toolsWorksheetGen ?? 'Worksheet Generator',
                          description: l10n?.toolsWorksheetGenDesc ?? 'Generate printable and digital multilingual worksheets with matching & vocabulary.',
                          icon: Icons.description_rounded,
                          tag: l10n?.labelOfflineReady ?? 'Offline Ready',
                          badgeVariant: AyoBadgeVariant.offline,
                          isCoreFeature: true,
                          onTap: () {},
                        ),
                        AyoActionCard(
                          title: l10n?.toolsQuizMaker ?? 'Quiz & Assessment Generator',
                          description: l10n?.toolsQuizMakerDesc ?? 'Build interactive comprehension quizzes, listening tests, and oral evaluations.',
                          icon: Icons.quiz_rounded,
                          tag: l10n?.badgeAssessments ?? 'Assessments',
                          badgeVariant: AyoBadgeVariant.neutral,
                          onTap: () {},
                        ),
                        AyoActionCard(
                          title: l10n?.toolsContinuityTitle ?? 'Learning Continuity Mode',
                          description: l10n?.toolsContinuityDesc ?? 'Pre-packaged autonomous learning modules when the teacher is unavailable.',
                          icon: Icons.all_inclusive_rounded,
                          tag: l10n?.badgeContinuity ?? 'Continuity',
                          badgeVariant: AyoBadgeVariant.motherTongue,
                          onTap: () {},
                        ),
                      ];

                      if (!isWide) {
                        return Column(
                          children: [
                            for (int i = 0; i < tools.length; i++) ...[
                              tools[i],
                              if (i < tools.length - 1)
                                const SizedBox(height: AppSpacing.md),
                            ],
                          ],
                        );
                      }

                      return GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: AppSpacing.md,
                        mainAxisSpacing: AppSpacing.md,
                        childAspectRatio: 1.9,
                        children: tools,
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
