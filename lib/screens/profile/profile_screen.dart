import 'package:flutter/material.dart';
import '../../app/responsive/responsive.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_typography.dart';
import '../../widgets/ayo_logo.dart';
import '../../widgets/ayo_screen_background.dart';

/// Screen: Teacher Profile for AYOVAANI Teacher App.
///
/// Replaces the old Progress module in the main navigation (Tab 3):
/// Home | Learn | Tools | Profile
///
/// Features:
/// - Teacher Profile header with avatar, name ("Teacher"), role ("Classroom Educator"), and [Edit Profile]
/// - Offline Ready card matching the Home screen green status
/// - My Classroom card (Class 1, Hindi → Mundari, 32 students)
/// - Language Settings card (Teaching Language: Hindi → Mundari)
/// - Downloaded Content card (24 lessons offline, 128 MB storage used)
/// - App Settings list (Notifications, Offline Sync, Help & Support, About AYOVAANI)
/// - Subtle Log Out button
/// - Responsive: 1-column on mobile (Pixel 4), intelligent 2-column on tablet (Pixel Tablet)
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    this.onNavigateTab,
  });

  final ValueChanged<int>? onNavigateTab;

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTabletOrLarger(context);
    final cornerSize = isTablet ? 135.0 : 95.0;

    return AyoScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              // Top-left Warli Corner Ornament
              Positioned(
                top: 0,
                left: 0,
                child: IgnorePointer(
                  child: _buildCornerDecoration(
                    isRight: false,
                    size: cornerSize,
                  ),
                ),
              ),

              // Top-right Warli Corner Ornament (Horizontally Mirrored)
              Positioned(
                top: 0,
                right: 0,
                child: IgnorePointer(
                  child: _buildCornerDecoration(
                    isRight: true,
                    size: cornerSize,
                  ),
                ),
              ),

              // Bottom-left Warli Corner Ornament
              Positioned(
                bottom: 0,
                left: 0,
                child: IgnorePointer(
                  child: Transform.flip(
                    flipY: true,
                    child: _buildCornerDecoration(
                      isRight: false,
                      size: cornerSize * 0.85,
                    ),
                  ),
                ),
              ),

              // Bottom-right Warli Corner Ornament
              Positioned(
                bottom: 0,
                right: 0,
                child: IgnorePointer(
                  child: Transform.flip(
                    flipX: true,
                    flipY: true,
                    child: _buildCornerDecoration(
                      isRight: true,
                      size: cornerSize * 0.85,
                    ),
                  ),
                ),
              ),

              // Main Scrollable Content
              LayoutBuilder(
                builder: (context, constraints) {
                  final horizontalPadding = isTablet ? 44.0 : AppSpacing.lg;
                  final contentMaxWidth = isTablet ? 1060.0 : double.infinity;

                  return SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: EdgeInsets.only(
                      left: horizontalPadding,
                      right: horizontalPadding,
                      top: isTablet ? 14.0 : 12.0,
                      bottom: 24.0,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: contentMaxWidth),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Top Bar: Centered AyoVaani Logo
                            _buildTopLogo(isTablet),

                            SizedBox(height: isTablet ? 16.0 : 14.0),

                            // 2. Section Heading: "Teacher Profile"
                            Text(
                              'Teacher Profile',
                              style: TextStyle(
                                fontFamily: AppTypography.headingFontFamily,
                                fontSize: isTablet ? 24.0 : 21.0,
                                fontWeight: FontWeight.w400,
                                color: AppColors.primaryBurgundy,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              'Classroom settings, offline sync status, and educator preferences.',
                              style: TextStyle(
                                fontFamily: AppTypography.bodyFontFamily,
                                fontSize: isTablet ? 13.5 : 12.5,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textSecondary,
                              ),
                            ),

                            SizedBox(height: isTablet ? 18.0 : 14.0),

                            // 3. Main Content: 2-Column on Tablet, Single-Column on Mobile
                            if (isTablet)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Left Column: Profile Card, Offline Status, My Classroom
                                  Expanded(
                                    child: Column(
                                      children: [
                                        _buildProfileHeaderCard(context, isTablet: true),
                                        const SizedBox(height: 14.0),
                                        _buildOfflineStatusCard(isTablet: true),
                                        const SizedBox(height: 14.0),
                                        _buildMyClassroomCard(context, isTablet: true),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 20.0),
                                  // Right Column: Language Settings, Downloads, Settings, Log Out
                                  Expanded(
                                    child: Column(
                                      children: [
                                        _buildLanguageSettingsCard(context, isTablet: true),
                                        const SizedBox(height: 14.0),
                                        _buildDownloadsCard(context, isTablet: true),
                                        const SizedBox(height: 14.0),
                                        _buildAppSettingsCard(context, isTablet: true),
                                        const SizedBox(height: 18.0),
                                        _buildLogoutButton(context, isTablet: true),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            else ...[
                              // Mobile: Single-Column Order
                              _buildProfileHeaderCard(context, isTablet: false),
                              const SizedBox(height: 12.0),
                              _buildOfflineStatusCard(isTablet: false),
                              const SizedBox(height: 12.0),
                              _buildMyClassroomCard(context, isTablet: false),
                              const SizedBox(height: 12.0),
                              _buildLanguageSettingsCard(context, isTablet: false),
                              const SizedBox(height: 12.0),
                              _buildDownloadsCard(context, isTablet: false),
                              const SizedBox(height: 12.0),
                              _buildAppSettingsCard(context, isTablet: false),
                              const SizedBox(height: 18.0),
                              _buildLogoutButton(context, isTablet: false),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Decorative Warli corner ornament.
  Widget _buildCornerDecoration({
    required bool isRight,
    required double size,
  }) {
    final imageWidget = Image.asset(
      'assets/images/corner-desing.png',
      width: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          'assets/images/corner-design.png',
          width: size,
          fit: BoxFit.contain,
        );
      },
    );

    return isRight
        ? Transform.flip(
            flipX: true,
            child: imageWidget,
          )
        : imageWidget;
  }

  /// 1. Top Area: Centered AyoVaani Logo
  Widget _buildTopLogo(bool isTablet) {
    return SizedBox(
      width: double.infinity,
      child: Center(
        child: AyoLogo(
          height: isTablet ? 95.0 : 75.0,
          assetPath: 'assets/images/ayovaani_logo.png',
        ),
      ),
    );
  }

  /// 2. Teacher Profile Header Card
  Widget _buildProfileHeaderCard(BuildContext context, {required bool isTablet}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF7), // Warm cream card surface
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(
          color: const Color(0xFFE8DECF),
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x084A3B32),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(isTablet ? 18.0 : 15.0),
      child: Row(
        children: [
          // Circular Teacher Avatar
          Container(
            width: isTablet ? 64.0 : 54.0,
            height: isTablet ? 64.0 : 54.0,
            decoration: BoxDecoration(
              color: const Color(0xFFF7EBE7),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFE2D2C6),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.person_rounded,
              size: isTablet ? 34.0 : 28.0,
              color: AppColors.primaryBurgundy,
            ),
          ),
          SizedBox(width: isTablet ? 16.0 : 13.0),

          // Name & Role
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Teacher',
                  style: TextStyle(
                    fontFamily: AppTypography.headingFontFamily,
                    fontSize: isTablet ? 20.0 : 18.0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  'Classroom Educator',
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: isTablet ? 13.0 : 12.0,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF8B4B3E), // Warm terracotta accent
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  'Primary Section • Tribal Language Focus',
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: isTablet ? 12.0 : 11.0,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8.0),

          // [ Edit Profile ] Button
          Material(
            color: const Color(0xFFF6ECE0),
            borderRadius: BorderRadius.circular(16.0),
            child: InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Profile editing will be available in the next release.',
                      style: TextStyle(fontFamily: AppTypography.bodyFontFamily),
                    ),
                    backgroundColor: const Color(0xFF4A3B32),
                    duration: const Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    margin: const EdgeInsets.all(16.0),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16.0),
              splashColor: AppColors.primaryBurgundy.withValues(alpha: 0.1),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: const Color(0xFFE2D6C5),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.edit_outlined,
                      size: 13.0,
                      color: AppColors.primaryBurgundy,
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      'Edit',
                      style: TextStyle(
                        fontFamily: AppTypography.bodyFontFamily,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBurgundy,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 3. Offline Ready Status Card (reusing the exact Home screen visual language)
  Widget _buildOfflineStatusCard({required bool isTablet}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9F5), // Light cream with soft green tint
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: const Color(0xFFD6E3D4), // Subtle soft green/olive border
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x062C4A26),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      child: Row(
        children: [
          // Soft green icon circle
          Container(
            width: 34.0,
            height: 34.0,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F0E4),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cloud_done_rounded,
              color: Color(0xFF4C7544),
              size: 19.0,
            ),
          ),
          const SizedBox(width: 12.0),

          // Status details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Offline Ready',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTypography.bodyFontFamily,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2C4A26),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    // 24 lessons badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 2.0,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2EDDF),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Text(
                        '24 lessons',
                        style: TextStyle(
                          fontFamily: AppTypography.bodyFontFamily,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF385E32),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2.0),
                Text(
                  'Content synced today.',
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF5E725B),
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  '24 lessons available offline',
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF385E32),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 4. My Classroom Card
  Widget _buildMyClassroomCard(BuildContext context, {required bool isTablet}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF7),
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(
          color: const Color(0xFFE8DECF),
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x084A3B32),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(isTablet ? 18.0 : 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF5ED),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  size: 16.0,
                  color: Color(0xFF5A7854),
                ),
              ),
              const SizedBox(width: 8.0),
              Text(
                'My Classroom',
                style: TextStyle(
                  fontFamily: AppTypography.headingFontFamily,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),

          // 3 Details Rows: Current Class, Language, Students
          _buildInfoRow(
            icon: Icons.auto_stories_rounded,
            label: 'Current Class',
            value: 'Class 1',
            accentColor: AppColors.primaryBurgundy,
          ),
          const Divider(height: 16.0, color: Color(0xFFEFE8DD), thickness: 0.8),
          _buildInfoRow(
            icon: Icons.translate_rounded,
            label: 'Language',
            value: 'Hindi → Mundari',
            accentColor: const Color(0xFF8B4B3E),
          ),
          const Divider(height: 16.0, color: Color(0xFFEFE8DD), thickness: 0.8),
          _buildInfoRow(
            icon: Icons.groups_rounded,
            label: 'Students',
            value: '32 students',
            accentColor: const Color(0xFF5A7854),
          ),
        ],
      ),
    );
  }

  /// Info row component
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color accentColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16.0,
          color: accentColor,
        ),
        const SizedBox(width: 10.0),
        Text(
          label,
          style: TextStyle(
            fontFamily: AppTypography.bodyFontFamily,
            fontSize: 12.5,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontFamily: AppTypography.bodyFontFamily,
            fontSize: 13.0,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  /// 5. Language Settings Card
  Widget _buildLanguageSettingsCard(BuildContext context, {required bool isTablet}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF7),
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(
          color: const Color(0xFFE8DECF),
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x084A3B32),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(isTablet ? 18.0 : 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7EBE7),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: const Icon(
                  Icons.language_rounded,
                  size: 16.0,
                  color: AppColors.primaryBurgundy,
                ),
              ),
              const SizedBox(width: 8.0),
              Text(
                'Language Settings',
                style: TextStyle(
                  fontFamily: AppTypography.headingFontFamily,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),

          // Teaching Language row with right chevron
          Material(
            color: const Color(0xFFFAF6EE),
            borderRadius: BorderRadius.circular(12.0),
            child: InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Hindi → Mundari is currently set as the primary language pair.',
                      style: TextStyle(fontFamily: AppTypography.bodyFontFamily),
                    ),
                    backgroundColor: const Color(0xFF4A3B32),
                    duration: const Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    margin: const EdgeInsets.all(16.0),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 11.0),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Teaching Language',
                          style: TextStyle(
                            fontFamily: AppTypography.bodyFontFamily,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF765E49),
                          ),
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          'Hindi → Mundari',
                          style: TextStyle(
                            fontFamily: AppTypography.headingFontFamily,
                            fontSize: 15.0,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryBurgundy,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 20.0,
                      color: Color(0xFF8B4B3E),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 6. Downloaded Content Card
  Widget _buildDownloadsCard(BuildContext context, {required bool isTablet}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF7),
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(
          color: const Color(0xFFE8DECF),
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x084A3B32),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(isTablet ? 18.0 : 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF5ED),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: const Icon(
                  Icons.download_done_rounded,
                  size: 16.0,
                  color: Color(0xFF4C7544),
                ),
              ),
              const SizedBox(width: 8.0),
              Text(
                'Downloaded Content',
                style: TextStyle(
                  fontFamily: AppTypography.headingFontFamily,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),

          // Download status items
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available Offline',
                      style: TextStyle(
                        fontFamily: AppTypography.bodyFontFamily,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF765E49),
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      '24 lessons available offline',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTypography.bodyFontFamily,
                        fontSize: 13.0,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Storage Used',
                    style: TextStyle(
                      fontFamily: AppTypography.bodyFontFamily,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF765E49),
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    '128 MB',
                    style: TextStyle(
                      fontFamily: AppTypography.headingFontFamily,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF385E32),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 7. App Settings Card (List-style)
  Widget _buildAppSettingsCard(BuildContext context, {required bool isTablet}) {
    final settingsItems = [
      const _SettingItemData(
        icon: Icons.notifications_none_rounded,
        title: 'Notifications',
        description: 'Classroom alerts & reminder updates',
      ),
      const _SettingItemData(
        icon: Icons.sync_rounded,
        title: 'Offline Sync',
        description: 'Sync lessons when Wi-Fi is available',
      ),
      const _SettingItemData(
        icon: Icons.help_outline_rounded,
        title: 'Help & Support',
        description: 'Teacher guide & classroom FAQs',
      ),
      const _SettingItemData(
        icon: Icons.info_outline_rounded,
        title: 'About AYOVAANI',
        description: 'Version 1.0.0 (MVP Prototype)',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF7),
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(
          color: const Color(0xFFE8DECF),
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x084A3B32),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(isTablet ? 18.0 : 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F6EB),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: const Icon(
                  Icons.settings_outlined,
                  size: 16.0,
                  color: Color(0xFF756E4E),
                ),
              ),
              const SizedBox(width: 8.0),
              Text(
                'Settings',
                style: TextStyle(
                  fontFamily: AppTypography.headingFontFamily,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),

          // List Items
          for (int i = 0; i < settingsItems.length; i++) ...[
            _buildSettingTile(context, settingsItems[i]),
            if (i < settingsItems.length - 1)
              const Divider(height: 12.0, color: Color(0xFFEFE8DD), thickness: 0.8),
          ],
        ],
      ),
    );
  }

  Widget _buildSettingTile(BuildContext context, _SettingItemData item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${item.title}: Configuration option.',
                style: TextStyle(fontFamily: AppTypography.bodyFontFamily),
              ),
              backgroundColor: const Color(0xFF4A3B32),
              duration: const Duration(milliseconds: 900),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              margin: const EdgeInsets.all(16.0),
            ),
          );
        },
        borderRadius: BorderRadius.circular(10.0),
        splashColor: AppColors.primaryBurgundy.withValues(alpha: 0.08),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7.0, horizontal: 4.0),
          child: Row(
            children: [
              Icon(
                item.icon,
                size: 20.0,
                color: const Color(0xFF6B5849),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontFamily: AppTypography.bodyFontFamily,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      item.description,
                      style: TextStyle(
                        fontFamily: AppTypography.bodyFontFamily,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 18.0,
                color: Color(0xFFA89A8E),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 8. Log Out Button (subtle deep maroon, visually secondary)
  Widget _buildLogoutButton(BuildContext context, {required bool isTablet}) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Logging out of offline session...',
                  style: TextStyle(fontFamily: AppTypography.bodyFontFamily),
                ),
                backgroundColor: AppColors.primaryBurgundy,
                duration: const Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                margin: const EdgeInsets.all(16.0),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20.0),
          splashColor: AppColors.primaryBurgundy.withValues(alpha: 0.12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(
                color: const Color(0xFFDCC8B8),
                width: 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.logout_rounded,
                  size: 17.0,
                  color: AppColors.primaryBurgundy,
                ),
                const SizedBox(width: 8.0),
                Text(
                  'Log Out',
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBurgundy,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingItemData {
  const _SettingItemData({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}
