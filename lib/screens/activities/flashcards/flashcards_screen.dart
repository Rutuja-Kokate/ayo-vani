import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../app/responsive/responsive.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/app_typography.dart';
import '../../../data/english_activities_data.dart';
import '../../../widgets/ayo_bottom_nav_bar.dart';
import '../../../widgets/ayo_logo.dart';
import '../../../widgets/ayo_screen_background.dart';
import '../../../services/tts_service.dart';



import '../../../services/content_generation_service.dart';

/// Interactive Flashcard item model
class FlashcardItem {
  const FlashcardItem({
    required this.word,
    required this.meaning,
    required this.pronunciation,
    required this.emoji,
    this.mundariRoman,
    this.mundariDevanagari,
    this.imageAsset,
  });

  final String word;
  final String meaning;
  final String pronunciation;
  final String emoji;
  final String? mundariRoman;
  final String? mundariDevanagari;
  final String? imageAsset;

  String? get mundariOdia => mundariDevanagari;

  String? get mundariDisplay {
    if (mundariRoman != null && mundariDevanagari != null) {
      return '( $mundariRoman / $mundariDevanagari )';
    }
    return null;
  }
}

/// Reusable Flashcards Screen for ANY chapter of ANY class.
class FlashcardsScreen extends StatefulWidget {
  const FlashcardsScreen({
    super.key,
    required this.className,
    required this.chapterNumber,
    required this.chapterName,
    this.subject = 'Hindi',
    this.onBack,
    this.onNavigateTab,
  });

  final String className;
  final int chapterNumber;
  final String chapterName;
  final String subject;
  final VoidCallback? onBack;
  final ValueChanged<int>? onNavigateTab;

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> {
  int _currentIndex = 0;
  late final TtsService _ttsService;
  bool _isSpeaking = false;
  bool _isFlipped = false;
  int _navIndex = 0;
  List<FlashcardItem> _cards = [];
  double _currentSpeechRate = 0.5;
  bool _isLoading = true;
  final ContentGenerationService _ragService = ContentGenerationService();

  void _setSpeechRate(double rate) {
    setState(() {
      _currentSpeechRate = rate;
    });
    _ttsService.setSpeechRate(rate);
  }

  @override
  void initState() {
    super.initState();
    _ttsService = TtsService();
    _ttsService.init();
    _loadCards();
  }

  bool _isRegenerating = false;

  Future<void> _loadCards({bool forceRefresh = false}) async {
    if (forceRefresh) {
      setState(() => _isRegenerating = true);
    }
    try {
      final ragSet = await _ragService.generateFlashcards(
        widget.chapterName,
        widget.className,
        forceRefresh: forceRefresh,
        subject: widget.subject,
      );
      final ragItems = ragSet.cards.map((c) {
        return FlashcardItem(
          word: c.wordHindi,
          meaning: c.meaningHindi,
          pronunciation: c.wordMundari.isNotEmpty ? c.wordMundari : 'RAG Generated',
          emoji: c.emoji.isNotEmpty ? c.emoji : '✨',
          mundariDevanagari: c.wordMundari,
          imageAsset: c.imageAsset,
        );
      }).toList();

      if (mounted) {
        setState(() {
          _cards = ragItems;
          _isLoading = false;
          _isRegenerating = false;
          _currentIndex = 0;
        });
        if (forceRefresh) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ RAG फ़्लैशकार्ड्स पुनः जनरेट एवं सहेजे गए!'),
              backgroundColor: Colors.green,
            ),
          );
        }
        WidgetsBinding.instance.addPostFrameCallback((_) => _autoPlayCurrentCard());
      }
      return;
    } catch (e) {
      debugPrint('[RAG] Failed to load/generate flashcards: $e');
    }

    if (mounted) {
      setState(() {
        _cards = _generateCards();
        _isLoading = false;
        _isRegenerating = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _autoPlayCurrentCard());
    }
  }

  /// Speak the current card (English/Hindi only) and update UI state.
  Future<void> _autoPlayCurrentCard() async {
    if (_isSpeaking || _cards.isEmpty) return;
    final card = _cards[_currentIndex];
    setState(() => _isSpeaking = true);
    // Passing null for Mundari so the TTS doesn't attempt to speak it.
    await _ttsService.speakWordAndMundari(card.word, null);
    if (mounted) setState(() => _isSpeaking = false);
  }

  List<FlashcardItem> _generateCards() {
    final hardcodedWords = EnglishActivitiesData.getWords(widget.chapterName);
    if (hardcodedWords != null && hardcodedWords.isNotEmpty) {
      return hardcodedWords.map((w) {
        return FlashcardItem(
          word: w.english,
          meaning: '${w.meaning} ${w.mundariDisplay}',
          mundariRoman: w.mundariRoman,
          mundariDevanagari: w.mundariDevanagari,
          pronunciation: w.pronunciation,
          emoji: w.emoji,
        );
      }).toList();
    }

    final lowerName = widget.chapterName.toLowerCase();
    if (lowerName.contains('fruit') || lowerName.contains('color')) {
      return const [
        FlashcardItem(word: 'Apple', meaning: 'A round red fruit (सेब / Seb)', pronunciation: 'ap-uhl', emoji: '🍎'),
        FlashcardItem(word: 'Banana', meaning: 'A sweet yellow fruit (केला / Kela)', pronunciation: 'buh-nan-uh', emoji: '🍌'),
        FlashcardItem(word: 'Grapes', meaning: 'Small juicy purple fruit (अंगूर / Angoor)', pronunciation: 'grayps', emoji: '🍇'),
        FlashcardItem(word: 'Mango', meaning: 'The king of fruits (आम / Aam)', pronunciation: 'mang-goh', emoji: '🥭'),
        FlashcardItem(word: 'Orange', meaning: 'A citrus round fruit (संतरा / Santra)', pronunciation: 'or-inj', emoji: '🍊'),
      ];
    } else if (lowerName.contains('number') || lowerName.contains('count')) {
      return const [
        FlashcardItem(word: 'One (1)', meaning: 'Single unit (एक / Ek)', pronunciation: 'wun', emoji: '1️⃣'),
        FlashcardItem(word: 'Two (2)', meaning: 'Pair of items (दो / Do)', pronunciation: 'too', emoji: '2️⃣'),
        FlashcardItem(word: 'Three (3)', meaning: 'Three items (तीन / Teen)', pronunciation: 'three', emoji: '3️⃣'),
        FlashcardItem(word: 'Four (4)', meaning: 'Four items (चार / Chaar)', pronunciation: 'for', emoji: '4️⃣'),
        FlashcardItem(word: 'Five (5)', meaning: 'Five items (पाँच / Paanch)', pronunciation: 'fyv', emoji: '5️⃣'),
      ];
    } else if (lowerName.contains('animal') || lowerName.contains('bird')) {
      return const [
        FlashcardItem(word: 'Cow', meaning: 'Domestic dairy animal (गाय / Gaay)', pronunciation: 'kow', emoji: '🐄'),
        FlashcardItem(word: 'Elephant', meaning: 'Large gentle giant (हाथी / Haathi)', pronunciation: 'el-uh-fuhnt', emoji: '🐘'),
        FlashcardItem(word: 'Parrot', meaning: 'Green talkative bird (तोता / Tota)', pronunciation: 'pair-uht', emoji: '🦜'),
        FlashcardItem(word: 'Tiger', meaning: 'Magnificent wild cat (बाघ / Baagh)', pronunciation: 'ty-ger', emoji: '🐅'),
      ];
    } else {
      return [
        FlashcardItem(
          word: widget.chapterName,
          meaning: 'Foundational concept (${widget.className})',
          pronunciation: 'Lesson ${widget.chapterNumber}',
          emoji: '📖',
        ),
        const FlashcardItem(
          word: 'Practice Word 1',
          meaning: 'Mother-tongue vocabulary unit',
          pronunciation: 'prak-tis',
          emoji: '🌟',
        ),
        const FlashcardItem(
          word: 'Practice Word 2',
          meaning: 'Classroom contextual dialogue',
          pronunciation: 'dia-log',
          emoji: '🗣️',
        ),
      ];
    }
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    final isTablet = Responsive.isTabletOrLarger(context);
    final currentCard = _cards[_currentIndex];

    return AyoScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              // Corner ornaments
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

              // Main Content
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Top Bar: Back button + AyoLogo
                        _buildTopBar(isTablet),
                        const SizedBox(height: 16.0),

                        // Breadcrumb Header
                        _buildHeader(isTablet),
                        const SizedBox(height: 24.0),

                        // Flip Flashcard Display
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isFlipped = !_isFlipped;
                            });
                          },
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: _isFlipped
                                ? _buildCardBack(currentCard, isTablet)
                                : _buildCardFront(currentCard, isTablet),
                          ),
                        ),
                        const SizedBox(height: 20.0),

                        // Audio & Controls Row
                        _buildControlsRow(isTablet),
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
                width: 42.0,
                height: 42.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(color: const Color(0xFFE8DECF)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x084A3B32),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  size: 24.0,
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

  Widget _buildHeader(bool isTablet) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF7),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFE8DECF)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBurgundy,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    '${widget.className} • Ch ${widget.chapterNumber}',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12.0,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                Flexible(
                  child: Text(
                    widget.chapterName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTypography.headingFontFamily,
                      fontSize: isTablet ? 18.0 : 15.0,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8.0),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5E5E2),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  'Card ${_currentIndex + 1}/${_cards.length}',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBurgundy,
                  ),
                ),
              ),
              const SizedBox(width: 6.0),
              IconButton.filledTonal(
                onPressed: _isRegenerating ? null : () => _loadCards(forceRefresh: true),
                style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFD49B2A).withValues(alpha: 0.15),
              foregroundColor: AppColors.primaryBurgundy,
            ),
            icon: _isRegenerating
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBurgundy),
                  )
                : const Icon(Icons.refresh_rounded, size: 18),
            tooltip: 'नया RAG फ़्लैशकार्ड्स तैयार करें',
          ),
        ],
      ),
    ],
  ),
);
}

  Widget _buildCardFront(FlashcardItem item, bool isTablet) {
    final width = isTablet ? 420.0 : double.infinity;
    final height = isTablet ? 320.0 : 280.0;

    return Container(
      key: const ValueKey('front'),
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(
          color: AppColors.primaryBurgundy,
          width: 2.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x124A3B32),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (item.imageAsset != null && item.imageAsset!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    item.imageAsset!,
                    height: isTablet ? 120.0 : 90.0,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Text(
                      item.emoji,
                      style: TextStyle(fontSize: isTablet ? 72.0 : 58.0),
                    ),
                  ),
                )
              else
                Text(
                  item.emoji,
                  style: TextStyle(fontSize: isTablet ? 72.0 : 58.0),
                ),
              const SizedBox(height: 10.0),
              Text(
                item.word,
                style: TextStyle(
                  fontFamily: AppTypography.headingFontFamily,
                  fontSize: isTablet ? 28.0 : 24.0,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              if (item.mundariRoman != null || item.mundariDevanagari != null) ...[
                const SizedBox(height: 4.0),
                Text(
                  item.mundariRoman != null && item.mundariDevanagari != null
                      ? '( ${item.mundariRoman} / ${item.mundariDevanagari} )'
                      : '( ${item.mundariRoman ?? item.mundariDevanagari} )',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: isTablet ? 19.0 : 16.0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBurgundy,
                  ),
                ),
              ],
              const SizedBox(height: 8.0),
              Text(
                AppLocalizations.of(context)?.flashcardTapReveal ?? 'Tap to reveal meaning / translation',
                style: TextStyle(
                  fontFamily: AppTypography.bodyFontFamily,
                  fontSize: 12.0,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardBack(FlashcardItem item, bool isTablet) {
    final width = isTablet ? 420.0 : double.infinity;
    final height = isTablet ? 320.0 : 280.0;

    return Container(
      key: const ValueKey('back'),
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF7),
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(
          color: const Color(0xFF8B4B3E),
          width: 2.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x124A3B32),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item.meaning,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTypography.headingFontFamily,
                  fontSize: isTablet ? 21.0 : 18.0,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5ECE1),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  'Pronunciation: /${item.pronunciation}/',
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 12.5,
                    color: const Color(0xFF765E49),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 12.0),
              Text(
                AppLocalizations.of(context)?.flashcardTapFlip ?? 'Tap to flip back',
                style: TextStyle(
                  fontFamily: AppTypography.bodyFontFamily,
                  fontSize: 12.0,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlsRow(bool isTablet) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Previous Button
        IconButton.filledTonal(
          onPressed: _currentIndex > 0
              ? () {
                  setState(() {
                    _currentIndex--;
                    _isFlipped = false;
                  });
                }
              : null,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFFFDFBF7),
            foregroundColor: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 20.0),

        // Audio Listen Button
        // Audio Listen Button
        ElevatedButton.icon(
          onPressed: _isSpeaking ? null : () async {
            setState(() => _isSpeaking = true);
            // Passing null so it skips the Mundari speech
            await _ttsService.speakWordAndMundari(_cards[_currentIndex].word, null);
            if (mounted) setState(() => _isSpeaking = false);
          },
          icon: _isSpeaking
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.volume_up_rounded, color: Colors.white, size: 20.0),
          label: const Text(
            'Listen',
            style: TextStyle(
              fontFamily: 'Inter',
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBurgundy,
            padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 12.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          ),
        ),
        const SizedBox(width: 20.0),

        // Speed Dropdown
        Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          decoration: BoxDecoration(
            color: const Color(0xFFFDFBF7),
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<double>(
              value: _currentSpeechRate,
              icon: const Icon(Icons.arrow_drop_down, color: AppColors.textPrimary, size: 20),
              dropdownColor: const Color(0xFFFDFBF7),
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
                fontSize: 13.0,
                color: AppColors.textPrimary,
              ),
              onChanged: _isSpeaking ? null : (double? newValue) {
                if (newValue != null) {
                  _setSpeechRate(newValue);
                }
              },
              items: const [
                DropdownMenuItem(value: 0.1, child: Text('0.1x')),
                DropdownMenuItem(value: 0.2, child: Text('0.2x')),
                DropdownMenuItem(value: 0.25, child: Text('0.25x')),
                DropdownMenuItem(value: 0.5, child: Text('0.5x')),
                DropdownMenuItem(value: 0.75, child: Text('0.75x')),
                DropdownMenuItem(value: 1.0, child: Text('1.0x')),
                DropdownMenuItem(value: 1.5, child: Text('1.5x')),
              ],
            ),
          ),
        ),
        const SizedBox(width: 20.0),

        // Next Button
        IconButton.filledTonal(
          onPressed: _currentIndex < _cards.length - 1
              ? () {
                  setState(() {
                    _currentIndex++;
                    _isFlipped = false;
                  });
                }
              : null,
          icon: const Icon(Icons.arrow_forward_ios_rounded),
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFFFDFBF7),
            foregroundColor: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
