import 'package:flutter/material.dart';
import '../../app/responsive/responsive.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_typography.dart';
import '../../data/balvatika_content_data.dart';
import '../../l10n/app_localizations.dart';
import '../../services/tts_service.dart';
import '../../widgets/ayo_bottom_nav_bar.dart';
import '../../widgets/ayo_logo.dart';
import '../../widgets/ayo_screen_background.dart';

/// Pre-school interactive activity screen for Balvatika topic learning
class BalvatikaTopicDetailScreen extends StatefulWidget {
  const BalvatikaTopicDetailScreen({
    super.key,
    required this.topicData,
    required this.moduleTitle,
    this.onBack,
    this.onNavigateTab,
  });

  final BalvatikaTopicData topicData;
  final String moduleTitle;
  final VoidCallback? onBack;
  final ValueChanged<int>? onNavigateTab;

  @override
  State<BalvatikaTopicDetailScreen> createState() => _BalvatikaTopicDetailScreenState();
}

class _BalvatikaTopicDetailScreenState extends State<BalvatikaTopicDetailScreen> {
  int _navIndex = 1;
  int _activeTab = 0;
  int _selectedCardIndex = 0;
  bool _isPlayingAudio = false;
  late final TtsService _ttsService;

  @override
  void initState() {
    super.initState();
    _ttsService = TtsService();
    _ttsService.init();
  }

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

  Future<void> _speakItem(BalvatikaItem item) async {
    setState(() => _isPlayingAudio = true);
    await _ttsService.speakWordAndMundari(item.nameHindi, item.nameTribalRoman);
    if (mounted) setState(() => _isPlayingAudio = false);
  }

  Future<void> _speakStory(BalvatikaRhymeStory story) async {
    setState(() => _isPlayingAudio = true);
    await _ttsService.speakWordAndMundari(story.titleHindi, story.textHindi);
    if (mounted) setState(() => _isPlayingAudio = false);
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTabletOrLarger(context);

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
                      maxWidth: isTablet ? 900.0 : double.infinity,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTopBar(isTablet),
                        const SizedBox(height: 14.0),
                        _buildTopicHeader(isTablet),
                        const SizedBox(height: 18.0),
                        _buildActivityTabs(isTablet),
                        const SizedBox(height: 20.0),
                        _buildTabContent(isTablet),
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

  Widget _buildTopicHeader(bool isTablet) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF7),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFE8DECF)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: const Color(0xFFC88A22),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Text(
              widget.topicData.emoji,
              style: const TextStyle(fontSize: 22.0),
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.moduleTitle,
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF8B4B3E),
                  ),
                ),
                Text(
                  widget.topicData.getLocalizedTitle(context),
                  style: TextStyle(
                    fontFamily: AppTypography.headingFontFamily,
                    fontSize: isTablet ? 18.0 : 16.0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTabs(bool isTablet) {
    final l10n = AppLocalizations.of(context);
    final tabs = [
      l10n?.tabListenLearn ?? 'Listen & Learn',
      l10n?.tabPictureWord ?? 'Picture & Sound',
      l10n?.tabPlayPractice ?? 'Play & Practice',
      l10n?.tabListenRepeat ?? 'Listen & Repeat',
    ];

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: List.generate(tabs.length, (index) {
        final isSelected = index == _activeTab;
        return ChoiceChip(
          label: Text(tabs[index]),
          selected: isSelected,
          onSelected: (val) => setState(() {
            _activeTab = index;
            _selectedCardIndex = 0;
          }),
          selectedColor: AppColors.primaryBurgundy,
          backgroundColor: const Color(0xFFFDFBF7),
          labelStyle: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 12.0,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: BorderSide(
              color: isSelected ? AppColors.primaryBurgundy : const Color(0xFFE5DACB),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTabContent(bool isTablet) {
    switch (_activeTab) {
      case 0:
        return _buildListenAndLearnTab(isTablet);
      case 1:
        return _buildPictureAndSoundTab(isTablet);
      case 2:
        return _buildPlayAndPracticeTab(isTablet);
      case 3:
        return _buildListenAndRepeatTab(isTablet);
      default:
        return _buildListenAndLearnTab(isTablet);
    }
  }

  /// Mode 1: Listen & Learn (Audio stories & rhymes)
  Widget _buildListenAndLearnTab(bool isTablet) {
    final l10n = AppLocalizations.of(context);
    final stories = widget.topicData.stories;

    if (stories.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.0),
          border: Border.all(color: const Color(0xFFEDE4D7)),
        ),
        child: Column(
          children: [
            Text(
              widget.topicData.emoji,
              style: const TextStyle(fontSize: 48.0),
            ),
            const SizedBox(height: 12.0),
            Text(
              widget.topicData.getLocalizedTitle(context),
              style: TextStyle(
                fontFamily: AppTypography.headingFontFamily,
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6.0),
            Text(
              widget.topicData.getLocalizedDesc(context),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTypography.bodyFontFamily,
                fontSize: 13.0,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    final story = stories.first;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 24.0 : 18.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.0),
        border: Border.all(color: AppColors.primaryBurgundy, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x104A3B32),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(story.emoji, style: TextStyle(fontSize: isTablet ? 64.0 : 52.0)),
          const SizedBox(height: 10.0),
          Text(
            story.titleHindi,
            style: TextStyle(
              fontFamily: AppTypography.headingFontFamily,
              fontSize: isTablet ? 22.0 : 19.0,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryBurgundy,
            ),
          ),
          if (story.titleTribal != null) ...[
            const SizedBox(height: 2.0),
            Text(
              '( ${story.titleTribal} )',
              style: TextStyle(
                fontFamily: AppTypography.bodyFontFamily,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF8B4B3E),
              ),
            ),
          ],
          const SizedBox(height: 14.0),
          Container(
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF7F2),
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(color: const Color(0xFFEDE4D7)),
            ),
            child: Text(
              story.textHindi,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTypography.bodyFontFamily,
                fontSize: isTablet ? 15.0 : 13.5,
                height: 1.5,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 14.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F0E4),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Text(
              '${l10n?.labelMoral ?? 'Moral:'} ${story.moral}',
              style: TextStyle(
                fontFamily: AppTypography.bodyFontFamily,
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF385E32),
              ),
            ),
          ),
          const SizedBox(height: 18.0),
          ElevatedButton.icon(
            onPressed: () => _speakStory(story),
            icon: Icon(
              _isPlayingAudio ? Icons.volume_up_rounded : Icons.play_arrow_rounded,
              color: Colors.white,
            ),
            label: Text(
              _isPlayingAudio
                  ? (l10n?.btnStopAudio ?? 'Playing...')
                  : (l10n?.btnPlayStory ?? 'Play Story Audio'),
              style: const TextStyle(fontFamily: 'Inter', color: Colors.white, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBurgundy,
              padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 12.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
            ),
          ),
        ],
      ),
    );
  }

  /// Mode 2: Picture & Sound Cards
  Widget _buildPictureAndSoundTab(bool isTablet) {
    final l10n = AppLocalizations.of(context);
    final items = widget.topicData.items;

    if (items.isEmpty) return const SizedBox.shrink();
    final currentItem = items[_selectedCardIndex];

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isTablet ? 24.0 : 18.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22.0),
            border: Border.all(color: const Color(0xFFC88A22), width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x104A3B32),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                currentItem.emoji,
                style: TextStyle(fontSize: isTablet ? 80.0 : 64.0),
              ),
              const SizedBox(height: 12.0),
              Text(
                currentItem.nameHindi,
                style: TextStyle(
                  fontFamily: AppTypography.headingFontFamily,
                  fontSize: isTablet ? 26.0 : 22.0,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              if (currentItem.tribalDisplay.isNotEmpty) ...[
                const SizedBox(height: 4.0),
                Text(
                  currentItem.tribalDisplay,
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: isTablet ? 17.0 : 15.0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBurgundy,
                  ),
                ),
              ],
              if (currentItem.extraDetail != null) ...[
                const SizedBox(height: 6.0),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF7F2),
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: const Color(0xFFEDE4D7)),
                  ),
                  child: Text(
                    currentItem.extraDetail!,
                    style: TextStyle(
                      fontFamily: AppTypography.bodyFontFamily,
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF8B4B3E),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16.0),
              ElevatedButton.icon(
                onPressed: () => _speakItem(currentItem),
                icon: const Icon(Icons.volume_up_rounded, color: Colors.white),
                label: Text(
                  l10n?.btnListen ?? 'Listen',
                  style: const TextStyle(fontFamily: 'Inter', color: Colors.white, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC88A22),
                  padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 10.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: _selectedCardIndex > 0
                  ? () => setState(() => _selectedCardIndex--)
                  : null,
              icon: const Icon(Icons.arrow_back_ios_rounded),
            ),
            Text(
              '${_selectedCardIndex + 1} / ${items.length}',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13.0,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            IconButton(
              onPressed: _selectedCardIndex < items.length - 1
                  ? () => setState(() => _selectedCardIndex++)
                  : null,
              icon: const Icon(Icons.arrow_forward_ios_rounded),
            ),
          ],
        ),
      ],
    );
  }

  /// Mode 3: Play & Practice (Simple interactive visual choices)
  Widget _buildPlayAndPracticeTab(bool isTablet) {
    final items = widget.topicData.items;
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(height: 10.0),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.0),
            child: InkWell(
              onTap: () => _speakItem(items[i]),
              borderRadius: BorderRadius.circular(14.0),
              child: Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14.0),
                  border: Border.all(color: const Color(0xFFEDE4D7)),
                ),
                child: Row(
                  children: [
                    Text(items[i].emoji, style: const TextStyle(fontSize: 32.0)),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            items[i].nameHindi,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15.0,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (items[i].tribalDisplay.isNotEmpty)
                            Text(
                              items[i].tribalDisplay,
                              style: TextStyle(
                                fontFamily: AppTypography.bodyFontFamily,
                                fontSize: 12.0,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryBurgundy,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const Icon(Icons.volume_up_rounded, color: Color(0xFFC88A22)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Mode 4: Listen & Repeat
  Widget _buildListenAndRepeatTab(bool isTablet) {
    final l10n = AppLocalizations.of(context);
    final items = widget.topicData.items;
    if (items.isEmpty) return const SizedBox.shrink();
    final item = items[_selectedCardIndex];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 24.0 : 18.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.0),
        border: Border.all(color: const Color(0xFF526B4F), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x104A3B32),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            l10n?.labelListenPrompt ?? 'Listen to the prompt and repeat out loud:',
            style: TextStyle(
              fontFamily: AppTypography.bodyFontFamily,
              fontSize: 13.0,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14.0),
          Text(item.emoji, style: TextStyle(fontSize: isTablet ? 72.0 : 56.0)),
          const SizedBox(height: 8.0),
          Text(
            item.nameHindi,
            style: TextStyle(
              fontFamily: AppTypography.headingFontFamily,
              fontSize: isTablet ? 24.0 : 20.0,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          if (item.tribalDisplay.isNotEmpty) ...[
            const SizedBox(height: 4.0),
            Text(
              item.tribalDisplay,
              style: TextStyle(
                fontFamily: AppTypography.bodyFontFamily,
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBurgundy,
              ),
            ),
          ],
          const SizedBox(height: 20.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => _speakItem(item),
                icon: const Icon(Icons.volume_up_rounded, color: Colors.white),
                label: Text(
                  l10n?.btnListen ?? 'Listen',
                  style: const TextStyle(fontFamily: 'Inter', color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF526B4F),
                  padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
                ),
              ),
              const SizedBox(width: 14.0),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Listening... Repeat after the prompt!'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                icon: const Icon(Icons.mic_rounded, color: AppColors.primaryBurgundy),
                label: Text(
                  l10n?.btnRecordRepeat ?? 'Tap to Repeat',
                  style: const TextStyle(fontFamily: 'Inter', color: AppColors.primaryBurgundy),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
                  side: const BorderSide(color: AppColors.primaryBurgundy),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
