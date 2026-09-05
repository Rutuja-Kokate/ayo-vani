import 'package:flutter/material.dart';
import '../../app/responsive/responsive.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_typography.dart';
import '../../widgets/ayo_badges.dart';
import '../../widgets/ayo_buttons.dart';
import '../../widgets/ayo_cards.dart';
import '../../widgets/ayo_dividers.dart';
import '../../widgets/ayo_inputs.dart';
import '../../widgets/ayo_logo.dart';
import '../../widgets/ayo_progress.dart';
import '../../widgets/ayo_screen_background.dart';
import '../../widgets/ayo_states.dart';
import '../../widgets/ayo_top_header.dart';
import '../settings/settings_screen.dart';

/// Comprehensive interactive design system preview for AYOVAANI.
///
/// Demonstrates every single token, color, typography, and reusable component:
/// - Brand logo variants using official asset
/// - Top header with settings trigger
/// - Color system swatches (Parchment, Burgundy, Terracotta, Olive, Gold)
/// - Typography hierarchy (DM Serif Display + Inter)
/// - Buttons & interactive controls (Primary, Outlined, Audio, Back)
/// - Cards (Base Paper Panel, Action, Lesson)
/// - Badges & Status chips
/// - Progress indicators (Linear, Circular, Step)
/// - Inputs, Selectors & Tabs
/// - States (Empty, Review, Offline, Confirmation)
class ThemePreviewScreen extends StatefulWidget {
  const ThemePreviewScreen({super.key});

  @override
  State<ThemePreviewScreen> createState() => _ThemePreviewScreenState();
}

class _ThemePreviewScreenState extends State<ThemePreviewScreen> {
  int _selectedTab = 0;
  String _sourceLang = 'Hindi';
  String _targetLang = 'Gondi';
  bool _isAudioPlaying = false;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isPhone = Responsive.isPhone(context);

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
                // 1. Top Header
                AyoTopHeader(
                  title: 'Design System & Foundation',
                  subtitle: 'Centralized tokens, cultural motifs, and reusable components',
                  onSettingsTap: () => SettingsScreen.show(context),
                ),
                const SizedBox(height: AppSpacing.lg),

                // 2. Responsive Device Info Banner
                AyoCard(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBurgundy,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: const Icon(
                          Icons.devices_rounded,
                          color: AppColors.cardSurface,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isPhone ? 'Phone Mode (< 600dp)' : 'Tablet Mode (>= 600dp)',
                              style: TextStyle(
                                fontFamily: AppTypography.bodyFontFamily,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Screen Width: ${width.toInt()} dp • Scalable Layout',
                              style: TextStyle(
                                fontFamily: AppTypography.bodyFontFamily,
                                fontSize: 12.0,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const AyoBadge(
                        label: 'Master Reference',
                        variant: AyoBadgeVariant.verified,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // 3. Official Brand Asset Logo
                const AyoSectionHeader(
                  title: 'Official Brand Logo',
                  subtitle: 'Exact mother-and-child artwork with pristine proportions',
                ),
                const SizedBox(height: AppSpacing.md),
                AyoCard(
                  child: Center(
                    child: Column(
                      children: [
                        const AyoLogo(
                          variant: AyoLogoVariant.hero,
                          height: 120,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        const AyoWarliDivider(height: 5),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: const [
                            AyoLogo(variant: AyoLogoVariant.compact, height: 42),
                            AyoLogo(variant: AyoLogoVariant.mark, height: 36),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // 4. Centralized Color Palette
                const AyoSectionHeader(
                  title: 'Master Reference Palette',
                  subtitle: 'Rich warm parchment (#EEDABC), burgundy (#671D21), terracotta & olive',
                ),
                const SizedBox(height: AppSpacing.md),
                GridView.count(
                  crossAxisCount: isPhone ? 2 : 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: AppSpacing.sm,
                  mainAxisSpacing: AppSpacing.sm,
                  childAspectRatio: 2.3,
                  children: const [
                    _ColorBox(name: 'App Background', hex: '#EEDABC', color: AppColors.background, textColor: AppColors.textPrimary),
                    _ColorBox(name: 'Primary Burgundy', hex: '#671D21', color: AppColors.primaryBurgundy, textColor: Colors.white),
                    _ColorBox(name: 'Card Surface', hex: '#F5E7CC', color: AppColors.cardSurface, textColor: AppColors.textPrimary),
                    _ColorBox(name: 'Dark Brown Text', hex: '#251E11', color: AppColors.textPrimary, textColor: Colors.white),
                    _ColorBox(name: 'Terracotta', hex: '#A85B4F', color: AppColors.secondaryTerracotta, textColor: Colors.white),
                    _ColorBox(name: 'Muted Olive', hex: '#526B4F', color: AppColors.oliveGreen, textColor: Colors.white),
                    _ColorBox(name: 'Warm Gold', hex: '#C0A993', color: AppColors.warmGold, textColor: AppColors.textPrimary),
                    _ColorBox(name: 'Soft Sand Border', hex: '#D8C6AC', color: AppColors.borderWarm, textColor: AppColors.textPrimary),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),

                // 5. Buttons & Interactive Controls
                const AyoSectionHeader(
                  title: 'Buttons & Action Controls',
                  subtitle: 'Deep burgundy action buttons & audio pronunciation',
                ),
                const SizedBox(height: AppSpacing.md),
                AyoCard(
                  child: Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.md,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      AyoPrimaryButton(
                        label: 'Start Classroom →',
                        onPressed: () {},
                      ),
                      AyoOutlinedButton(
                        label: 'Explore Lessons',
                        onPressed: () {},
                      ),
                      AyoAudioButton(
                        isPlaying: _isAudioPlaying,
                        onPressed: () => setState(() => _isAudioPlaying = !_isAudioPlaying),
                      ),
                      const AyoBackButton(),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // 6. Badges & Status Indicators
                const AyoSectionHeader(
                  title: 'Status Badges & Chips',
                  subtitle: 'Semantic tags for offline, mother-tongue, and review states',
                ),
                const SizedBox(height: AppSpacing.md),
                AyoCard(
                  child: Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: const [
                      AyoBadge(label: 'Offline Ready', variant: AyoBadgeVariant.offline),
                      AyoBadge(label: 'Hindi → Gondi', variant: AyoBadgeVariant.motherTongue),
                      AyoBadge(label: 'Teacher Verified', variant: AyoBadgeVariant.verified),
                      AyoBadge(label: 'Review Needed', variant: AyoBadgeVariant.reviewNeeded),
                      AyoBadge(label: 'Live Mode', variant: AyoBadgeVariant.live),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // 7. Inputs, Selectors & Tabs
                const AyoSectionHeader(
                  title: 'Input Controls & Selectors',
                  subtitle: 'Language selectors, dropdowns, and modular tab switchers',
                ),
                const SizedBox(height: AppSpacing.md),
                AyoTabBar(
                  tabs: const ['Curriculum', 'Teacher Tools', 'Progress'],
                  selectedIndex: _selectedTab,
                  onTabSelected: (i) => setState(() => _selectedTab = i),
                ),
                const SizedBox(height: AppSpacing.md),
                AyoLanguageSelector(
                  sourceLanguage: _sourceLang,
                  targetLanguage: _targetLang,
                  onSourceTap: () {},
                  onTargetTap: () {},
                  onSwapTap: () {
                    setState(() {
                      final t = _sourceLang;
                      _sourceLang = _targetLang;
                      _targetLang = t;
                    });
                  },
                ),

                const SizedBox(height: AppSpacing.xl),

                // 8. Progress Indicators
                const AyoSectionHeader(
                  title: 'Progress Indicators',
                  subtitle: 'Linear, circular, and multi-step progress',
                ),
                const SizedBox(height: AppSpacing.md),
                AyoCard(
                  child: Column(
                    children: const [
                      AyoLinearProgress(progress: 0.75, showLabel: true, label: 'Lesson Completion'),
                      SizedBox(height: AppSpacing.lg),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          AyoCircularProgress(progress: 0.82),
                          AyoStepProgress(totalSteps: 5, currentStep: 2),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // 9. States (Review, Offline, Empty)
                const AyoSectionHeader(
                  title: 'Semantic State Components',
                  subtitle: 'Human-in-the-loop alerts, offline indicators, and empty states',
                ),
                const SizedBox(height: AppSpacing.md),
                const AyoReviewBanner(
                  title: 'AI Translation Review',
                  message: 'Verify 3 Gondi vocabulary terms before printing worksheets.',
                  pendingCount: 3,
                ),
                const SizedBox(height: AppSpacing.md),
                const AyoOfflineIndicator(
                  isOffline: true,
                  lastSyncedTime: 'Today, 8:30 AM',
                  downloadedModulesCount: 14,
                ),
                const SizedBox(height: AppSpacing.md),
                const AyoEmptyState(
                  title: 'No Worksheets Generated Yet',
                  description: 'Select a lesson module and tap Generate to create printable classroom exercises.',
                  actionLabel: 'Create Worksheet',
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

class _ColorBox extends StatelessWidget {
  const _ColorBox({
    required this.name,
    required this.hex,
    required this.color,
    required this.textColor,
  });

  final String name;
  final String hex;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.borderWarm, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            name,
            style: TextStyle(
              fontFamily: AppTypography.bodyFontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            hex,
            style: TextStyle(
              fontFamily: AppTypography.bodyFontFamily,
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: textColor.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
