import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../app/theme/app_typography.dart';

// ---------------------------------------------------------------------------
// Data model
// ---------------------------------------------------------------------------

enum LevelState { active, locked }

class LevelData {
  const LevelData({
    required this.number,
    required this.label,
    required this.subtitle,
    required this.state,
  });

  final int number;
  final String label;
  final String subtitle;
  final LevelState state;
}

const List<LevelData> kDefaultLevels = [
  LevelData(number: 1, label: 'Level 1', subtitle: 'Basics', state: LevelState.active),
  LevelData(number: 2, label: 'Level 2', subtitle: 'Coming Soon', state: LevelState.locked),
  LevelData(number: 3, label: 'Level 3', subtitle: 'Coming Soon', state: LevelState.locked),
  LevelData(number: 4, label: 'Level 4', subtitle: 'Coming Soon', state: LevelState.locked),
  LevelData(number: 5, label: 'Level 5', subtitle: 'Coming Soon', state: LevelState.locked),
  LevelData(number: 6, label: 'Level 6', subtitle: 'Coming Soon', state: LevelState.locked),
  LevelData(number: 7, label: 'Level 7', subtitle: 'Coming Soon', state: LevelState.locked),
  LevelData(number: 8, label: 'Level 8', subtitle: 'Coming Soon', state: LevelState.locked),
  LevelData(number: 9, label: 'Level 9', subtitle: 'Coming Soon', state: LevelState.locked),
  LevelData(number: 10, label: 'Level 10', subtitle: 'Coming Soon', state: LevelState.locked),
];

// ---------------------------------------------------------------------------
// Winding Path View
// ---------------------------------------------------------------------------

class WindingPathView extends StatelessWidget {
  const WindingPathView({
    super.key,
    required this.levels,
    required this.pulseAnimation,
    required this.onLevelTap,
  });

  final List<LevelData> levels;
  final Animation<double> pulseAnimation;
  final ValueChanged<LevelData> onLevelTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        const nodeSize = 82.0;
        const stepY = 142.0;
        const topPadding = 66.0;

        final totalLevels = levels.length;

        final xProportions = [
          0.40, // Level 1
          0.65, // Level 2
          0.34, // Level 3
          0.63, // Level 4
          0.37, // Level 5
          0.65, // Level 6
          0.34, // Level 7
          0.63, // Level 8
          0.36, // Level 9
          0.50, // Level 10
        ];

        final nodePoints = <Offset>[];
        for (var i = 0; i < totalLevels; i++) {
          final x = w * xProportions[i];
          final y = topPadding + (totalLevels - 1 - i) * stepY + (nodeSize / 2);
          nodePoints.add(Offset(x, y));
        }

        final totalHeight = nodePoints.first.dy + 80.0;

        return SizedBox(
          width: w,
          height: totalHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 1. Winding Road/Trail Custom Painter
              CustomPaint(
                size: Size(w, totalHeight),
                painter: CurvedRoadPainter(nodePoints: nodePoints),
              ),

              // 2. Decorative Illustrations in Path across Levels 1-10
              _buildDecorations(w, totalHeight, nodePoints),

              // 3. Level Nodes & Wood Plaques
              for (var i = 0; i < totalLevels; i++)
                _buildNodePositioned(
                  levels[i],
                  nodePoints[i],
                  nodeSize,
                  w,
                  i,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDecorations(double w, double totalHeight, List<Offset> points) {
    final p1 = points[0];
    final p2 = points[1];
    final p3 = points[2];
    final p4 = points[3];
    final p5 = points[4];
    final p6 = points[5];
    final p7 = points[6];
    final p8 = points[7];
    final p9 = points[8];
    final p10 = points[9];

    return Stack(
      children: [
        // LEVEL 1: Natural girl.png on right, grass1.png and grass2.png on left/bottom
        Positioned(
          right: math.max(12.0, w * 0.06),
          top: p1.dy - 18,
          child: PngGirl(width: math.min(84.0, w * 0.22)),
        ),
        Positioned(
          left: 14.0,
          top: p1.dy + 18,
          child: const PngGrass1(width: 38.0),
        ),
        Positioned(
          left: 48.0,
          top: p1.dy + 36,
          child: const PngGrass2(width: 42.0),
        ),

        // LEVEL 2: house.png on left, grass2.png and grass1.png
        Positioned(
          left: math.max(12.0, w * 0.05),
          top: p2.dy - 42,
          child: PngHouse(width: math.min(86.0, w * 0.23)),
        ),
        Positioned(
          left: math.max(14.0, w * 0.05) + 64,
          top: p2.dy + 12,
          child: const PngGrass2(width: 40.0),
        ),
        Positioned(
          right: 18.0,
          top: p2.dy + 38,
          child: const PngGrass1(width: 34.0),
        ),

        // LEVEL 3: grass3.png on right, grass1.png on left
        Positioned(
          right: math.max(18.0, w * 0.08),
          top: p3.dy - 22,
          child: const PngGrass3(width: 48.0),
        ),
        Positioned(
          left: 16.0,
          top: p3.dy + 32,
          child: const PngGrass1(width: 34.0, isFlipped: true),
        ),

        // LEVEL 4: house.png on left open area, grass3.png on right
        Positioned(
          left: math.max(14.0, w * 0.06),
          top: p4.dy - 46,
          child: PngHouse(width: math.min(88.0, w * 0.24)),
        ),
        Positioned(
          left: math.max(14.0, w * 0.06) + 68,
          top: p4.dy + 16,
          child: const PngGrass2(width: 38.0),
        ),
        Positioned(
          right: 14.0,
          top: p4.dy + 36,
          child: const PngGrass3(width: 44.0),
        ),

        // LEVEL 5: girl.png on right (flipped), grass2.png & grass3.png on left
        Positioned(
          right: math.max(14.0, w * 0.07),
          top: p5.dy - 24,
          child: PngGirl(
            width: math.min(80.0, w * 0.20),
            isFlipped: true,
          ),
        ),
        Positioned(
          right: math.max(14.0, w * 0.07) + 62,
          top: p5.dy + 20,
          child: const PngGrass2(width: 38.0),
        ),
        Positioned(
          left: 14.0,
          top: p5.dy + 30,
          child: const PngGrass3(width: 42.0),
        ),

        // LEVEL 6: house.png on left (flipped), grass1.png & grass2.png
        Positioned(
          left: math.max(12.0, w * 0.05),
          top: p6.dy - 44,
          child: PngHouse(
            width: math.min(86.0, w * 0.23),
            isFlipped: true,
          ),
        ),
        Positioned(
          left: math.max(12.0, w * 0.05) + 68,
          top: p6.dy + 14,
          child: const PngGrass1(width: 36.0),
        ),
        Positioned(
          right: 18.0,
          top: p6.dy + 36,
          child: const PngGrass2(width: 40.0),
        ),

        // LEVEL 7: grass3.png & grass1.png on right, grass2.png on left
        Positioned(
          right: math.max(18.0, w * 0.08),
          top: p7.dy - 16,
          child: const PngGrass3(width: 48.0),
        ),
        Positioned(
          right: math.max(16.0, w * 0.07) + 40,
          top: p7.dy + 22,
          child: const PngGrass1(width: 34.0),
        ),
        Positioned(
          left: 16.0,
          top: p7.dy + 32,
          child: const PngGrass2(width: 36.0, isFlipped: true),
        ),

        // LEVEL 8: girl.png on left open space, grass3.png & grass1.png
        Positioned(
          left: math.max(14.0, w * 0.06),
          top: p8.dy - 22,
          child: PngGirl(width: math.min(80.0, w * 0.20)),
        ),
        Positioned(
          left: math.max(14.0, w * 0.06) + 66,
          top: p8.dy + 18,
          child: const PngGrass3(width: 44.0),
        ),
        Positioned(
          right: 16.0,
          top: p8.dy + 38,
          child: const PngGrass1(width: 34.0),
        ),

        // LEVEL 9: house.png on right, grass2.png & grass3.png on left
        Positioned(
          right: math.max(12.0, w * 0.05),
          top: p9.dy - 44,
          child: PngHouse(width: math.min(88.0, w * 0.23)),
        ),
        Positioned(
          right: math.max(12.0, w * 0.05) + 66,
          top: p9.dy + 14,
          child: const PngGrass2(width: 38.0),
        ),
        Positioned(
          left: 14.0,
          top: p9.dy + 30,
          child: const PngGrass3(width: 42.0, isFlipped: true),
        ),

        // LEVEL 10: girl.png on top-left (flipped) with grass1.png, grass3.png on top-right
        Positioned(
          left: math.max(14.0, w * 0.06),
          top: p10.dy - 34,
          child: PngGirl(
            width: math.min(78.0, w * 0.20),
            isFlipped: true,
          ),
        ),
        Positioned(
          left: math.max(14.0, w * 0.06) + 62,
          top: p10.dy + 10,
          child: const PngGrass1(width: 36.0),
        ),
        Positioned(
          right: math.max(14.0, w * 0.06),
          top: p10.dy - 22,
          child: const PngGrass3(width: 48.0),
        ),
        Positioned(
          right: math.max(16.0, w * 0.07),
          top: p10.dy + 24,
          child: const PngGrass2(width: 38.0),
        ),
      ],
    );
  }

  Widget _buildNodePositioned(
    LevelData level,
    Offset point,
    double nodeSize,
    double screenW,
    int index,
  ) {
    final isActive = level.state == LevelState.active;
    final isPlaqueOnRight = (index % 2 == 1);

    return Positioned(
      left: point.dx - (nodeSize / 2) - (isPlaqueOnRight ? 0 : 80),
      top: point.dy - (nodeSize / 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (!isPlaqueOnRight) ...[
            WoodPlaque(label: level.label, subtitle: level.subtitle),
            const SizedBox(width: 8),
          ],
          LevelNode(
            level: level,
            nodeSize: nodeSize,
            pulseAnimation: isActive ? pulseAnimation : null,
            onTap: () => onLevelTap(level),
          ),
          if (isPlaqueOnRight) ...[
            const SizedBox(width: 8),
            WoodPlaque(label: level.label, subtitle: level.subtitle),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Circular Layered Level Node
// ---------------------------------------------------------------------------

class LevelNode extends StatelessWidget {
  const LevelNode({
    super.key,
    required this.level,
    required this.nodeSize,
    required this.onTap,
    this.pulseAnimation,
  });

  final LevelData level;
  final double nodeSize;
  final VoidCallback onTap;
  final Animation<double>? pulseAnimation;

  @override
  Widget build(BuildContext context) {
    final isActive = level.state == LevelState.active;

    Widget nodeContent = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Platform 3D Disc
        Container(
          width: nodeSize,
          height: nodeSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFE5D5BF), // top highlight
                Color(0xFFC7B39B), // mid surface
                Color(0xFFA69076), // bottom shaded pedestal
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6B5845).withValues(alpha: 0.35),
                blurRadius: 8.0,
                offset: const Offset(0, 5),
              ),
              if (isActive)
                BoxShadow(
                  color: const Color(0xFFE5B560).withValues(alpha: 0.40),
                  blurRadius: 14.0,
                  spreadRadius: 2.0,
                ),
            ],
            border: Border.all(
              color: const Color(0xFFFAF2E6),
              width: 3.0,
            ),
          ),
          child: Center(
            child: Container(
              width: nodeSize * 0.68,
              height: nodeSize * 0.68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isActive
                    ? const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF8B252C),
                          Color(0xFF671D21),
                          Color(0xFF4C1215),
                        ],
                      )
                    : const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF9E8D7F),
                          Color(0xFF7E6E61),
                          Color(0xFF65564A),
                        ],
                      ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 4.0,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: isActive ? const Color(0xFFE58F94) : const Color(0xFFB5A698),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  '${level.number}',
                  style: TextStyle(
                    fontFamily: AppTypography.headingFontFamily,
                    fontSize: nodeSize * 0.34,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Lock icon below node (for locked levels) OR 3 Stars for Level 1
        Transform.translate(
          offset: const Offset(0, -10),
          child: isActive
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    3,
                    (i) => const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 1.0),
                      child: Icon(
                        Icons.star_rounded,
                        size: 16.0,
                        color: Color(0xFFEAA628),
                      ),
                    ),
                  ),
                )
              : Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7EFE4),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFC7B39B),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 3.0,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.lock_rounded,
                      size: 14.0,
                      color: Color(0xFF6B5845),
                    ),
                  ),
                ),
        ),
      ],
    );

    if (pulseAnimation != null) {
      nodeContent = ScaleTransition(
        scale: pulseAnimation!,
        child: nodeContent,
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: nodeContent,
    );
  }
}

// ---------------------------------------------------------------------------
// Wooden Plaque Label
// ---------------------------------------------------------------------------

class WoodPlaque extends StatelessWidget {
  const WoodPlaque({
    super.key,
    required this.label,
    required this.subtitle,
  });

  final String label;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF8B5A3C),
                Color(0xFF6F432A),
              ],
            ),
            borderRadius: BorderRadius.circular(6.0),
            border: Border.all(
              color: const Color(0xFFA57350),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3F2516).withValues(alpha: 0.35),
                blurRadius: 3.0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11.0,
              fontWeight: FontWeight.w700,
              color: Color(0xFFFFF3E3),
              letterSpacing: 0.2,
            ),
          ),
        ),
        const SizedBox(height: 3.0),
        Text(
          subtitle,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 10.5,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6F5946),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Curved Road Painter
// ---------------------------------------------------------------------------

class CurvedRoadPainter extends CustomPainter {
  const CurvedRoadPainter({required this.nodePoints});

  final List<Offset> nodePoints;

  @override
  void paint(Canvas canvas, Size size) {
    if (nodePoints.length < 2) return;

    final roadPaint = Paint()
      ..color = const Color(0xFFE6D6BC).withValues(alpha: 0.50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 36.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final dashPaint = Paint()
      ..color = const Color(0xFFA85B4F).withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(nodePoints.first.dx, nodePoints.first.dy);

    for (var i = 0; i < nodePoints.length - 1; i++) {
      final current = nodePoints[i];
      final next = nodePoints[i + 1];

      final midY = (current.dy + next.dy) / 2;
      path.cubicTo(
        current.dx,
        midY,
        next.dx,
        midY,
        next.dx,
        next.dy,
      );
    }

    canvas.drawPath(path, roadPaint);
    _drawDashedPath(canvas, path, dashPaint, 8.0, 7.0);
  }

  void _drawDashedPath(
    Canvas canvas,
    Path source,
    Paint paint,
    double dashWidth,
    double dashSpace,
  ) {
    for (final metric in source.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final len = math.min(dashWidth, metric.length - distance);
        final extract = metric.extractPath(distance, distance + len);
        canvas.drawPath(extract, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CurvedRoadPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// Natural PNG Illustrations from assets/images/
// ---------------------------------------------------------------------------

class PngGirl extends StatelessWidget {
  const PngGirl({
    super.key,
    this.width = 76.0,
    this.isFlipped = false,
  });

  final double width;
  final bool isFlipped;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      'assets/images/girl.png',
      width: width,
      fit: BoxFit.contain,
    );
    return isFlipped ? Transform.flip(flipX: true, child: image) : image;
  }
}

class PngHouse extends StatelessWidget {
  const PngHouse({
    super.key,
    this.width = 88.0,
    this.isFlipped = false,
  });

  final double width;
  final bool isFlipped;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      'assets/images/house.png',
      width: width,
      fit: BoxFit.contain,
    );
    return isFlipped ? Transform.flip(flipX: true, child: image) : image;
  }
}

class PngGrass1 extends StatelessWidget {
  const PngGrass1({
    super.key,
    this.width = 38.0,
    this.isFlipped = false,
  });

  final double width;
  final bool isFlipped;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      'assets/images/grass1.png',
      width: width,
      fit: BoxFit.contain,
    );
    return isFlipped ? Transform.flip(flipX: true, child: image) : image;
  }
}

class PngGrass2 extends StatelessWidget {
  const PngGrass2({
    super.key,
    this.width = 42.0,
    this.isFlipped = false,
  });

  final double width;
  final bool isFlipped;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      'assets/images/grass2.png',
      width: width,
      fit: BoxFit.contain,
    );
    return isFlipped ? Transform.flip(flipX: true, child: image) : image;
  }
}

class PngGrass3 extends StatelessWidget {
  const PngGrass3({
    super.key,
    this.width = 46.0,
    this.isFlipped = false,
  });

  final double width;
  final bool isFlipped;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      'assets/images/grass3.png',
      width: width,
      fit: BoxFit.contain,
    );
    return isFlipped ? Transform.flip(flipX: true, child: image) : image;
  }
}

// ---------------------------------------------------------------------------
// Corner decoration
// ---------------------------------------------------------------------------

class LevelCornerDecoration extends StatelessWidget {
  const LevelCornerDecoration({super.key, required this.isRight, required this.size});
  final bool isRight;
  final double size;

  @override
  Widget build(BuildContext context) {
    final img = Image.asset(
      'assets/images/corner-design.png',
      width: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => Image.asset(
        'assets/images/corner-desing.png',
        width: size,
        fit: BoxFit.contain,
      ),
    );
    return isRight ? Transform.flip(flipX: true, child: img) : img;
  }
}

// ---------------------------------------------------------------------------
// Leaf divider painter
// ---------------------------------------------------------------------------

class LevelLeafDividerPainter extends CustomPainter {
  const LevelLeafDividerPainter({required this.color});
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
    final cx = size.width / 2;
    final cy = size.height / 2;
    canvas.drawLine(Offset(0, cy), Offset(cx - 13, cy), linePaint);
    canvas.drawLine(Offset(cx + 13, cy), Offset(size.width, cy), linePaint);
    canvas.drawPath(
      Path()
        ..moveTo(cx, cy + 3)
        ..quadraticBezierTo(cx - 3.2, cy - 2, cx, cy - 6.5)
        ..quadraticBezierTo(cx + 3.2, cy - 2, cx, cy + 3)
        ..close(),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(cx - 1.2, cy + 3)
        ..quadraticBezierTo(cx - 7.5, cy + 2.5, cx - 8.5, cy - 1.5)
        ..quadraticBezierTo(cx - 3.5, cy - 2.5, cx - 1.2, cy + 3)
        ..close(),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(cx + 1.2, cy + 3)
        ..quadraticBezierTo(cx + 7.5, cy + 2.5, cx + 8.5, cy - 1.5)
        ..quadraticBezierTo(cx + 3.5, cy - 2.5, cx + 1.2, cy + 3)
        ..close(),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant LevelLeafDividerPainter oldDelegate) => oldDelegate.color != color;
}
