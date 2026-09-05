import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';

/// Clean hero section with concise headline, supporting text, and action buttons.
class WelcomeHeroContent extends StatelessWidget {
  const WelcomeHeroContent({
    super.key,
    this.onPrimaryAction,
    this.onSecondaryAction,
  });

  final VoidCallback? onPrimaryAction;
  final VoidCallback? onSecondaryAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Headline
        Text(
          'Learn. Understand. Connect.',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontSize: 28.0,
                fontWeight: FontWeight.w800,
                color: AppColors.darkBrown,
                letterSpacing: -0.4,
                height: 1.2,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Concise Supporting Text
        Text(
          'Breaking language barriers in classrooms with simple multilingual learning tools.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.mutedBrown,
                fontSize: 15.0,
                height: 1.45,
              ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Action Buttons
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.sm,
          children: [
            // Primary CTA: Start Learning
            ElevatedButton(
              onPressed: onPrimaryAction ?? () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryMaroon,
                foregroundColor: Colors.white,
                minimumSize: const Size(160, 48),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Start Learning',
                    style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),

            // Secondary CTA: Explore Ayo Vaani
            OutlinedButton(
              onPressed: onSecondaryAction ?? () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryMaroon,
                side: const BorderSide(
                  color: AppColors.primaryMaroon,
                  width: 1.5,
                ),
                minimumSize: const Size(160, 48),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              child: const Text(
                'Explore Ayo Vaani',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
