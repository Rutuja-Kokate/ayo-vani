import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../widgets/cultural_pattern_bar.dart';

/// Clean bottom footer with cultural pattern accent and educational trust tagline.
class HomeFooterBar extends StatelessWidget {
  const HomeFooterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CulturalPatternBar(height: 5),
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.school_rounded,
              size: 14,
              color: AppColors.mutedBrown,
            ),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                'Ayo Vaani • Designed for Multilingual Educators',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.mutedBrown,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
