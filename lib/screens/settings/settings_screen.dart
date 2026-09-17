import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/responsive/responsive.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_typography.dart';
import '../../providers/locale_provider.dart';
import '../../widgets/ayo_badges.dart';
import '../../widgets/ayo_buttons.dart';
import '../../widgets/ayo_cards.dart';
import '../../widgets/ayo_dividers.dart';
import '../../widgets/ayo_inputs.dart';
import '../../widgets/ayo_screen_background.dart';

/// Teacher Profile & Classroom Settings destination / modal.
/// Accessible directly from the top-right header action.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  /// Opens the settings screen as a clean, responsive modal bottom sheet.
  static void show(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SettingsScreen(),
    );
  }

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedMedium = 'Hindi';
  String _selectedMotherTongue = 'Gondi';
  bool _requireHumanVerification = true;
  bool _offlineAutoSync = true;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.88,
      child: AyoScreenBackground(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
        child: Column(
          children: [
            // Drag Handle
            const SizedBox(height: AppSpacing.md),
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderWarm,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Teacher Profile & Settings',
                        style: TextStyle(
                          fontFamily: AppTypography.headingFontFamily,
                          fontSize: 20.0,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Classroom parameters & offline management',
                        style: TextStyle(
                          fontFamily: AppTypography.bodyFontFamily,
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
            const AyoWarliDivider(height: 5),

            // Scrollable Settings Content
            Expanded(
              child: SingleChildScrollView(
                padding: Responsive.screenPadding(context),
                child: ResponsiveContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Teacher Profile Card
                      AyoCard(
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: AppColors.primaryBurgundy,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.warmGold,
                                  width: 1.2,
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.person_rounded,
                                  color: AppColors.cardSurface,
                                  size: 28,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.lg),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Priya Sharma',
                                    style: TextStyle(
                                      fontFamily: AppTypography.headingFontFamily,
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Primary Educator • Grade 4 Section A',
                                    style: TextStyle(
                                      fontFamily: AppTypography.bodyFontFamily,
                                      fontSize: 12.5,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  const AyoBadge(
                                    label: 'Teacher-Only Device Active',
                                    variant: AyoBadgeVariant.verified,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // 2. App Interface Language Switcher
                      const AyoSectionHeader(
                        title: 'App Interface Language',
                        subtitle: 'Choose your preferred language for the app interface',
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Consumer<LocaleProvider>(
                        builder: (context, localeProvider, child) {
                          final currentLanguageCode = localeProvider.locale.languageCode;
                          return AyoCard(
                            child: Row(
                              children: [
                                Expanded(
                                  child: _LanguageOptionTile(
                                    label: 'English',
                                    subLabel: 'Default',
                                    isSelected: currentLanguageCode == 'en',
                                    onTap: () {
                                      context.read<LocaleProvider>().setLocale(const Locale('en'));
                                    },
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: _LanguageOptionTile(
                                    label: 'हिन्दी',
                                    subLabel: 'Hindi',
                                    isSelected: currentLanguageCode == 'hi',
                                    onTap: () {
                                      context.read<LocaleProvider>().setLocale(const Locale('hi'));
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // 3. Classroom Language Defaults
                      const AyoSectionHeader(
                        title: 'Classroom Languages',
                        subtitle: 'Configure default mother-tongue and medium of instruction',
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AyoCard(
                        child: Column(
                          children: [
                            AyoDropdownField<String>(
                              label: 'Medium of Instruction',
                              value: _selectedMedium,
                              items: const [
                                DropdownMenuItem(value: 'Hindi', child: Text('Hindi (हिन्दी)')),
                                DropdownMenuItem(value: 'Marathi', child: Text('Marathi (मराठी)')),
                                DropdownMenuItem(value: 'English', child: Text('English')),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedMedium = val);
                              },
                            ),
                            const SizedBox(height: AppSpacing.md),
                            AyoDropdownField<String>(
                              label: 'Mother Tongue / Regional Dialect',
                              value: _selectedMotherTongue,
                              items: const [
                                DropdownMenuItem(value: 'Gondi', child: Text('Gondi (कोयतूर)')),
                                DropdownMenuItem(value: 'Santhali', child: Text('Santhali (ᱥᱟᱱᱛᱟᱲᱤ)')),
                                DropdownMenuItem(value: 'Bhil', child: Text('Bhili (भीली)')),
                                DropdownMenuItem(value: 'Halbi', child: Text('Halbi (हल्बी)')),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedMotherTongue = val);
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // 4. Offline Storage & Synchronization
                      const AyoSectionHeader(
                        title: 'Offline Content & Storage',
                        subtitle: 'Download lessons, audio pronunciations, and worksheets for zero-internet use',
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AyoCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(AppSpacing.sm),
                                  decoration: BoxDecoration(
                                    color: AppColors.oliveGreenLight,
                                    borderRadius: BorderRadius.circular(AppRadius.sm),
                                  ),
                                  child: const Icon(
                                    Icons.download_for_offline_rounded,
                                    color: AppColors.oliveGreen,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Offline Pack: Grade 4 Multilingual',
                                        style: TextStyle(
                                          fontFamily: AppTypography.bodyFontFamily,
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        '1.4 GB / 1.4 GB downloaded (100% complete)',
                                        style: TextStyle(
                                          fontFamily: AppTypography.bodyFontFamily,
                                          fontSize: 12.0,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const AyoBadge(
                                  label: 'Ready',
                                  variant: AyoBadgeVariant.offline,
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                'Auto-sync when Wi-Fi is available',
                                style: TextStyle(fontFamily: AppTypography.bodyFontFamily),
                              ),
                              subtitle: Text(
                                'Background synchronization of teacher logs',
                                style: TextStyle(fontFamily: AppTypography.bodyFontFamily),
                              ),
                              value: _offlineAutoSync,
                              activeThumbColor: AppColors.primaryBurgundy,
                              onChanged: (val) => setState(() => _offlineAutoSync = val),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // 5. Human-In-The-Loop AI Preferences
                      const AyoSectionHeader(
                        title: 'Human-in-the-Loop AI Translation',
                        subtitle: 'Teacher verification before classroom broadcast',
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AyoCard(
                        child: SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            'Require Teacher Approval for New Words',
                            style: TextStyle(fontFamily: AppTypography.bodyFontFamily),
                          ),
                          subtitle: Text(
                            'Flag AI-translated phrases for teacher review before adding to student flashcards',
                            style: TextStyle(fontFamily: AppTypography.bodyFontFamily),
                          ),
                          value: _requireHumanVerification,
                          activeThumbColor: AppColors.primaryBurgundy,
                          onChanged: (val) => setState(() => _requireHumanVerification = val),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xxl),

                      // Save Button
                      AyoPrimaryButton(
                        label: 'Save Classroom Settings',
                        isFullWidth: true,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageOptionTile extends StatelessWidget {
  const _LanguageOptionTile({
    required this.label,
    required this.subLabel,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String subLabel;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.primaryBurgundy.withValues(alpha: 0.08) : AppColors.cardSurface,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: isSelected ? AppColors.primaryBurgundy : AppColors.borderWarm,
              width: isSelected ? 2.0 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                color: isSelected ? AppColors.primaryBurgundy : AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: AppTypography.headingFontFamily,
                        fontSize: 15.0,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? AppColors.primaryBurgundy : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      subLabel,
                      style: TextStyle(
                        fontFamily: AppTypography.bodyFontFamily,
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
