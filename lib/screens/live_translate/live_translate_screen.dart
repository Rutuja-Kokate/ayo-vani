import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/responsive/responsive.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_typography.dart';
import '../../widgets/ayo_bottom_nav_bar.dart';
import '../../widgets/ayo_logo.dart';
import '../../widgets/ayo_screen_background.dart';

/// Card states for the Single Translation Card flow.
enum TranslationCardState {
  input,
  translating,
  translated,
}

/// Screen: Live Translation for AYOVAANI Teacher App.
///
/// Features:
/// - Single unified translation card handling Hindi → Mundari flow
/// - State 1: Hindi input / teacher speech transcription + "Transcribe" button
/// - State 2: Translating in-place loading indicator
/// - State 3: Dual Hindi transcription + Mundari translation with audio pronunciation
/// - Direction: Hindi (हिंदी) → Mundari (मुंडारी)
/// - Exact AYOVAANI visual language: warm cream card, maroon accents, Warli watermark
/// - "How to Use" guidance card with interactive example phrase chips
/// - Responsive layout for Pixel 4 and Pixel Tablet
class LiveTranslateScreen extends StatefulWidget {
  const LiveTranslateScreen({
    super.key,
    this.initialText,
    this.onBack,
    this.onNavigateTab,
    this.isShellTab = false,
  });

  final String? initialText;
  final VoidCallback? onBack;
  final ValueChanged<int>? onNavigateTab;
  final bool isShellTab;

  @override
  State<LiveTranslateScreen> createState() => _LiveTranslateScreenState();
}

class _LiveTranslateScreenState extends State<LiveTranslateScreen>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _inputController;
  late final FocusNode _inputFocusNode;

  TranslationCardState _cardState = TranslationCardState.input;
  bool _isListening = false;
  String _translatedText = '';
  int _navIndex = 2; // Translate tab index (Home: 0, Learn: 1, Translate: 2, Profile: 3)

  // Dictionary of sample teacher phrases for classroom interaction (Mundari demo phrases)
  final Map<String, String> _sampleTranslations = {
    'यह एक सेब है।': 'नेया मिद सेब तना।',
    'यह एक सेब है': 'नेया मिद सेब तना।',
    'आप कैसे हैं?': 'चेतना मेना?',
    'मेरा नाम ____ है।': 'इंग नाम ____ तना।',
    'धन्यवाद।': 'जोहार!',
    'धन्यवाद!': 'जोहार!',
    'नमस्ते': 'जोहार',
    'किताब खोलो': 'पुथी ओलोल पे',
    'यहाँ आओ': 'नेनता हिजू मे',
    'चुप रहो': 'थिर कोपे',
    'शाबाश': 'बेस कजि',
  };

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController(text: widget.initialText ?? '');
    _inputFocusNode = FocusNode();

    if (_inputController.text.isNotEmpty) {
      _updateTranslation(_inputController.text);
      _cardState = TranslationCardState.input;
    }

    _inputController.addListener(_onInputChanged);
  }

  void _onInputChanged() {
    setState(() {
      _updateTranslation(_inputController.text);
    });
  }

  void _updateTranslation(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      _translatedText = '';
      return;
    }

    // Check exact dictionary match
    if (_sampleTranslations.containsKey(trimmed)) {
      _translatedText = _sampleTranslations[trimmed]!;
      return;
    }

    // Check partial dictionary match
    for (final entry in _sampleTranslations.entries) {
      final keyClean = entry.key
          .replaceAll('!', '')
          .replaceAll('?', '')
          .replaceAll('।', '');
      if (trimmed.contains(keyClean)) {
        _translatedText = entry.value;
        return;
      }
    }

    // Fallback translation in Mundari demo mode
    _translatedText = 'नेया मिद सेब तना। अम दो चेतना मेना?';
  }

  void _toggleListening() {
    setState(() {
      _isListening = !_isListening;
      if (_isListening) {
        // Teacher speech simulation: default to sample Hindi sentence if empty
        if (_inputController.text.isEmpty) {
          _inputController.text = 'यह एक सेब है।';
        }
        if (_cardState == TranslationCardState.translated) {
          _cardState = TranslationCardState.input;
        }
      }
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isListening
              ? 'माइक्रोफ़ोन सक्रिय है: सुन रहे हैं...'
              : 'माइक्रोफ़ोन बंद किया गया',
          style: TextStyle(
            fontFamily: AppTypography.bodyFontFamily,
            color: Colors.white,
          ),
        ),
        backgroundColor: _isListening
            ? AppColors.primaryBurgundy
            : const Color(0xFF4A3B32),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        margin: const EdgeInsets.all(16.0),
      ),
    );
  }

  void _onTranscribePressed() async {
    if (_inputController.text.trim().isEmpty) {
      _inputController.text = 'यह एक सेब है।';
    }
    _updateTranslation(_inputController.text);

    setState(() {
      _isListening = false;
      _cardState = TranslationCardState.translating;
    });

    // Short processing delay for realistic UX
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;

    setState(() {
      _cardState = TranslationCardState.translated;
    });
  }

  void _applyExample(String hindi, String mundari) {
    setState(() {
      _inputController.text = hindi;
      _translatedText = mundari;
      _cardState = TranslationCardState.translated;
    });
  }

  void _copyToClipboard(String text) {
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'अनुवाद क्लिपबोर्ड में कॉपी किया गया!',
          style: TextStyle(fontFamily: AppTypography.bodyFontFamily),
        ),
        backgroundColor: const Color(0xFF385E32),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        margin: const EdgeInsets.all(16.0),
      ),
    );
  }

  void _speakTranslation(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.volume_up_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'मुंडारी उच्चारण सुनाया जा रहा है...',
                style: TextStyle(fontFamily: AppTypography.bodyFontFamily),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryBurgundy,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        margin: const EdgeInsets.all(16.0),
      ),
    );
  }

  void _shareTranslation(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'अनुवाद साझा करने के लिए तैयार!',
          style: TextStyle(fontFamily: AppTypography.bodyFontFamily),
        ),
        backgroundColor: const Color(0xFF385E32),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        margin: const EdgeInsets.all(16.0),
      ),
    );
  }

  void _handleBack() {
    setState(() {
      _cardState = TranslationCardState.input;
      _isListening = false;
    });
    if (widget.onBack != null) {
      widget.onBack!();
    } else if (widget.isShellTab && widget.onNavigateTab != null) {
      widget.onNavigateTab!(0);
    } else {
      Navigator.of(context).maybePop();
    }
  }

  void _onBottomNavSelected(int index) {
    if (index == 2) {
      // Already on Translate tab
      return;
    }
    if (widget.onNavigateTab != null) {
      widget.onNavigateTab!(index);
    } else {
      setState(() {
        _navIndex = index;
      });
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void dispose() {
    _inputController.removeListener(_onInputChanged);
    _inputController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

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

              // Bottom-left Warli Corner Ornament (Subtle ambient)
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

              // Bottom-right Warli Corner Ornament (Subtle ambient)
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
                  final contentMaxWidth = isTablet ? 780.0 : double.infinity;

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
                            // 1. Top Bar: Back Button + Centered AyoVaani Logo
                            _buildTopBar(isTablet),

                            SizedBox(height: isTablet ? 12.0 : 14.0),

                            // 2. Title Row: Icon Badge + Heading/Status + Language Selector
                            _buildTitleAndSelectorRow(isTablet),

                            SizedBox(height: isTablet ? 18.0 : 16.0),

                            // 3. Unified Single Translation Card
                            _buildSingleTranslationCard(isTablet),

                            SizedBox(height: isTablet ? 18.0 : 16.0),

                            // 4. How to Use / Help Section with Example Chips
                            _buildHowToUseSection(isTablet),
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
        bottomNavigationBar: widget.isShellTab
            ? null
            : AyoBottomNavBar(
                selectedIndex: _navIndex,
                onItemSelected: _onBottomNavSelected,
              ),
      ),
    );
  }

  /// Top decorative Warli corner ornament.
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

  /// 1. Top Bar: Back Button at top-left, Centered AyoVaani Logo
  Widget _buildTopBar(bool isTablet) {
    final logoHeight = isTablet ? 100.0 : 80.0;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Back Button on the top left
        Align(
          alignment: Alignment.centerLeft,
          child: Material(
            color: const Color(0xFFFDFBF7),
            borderRadius: BorderRadius.circular(20.0),
            child: InkWell(
              onTap: _handleBack,
              borderRadius: BorderRadius.circular(20.0),
              splashColor: AppColors.primaryBurgundy.withValues(alpha: 0.12),
              child: Container(
                width: 40.0,
                height: 40.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(
                    color: const Color(0xFFE8DECF),
                    width: 1.0,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x084A3B32),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
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

        // Centered Official AyoVaani Logo
        Center(
          child: AyoLogo(
            height: logoHeight,
            assetPath: 'assets/images/ayovaani_logo.png',
          ),
        ),
      ],
    );
  }

  /// 2. Title Row: Translation Icon Badge, Title/Status, and Language Direction Pill
  Widget _buildTitleAndSelectorRow(bool isTablet) {
    final titleBlock = Row(
      children: [
        // Circular Burgundy Icon Badge
        Container(
          width: isTablet ? 50.0 : 44.0,
          height: isTablet ? 50.0 : 44.0,
          decoration: BoxDecoration(
            color: AppColors.primaryBurgundy,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F671D21),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            Icons.g_translate_rounded,
            color: Colors.white,
            size: isTablet ? 26.0 : 22.0,
          ),
        ),
        const SizedBox(width: 14.0),

        // Title + Subtitle + Live Status
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Live Translation',
                style: TextStyle(
                  fontFamily: AppTypography.headingFontFamily,
                  fontSize: isTablet ? 25.0 : 20.0,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 2.0),
              Text(
                'Hindi to Mundari Translation',
                style: TextStyle(
                  fontFamily: AppTypography.bodyFontFamily,
                  fontSize: isTablet ? 13.5 : 12.0,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 3.0),

              // Live status indicator
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7.0,
                    height: 7.0,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4C7544),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5.0),
                  Text(
                    'Live Translation',
                    style: TextStyle(
                      fontFamily: AppTypography.bodyFontFamily,
                      fontSize: 11.0,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF4C7544),
                    ),
                  ),
                  const SizedBox(width: 6.0),
                  Flexible(
                    child: Text(
                      '•  Ready to translate',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTypography.bodyFontFamily,
                        fontSize: 11.0,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF5E725B),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );

    final languagePill = Material(
      color: const Color(0xFFFDFBF7),
      borderRadius: BorderRadius.circular(22.0),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'वर्तमान भाषा दिशा: हिंदी → मुंडारी (कक्षा उपयोग के लिए सक्रिय)',
                style: TextStyle(fontFamily: AppTypography.bodyFontFamily),
              ),
              backgroundColor: AppColors.primaryBurgundy,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              margin: const EdgeInsets.all(16.0),
            ),
          );
        },
        borderRadius: BorderRadius.circular(22.0),
        splashColor: AppColors.primaryBurgundy.withValues(alpha: 0.1),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22.0),
            border: Border.all(
              color: const Color(0xFFE8DECF),
              width: 1.0,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x084A3B32),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'हिंदी  →  मुंडारी',
                style: TextStyle(
                  fontFamily: AppTypography.bodyFontFamily,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 6.0),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18.0,
                color: AppColors.textPrimary,
              ),
            ],
          ),
        ),
      ),
    );

    if (isTablet) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: titleBlock),
          const SizedBox(width: 16.0),
          languagePill,
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleBlock,
          const SizedBox(height: 10.0),
          Align(
            alignment: Alignment.centerRight,
            child: languagePill,
          ),
        ],
      );
    }
  }

  /// 3. Unified Single Translation Card
  Widget _buildSingleTranslationCard(bool isTablet) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF7), // Warm cream card surface
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: const Color(0xFFE8DECF), // Subtle warm border
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A4A3B32),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Subtle Warli Village Artwork watermark inside the card
          Positioned(
            right: -8.0,
            bottom: -8.0,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.15,
                child: Image.asset(
                  'assets/images/warli_background.png',
                  height: isTablet ? 130.0 : 100.0,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
              ),
            ),
          ),

          // Main Card Content
          Padding(
            padding: EdgeInsets.all(isTablet ? 22.0 : 18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Card Direction Bar
                _buildCardDirectionHeader(isTablet),

                const SizedBox(height: 14.0),

                // Hindi Input / Transcription Section
                _buildHindiSection(isTablet),

                // State 2: Translating in-place loading state
                if (_cardState == TranslationCardState.translating) ...[
                  const SizedBox(height: 16.0),
                  _buildTranslatingState(isTablet),
                ],

                // State 3: Translated State (Mundari Output)
                if (_cardState == TranslationCardState.translated) ...[
                  const SizedBox(height: 16.0),
                  _buildDivider(),
                  const SizedBox(height: 16.0),
                  _buildMundariSection(isTablet),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Direction Header inside the single card
  Widget _buildCardDirectionHeader(bool isTablet) {
    return Wrap(
      spacing: 12.0,
      runSpacing: 8.0,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: const Color(0xFFF2E7D8),
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: const Color(0xFFE2D4C0),
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.translate_rounded,
                size: 16.0,
                color: AppColors.primaryBurgundy,
              ),
              const SizedBox(width: 7.0),
              Text(
                'Hindi → Mundari',
                style: TextStyle(
                  fontFamily: AppTypography.bodyFontFamily,
                  fontSize: 13.0,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryBurgundy,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),

        // Reset / Clear button if translated or text is present
        if (_cardState == TranslationCardState.translated ||
            _inputController.text.isNotEmpty)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _cardState = TranslationCardState.input;
                  _inputController.clear();
                  _translatedText = '';
                  _isListening = false;
                });
              },
              borderRadius: BorderRadius.circular(8.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.refresh_rounded,
                      size: 16.0,
                      color: Color(0xFF8B4B3E),
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      'नया अनुवाद',
                      style: TextStyle(
                        fontFamily: AppTypography.bodyFontFamily,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF8B4B3E),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Hindi Input / Transcription Section
  Widget _buildHindiSection(bool isTablet) {
    final isInputState = _cardState == TranslationCardState.input;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row: Badge + Language Label + controls
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 28.0,
                    height: 28.0,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7EBE7),
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                    child: const Icon(
                      Icons.record_voice_over_rounded,
                      color: Color(0xFF8B4B3E),
                      size: 16.0,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Flexible(
                    child: Text(
                      'हिंदी (Hindi)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTypography.bodyFontFamily,
                        fontSize: isTablet ? 16.0 : 15.0,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (isInputState)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeaderIconButton(
                    icon: Icons.mic_none_rounded,
                    tooltip: 'माइक्रोफ़ोन',
                    onTap: _toggleListening,
                  ),
                  const SizedBox(width: 6.0),
                  _buildHeaderIconButton(
                    icon: Icons.keyboard_alt_outlined,
                    tooltip: 'कीबोर्ड',
                    onTap: () {
                      _inputFocusNode.requestFocus();
                    },
                  ),
                ],
              )
            else
              InkWell(
                onTap: () {
                  setState(() {
                    _cardState = TranslationCardState.input;
                  });
                  _inputFocusNode.requestFocus();
                },
                borderRadius: BorderRadius.circular(8.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.edit_outlined,
                        size: 15.0,
                        color: Color(0xFF756760),
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        'संपादित करें',
                        style: TextStyle(
                          fontFamily: AppTypography.bodyFontFamily,
                          fontSize: 12.0,
                          color: const Color(0xFF756760),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 10.0),

        if (isInputState) ...[
          // Editable Input area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: TextField(
              controller: _inputController,
              focusNode: _inputFocusNode,
              maxLines: isTablet ? 3 : 2,
              maxLength: 500,
              buildCounter: (
                context, {
                required currentLength,
                required isFocused,
                maxLength,
              }) =>
                  null,
              style: TextStyle(
                fontFamily: AppTypography.bodyFontFamily,
                fontSize: 15.0,
                color: AppColors.textPrimary,
                height: 1.45,
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintText: 'हिंदी में टाइप करें या माइक्रोफोन दबाकर बोलें...',
                hintStyle: TextStyle(
                  fontFamily: AppTypography.bodyFontFamily,
                  fontSize: 14.5,
                  color: const Color(0xFF95806E),
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
              ),
            ),
          ),

          const SizedBox(height: 12.0),

          // Center Microphone Button
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Material(
                  color: AppColors.primaryBurgundy,
                  shape: const CircleBorder(),
                  elevation: _isListening ? 6 : 2,
                  shadowColor: AppColors.primaryBurgundy.withValues(alpha: 0.4),
                  child: InkWell(
                    onTap: _toggleListening,
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: isTablet ? 56.0 : 50.0,
                      height: isTablet ? 56.0 : 50.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _isListening
                              ? Colors.white.withValues(alpha: 0.6)
                              : Colors.transparent,
                          width: 2.0,
                        ),
                      ),
                      child: Icon(
                        _isListening ? Icons.graphic_eq_rounded : Icons.mic_rounded,
                        color: Colors.white,
                        size: isTablet ? 26.0 : 24.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5.0),
                Text(
                  _isListening ? 'सुन रहे हैं...' : 'बोलें',
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: _isListening
                        ? AppColors.primaryBurgundy
                        : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14.0),

          // Prominent Transcribe Button inside the same card
          SizedBox(
            width: double.infinity,
            height: 46.0,
            child: ElevatedButton.icon(
              onPressed: _onTranscribePressed,
              icon: const Icon(Icons.auto_awesome_rounded, size: 18.0),
              label: Text(
                'Transcribe',
                style: TextStyle(
                  fontFamily: AppTypography.bodyFontFamily,
                  fontSize: 15.0,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBurgundy,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(23.0),
                ),
              ),
            ),
          ),
        ] else ...[
          // Prominent transcribed Hindi text
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F5EE),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: const Color(0xFFECE1D2),
                width: 1.0,
              ),
            ),
            child: Text(
              _inputController.text.isNotEmpty
                  ? _inputController.text
                  : 'यह एक सेब है।',
              style: TextStyle(
                fontFamily: AppTypography.bodyFontFamily,
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Loading state indicator while translating inside the same card
  Widget _buildTranslatingState(bool isTablet) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF7EBE7).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: const Color(0xFFE8D2CB),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20.0,
            height: 20.0,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: AppColors.primaryBurgundy,
            ),
          ),
          const SizedBox(width: 12.0),
          Text(
            'Translating to Mundari...',
            style: TextStyle(
              fontFamily: AppTypography.bodyFontFamily,
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryBurgundy,
            ),
          ),
        ],
      ),
    );
  }

  /// Subtle divider separating Hindi and Mundari inside the single card
  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1.0,
            color: const Color(0xFFE8DECF),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Container(
            width: 7.0,
            height: 7.0,
            decoration: BoxDecoration(
              color: const Color(0xFF8B4B3E).withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1.0,
            color: const Color(0xFFE8DECF),
          ),
        ),
      ],
    );
  }

  /// Mundari Output Section inside the single card
  Widget _buildMundariSection(bool isTablet) {
    final displayText = _translatedText.isNotEmpty
        ? _translatedText
        : 'नेया मिद सेब तना।';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mundari Header: Badge + Label + copy/share actions
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 28.0,
                    height: 28.0,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF5ED),
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                    child: const Icon(
                      Icons.translate_rounded,
                      color: Color(0xFF5A7854),
                      size: 16.0,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Flexible(
                    child: Text(
                      'मुंडारी (Mundari)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTypography.bodyFontFamily,
                        fontSize: isTablet ? 16.0 : 15.0,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeaderIconButton(
                  icon: Icons.copy_rounded,
                  tooltip: 'कॉपी करें',
                  onTap: () => _copyToClipboard(displayText),
                ),
                const SizedBox(width: 6.0),
                _buildHeaderIconButton(
                  icon: Icons.share_rounded,
                  tooltip: 'साझा करें',
                  onTap: () => _shareTranslation(displayText),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 10.0),

        // Translated Mundari Output Box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
          decoration: BoxDecoration(
            color: const Color(0xFFFAF4EC),
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(
              color: const Color(0xFFE8DECF),
              width: 1.0,
            ),
          ),
          child: Text(
            displayText,
            style: TextStyle(
              fontFamily: AppTypography.bodyFontFamily,
              fontSize: isTablet ? 18.0 : 17.0,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryBurgundy,
              height: 1.45,
            ),
          ),
        ),

        const SizedBox(height: 14.0),

        // Controls Row: Speaker button on left, Translation Status on right
        Wrap(
          spacing: 12.0,
          runSpacing: 10.0,
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.start,
          children: [
            // Speaker / Play Mundari pronunciation Button
            Material(
              color: const Color(0xFFF7EBE7),
              borderRadius: BorderRadius.circular(20.0),
              child: InkWell(
                onTap: () => _speakTranslation(displayText),
                borderRadius: BorderRadius.circular(20.0),
                splashColor: AppColors.primaryBurgundy.withValues(alpha: 0.12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 8.0,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(
                      color: const Color(0xFFE8D2CB),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.volume_up_rounded,
                        color: AppColors.primaryBurgundy,
                        size: 20.0,
                      ),
                      const SizedBox(width: 8.0),
                      Flexible(
                        child: Text(
                          'Play Mundari pronunciation',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: AppTypography.bodyFontFamily,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryBurgundy,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Status Badge: ✓ Translation Ready
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 6.0,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF5ED),
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                  color: const Color(0xFFD4E3D1),
                  width: 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 14.0,
                    color: Color(0xFF385E32),
                  ),
                  const SizedBox(width: 5.0),
                  Text(
                    '✓ Translation Ready',
                    style: TextStyle(
                      fontFamily: AppTypography.bodyFontFamily,
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF385E32),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Small Icon button helper
  Widget _buildHeaderIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(6.0),
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6.0),
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Icon(
              icon,
              size: 20.0,
              color: const Color(0xFF756760),
            ),
          ),
        ),
      ),
    );
  }

  /// 4. How to Use / Help Section with Example Chips
  Widget _buildHowToUseSection(bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF7), // Cream card surface
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(
          color: const Color(0xFFE8DECF), // Subtle warm border
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x064A3B32),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(isTablet ? 18.0 : 16.0),
      child: isTablet
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left Side: Lightbulb Icon + "How to use" text
                Expanded(
                  flex: 4,
                  child: Row(
                    children: [
                      Container(
                        width: 40.0,
                        height: 40.0,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAECD5),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: const Icon(
                          Icons.lightbulb_outline_rounded,
                          color: Color(0xFFB8782E),
                          size: 22.0,
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'कैसे उपयोग करें?',
                              style: TextStyle(
                                fontFamily: AppTypography.bodyFontFamily,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 3.0),
                            Text(
                              'हिंदी में टाइप करें या बोलें।\n"Transcribe" दबाएं और मुंडारी अनुवाद देखें।',
                              style: TextStyle(
                                fontFamily: AppTypography.bodyFontFamily,
                                fontSize: 12.0,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textSecondary,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Vertical Divider Line
                Container(
                  width: 1.0,
                  height: 60.0,
                  margin: const EdgeInsets.symmetric(horizontal: 20.0),
                  color: const Color(0xFFE8DECF),
                ),

                // Right Side: Example Sentence Chips
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'उदाहरण वाक्य',
                            style: TextStyle(
                              fontFamily: AppTypography.bodyFontFamily,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 6.0),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6.0,
                              vertical: 1.5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0E5D4),
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                            child: Text(
                              'डेमो',
                              style: TextStyle(
                                fontFamily: AppTypography.bodyFontFamily,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF765E49),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: [
                          _buildExampleChip(
                            hindi: 'यह एक सेब है।',
                            mundari: 'नेया मिद सेब तना।',
                          ),
                          _buildExampleChip(
                            hindi: 'आप कैसे हैं?',
                            mundari: 'चेतना मेना?',
                          ),
                          _buildExampleChip(
                            hindi: 'नमस्ते',
                            mundari: 'जोहार',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mobile: How to use top
                Row(
                  children: [
                    Container(
                      width: 36.0,
                      height: 36.0,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAECD5),
                        borderRadius: BorderRadius.circular(9.0),
                      ),
                      child: const Icon(
                        Icons.lightbulb_outline_rounded,
                        color: Color(0xFFB8782E),
                        size: 20.0,
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'कैसे उपयोग करें?',
                            style: TextStyle(
                              fontFamily: AppTypography.bodyFontFamily,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'हिंदी में बोलें या लिखें, फिर "Transcribe" दबाएं।',
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

                const SizedBox(height: 12.0),
                const Divider(color: Color(0xFFE8DECF), height: 1.0),
                const SizedBox(height: 12.0),

                // Example Chips Header
                Row(
                  children: [
                    Text(
                      'उदाहरण वाक्य',
                      style: TextStyle(
                        fontFamily: AppTypography.bodyFontFamily,
                        fontSize: 13.0,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6.0),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6.0,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0E5D4),
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: Text(
                        'डेमो',
                        style: TextStyle(
                          fontFamily: AppTypography.bodyFontFamily,
                          fontSize: 10.0,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF765E49),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),

                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: [
                    _buildExampleChip(
                      hindi: 'यह एक सेब है।',
                      mundari: 'नेया मिद सेब तना।',
                    ),
                    _buildExampleChip(
                      hindi: 'आप कैसे हैं?',
                      mundari: 'चेतना मेना?',
                    ),
                    _buildExampleChip(
                      hindi: 'नमस्ते',
                      mundari: 'जोहार',
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  /// Reusable Example Sentence Chip
  Widget _buildExampleChip({
    required String hindi,
    required String mundari,
  }) {
    return Material(
      color: const Color(0xFFF7F1E8),
      borderRadius: BorderRadius.circular(16.0),
      child: InkWell(
        onTap: () => _applyExample(hindi, mundari),
        borderRadius: BorderRadius.circular(16.0),
        splashColor: AppColors.primaryBurgundy.withValues(alpha: 0.12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11.0, vertical: 6.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: const Color(0xFFE2D4C0),
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.touch_app_outlined,
                size: 14.0,
                color: Color(0xFF8B4B3E),
              ),
              const SizedBox(width: 5.0),
              Text(
                hindi,
                style: TextStyle(
                  fontFamily: AppTypography.bodyFontFamily,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
