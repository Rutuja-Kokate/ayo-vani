import 'package:flutter/material.dart';
import '../../app/responsive/responsive.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_typography.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/ayo_bottom_nav_bar.dart';
import '../../widgets/ayo_logo.dart';
import '../../widgets/ayo_screen_background.dart';
import 'student_levels_screen.dart';
import 'teacher_levels_screen.dart';

/// Screen: Learn Module Entry Screen for AYOVAANI.
///
/// Features TWO primary learning pathways:
/// 1. For Teachers: "Plan, prepare & teach" (Lessons • Worksheets • Quizzes • Translation)
/// 2. For Students: "Learn, practice & play" (Lessons • Flashcards • Games • Activities)
///
/// Faithfully reproduces the reference visual design:
/// - Warm cream/parchment background with Warli corner art
/// - Circular back button at top-left
/// - Centered official AyoVaani logo
/// - Serif "Learning" heading & warm brown subtitle
/// - Elegant botanical 3-leaf Warli decorative divider
/// - Two large rounded cards with culturally authentic illustrations & corner ornaments
/// - Burgundy pill action buttons ("Explore →" & "Start Learning →")
/// - Responsive adaptation for mobile and tablet
class LearnScreen extends StatelessWidget {
  const LearnScreen({
    super.key,
    this.onBack,
    this.onNavigateToTeacher,
    this.onNavigateToStudent,
    this.onNavigateToBalvatika,
    this.onNavigateToFirst,
    this.onNavigateToSecond,
    this.onNavigateToThird,
    this.onNavigateTab,
    this.isShellTab = false,
  });

  final VoidCallback? onBack;
  final VoidCallback? onNavigateToTeacher;
  final VoidCallback? onNavigateToStudent;
  final VoidCallback? onNavigateToBalvatika;
  final VoidCallback? onNavigateToFirst;
  final VoidCallback? onNavigateToSecond;
  final VoidCallback? onNavigateToThird;
  final ValueChanged<int>? onNavigateTab;
  final bool isShellTab;

  void _handleBack(BuildContext context) {
    if (onBack != null) {
      onBack!();
    } else if (isShellTab && onNavigateTab != null) {
      onNavigateTab!(0); // Switch to Home tab
    } else {
      Navigator.of(context).maybePop();
    }
  }

  void _handleTeacherAction(BuildContext context) {
    if (onNavigateToTeacher != null) {
      onNavigateToTeacher!();
    } else {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => TeacherLevelsScreen(
            onNavigateTab: onNavigateTab,
          ),
        ),
      );
    }
  }

  void _handleStudentAction(BuildContext context) {
    if (onNavigateToStudent != null) {
      onNavigateToStudent!();
    } else {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => StudentLevelsScreen(
            onNavigateTab: onNavigateTab,
          ),
        ),
      );
    }
  }

  void _onBottomNavSelected(BuildContext context, int index) {
    if (index == 1) {
      // Already on Learn tab
      return;
    }
    if (onNavigateTab != null) {
      onNavigateTab!(index);
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTabletOrLarger(context);
    final cornerSize = isTablet ? 120.0 : 88.0;

    return AyoScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              // Top-left Warli Corner Ornament
              Positioned(
                top: 0,
                left: 0,
                child: IgnorePointer(
                  child: _buildCornerDecoration(
                    isRight: false,
                    size: cornerSize,
                  ),
                ),
              ),

              // Top-right Warli Corner Ornament (Horizontally Mirrored)
              Positioned(
                top: 0,
                right: 0,
                child: IgnorePointer(
                  child: _buildCornerDecoration(
                    isRight: true,
                    size: cornerSize,
                  ),
                ),
              ),

              // Main Scrollable Content
              LayoutBuilder(
                builder: (context, constraints) {
                  final horizontalPadding = isTablet ? 40.0 : AppSpacing.md;
                  final contentMaxWidth = isTablet ? 680.0 : double.infinity;

                  return SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: EdgeInsets.only(
                      left: horizontalPadding,
                      right: horizontalPadding,
                      top: isTablet ? 12.0 : 8.0,
                      bottom: 24.0,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: contentMaxWidth),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // 1. Top Bar: Back Button (Upper-Left) + Centered AyoVaani Brand Logo
                            _buildTopBar(context, isTablet),

                            SizedBox(height: isTablet ? 16.0 : 12.0),

                            // 2. Section Header: Title, Subtitle, & Botanical Divider
                            _buildHeader(context, isTablet),

                            SizedBox(height: isTablet ? 20.0 : 16.0),

                            // 3. Card 1: For Teachers
                            _buildLearningCard(
                              context: context,
                              isTablet: isTablet,
                              title: AppLocalizations.of(context)?.learnForTeachers ?? 'For Teachers',
                              subtitle: AppLocalizations.of(context)?.learnTeacherSubtitle ?? 'Plan, prepare & teach',
                              tags: AppLocalizations.of(context)?.learnTeacherTags ?? 'Lessons • Worksheets • Quizzes • Translation',
                              buttonText: AppLocalizations.of(context)?.btnExplore ?? 'Explore',
                              badgeIcon: Icons.co_present_rounded,
                              badgeBgColor: const Color(0xFFF7EBEB),
                              badgeIconColor: AppColors.primaryBurgundy,
                              imageAsset: 'assets/images/teacher_learning.jpg',
                              fallbackIcon: Icons.school_rounded,
                              onTap: () => _handleTeacherAction(context),
                            ),

                            SizedBox(height: isTablet ? 18.0 : 14.0),

                            // 4. Card 2: For Students
                            _buildLearningCard(
                              context: context,
                              isTablet: isTablet,
                              title: AppLocalizations.of(context)?.learnForStudents ?? 'For Students',
                              subtitle: AppLocalizations.of(context)?.learnStudentSubtitle ?? 'Learn, practice & play',
                              tags: AppLocalizations.of(context)?.learnStudentTags ?? 'Lessons • Flashcards • Games • Activities',
                              buttonText: AppLocalizations.of(context)?.btnStartLearning ?? 'Start Learning',
                              badgeIcon: Icons.face_rounded,
                              badgeBgColor: const Color(0xFFEAF3E8),
                              badgeIconColor: const Color(0xFF416B3C),
                              imageAsset: 'assets/images/student_learning.jpg',
                              fallbackIcon: Icons.menu_book_rounded,
                              onTap: () => _handleStudentAction(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        bottomNavigationBar: isShellTab
            ? null
            : AyoBottomNavBar(
                selectedIndex: 1,
                onItemSelected: (index) => _onBottomNavSelected(context, index),
              ),
      ),
    );
  }

  /// Top decorative Warli corner ornament.
  Widget _buildCornerDecoration({
    required bool isRight,
    required double size,
  }) {
    final imageWidget = Image.asset(
      'assets/images/corner-design.png',
      width: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          'assets/images/corner-desing.png',
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

  /// Top Bar with Back Button at upper-left and Centered AyoVaani Logo.
  Widget _buildTopBar(BuildContext context, bool isTablet) {
    final logoHeight = isTablet ? 122.0 : 96.0;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Circular White Back Button on the Upper-Left
        Align(
          alignment: Alignment.centerLeft,
          child: Material(
            color: Colors.white,
            shape: const CircleBorder(),
            elevation: 1.5,
            shadowColor: Colors.black.withValues(alpha: 0.10),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => _handleBack(context),
              splashColor: AppColors.primaryBurgundy.withValues(alpha: 0.12),
              child: Container(
                width: 38.0,
                height: 38.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFE8DECF),
                    width: 1.0,
                  ),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.textPrimary,
                  size: 20.0,
                ),
              ),
            ),
          ),
        ),

        // Centered AyoVaani Brand Logo
        AyoLogo(
          height: logoHeight,
        ),
      ],
    );
  }

  /// Header with Title, Subtitle, and small Botanical Divider.
  Widget _buildHeader(BuildContext context, bool isTablet) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        Text(
          l10n?.learnTitle ?? 'Learning',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTypography.headingFontFamily,
            fontSize: isTablet ? 34.0 : 30.0,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          l10n?.learnSubtitle ?? 'Choose how you want to learn today',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTypography.bodyFontFamily,
            fontSize: isTablet ? 14.5 : 13.5,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12.0),
        // Small Centered Botanical Warli Leaf Divider
        SizedBox(
          width: 110.0,
          height: 14.0,
          child: CustomPaint(
            painter: _DecorativeLeafDividerPainter(
              color: const Color(0xFF671D21),
            ),
          ),
        ),
      ],
    );
  }

  /// Large Learning Card (Used for Teachers and Students).
  Widget _buildLearningCard({
    required BuildContext context,
    required bool isTablet,
    required String title,
    required String subtitle,
    required String tags,
    required String buttonText,
    required IconData badgeIcon,
    required Color badgeBgColor,
    required Color badgeIconColor,
    required String imageAsset,
    required IconData fallbackIcon,
    required VoidCallback onTap,
  }) {
    final imageSize = isTablet ? 140.0 : 106.0;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFCFAF7),
        borderRadius: BorderRadius.circular(22.0),
        border: Border.all(
          color: const Color(0xFFEBE0D0),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A3427).withValues(alpha: 0.05),
            blurRadius: 12.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22.0),
          splashColor: AppColors.primaryBurgundy.withValues(alpha: 0.06),
          highlightColor: AppColors.primaryBurgundy.withValues(alpha: 0.03),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 20.0 : 13.0,
              vertical: isTablet ? 18.0 : 13.0,
            ),
            child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Illustration on the LEFT inside a soft circular container
                      Container(
                        width: imageSize,
                        height: imageSize,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFF7EFE4),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            imageAsset,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(
                                  fallbackIcon,
                                  size: 44.0,
                                  color: AppColors.primaryBurgundy.withValues(alpha: 0.4),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      SizedBox(width: isTablet ? 16.0 : 12.0),

                      // Content on the RIGHT
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Badge Icon + Title Row
                            Row(
                              children: [
                                Container(
                                  width: 34.0,
                                  height: 34.0,
                                  decoration: BoxDecoration(
                                    color: badgeBgColor,
                                    borderRadius: BorderRadius.circular(9.0),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      badgeIcon,
                                      size: 19.0,
                                      color: badgeIconColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                Flexible(
                                  child: Text(
                                    title,
                                    style: TextStyle(
                                      fontFamily: AppTypography.headingFontFamily,
                                      fontSize: isTablet ? 22.0 : 18.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                      letterSpacing: -0.1,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 5.0),

                            // Subtitle
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontFamily: AppTypography.bodyFontFamily,
                                fontSize: isTablet ? 13.5 : 12.0,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2C2217),
                              ),
                            ),

                            const SizedBox(height: 2.0),

                            // Tags / Features Line
                            Text(
                              tags,
                              style: TextStyle(
                                fontFamily: AppTypography.bodyFontFamily,
                                fontSize: isTablet ? 11.5 : 10.2,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textSecondary,
                                height: 1.3,
                              ),
                            ),

                            const SizedBox(height: 8.0),

                            // Burgundy Rounded Action Button
                            Material(
                              color: AppColors.primaryBurgundy,
                              borderRadius: BorderRadius.circular(20.0),
                              elevation: 0.5,
                              shadowColor: AppColors.primaryBurgundy.withValues(alpha: 0.3),
                              child: InkWell(
                                onTap: onTap,
                                borderRadius: BorderRadius.circular(20.0),
                                splashColor: Colors.white.withValues(alpha: 0.2),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isTablet ? 18.0 : 14.0,
                                    vertical: isTablet ? 8.0 : 6.0,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        buttonText,
                                        style: TextStyle(
                                          fontFamily: AppTypography.bodyFontFamily,
                                          fontSize: isTablet ? 13.0 : 11.5,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 5.0),
                                      const Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 13.0,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}

/// Custom Painter for the Centered Botanical 3-Leaf Warli Divider.
class _DecorativeLeafDividerPainter extends CustomPainter {
  const _DecorativeLeafDividerPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final linePaint = Paint()
      ..color = color.withValues(alpha: 0.50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Flanking horizontal lines
    canvas.drawLine(
      Offset(0, centerY),
      Offset(centerX - 13.0, centerY),
      linePaint,
    );

    canvas.drawLine(
      Offset(centerX + 13.0, centerY),
      Offset(size.width, centerY),
      linePaint,
    );

    // Center upright leaf petal
    final centerPetal = Path()
      ..moveTo(centerX, centerY + 3.0)
      ..quadraticBezierTo(centerX - 3.2, centerY - 2.0, centerX, centerY - 6.5)
      ..quadraticBezierTo(centerX + 3.2, centerY - 2.0, centerX, centerY + 3.0)
      ..close();
    canvas.drawPath(centerPetal, paint);

    // Left curved leaf petal
    final leftPetal = Path()
      ..moveTo(centerX - 1.2, centerY + 3.0)
      ..quadraticBezierTo(centerX - 7.5, centerY + 2.5, centerX - 8.5, centerY - 1.5)
      ..quadraticBezierTo(centerX - 3.5, centerY - 2.5, centerX - 1.2, centerY + 3.0)
      ..close();
    canvas.drawPath(leftPetal, paint);

    // Right curved leaf petal
    final rightPetal = Path()
      ..moveTo(centerX + 1.2, centerY + 3.0)
      ..quadraticBezierTo(centerX + 7.5, centerY + 2.5, centerX + 8.5, centerY - 1.5)
      ..quadraticBezierTo(centerX + 3.5, centerY - 2.5, centerX + 1.2, centerY + 3.0)
      ..close();
    canvas.drawPath(rightPetal, paint);
  }

  @override
  bool shouldRepaint(covariant _DecorativeLeafDividerPainter oldDelegate) =>
      oldDelegate.color != color;
}
