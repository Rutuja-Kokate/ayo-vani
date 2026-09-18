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
import '../validation/hitl_validation_screen.dart';
import '../../services/hitl_validation_service.dart';
import '../../models/hitl_validation_models.dart';

/// Screen 03 — Home / Dashboard for AYOVAANI Teacher App.
///
/// Performance-Optimized for 2GB RAM Target Devices.
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
                ? (isCompactHeight ? 16.0 : 22.0)
                : (isCompactHeight ? 16.0 : (availableHeight * 0.040).clamp(22.0, 34.0));

            final sectionSpacing = isCompactHeight ? 12.0 : 16.0;

            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.only(
                left: isTablet ? 48.0 : AppSpacing.lg,
                right: isTablet ? 48.0 : AppSpacing.lg,
                top: topSpacing,
                bottom: 24.0,
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

                      // 2. Teacher Greeting Header with Option B Sync Info
                      _buildGreeting(context, isTablet),

                      SizedBox(height: sectionSpacing),

                      // 3. Progress / Stats Row
                      _buildStatsRow(context, isTablet),

                      SizedBox(height: sectionSpacing),

                      // 4. Offline Status Card
                      _buildOfflineStatusCard(context),

                      SizedBox(height: sectionSpacing),

                      // 4b. Teacher HITL Validation Center Card
                      _buildHitlValidationCard(context),

                      SizedBox(height: sectionSpacing + 2.0),

                      // 5. Main Content Layout: 2-Column on Tablet, Single-Column on Mobile
                      if (isTablet)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildTodaysLessonSection(context, isTablet: true),
                            ),
                            const SizedBox(width: 20.0),
                            Expanded(
                              child: _buildQuickToolsSection(context, isTablet: true),
                            ),
                          ],
                        )
                      else ...[
                        _buildTodaysLessonSection(context, isTablet: false),
                        SizedBox(height: sectionSpacing + 2.0),
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

  /// Greeting Header with Option B Whitespace Usage (Last Sync Info)
  Widget _buildGreeting(BuildContext context, bool isTablet) {
    final l10n = AppLocalizations.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
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
              const SizedBox(height: 3.0),
              Text(
                l10n?.homeSubGreeting ?? 'Ready to inspire today?',
                style: TextStyle(
                  fontFamily: AppTypography.bodyFontFamily,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 2.0),
              // Option B Header Whitespace: Plain text last sync info
              Text(
                l10n?.homeHeaderLastSync ?? 'Last sync: Today 9:00 AM',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11.0,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF8B4B3E),
                ),
              ),
            ],
          ),
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
                      color: Color(0x064A3B32),
                      blurRadius: 4,
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

  /// Section 1: Progress / Stats Row
  Widget _buildStatsRow(BuildContext context, bool isTablet) {
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        // Today's completed lessons
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF7EBE7),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: const Color(0xFFE8DECF),
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.task_alt_rounded,
                  size: 16.0,
                  color: AppColors.primaryBurgundy,
                ),
                const SizedBox(width: 6.0),
                Expanded(
                  child: Text(
                    l10n?.homeStatsTodayCompleted(3) ?? 'Today: 3 lessons completed',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTypography.bodyFontFamily,
                      fontSize: isTablet ? 12.5 : 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryBurgundy,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10.0),

        // Weekly count / streak
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F6EB),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: const Color(0xFFE8DECF),
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.local_fire_department_rounded,
                  size: 16.0,
                  color: Color(0xFF756E4E),
                ),
                const SizedBox(width: 6.0),
                Expanded(
                  child: Text(
                    l10n?.homeStatsWeeklyTotal(12) ?? 'This week: 12 lessons',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTypography.bodyFontFamily,
                      fontSize: isTablet ? 12.5 : 11.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF756E4E),
                    ),
                  ),
                ),
              ],
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
            blurRadius: 4,
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

  Widget _buildHitlValidationCard(BuildContext context) {
    final pendingCount = HitlValidationService().flaggedTranslations.where((t) => t.status == HitlStatusEnum.flagged).length;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const HitlValidationScreen()),
          );
        },
        borderRadius: BorderRadius.circular(14.0),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFDF8F0),
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(
              color: const Color(0xFFE8DECF),
              width: 1.0,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x064A3B32),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
          child: Row(
            children: [
              Container(
                width: 34.0,
                height: 34.0,
                decoration: const BoxDecoration(
                  color: Color(0xFFF7EBEB),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  color: AppColors.primaryBurgundy,
                  size: 20.0,
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
                        const Flexible(
                          child: Text(
                            'शिक्षक सुधार केंद्र (Teacher Validation)',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBurgundy,
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
                            color: const Color(0xFFF7EBEB),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Text(
                            '$pendingCount लंबित',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11.0,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBurgundy,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2.0),
                    const Text(
                      'कम विश्वास वाले अनुवादों की समीक्षा करें (Review Low-Confidence)',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12.0,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  /// Section 2: Enhanced "Continue" Card with static progress bar and next lesson preview
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
                color: Color(0x064A3B32),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.all(isTablet ? 20.0 : 16.0),
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
                        const SizedBox(height: 3.0),
                        Text(
                          '${l10n?.labelClassWithNumber('2') ?? 'Class 2'} • Santhali',
                          style: TextStyle(
                            fontFamily: AppTypography.bodyFontFamily,
                            fontSize: isTablet ? 13.0 : 12.5,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 3.0),
                        // Next Lesson Preview
                        Text(
                          l10n?.homeNextLessonPreview ?? 'Next lesson: Addition Practice',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF8B4B3E),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14.0),
                  // Lightweight illustration asset
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
              const SizedBox(height: 12.0),

              // Thin Static Progress Bar (60% completion of "Numbers 1-20")
              _buildStaticProgressBar(0.60),

              SizedBox(height: isTablet ? 16.0 : 14.0),

              SizedBox(
                width: double.infinity,
                height: 46.0,
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
                          fontSize: 14.5,
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

  /// Static, non-animated progress bar with zero recomposition or GPU overhead
  Widget _buildStaticProgressBar(double ratio) {
    return Container(
      width: double.infinity,
      height: 4.0,
      decoration: BoxDecoration(
        color: const Color(0xFFEFE8DD),
        borderRadius: BorderRadius.circular(2.0),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: ratio,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primaryBurgundy,
            borderRadius: BorderRadius.circular(2.0),
          ),
        ),
      ),
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
