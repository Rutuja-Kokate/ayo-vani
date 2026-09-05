import 'package:flutter/material.dart';
import '../../../app/responsive/responsive.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../widgets/app_card.dart';

/// Section showcasing the 3 core features of Ayo Vaani in a minimal, focused layout.
class PurposePillarsSection extends StatelessWidget {
  const PurposePillarsSection({
    super.key,
    this.onFeatureTap,
  });

  final ValueChanged<int>? onFeatureTap;

  @override
  Widget build(BuildContext context) {
    const features = [
      _FeatureData(
        icon: Icons.translate_rounded,
        title: 'Live Translation',
        description: 'Understand conversations across languages.',
      ),
      _FeatureData(
        icon: Icons.menu_book_rounded,
        title: 'Interactive Learning',
        description: 'Learn through multilingual content.',
      ),
      _FeatureData(
        icon: Icons.school_rounded,
        title: 'Teacher Support',
        description: 'Simple tools for inclusive classrooms.',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Text(
          'Why Ayo Vaani?',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 20.0,
                fontWeight: FontWeight.w800,
                color: AppColors.darkBrown,
              ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          'Simple tools that make multilingual classrooms more inclusive.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.mutedBrown,
                fontSize: 14.0,
              ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Responsive Cards (1 column on mobile, 3 columns on tablet)
        LayoutBuilder(
          builder: (context, constraints) {
            final isTabletOrWide =
                constraints.maxWidth >= Responsive.phoneBreakpoint;

            if (!isTabletOrWide) {
              // Mobile Phone Layout
              return Column(
                children: [
                  for (int i = 0; i < features.length; i++) ...[
                    _buildFeatureCard(
                      context,
                      features[i],
                      () => onFeatureTap?.call(i),
                    ),
                    if (i < features.length - 1)
                      const SizedBox(height: AppSpacing.sm + 2),
                  ],
                ],
              );
            }

            // Tablet / Wide Layout
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < features.length; i++) ...[
                  Expanded(
                    child: _buildFeatureCard(
                      context,
                      features[i],
                      () => onFeatureTap?.call(i),
                    ),
                  ),
                  if (i < features.length - 1)
                    const SizedBox(width: AppSpacing.md),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    _FeatureData data,
    VoidCallback onTap,
  ) {
    return AppCard(
      onTap: onTap,
      backgroundColor: AppColors.ivoryWhite,
      borderColor: AppColors.borderBeige,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md + 2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.warmBeige,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              data.icon,
              color: AppColors.primaryMaroon,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkBrown,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.mutedBrown,
                        fontSize: 13.0,
                        height: 1.35,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureData {
  const _FeatureData({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}
