import 'package:flutter/material.dart';
import '../app/theme/app_colors.dart';
import 'ayo_dividers.dart';

/// Legacy wrapper for Warli ornamental divider.
class CulturalPatternBar extends StatelessWidget {
  const CulturalPatternBar({
    super.key,
    this.height = 6.0,
    this.color = AppColors.primaryBurgundy,
    this.accentColor = AppColors.warmAmber,
  });

  final double height;
  final Color color;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return AyoWarliDivider(
      height: height,
      color: color,
      accentColor: accentColor,
      margin: EdgeInsets.zero,
    );
  }
}
