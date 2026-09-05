import 'package:flutter/material.dart';
import '../../app/responsive/responsive.dart';
import '../../app/theme/app_colors.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_header.dart';
import '../../widgets/ayo_screen_background.dart';
import '../../widgets/section_card.dart';

/// Continuity screen focusing on Offline Self-Learning pathways.
class ContinuityScreen extends StatelessWidget {
  const ContinuityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AyoScreenBackground(
      child: SingleChildScrollView(
      padding: Responsive.screenPadding(context),
      child: ResponsiveContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppHeader(
              title: 'Continuity',
              subtitle: 'Ensure uninterrupted learning experiences without internet dependency',
              badgeText: 'Offline Ready',
            ),

            AppCard(
              backgroundColor: AppColors.warmBeige,
              borderColor: AppColors.borderBeige,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryMaroon,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.all_inclusive_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Uninterrupted Offline Learning',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkBrown,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Students can continue learning journeys at home or offline without friction.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.mutedBrown,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Continuity Programs',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 14),

            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= Responsive.phoneBreakpoint;

                final items = [
                  SectionCard(
                    title: 'Offline Self-Learning',
                    description: 'Pre-packaged offline learning modules, guided exercises, and practice challenges.',
                    icon: Icons.offline_bolt_rounded,
                    tag: 'Core Program',
                    onTap: () {},
                  ),
                ];

                if (!isWide) {
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (_, index) => items[index],
                  );
                }

                return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 2.2,
                  children: items,
                );
              },
            ),
          ],
        ),
      ),
    ),
    );
  }
}
