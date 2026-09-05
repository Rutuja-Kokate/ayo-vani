import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';

/// Clean top header with Ayo Vaani brand mark, title, and subtitle.
class HomeTopBar extends StatelessWidget {
  const HomeTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Brand Mark
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryMaroon,
            borderRadius: BorderRadius.circular(AppRadius.sm + 2),
            border: Border.all(
              color: AppColors.goldenAccent.withValues(alpha: 0.4),
              width: 1.0,
            ),
          ),
          child: const Center(
            child: Text(
              'AV',
              style: TextStyle(
                color: AppColors.primaryCream,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),

        // Brand Name & Subtitle
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Ayo Vaani',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkBrown,
                    height: 1.15,
                  ),
            ),
            const SizedBox(height: 1),
            Text(
              'Multilingual Education',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.mutedBrown,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
