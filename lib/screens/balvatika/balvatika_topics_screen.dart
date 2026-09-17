import 'package:flutter/material.dart';
import '../../app/responsive/responsive.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_typography.dart';
import '../../data/balvatika_content_data.dart';
import '../../l10n/app_localizations.dart';
import '../../models/subject_data.dart';
import '../../widgets/ayo_bottom_nav_bar.dart';
import '../../widgets/ayo_logo.dart';
import '../../widgets/ayo_screen_background.dart';
import 'balvatika_topic_detail_screen.dart';

/// Screen displaying the topics/units for a selected Balvatika module
class BalvatikaTopicsScreen extends StatefulWidget {
  const BalvatikaTopicsScreen({
    super.key,
    required this.module,
    this.onBack,
    this.onNavigateTab,
  });

  final Subject module;
  final VoidCallback? onBack;
  final ValueChanged<int>? onNavigateTab;

  @override
  State<BalvatikaTopicsScreen> createState() => _BalvatikaTopicsScreenState();
}

class _BalvatikaTopicsScreenState extends State<BalvatikaTopicsScreen> {
  int _navIndex = 1;

  void _handleBack() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  void _onBottomNavSelected(int index) {
    if (index == 0) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (widget.onNavigateTab != null) {
      widget.onNavigateTab!(index);
    } else {
      setState(() => _navIndex = index);
    }
  }

  String _getLocalizedModuleName(BuildContext context, Subject module) {
    final isHindi = Localizations.localeOf(context).languageCode == 'hi';
    if (isHindi && module.hindiName != null) {
      return module.hindiName!;
    }
    return module.name;
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTabletOrLarger(context);
    final topics = BalvatikaContentRepository.getTopicsForModule(widget.module.id);

    return AyoScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                child: IgnorePointer(
                  child: Image.asset(
                    'assets/images/corner-design.png',
                    width: isTablet ? 120.0 : 85.0,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IgnorePointer(
                  child: Transform.flip(
                    flipX: true,
                    child: Image.asset(
                      'assets/images/corner-design.png',
                      width: isTablet ? 120.0 : 85.0,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.only(
                  left: isTablet ? 48.0 : AppSpacing.lg,
                  right: isTablet ? 48.0 : AppSpacing.lg,
                  top: 14.0,
                  bottom: 28.0,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isTablet ? 960.0 : double.infinity,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTopBar(isTablet),
                        const SizedBox(height: 16.0),
                        _buildModuleHeader(isTablet),
                        const SizedBox(height: 20.0),
                        _buildTopicsContainer(topics, isTablet),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: AyoBottomNavBar(
          selectedIndex: _navIndex,
          onItemSelected: _onBottomNavSelected,
        ),
      ),
    );
  }

  Widget _buildTopBar(bool isTablet) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Material(
            color: const Color(0xFFFDFBF7),
            borderRadius: BorderRadius.circular(20.0),
            child: InkWell(
              onTap: _handleBack,
              borderRadius: BorderRadius.circular(20.0),
              child: Container(
                width: 40.0,
                height: 40.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(
                    color: const Color(0xFFE8DECF),
                    width: 1.0,
                  ),
                ),
                child: const Icon(
                  Icons.chevron_left_rounded,
                  size: 26.0,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
        Center(
          child: AyoLogo(
            height: isTablet ? 95.0 : 75.0,
            assetPath: 'assets/images/ayovaani_logo.png',
          ),
        ),
      ],
    );
  }

  Widget _buildModuleHeader(bool isTablet) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF7),
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(color: const Color(0xFFE8DECF)),
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
            width: isTablet ? 56.0 : 48.0,
            height: isTablet ? 56.0 : 48.0,
            decoration: BoxDecoration(
              color: const Color(0xFFF7EBE7),
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(color: const Color(0xFFE8D4C8)),
            ),
            child: Icon(
              widget.module.icon,
              size: isTablet ? 26.0 : 22.0,
              color: AppColors.primaryBurgundy,
            ),
          ),
          const SizedBox(width: 14.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBurgundy,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Text(
                        l10n?.classBalvatika ?? 'Balvatika',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11.0,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F0E4),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Text(
                        l10n?.labelAvailable ?? 'Available',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11.0,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF385E32),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4.0),
                Text(
                  _getLocalizedModuleName(context, widget.module),
                  style: TextStyle(
                    fontFamily: AppTypography.headingFontFamily,
                    fontSize: isTablet ? 20.0 : 17.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBurgundy,
                  ),
                ),
                if (widget.module.description != null) ...[
                  const SizedBox(height: 2.0),
                  Text(
                    widget.module.description!,
                    style: TextStyle(
                      fontFamily: AppTypography.bodyFontFamily,
                      fontSize: 12.0,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicsContainer(List<BalvatikaTopicData> topics, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < topics.length; i++) ...[
          if (i > 0) const SizedBox(height: 12.0),
          _buildTopicCard(topics[i], isTablet),
        ],
      ],
    );
  }

  Widget _buildTopicCard(BalvatikaTopicData topic, bool isTablet) {
    final l10n = AppLocalizations.of(context);
    final unitPrefix = l10n?.unitLabel ?? 'Unit';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.0),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => BalvatikaTopicDetailScreen(
                topicData: topic,
                moduleTitle: _getLocalizedModuleName(context, widget.module),
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16.0),
        child: Container(
          padding: EdgeInsets.all(isTablet ? 18.0 : 14.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: const Color(0xFFE2D4C0), width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x084A3B32),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: isTablet ? 50.0 : 44.0,
                height: isTablet ? 50.0 : 44.0,
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF7F2),
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: const Color(0xFFC88A22), width: 1.2),
                ),
                child: Center(
                  child: Text(
                    topic.emoji,
                    style: TextStyle(fontSize: isTablet ? 26.0 : 22.0),
                  ),
                ),
              ),
              const SizedBox(width: 14.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$unitPrefix ${topic.topicNumber}: ${topic.getLocalizedTitle(context)}',
                      style: TextStyle(
                        fontFamily: AppTypography.headingFontFamily,
                        fontSize: isTablet ? 16.5 : 15.0,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3.0),
                    Text(
                      topic.getLocalizedDesc(context),
                      style: TextStyle(
                        fontFamily: AppTypography.bodyFontFamily,
                        fontSize: isTablet ? 12.5 : 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
              const Icon(
                Icons.chevron_right_rounded,
                size: 24.0,
                color: Color(0xFFC88A22),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
