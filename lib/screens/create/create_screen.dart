import 'package:flutter/material.dart';
import '../../app/responsive/responsive.dart';
import '../../app/theme/app_colors.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_header.dart';
import '../../widgets/ayo_screen_background.dart';
import '../../widgets/section_card.dart';

/// Create screen for generating pedagogical assets (Worksheet & Quiz).
class CreateScreen extends StatelessWidget {
  const CreateScreen({super.key});

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
              title: 'Create',
              subtitle: 'Generate customized classroom materials, worksheets, and interactive quizzes',
              badgeText: 'Teacher Studio',
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
                      Icons.auto_awesome_rounded,
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
                          'Classroom Material Generator',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkBrown,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Quickly assemble printable and digital multilingual exercises.',
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
              'Creation Tools',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 14),

            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= Responsive.phoneBreakpoint;

                final items = [
                  SectionCard(
                    title: 'Worksheet',
                    description: 'Generate printable multilingual worksheets with fill-in-the-blanks, matching, and vocabulary.',
                    icon: Icons.description_rounded,
                    tag: 'Print & Digital',
                    onTap: () {},
                  ),
                  SectionCard(
                    title: 'Quiz',
                    description: 'Build interactive comprehension quizzes, listening assessments, and multiple-choice tests.',
                    icon: Icons.quiz_rounded,
                    tag: 'Assessments',
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
