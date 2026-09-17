import 'package:flutter/material.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_dimens.dart';
import '../app/theme/app_typography.dart';
import '../l10n/app_localizations.dart';

/// Reusable Dropdown / Select Field with warm parchment styling.
class AyoDropdownField<T> extends StatelessWidget {
  const AyoDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
    this.prefixIcon,
    this.helperText,
  });

  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? hint;
  final IconData? prefixIcon;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: AppTypography.bodyFontFamily,
            fontSize: 13.0,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.borderWarm, width: AppBorders.thin),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              items: items,
              onChanged: onChanged,
              hint: hint != null
                  ? Text(
                      hint!,
                      style: TextStyle(
                        fontFamily: AppTypography.bodyFontFamily,
                        fontSize: 14.0,
                        color: AppColors.textMuted,
                      ),
                    )
                  : null,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.primaryBurgundy,
              ),
              isExpanded: true,
              dropdownColor: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              style: TextStyle(
                fontFamily: AppTypography.bodyFontFamily,
                fontSize: 14.0,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(
            helperText!,
            style: TextStyle(
              fontFamily: AppTypography.bodyFontFamily,
              fontSize: 11.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

/// Specialized Language Pair Selector for classroom translation & learning.
class AyoLanguageSelector extends StatelessWidget {
  const AyoLanguageSelector({
    super.key,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.onSourceTap,
    required this.onTargetTap,
    required this.onSwapTap,
  });

  final String sourceLanguage;
  final String targetLanguage;
  final VoidCallback onSourceTap;
  final VoidCallback onTargetTap;
  final VoidCallback onSwapTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderWarm, width: AppBorders.thin),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Row(
        children: [
          // Source Language Button
          Expanded(
            child: _buildLanguageTile(
              label: l10n?.labelInstructionLanguage ?? 'Instruction Language',
              language: sourceLanguage,
              onTap: onSourceTap,
            ),
          ),

          // Swap Action Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onSwapTap,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBurgundy,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBurgundy.withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.swap_horiz_rounded,
                    color: AppColors.cardSurface,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),

          // Target / Mother Tongue Language Button
          Expanded(
            child: _buildLanguageTile(
              label: l10n?.labelMotherTongue ?? 'Mother Tongue',
              language: targetLanguage,
              onTap: onTargetTap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageTile({
    required String label,
    required String language,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.borderWarm, width: 0.8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppTypography.bodyFontFamily,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      language,
                      style: TextStyle(
                        fontFamily: AppTypography.bodyFontFamily,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: AppColors.primaryBurgundy,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Clean Tab Bar for switching module sub-sections.
class AyoTabBar extends StatelessWidget {
  const AyoTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.borderWarm, width: 0.8),
      ),
      child: Row(
        children: [
          for (int i = 0; i < tabs.length; i++) ...[
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onTabSelected(i),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: selectedIndex == i
                          ? AppColors.primaryBurgundy
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      boxShadow: selectedIndex == i ? AppShadows.cardShadow : null,
                    ),
                    child: Center(
                      child: Text(
                        tabs[i],
                        style: TextStyle(
                          fontFamily: AppTypography.bodyFontFamily,
                          fontSize: 12.5,
                          fontWeight: selectedIndex == i
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: selectedIndex == i
                              ? AppColors.cardSurface
                              : AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
