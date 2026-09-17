import 'package:flutter/material.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_typography.dart';
import '../l10n/app_localizations.dart';
import '../models/subject_data.dart';

/// Reusable subject card widget for class subject selection screens.
class AyoSubjectCard extends StatelessWidget {
  const AyoSubjectCard({
    super.key,
    required this.subject,
    this.onTap,
    this.isTablet = false,
  });

  final Subject subject;
  final VoidCallback? onTap;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    final isAvailable = subject.isAvailable;

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: isAvailable
              ? const Color(0xFFFDFBF7)
              : const Color(0xFFF8F5F0),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: isAvailable
                ? const Color(0xFFE2D6C5)
                : const Color(0xFFEAE4D9),
            width: isAvailable ? 1.4 : 1.0,
          ),
          boxShadow: isAvailable
              ? const [
                  BoxShadow(
                    color: Color(0x0A4A3B32),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ]
              : const [],
        ),
        child: InkWell(
          onTap: isAvailable ? onTap : null,
          borderRadius: BorderRadius.circular(16.0),
          splashColor: isAvailable
              ? AppColors.primaryBurgundy.withValues(alpha: 0.08)
              : Colors.transparent,
          highlightColor: isAvailable
              ? AppColors.primaryBurgundy.withValues(alpha: 0.04)
              : Colors.transparent,
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 18.0 : 15.0),
            child: Row(
              children: [
                // Subject Icon Container
                Container(
                  width: isTablet ? 56.0 : 48.0,
                  height: isTablet ? 56.0 : 48.0,
                  decoration: BoxDecoration(
                    color: isAvailable
                        ? const Color(0xFFF7EBE7)
                        : const Color(0xFFECE7DE),
                    borderRadius: BorderRadius.circular(14.0),
                    border: Border.all(
                      color: isAvailable
                          ? const Color(0xFFE8D4C8)
                          : const Color(0xFFDFD8CC),
                      width: 1.0,
                    ),
                  ),
                  child: Icon(
                    subject.icon,
                    size: isTablet ? 26.0 : 22.0,
                    color: isAvailable
                        ? AppColors.primaryBurgundy
                        : const Color(0xFF9E8F82),
                  ),
                ),
                SizedBox(width: isTablet ? 16.0 : 13.0),

                // Subject Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Subject Title
                      Text(
                        subject.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTypography.headingFontFamily,
                          fontSize: isTablet ? 17.5 : 16.0,
                          fontWeight: FontWeight.w600,
                          color: isAvailable
                              ? AppColors.primaryBurgundy
                              : const Color(0xFF7D6F63),
                          letterSpacing: -0.1,
                        ),
                      ),
                      if (subject.hindiName != null) ...[
                        const SizedBox(height: 1.0),
                        Text(
                          subject.hindiName!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: AppTypography.bodyFontFamily,
                            fontSize: isTablet ? 12.0 : 11.5,
                            fontWeight: FontWeight.w500,
                            color: isAvailable
                                ? const Color(0xFF8B4B3E)
                                : const Color(0xFFA09387),
                          ),
                        ),
                      ],
                      const SizedBox(height: 3.0),

                      // Supporting Description
                      if (subject.description != null)
                        Text(
                          subject.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: AppTypography.bodyFontFamily,
                            fontSize: isTablet ? 12.5 : 12.0,
                            fontWeight: FontWeight.w400,
                            color: isAvailable
                                ? AppColors.textSecondary
                                : const Color(0xFFA89D92),
                            height: 1.3,
                          ),
                        ),
                      const SizedBox(height: 7.0),

                      // Status Badge: "Available" or "Coming Soon"
                      _buildStatusBadge(context, isAvailable),
                    ],
                  ),
                ),
                const SizedBox(width: 8.0),

                if (isAvailable)
                  Container(
                    width: 32.0,
                    height: 32.0,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF6ECE0),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      size: 22.0,
                      color: AppColors.primaryBurgundy,
                    ),
                  )
                else
                  const Padding(
                    padding: EdgeInsets.only(right: 4.0),
                    child: Icon(
                      Icons.lock_outline_rounded,
                      size: 18.0,
                      color: Color(0xFFB5A99D),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, bool isAvailable) {
    final l10n = AppLocalizations.of(context);

    if (isAvailable) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 9.0, vertical: 3.0),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F0E4),
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: const Color(0xFFCCE0C8),
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_rounded,
              size: 12.0,
              color: Color(0xFF385E32),
            ),
            const SizedBox(width: 4.0),
            Text(
              l10n?.labelAvailable ?? 'Available',
              style: TextStyle(
                fontFamily: AppTypography.bodyFontFamily,
                fontSize: 11.0,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF385E32),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.5),
      decoration: BoxDecoration(
        color: const Color(0xFFECE7DE),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          color: const Color(0xFFDDD5C8),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.schedule_rounded,
            size: 11.5,
            color: Color(0xFF8C7C6D),
          ),
          const SizedBox(width: 4.0),
          Text(
            l10n?.labelComingSoon ?? 'Coming Soon',
            style: TextStyle(
              fontFamily: AppTypography.bodyFontFamily,
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF8C7C6D),
            ),
          ),
        ],
      ),
    );
  }
}
