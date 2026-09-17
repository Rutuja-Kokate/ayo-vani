import 'package:flutter/material.dart';
import '../app/responsive/responsive.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_typography.dart';
import '../l10n/app_localizations.dart';
import '../screens/balvatika/balvatika_screen.dart';
import '../screens/first/first_screen.dart';
import '../screens/second/second_screen.dart';
import '../screens/third/third_screen.dart';

/// Reusable Class Selection 2 × 2 Grid for AYOVAANI.
class AyoClassSelectionGrid extends StatelessWidget {
  const AyoClassSelectionGrid({
    super.key,
    this.onNavigateToBalvatika,
    this.onNavigateToFirst,
    this.onNavigateToSecond,
    this.onNavigateToThird,
    this.isTablet,
    this.showSectionTitle = true,
    this.sectionTitle,
  });

  final VoidCallback? onNavigateToBalvatika;
  final VoidCallback? onNavigateToFirst;
  final VoidCallback? onNavigateToSecond;
  final VoidCallback? onNavigateToThird;
  final bool? isTablet;
  final bool showSectionTitle;
  final String? sectionTitle;

  @override
  Widget build(BuildContext context) {
    final tablet = isTablet ?? Responsive.isTabletOrLarger(context);
    final l10n = AppLocalizations.of(context);
    final effectiveTitle = sectionTitle ?? (l10n?.labelClasses ?? 'Classes');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showSectionTitle) ...[
          Text(
            effectiveTitle,
            style: TextStyle(
              fontFamily: AppTypography.headingFontFamily,
              fontSize: tablet ? 20.0 : 18.0,
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary,
              letterSpacing: -0.1,
            ),
          ),
          SizedBox(height: tablet ? 12.0 : 12.0),
        ],

        // 2 × 2 Grid Layout
        Row(
          children: [
            Expanded(
              child: _buildQuickToolCard(
                context: context,
                label: l10n?.classBalvatika ?? 'Balvatika',
                icon: Icons.g_translate_rounded,
                iconColor: const Color(0xFF8B4B3E),
                iconBgColor: const Color(0xFFF7EBE7),
                onTap: () {
                  if (onNavigateToBalvatika != null) {
                    onNavigateToBalvatika!();
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => const BalvatikaScreen(),
                      ),
                    );
                  }
                },
                isTablet: tablet,
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: _buildQuickToolCard(
                context: context,
                label: l10n?.classFirst ?? 'First',
                icon: Icons.description_outlined,
                iconColor: const Color(0xFF5A7854),
                iconBgColor: const Color(0xFFEFF5ED),
                onTap: () {
                  if (onNavigateToFirst != null) {
                    onNavigateToFirst!();
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => const FirstScreen(),
                      ),
                    );
                  }
                },
                isTablet: tablet,
              ),
            ),
          ],
        ),
        SizedBox(height: tablet ? 14.0 : 12.0),
        Row(
          children: [
            Expanded(
              child: _buildQuickToolCard(
                context: context,
                label: l10n?.classSecond ?? 'Second',
                icon: Icons.style_outlined,
                iconColor: const Color(0xFF756E4E),
                iconBgColor: const Color(0xFFF7F6EB),
                onTap: () {
                  if (onNavigateToSecond != null) {
                    onNavigateToSecond!();
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => const SecondScreen(),
                      ),
                    );
                  }
                },
                isTablet: tablet,
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: _buildQuickToolCard(
                context: context,
                label: l10n?.classThird ?? 'Third',
                icon: Icons.sports_esports_rounded,
                iconColor: const Color(0xFF8C3238),
                iconBgColor: const Color(0xFFF8EBEB),
                onTap: () {
                  if (onNavigateToThird != null) {
                    onNavigateToThird!();
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => const ThirdScreen(),
                      ),
                    );
                  }
                },
                isTablet: tablet,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickToolCard({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required VoidCallback onTap,
    bool isTablet = false,
  }) {
    return Material(
      color: const Color(0xFFFDFBF7),
      borderRadius: BorderRadius.circular(16.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        splashColor: iconColor.withValues(alpha: 0.1),
        highlightColor: iconColor.withValues(alpha: 0.05),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 16.0 : 14.0,
            vertical: isTablet ? 18.0 : 14.0,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: const Color(0xFFE8DECF),
              width: 1.0,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x064A3B32),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: isTablet ? 40.0 : 36.0,
                height: isTablet ? 40.0 : 36.0,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: isTablet ? 22.0 : 20.0,
                ),
              ),
              SizedBox(width: isTablet ? 12.0 : 10.0),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: isTablet ? 14.5 : 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
