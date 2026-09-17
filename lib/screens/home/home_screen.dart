import 'package:flutter/material.dart';
import '../../app/responsive/responsive.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_typography.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/ayo_class_selection_grid.dart';
import '../../widgets/ayo_logo.dart';
import '../live_translate/live_translate_screen.dart';
import '../settings/settings_screen.dart';

/// Screen 03 — Home / Dashboard for AYOVAANI Teacher App.
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    this.onNavigateToLearn,
    this.onNavigateToTools,
    this.onNavigateToProgress,
    this.onNavigateToProfile,
    this.onNavigateToTranslate,
    this.onNavigateToBalvatika,
    this.onNavigateToFirst,
    this.onNavigateToSecond,
    this.onNavigateToThird,
  });

  final VoidCallback? onNavigateToLearn;
  final VoidCallback? onNavigateToTools;
  final VoidCallback? onNavigateToProgress;
  final VoidCallback? onNavigateToProfile;
  final VoidCallback? onNavigateToTranslate;
  final VoidCallback? onNavigateToBalvatika;
  final VoidCallback? onNavigateToFirst;
  final VoidCallback? onNavigateToSecond;
  final VoidCallback? onNavigateToThird;

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTabletOrLarger(context);
    final cornerSize = isTablet ? 135.0 : 100.0;

    return Stack(
      children: [
        // Decorative Corner Ornaments
        Positioned(
          top: 0,
          left: 0,
          child: IgnorePointer(
            child: _buildCornerDecoration(isRight: false, size: cornerSize),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: IgnorePointer(
            child: _buildCornerDecoration(isRight: true, size: cornerSize),
          ),
        ),

        // Main Home Screen Content
        LayoutBuilder(
          builder: (context, constraints) {
            final availableHeight = constraints.maxHeight;
            final isCompactHeight = availableHeight < 700.0;

            final topSpacing = isTablet
                ? (isCompactHeight ? 14.0 : 20.0)
                : (isCompactHeight ? 14.0 : (availableHeight * 0.032).clamp(20.0, 30.0));

            final logoHeight = isTablet
                ? (isCompactHeight ? 115.0 : 130.0)
                : (isCompactHeight ? 88.0 : (availableHeight * 0.14).clamp(98.0, 108.0));

            final logoToGreetingSpacing = isTablet
                ? (isCompactHeight ? 18.0 : 24.0)
                : (isCompactHeight ? 20.0 : (availableHeight * 0.046).clamp(30.0, 42.0));

            final greetingToOfflineSpacing = isTablet
                ? (isCompactHeight ? 14.0 : 18.0)
                : (isCompactHeight ? 14.0 : (availableHeight * 0.026).clamp(18.0, 24.0));

            final offlineToContentSpacing = isTablet
                ? (isCompactHeight ? 20.0 : 26.0)
                : (isCompactHeight ? 16.0 : (availableHeight * 0.030).clamp(20.0, 26.0));

            final lessonToToolsSpacing = isCompactHeight
                ? 16.0
                : (availableHeight * 0.030).clamp(20.0, 26.0);

            final bottomSpacing = isTablet
                ? (isCompactHeight ? 16.0 : 24.0)
                : (isCompactHeight ? 12.0 : (availableHeight * 0.020).clamp(14.0, 22.0));

            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.only(
                left: isTablet ? 48.0 : AppSpacing.lg,
                right: isTablet ? 48.0 : AppSpacing.lg,
                top: topSpacing,
                bottom: bottomSpacing,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isTablet ? 1060.0 : double.infinity,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Top Center: Logo
                      _buildTopLogo(logoHeight),

                      SizedBox(height: logoToGreetingSpacing),

                      // 2. Teacher Greeting + Settings Entry Point
                      _buildGreeting(context, isTablet),

                      SizedBox(height: greetingToOfflineSpacing),

                      // 3. Offline Status Card
                      _buildOfflineStatusCard(context),

                      SizedBox(height: offlineToContentSpacing),

                      // 4. Main Content: 2-Column on Tablet, Single-Column on Mobile
                      if (isTablet)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildTodaysLessonSection(context, isTablet: true),
                            ),
                            const SizedBox(width: 24.0),
                            Expanded(
                              child: _buildQuickToolsSection(context, isTablet: true),
                            ),
                          ],
                        )
                      else ...[
                        _buildTodaysLessonSection(context, isTablet: false),
                        SizedBox(height: lessonToToolsSpacing),
                        _buildQuickToolsSection(context, isTablet: false),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCornerDecoration({
    required bool isRight,
    required double size,
  }) {
    final imageWidget = Image.asset(
      'assets/images/corner-desing.png',
      width: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          'assets/images/corner-design.png',
          width: size,
          fit: BoxFit.contain,
        );
      },
    );

    return isRight
        ? Transform.flip(
            flipX: true,
            child: imageWidget,
          )
        : imageWidget;
  }

  Widget _buildTopLogo(double logoHeight) {
    return SizedBox(
      width: double.infinity,
      child: Center(
        child: AyoLogo(
          height: logoHeight,
        ),
      ),
    );
  }

  Widget _buildGreeting(BuildContext context, bool isTablet) {
    final l10n = AppLocalizations.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.homeGreeting ?? 'Hello, Teacher',
              style: TextStyle(
                fontFamily: AppTypography.headingFontFamily,
                fontSize: isTablet ? 25.0 : 22.0,
                fontWeight: FontWeight.w400,
                color: AppColors.primaryBurgundy,
                letterSpacing: -0.2,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              l10n?.homeSubGreeting ?? 'Ready to inspire today?',
              style: TextStyle(
                fontFamily: AppTypography.bodyFontFamily,
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),
          ],
        ),

        Tooltip(
          message: l10n?.profileTitle ?? 'Teacher Profile & Settings',
          child: Material(
            color: const Color(0xFFFDFBF7),
            borderRadius: BorderRadius.circular(20.0),
            child: InkWell(
              onTap: () => SettingsScreen.show(context),
              borderRadius: BorderRadius.circular(20.0),
              child: Container(
                width: 42.0,
                height: 42.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(color: const Color(0xFFE8DECF)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x084A3B32),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.settings_rounded,
                  size: 22.0,
                  color: AppColors.primaryBurgundy,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOfflineStatusCard(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9F5),
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: const Color(0xFFD6E3D4),
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x062C4A26),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      child: Row(
        children: [
          Container(
            width: 32.0,
            height: 32.0,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F0E4),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cloud_done_rounded,
              color: Color(0xFF4C7544),
              size: 18.0,
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        l10n?.labelOfflineReady ?? 'Offline Ready',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTypography.bodyFontFamily,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2C4A26),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 2.0,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2EDDF),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Text(
                        '24 lessons',
                        style: TextStyle(
                          fontFamily: AppTypography.bodyFontFamily,
                          fontSize: 11.0,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF385E32),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2.0),
                Text(
                  l10n?.homeContentSynced ?? 'Content synced today.',
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF5E725B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaysLessonSection(BuildContext context, {bool isTablet = false}) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n?.homeLetsStart ?? "Let's Start",
          style: TextStyle(
            fontFamily: AppTypography.headingFontFamily,
            fontSize: isTablet ? 20.0 : 18.0,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
            letterSpacing: -0.1,
          ),
        ),
        SizedBox(height: isTablet ? 12.0 : 10.0),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFDFBF7),
            borderRadius: BorderRadius.circular(18.0),
            border: Border.all(
              color: const Color(0xFFE8DECF),
              width: 1.0,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x084A3B32),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          padding: EdgeInsets.all(isTablet ? 20.0 : 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n?.math ?? 'Mathematics',
                          style: TextStyle(
                            fontFamily: AppTypography.headingFontFamily,
                            fontSize: isTablet ? 20.0 : 18.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          l10n?.homeFeaturedLessonTitle ?? 'Numbers 1–20',
                          style: TextStyle(
                            fontFamily: AppTypography.bodyFontFamily,
                            fontSize: isTablet ? 15.0 : 14.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          '${l10n?.labelClassWithNumber('2') ?? 'Class 2'} • Santhali',
                          style: TextStyle(
                            fontFamily: AppTypography.bodyFontFamily,
                            fontSize: isTablet ? 13.5 : 13.0,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14.0),
                  Container(
                    width: isTablet ? 78.0 : 72.0,
                    height: isTablet ? 78.0 : 72.0,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2E6D5),
                      borderRadius: BorderRadius.circular(14.0),
                      border: Border.all(
                        color: const Color(0xFFE2D4C0),
                        width: 1.0,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          'assets/images/warli_background.png',
                          fit: BoxFit.cover,
                          alignment: const Alignment(-0.25, 0.65),
                        ),
                        Container(
                          color: const Color(0x10671D21),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: isTablet ? 20.0 : 18.0),
              SizedBox(
                width: double.infinity,
                height: 48.0,
                child: ElevatedButton(
                  onPressed: () {
                    if (onNavigateToTranslate != null) {
                      onNavigateToTranslate!();
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) => const LiveTranslateScreen(),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBurgundy,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n?.navTranslate ?? 'Translate',
                        style: TextStyle(
                          fontFamily: AppTypography.bodyFontFamily,
                          fontSize: 15.0,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 18.0,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickToolsSection(BuildContext context, {bool isTablet = false}) {
    return AyoClassSelectionGrid(
      onNavigateToBalvatika: onNavigateToBalvatika,
      onNavigateToFirst: onNavigateToFirst,
      onNavigateToSecond: onNavigateToSecond,
      onNavigateToThird: onNavigateToThird,
      isTablet: isTablet,
    );
  }
}
