import 'package:flutter/material.dart';
import '../../app/responsive/responsive.dart';
import '../../app/theme/app_dimens.dart';
import '../../widgets/ayo_badges.dart';
import '../../widgets/ayo_cards.dart';
import '../../widgets/ayo_dividers.dart';
import '../../widgets/ayo_inputs.dart';
import '../../widgets/ayo_screen_background.dart';
import '../../widgets/ayo_states.dart';
import '../../widgets/ayo_top_header.dart';
import '../settings/settings_screen.dart';

/// Tools Screen Foundation for AYOVAANI.
///
/// Teacher-side Studio Tools:
/// 1. Automatic Worksheet Generation
/// 2. Automatic Quiz Generation
/// 3. Live Two-Way Voice Translation (Human-in-the-loop)
/// 4. Learning Continuity Mode
/// 5. Classroom Teaching Mode
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
                  title: 'Teacher Tools',
                  subtitle: 'Automated pedagogy generators, live translation & learning continuity',
                  onSettingsTap: () => SettingsScreen.show(context),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Language Pair Selector Bar
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

                // Human-in-the-loop review alert
                AyoReviewBanner(
                  title: 'Human-in-the-Loop Translation Notice',
                  message: '2 AI-suggested Gondi translations require teacher confirmation before printing.',
                  pendingCount: 2,
                  onReviewTap: () {},
                ),
                const SizedBox(height: AppSpacing.xl),

                const AyoSectionHeader(
                  title: 'Classroom Creation & Pedagogy Tools',
                  subtitle: 'Generate customized materials and initiate real-time dialogue',
                ),
                const SizedBox(height: AppSpacing.md),

                // Tool Action Cards Grid
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= Responsive.phoneBreakpoint;

                    final tools = [
                      AyoActionCard(
                        title: 'Live Two-Way Voice Translation',
                        description: 'Real-time teacher-student dialogue with mother-tongue audio & text display.',
                        icon: Icons.record_voice_over_rounded,
                        tag: 'Real-Time',
                        badgeVariant: AyoBadgeVariant.live,
                        isCoreFeature: true,
                        onTap: () {
                          widget.onNavigateToLiveTranslate?.call();
                        },
                      ),
                      AyoActionCard(
                        title: 'Worksheet Generator',
                        description: 'Generate printable and digital multilingual worksheets with matching & vocabulary.',
                        icon: Icons.description_rounded,
                        tag: 'Offline Ready',
                        badgeVariant: AyoBadgeVariant.offline,
                        isCoreFeature: true,
                        onTap: () {},
                      ),
                      AyoActionCard(
                        title: 'Quiz & Assessment Generator',
                        description: 'Build interactive comprehension quizzes, listening tests, and oral evaluations.',
                        icon: Icons.quiz_rounded,
                        tag: 'Assessments',
                        badgeVariant: AyoBadgeVariant.neutral,
                        onTap: () {},
                      ),
                      AyoActionCard(
                        title: 'Learning Continuity Mode',
                        description: 'Pre-packaged autonomous learning modules when the teacher is unavailable.',
                        icon: Icons.all_inclusive_rounded,
                        tag: 'Continuity',
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
