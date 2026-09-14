import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../first/phase1_question1_screen.dart';
import '../../first/phase2_question_screen.dart';
import '../../first/phase3_question_screen.dart';

/// Interactive Phase Selection Dialog matching the AyoVaani visual design reference.
///
/// Features:
/// - Semi-transparent dimmed background overlay
/// - Warm ivory/cream parchment card with rounded corners and subtle border
/// - Traditional Indian/Warli corner ornaments (top-left & top-right)
/// - Subtle natural grass/botanical ornaments (bottom-left & bottom-right)
/// - Circular close ("X") button in upper-right corner
/// - Maroon open-book badge icon, serif "Choose a Phase" title & encouraging subtitle
/// - Three phase cards (Phase 1 unlocked/active, Phase 2 & 3 locked)
/// - Smooth scale + fade-in modal animation
class PhaseSelectionDialog extends StatelessWidget {
  const PhaseSelectionDialog({
    super.key,
    required this.levelNumber,
    required this.levelTitle,
    this.onStartPhase,
  });

  final int levelNumber;
  final String levelTitle;
  final void Function(int phaseNumber)? onStartPhase;

  /// Helper to open the phase selection dialog with smooth transition
  static Future<void> show({
    required BuildContext context,
    required int levelNumber,
    required String levelTitle,
    void Function(int phaseNumber)? onStartPhase,
  }) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.52),
      transitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (context, anim1, anim2) {
        return PhaseSelectionDialog(
          levelNumber: levelNumber,
          levelTitle: levelTitle,
          onStartPhase: onStartPhase,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  void _handlePhase1Tap(BuildContext context) {
    Navigator.of(context).pop();
    if (onStartPhase != null) {
      onStartPhase!(1);
    } else {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => const Phase1Question1Screen(),
        ),
      );
    }
  }

  void _handlePhase2Tap(BuildContext context) {
    Navigator.of(context).pop();
    if (onStartPhase != null) {
      onStartPhase!(2);
    } else {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => const Phase2QuestionScreen(),
        ),
      );
    }
  }

  void _handlePhase3Tap(BuildContext context) {
    Navigator.of(context).pop();
    if (onStartPhase != null) {
      onStartPhase!(3);
    } else {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => const Phase3QuestionScreen(),
        ),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isTablet = mediaQuery.size.width >= 600;
    final cardWidth = isTablet ? 420.0 : math.min(mediaQuery.size.width - 36.0, 360.0);

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: cardWidth,
          margin: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 24.0),
          decoration: BoxDecoration(
            color: const Color(0xFFFCFAF6), // Warm ivory/cream parchment
            borderRadius: BorderRadius.circular(24.0),
            border: Border.all(
              color: const Color(0xFFE5D7C3),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF251E11).withValues(alpha: 0.28),
                blurRadius: 28.0,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24.0),
            child: Stack(
              children: [
                // 1. Top-Left Warli corner ornament
                Positioned(
                  top: 0,
                  left: 0,
                  child: IgnorePointer(
                    child: Image.asset(
                      'assets/images/corner-design.png',
                      width: 48.0,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        'assets/images/corner-desing.png',
                        width: 48.0,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                // 2. Top-Right Warli corner ornament (horizontally flipped)
                Positioned(
                  top: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: Transform.flip(
                      flipX: true,
                      child: Image.asset(
                        'assets/images/corner-design.png',
                        width: 48.0,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Image.asset(
                          'assets/images/corner-desing.png',
                          width: 48.0,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),

                // 3. Bottom-Left grass ornament
                Positioned(
                  bottom: 2,
                  left: 6,
                  child: IgnorePointer(
                    child: Image.asset(
                      'assets/images/grass1.png',
                      width: 28.0,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                // 4. Bottom-Right grass ornament (flipped)
                Positioned(
                  bottom: 2,
                  right: 6,
                  child: IgnorePointer(
                    child: Transform.flip(
                      flipX: true,
                      child: Image.asset(
                        'assets/images/grass1.png',
                        width: 28.0,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                // 5. Close ("X") button in upper-right
                Positioned(
                  top: 14.0,
                  right: 14.0,
                  child: Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    elevation: 2.0,
                    shadowColor: Colors.black.withValues(alpha: 0.12),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => Navigator.of(context).pop(),
                      splashColor: AppColors.primaryBurgundy.withValues(alpha: 0.15),
                      child: Container(
                        width: 36.0,
                        height: 36.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFE8DECF),
                            width: 1.0,
                          ),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Color(0xFF251E11),
                          size: 20.0,
                        ),
                      ),
                    ),
                  ),
                ),

                // 6. Main Dialog Content
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Top Maroon Book Icon Badge
                      Container(
                        width: 46.0,
                        height: 46.0,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFBECEB), // Soft pale pink/cream
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.auto_stories_rounded,
                            color: Color(0xFF671D21), // Deep maroon
                            size: 24.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12.0),

                      // Title: "Choose a Phase"
                      Text(
                        'Choose a Phase',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppTypography.headingFontFamily,
                          fontSize: isTablet ? 28.0 : 25.0,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF251E11),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 6.0),

                      // Subtitle
                      Text(
                        'Each phase has 5 questions. Complete all\nphases to finish the level.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppTypography.bodyFontFamily,
                          fontSize: isTablet ? 13.5 : 12.5,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF765E49),
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 20.0),

                      // PHASE 1 CARD (Unlocked / Active)
                      _buildPhaseCard(
                        context: context,
                        isUnlocked: true,
                        phaseNumber: 1,
                        questionCount: '5 Questions',
                        iconWidget: const _OpenBookPhaseIcon(),
                        onTap: () => _handlePhase1Tap(context),
                      ),
                      const SizedBox(height: 12.0),

                      // PHASE 2 CARD (Unlocked)
                      _buildPhaseCard(
                        context: context,
                        isUnlocked: true,
                        phaseNumber: 2,
                        questionCount: '5 Questions',
                        iconWidget: const _PencilPhaseIcon(),
                        onTap: () => _handlePhase2Tap(context),
                      ),
                      const SizedBox(height: 12.0),

                      // PHASE 3 CARD (Unlocked)
                      _buildPhaseCard(
                        context: context,
                        isUnlocked: true,
                        phaseNumber: 3,
                        questionCount: '5 Questions',
                        iconWidget: const _TrophyPhaseIcon(),
                        onTap: () => _handlePhase3Tap(context),
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

  Widget _buildPhaseCard({
    required BuildContext context,
    required bool isUnlocked,
    required int phaseNumber,
    required String questionCount,
    required Widget iconWidget,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isUnlocked
            ? const Color(0xFFFFF7F6) // Warm soft pink/cream tint
            : const Color(0xFFFAF6F0), // Neutral warm cream
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(
          color: isUnlocked
              ? const Color(0xFFD49B9E) // Visible maroon outline
              : const Color(0xFFE8DEC8), // Subtle warm border
          width: isUnlocked ? 1.4 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF251E11).withValues(alpha: isUnlocked ? 0.05 : 0.02),
            blurRadius: 6.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18.0),
          splashColor: isUnlocked
              ? AppColors.primaryBurgundy.withValues(alpha: 0.12)
              : Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Left Illustration / Icon
                SizedBox(
                  width: 58.0,
                  height: 48.0,
                  child: Center(child: iconWidget),
                ),
                const SizedBox(width: 12.0),

                // 2. Middle Content (Phase pill & question count)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Phase Name Pill / Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9.0, vertical: 3.0),
                        decoration: BoxDecoration(
                          color: isUnlocked
                              ? const Color(0xFFF8E5E7) // Soft pink pill
                              : const Color(0xFFEFE8DD), // Soft cream pill
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        child: Text(
                          'Phase $phaseNumber',
                          style: TextStyle(
                            fontFamily: AppTypography.bodyFontFamily,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w700,
                            color: isUnlocked
                                ? const Color(0xFF671D21) // Maroon
                                : const Color(0xFF3B2A1E), // Dark warm brown
                          ),
                        ),
                      ),
                      const SizedBox(height: 3.5),

                      // Questions count
                      Text(
                        questionCount,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12.0,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF765E49),
                        ),
                      ),
                    ],
                  ),
                ),

                // 3. Right Action / Status
                if (isUnlocked)
                  Container(
                    width: 36.0,
                    height: 36.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF8B252C), // Active burgundy
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B252C).withValues(alpha: 0.35),
                          blurRadius: 6.0,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 18.0,
                      ),
                    ),
                  )
                else
                  Container(
                    width: 34.0,
                    height: 34.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFEDE4D6),
                      border: Border.all(
                        color: const Color(0xFFD6C8B5),
                        width: 1.0,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.lock_rounded,
                        color: Color(0xFF9E8D7D),
                        size: 16.0,
                      ),
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

// ---------------------------------------------------------------------------
// Phase Left Illustrations Matching Reference Image
// ---------------------------------------------------------------------------

/// Phase 1: Open book illustration with soft sunburst background & sparkle rays
class _OpenBookPhaseIcon extends StatelessWidget {
  const _OpenBookPhaseIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 54.0,
      height: 44.0,
      child: CustomPaint(
        painter: _OpenBookPainter(),
      ),
    );
  }
}

class _OpenBookPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    // 1. Soft pinkish-cream sunburst glow
    final glowPaint = Paint()..color = const Color(0xFFFDECEB);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: w * 0.90, height: h * 0.90),
      glowPaint,
    );

    // 2. Sparkle dash rays around book
    final rayPaint = Paint()
      ..color = const Color(0xFF8B4B4E).withValues(alpha: 0.65)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    // Top left ray
    canvas.drawLine(Offset(cx - 16, cy - 14), Offset(cx - 20, cy - 17), rayPaint);
    // Top right ray
    canvas.drawLine(Offset(cx + 16, cy - 14), Offset(cx + 20, cy - 17), rayPaint);
    // Far left ray
    canvas.drawLine(Offset(cx - 20, cy + 2), Offset(cx - 23, cy + 2), rayPaint);
    // Far right ray
    canvas.drawLine(Offset(cx + 20, cy + 2), Offset(cx + 23, cy + 2), rayPaint);

    // 3. Open Book Base / Cover
    final coverPaint = Paint()..color = const Color(0xFF7A2026); // Burgundy cover
    final coverPath = Path()
      ..moveTo(cx - 16, cy - 8)
      ..lineTo(cx, cy - 5)
      ..lineTo(cx + 16, cy - 8)
      ..lineTo(cx + 16, cy + 10)
      ..lineTo(cx, cy + 12)
      ..lineTo(cx - 16, cy + 10)
      ..close();
    canvas.drawPath(coverPath, coverPaint);

    // 4. Book Pages (Left & Right Leaf)
    final pagePaint = Paint()..color = const Color(0xFFFFF9EE); // Ivory paper
    final linePaint = Paint()
      ..color = const Color(0xFF8B4B4E).withValues(alpha: 0.35)
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    // Left page
    final leftPage = Path()
      ..moveTo(cx - 14.5, cy - 9)
      ..quadraticBezierTo(cx - 8, cy - 11, cx - 1, cy - 7)
      ..lineTo(cx - 1, cy + 9)
      ..quadraticBezierTo(cx - 8, cy + 7, cx - 14.5, cy + 9)
      ..close();
    canvas.drawPath(leftPage, pagePaint);

    // Right page
    final rightPage = Path()
      ..moveTo(cx + 1, cy - 7)
      ..quadraticBezierTo(cx + 8, cy - 11, cx + 14.5, cy - 9)
      ..lineTo(cx + 14.5, cy + 9)
      ..quadraticBezierTo(cx + 8, cy + 7, cx + 1, cy + 9)
      ..close();
    canvas.drawPath(rightPage, pagePaint);

    // Page text lines
    canvas.drawLine(Offset(cx - 12, cy - 4), Offset(cx - 3, cy - 3), linePaint);
    canvas.drawLine(Offset(cx - 12, cy), Offset(cx - 3, cy + 1), linePaint);
    canvas.drawLine(Offset(cx - 12, cy + 4), Offset(cx - 3, cy + 5), linePaint);

    canvas.drawLine(Offset(cx + 3, cy - 3), Offset(cx + 12, cy - 4), linePaint);
    canvas.drawLine(Offset(cx + 3, cy + 1), Offset(cx + 12, cy), linePaint);
    canvas.drawLine(Offset(cx + 3, cy + 5), Offset(cx + 12, cy + 4), linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Phase 2: Angled pencil illustration with soft background & sparkle rays
class _PencilPhaseIcon extends StatelessWidget {
  const _PencilPhaseIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 54.0,
      height: 44.0,
      child: CustomPaint(
        painter: _PencilPainter(),
      ),
    );
  }
}

class _PencilPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    // 1. Soft neutral glowing circle
    final glowPaint = Paint()..color = const Color(0xFFF7EFE4);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: w * 0.90, height: h * 0.90),
      glowPaint,
    );

    // 2. Radiating Sparkle rays
    final rayPaint = Paint()
      ..color = const Color(0xFF8B6B4E).withValues(alpha: 0.60)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(cx - 15, cy - 12), Offset(cx - 18, cy - 15), rayPaint);
    canvas.drawLine(Offset(cx + 14, cy - 13), Offset(cx + 17, cy - 16), rayPaint);
    canvas.drawLine(Offset(cx - 18, cy + 4), Offset(cx - 21, cy + 4), rayPaint);
    canvas.drawLine(Offset(cx + 16, cy + 6), Offset(cx + 19, cy + 6), rayPaint);

    // 3. Draw Angled Pencil
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(-0.55); // ~32 degrees angle

    // Eraser (Pink)
    final eraserPaint = Paint()..color = const Color(0xFFD47C84);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        const Rect.fromLTWH(-5.0, -18.0, 10.0, 5.0),
        topLeft: const Radius.circular(3.0),
        topRight: const Radius.circular(3.0),
      ),
      eraserPaint,
    );

    // Metal collar (Silver/tan)
    final collarPaint = Paint()..color = const Color(0xFFB5A698);
    canvas.drawRect(const Rect.fromLTWH(-5.0, -13.0, 10.0, 3.0), collarPaint);

    // Pencil Body (Yellow/Orange wood)
    final bodyPaint = Paint()..color = const Color(0xFFDCA54B);
    final bodyDark = Paint()..color = const Color(0xFFC78B35);
    canvas.drawRect(const Rect.fromLTWH(-5.0, -10.0, 7.0, 16.0), bodyPaint);
    canvas.drawRect(const Rect.fromLTWH(2.0, -10.0, 3.0, 16.0), bodyDark);

    // Sharpened wood cone
    final woodPaint = Paint()..color = const Color(0xFFF2DEBA);
    final tipPath = Path()
      ..moveTo(-5.0, 6.0)
      ..lineTo(5.0, 6.0)
      ..lineTo(0.0, 15.0)
      ..close();
    canvas.drawPath(tipPath, woodPaint);

    // Graphite tip (Dark grey)
    final leadPaint = Paint()..color = const Color(0xFF3A3026);
    final leadPath = Path()
      ..moveTo(-2.0, 11.5)
      ..lineTo(2.0, 11.5)
      ..lineTo(0.0, 15.0)
      ..close();
    canvas.drawPath(leadPath, leadPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Phase 3: Golden trophy illustration with soft background & sparkle rays
class _TrophyPhaseIcon extends StatelessWidget {
  const _TrophyPhaseIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 54.0,
      height: 44.0,
      child: CustomPaint(
        painter: _TrophyPainter(),
      ),
    );
  }
}

class _TrophyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    // 1. Soft amber glowing circle
    final glowPaint = Paint()..color = const Color(0xFFFAF0DC);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: w * 0.90, height: h * 0.90),
      glowPaint,
    );

    // 2. Radiating Sparkle rays
    final rayPaint = Paint()
      ..color = const Color(0xFFB88C4E).withValues(alpha: 0.65)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(cx - 15, cy - 13), Offset(cx - 18, cy - 16), rayPaint);
    canvas.drawLine(Offset(cx + 15, cy - 13), Offset(cx + 18, cy - 16), rayPaint);
    canvas.drawLine(Offset(cx - 19, cy + 2), Offset(cx - 22, cy + 2), rayPaint);
    canvas.drawLine(Offset(cx + 19, cy + 2), Offset(cx + 22, cy + 2), rayPaint);

    // 3. Trophy Cup (Gold/Amber)
    final goldPaint = Paint()..color = const Color(0xFFDDA638);
    final goldDark = Paint()..color = const Color(0xFFBF8824);
    final goldLight = Paint()..color = const Color(0xFFF7D16B);

    // Base pedestal
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy + 12), width: 16.0, height: 4.0),
        const Radius.circular(1.5),
      ),
      goldDark,
    );
    // Stem
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx, cy + 8), width: 5.0, height: 6.0),
      goldPaint,
    );

    // Main Cup Bowl
    final cupPath = Path()
      ..moveTo(cx - 11, cy - 9)
      ..lineTo(cx + 11, cy - 9)
      ..quadraticBezierTo(cx + 11, cy + 4, cx, cy + 6)
      ..quadraticBezierTo(cx - 11, cy + 4, cx - 11, cy - 9)
      ..close();
    canvas.drawPath(cupPath, goldPaint);

    // Cup rim highlight
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy - 9), width: 22.0, height: 4.0),
      goldLight,
    );

    // Handles on sides
    final handlePaint = Paint()
      ..color = const Color(0xFFBF8824)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Left handle
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx - 11, cy - 3), width: 8.0, height: 10.0),
      1.57,
      3.14,
      false,
      handlePaint,
    );
    // Right handle
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx + 11, cy - 3), width: 8.0, height: 10.0),
      -1.57,
      3.14,
      false,
      handlePaint,
    );

    // Star icon in center of cup
    final starPaint = Paint()..color = const Color(0xFF7A2026); // Burgundy star
    canvas.drawCircle(Offset(cx, cy - 2), 2.5, starPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
