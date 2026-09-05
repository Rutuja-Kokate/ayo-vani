import 'package:flutter/material.dart';
import '../app/responsive/responsive.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_typography.dart';

/// Fixed 4-destination bottom navigation bar for AYOVAANI.
///
/// Strictly reproduces the bottom navigation design shown in:
/// - Screen 03: Home (Dashboard)
/// - Panel 22: Design Elements (Bottom Navigation)
///
/// Destinations:
/// 0: Home (house icon)
/// 1: Learn (open book icon)
/// 2: Translate (translate icon)
/// 3: Profile (person icon)
class AyoBottomNavBar extends StatelessWidget {
  const AyoBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTabletOrLarger(context);

    final items = const [
      _BottomNavItemData(
        icon: Icons.home_rounded,
        label: 'Home',
      ),
      _BottomNavItemData(
        icon: Icons.menu_book_rounded,
        label: 'Learn',
      ),
      _BottomNavItemData(
        icon: Icons.translate_rounded,
        label: 'Translate',
      ),
      _BottomNavItemData(
        icon: Icons.person_rounded,
        label: 'Profile',
      ),
    ];

    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Container(
      height: 64.0 + bottomPadding,
      decoration: const BoxDecoration(
        color: Color(0xFFFAF3E8),
        border: Border(
          top: BorderSide(
            color: Color(0xFFE8DECF),
            width: 1.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 10,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isTablet ? 650.0 : double.infinity,
            ),
            child: SizedBox(
              height: 64.0,
              child: Row(
                children: [
                  for (int i = 0; i < items.length; i++)
                    Expanded(
                      child: _BottomNavItem(
                        data: items[i],
                        isSelected: selectedIndex == i,
                        onTap: () => onItemSelected(i),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItemData {
  const _BottomNavItemData({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.data,
    required this.isSelected,
    required this.onTap,
  });

  final _BottomNavItemData data;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? AppColors.primaryBurgundy // #671D21
        : const Color(0xFF756760); // Muted dark brown/gray

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.primaryBurgundy.withValues(alpha: 0.08),
        highlightColor: AppColors.primaryBurgundy.withValues(alpha: 0.04),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              data.icon,
              size: 24.0,
              color: color,
            ),
            const SizedBox(height: 3.0),
            Text(
              data.label,
              style: TextStyle(
                fontFamily: AppTypography.bodyFontFamily,
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: color,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
