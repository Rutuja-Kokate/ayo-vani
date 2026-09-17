import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';

import '../../app/responsive/responsive.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../l10n/app_localizations.dart';
import '../../pipeline/demo_cache_manager.dart';
import '../../pipeline/fuzzy_matcher.dart';
import '../../pipeline/hindi_stt_service.dart';
import '../../services/audio_player_service.dart';
import '../../services/speech_to_speech_service.dart';
import '../../widgets/ayo_badges.dart';
import '../../widgets/ayo_bottom_nav_bar.dart';
import '../../widgets/ayo_logo.dart';
import '../../widgets/ayo_screen_background.dart';

enum TranslationDirection {
  hindiToMundari,
  mundariToHindi,
}

class _RecentTranslationItem {
  final String hindi;
  final String mundari;
  final DateTime timestamp;

  const _RecentTranslationItem({
    required this.hindi,
    required this.mundari,
    required this.timestamp,
  });
}

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

class _LiveTranslateScreenState extends State<LiveTranslateScreen> {
  int _navIndex = 2;
  TranslationDirection _direction = TranslationDirection.hindiToMundari;
  bool _isListening = false;
  bool _isProcessing = false;
  bool _isModelLoading = true;

  String _sourceText = '';
  String _translatedMundariText = '';

  StreamSubscription<Amplitude>? _amplitudeSub;
  int _silenceMs = 0;
  Timer? _maxRecordingTimer;

  final List<_RecentTranslationItem> _recentHistory = [];

  final List<Map<String, String>> _quickPhrases = const [
    {'hindi': 'कक्षा शुरू करें', 'mundari': 'श्रेणी एतोहोब पे'},
    {'hindi': 'ध्यान दें', 'mundari': 'ध्यान इम पे'},
    {'hindi': 'अच्छा काम', 'mundari': 'बेस कजि'},
    {'hindi': 'किताब खोलें', 'mundari': 'पुथी ओलोल पे'},
    {'hindi': 'बैठ जाएं', 'mundari': 'दुब पे'},
  ];

  final Map<String, String> _sampleHindiToMundari = {
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
    'कक्षा शुरू करें': 'श्रेणी एतोहोब पे',
    'ध्यान दें': 'ध्यान इम पे',
    'अच्छा काम': 'बेस कजि',
    'किताब खोलें': 'पुथी ओलोल पे',
    'बैठ जाएं': 'दुब पे',
  };

  final _audioRecorder = AudioRecorder();
  String? _audioPath;

  void _handleBack() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else if (widget.isShellTab && widget.onNavigateTab != null) {
      widget.onNavigateTab!(0);
    } else {
      Navigator.of(context).maybePop();
    }
  }

  void _onBottomNavSelected(int index) {
    if (index == 2) return;
    if (widget.onNavigateTab != null) {
      widget.onNavigateTab!(index);
    } else {
      setState(() => _navIndex = index);
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initModel();
    });
  }

  Future<void> _initModel() async {
    final stt = context.read<HindiSttService>();
    final s2st = context.read<SpeechToSpeechService>();

    if (!stt.isInitialized) {
      await stt.initialize();
    }
    await s2st.initialize();

    if (mounted) {
      setState(() {
        _isModelLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _amplitudeSub?.cancel();
    _maxRecordingTimer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  void _addTranslationToHistory(String hindi, String mundari) {
    final cleanHindi = hindi.trim();
    final cleanMundari = mundari.trim();
    if (cleanHindi.isEmpty || cleanMundari.isEmpty) return;

    if (!mounted) return;
    setState(() {
      _sourceText = cleanHindi;
      _translatedMundariText = cleanMundari;

      _recentHistory.removeWhere((item) => item.hindi == cleanHindi);
      _recentHistory.insert(
        0,
        _RecentTranslationItem(
          hindi: cleanHindi,
          mundari: cleanMundari,
          timestamp: DateTime.now(),
        ),
      );

      if (_recentHistory.length > 3) {
        _recentHistory.removeLast();
      }
    });

    context.read<S2SAudioPlayerService>().playTranslationResult(
      S2STranslationResult(
        hindiText: cleanHindi,
        mundariText: cleanMundari,
        audioBytes: null,
        source: TranslationSource.demoCache,
        latencyMs: 0,
      ),
    );
  }

  Future<void> _toggleListening() async {
    if (_isModelLoading || _isProcessing) return;

    final hindiStt = context.read<HindiSttService>();
    final cacheManager = context.read<DemoCacheManager>();

    if (_isListening) {
      _amplitudeSub?.cancel();
      _maxRecordingTimer?.cancel();
      _silenceMs = 0;

      if (!mounted) return;
      setState(() {
        _isListening = false;
        _isProcessing = true;
        _sourceText = 'प्रोसेस हो रहा है...';
      });

      try {
        final path = await _audioRecorder.stop();
        if (path != null && mounted) {
          final transcribedHindi = await hindiStt.transcribe(path);
          final trimmedText = transcribedHindi.trim();

          if (trimmedText.isEmpty) {
            if (mounted) {
              setState(() {
                _isProcessing = false;
                _sourceText = 'बोली नहीं सुनाई दी। फिर कोशिश करें।';
                _translatedMundariText = '';
              });
            }
            return;
          }

          final match = FuzzyMatcher.findBestMatch(trimmedText, cacheManager, threshold: 0.4);
          final finalHindi = match.entry?.hindi ?? trimmedText;
          final resultMundari = match.entry?.mundariDevanagari ??
              _sampleHindiToMundari[trimmedText] ??
              'जोहार $trimmedText';

          if (mounted) {
            _addTranslationToHistory(finalHindi, resultMundari);
          }
        }
      } catch (e) {
        debugPrint('STT Processing Error: $e');
        if (mounted) {
          setState(() {
            _sourceText = 'त्रुटि हुई। फिर कोशिश करें।';
            _translatedMundariText = '';
          });
        }
      } finally {
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });
        }
      }
    } else {
      if (await _audioRecorder.hasPermission()) {
        final tempDir = await getTemporaryDirectory();
        _audioPath = '${tempDir.path}/live_record_${DateTime.now().millisecondsSinceEpoch}.wav';

        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.wav,
            sampleRate: 16000,
            numChannels: 1,
          ),
          path: _audioPath!,
        );

        if (!mounted) return;
        setState(() {
          _isListening = true;
          _isProcessing = false;
          _sourceText = 'सुन रहा है...';
          _translatedMundariText = '';
        });

        _silenceMs = 0;
        _amplitudeSub = _audioRecorder.onAmplitudeChanged(const Duration(milliseconds: 100)).listen((amp) {
          if (amp.current < -35.0) {
            _silenceMs += 100;
            if (_silenceMs >= 1500 && _isListening && !_isProcessing) {
              _toggleListening();
            }
          } else {
            _silenceMs = 0;
          }
        });

        _maxRecordingTimer = Timer(const Duration(seconds: 4), () {
          if (_isListening && !_isProcessing) {
            _toggleListening();
          }
        });
      }
    }
  }

  void _showTypeDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFDFBF7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
        title: Text(
          l10n?.typeDialogTitle ?? 'हिंदी वाक्यांश टाइप करें',
          style: TextStyle(
            fontFamily: AppTypography.headingFontFamily,
            fontSize: 18.0,
            color: AppColors.primaryBurgundy,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n?.typeDialogHint ?? 'यहां टेक्स्ट दर्ज करें...',
            hintStyle: const TextStyle(fontFamily: 'Inter', color: AppColors.textMuted),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: Color(0xFFE8DECF)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              l10n?.btnCancel ?? 'रद्द करें',
              style: const TextStyle(fontFamily: 'Inter', color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final typed = controller.text.trim();
              if (typed.isNotEmpty) {
                Navigator.of(context).pop();
                final mundari = _sampleHindiToMundari[typed] ?? 'जोहार $typed';
                _addTranslationToHistory(typed, mundari);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBurgundy,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            ),
            child: Text(
              l10n?.btnSubmit ?? 'जमा करें',
              style: const TextStyle(fontFamily: 'Inter', color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    final l10n = AppLocalizations.of(context);
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n?.msgCopied ?? 'क्लिपबोर्ड पर कॉपी किया गया',
          style: const TextStyle(fontFamily: 'Inter'),
        ),
        backgroundColor: const Color(0xFF4A3B32),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _shareTranslation(BuildContext context, String source, String target) {
    final l10n = AppLocalizations.of(context);
    final textToShare = '$source\n$target';
    Clipboard.setData(ClipboardData(text: textToShare));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n?.msgShared ?? 'अनुवाद साझा किया जा रहा है...',
          style: const TextStyle(fontFamily: 'Inter'),
        ),
        backgroundColor: AppColors.primaryBurgundy,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTabletOrLarger(context);

    return AyoScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.chevron_left_rounded, size: 30, color: AppColors.textPrimary),
            onPressed: _handleBack,
          ),
          title: AyoLogo(
            height: isTablet ? 80.0 : 60.0,
            assetPath: 'assets/images/ayovaani_logo.png',
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isTablet ? 800.0 : double.infinity),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildLanguageSelector(),
                    const SizedBox(height: 12.0),
                    _buildQuickPhraseChips(),
                    const SizedBox(height: 14.0),
                    _buildSourceCard(isTablet),
                    const SizedBox(height: 10.0),
                    _buildTargetCard(isTablet),
                    const SizedBox(height: 20.0),
                    _buildMicAndTypeArea(),
                    const SizedBox(height: 22.0),
                    _buildRecentTranslationsSection(),
                  ],
                ),
              ),
            ),
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

  Widget _buildLanguageSelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF7),
        borderRadius: BorderRadius.circular(30.0),
        border: Border.all(color: const Color(0xFFE8DECF), width: 1.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<TranslationDirection>(
          value: _direction,
          isExpanded: true,
          icon: const Icon(Icons.swap_horiz_rounded, color: AppColors.primaryBurgundy),
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            fontSize: 15.0,
            color: AppColors.textPrimary,
          ),
          items: const [
            DropdownMenuItem(
              value: TranslationDirection.hindiToMundari,
              child: Text('Hindi → Mundari'),
            ),
            DropdownMenuItem(
              value: TranslationDirection.mundariToHindi,
              child: Text('Mundari → Hindi'),
            ),
          ],
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _direction = val;
                _sourceText = '';
                _translatedMundariText = '';
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildQuickPhraseChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          for (final phrase in _quickPhrases) ...[
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ActionChip(
                label: Text(
                  phrase['hindi']!,
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                backgroundColor: const Color(0xFFFDFBF7),
                side: const BorderSide(color: Color(0xFFE8DECF), width: 1.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                onPressed: () => _addTranslationToHistory(
                  phrase['hindi']!,
                  phrase['mundari']!,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSourceCard(bool isTablet) {
    final l10n = AppLocalizations.of(context);
    final hasText = _sourceText.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF7),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFE8DECF), width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x064A3B32),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n?.hindi ?? 'Hindi',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6.0),
          Text(
            hasText ? _sourceText : (l10n?.translateSourcePlaceholder ?? 'बोलकर या टाइप करके शुरू करें'),
            style: TextStyle(
              fontFamily: AppTypography.bodyFontFamily,
              fontSize: isTablet ? 18.0 : 15.0,
              fontWeight: hasText ? FontWeight.w600 : FontWeight.w400,
              color: hasText ? AppColors.textPrimary : AppColors.textMuted,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetCard(bool isTablet) {
    final l10n = AppLocalizations.of(context);
    final hasText = _translatedMundariText.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: AppColors.primaryBurgundy,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18671D21),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mundari',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFE2D4C0),
                  letterSpacing: 0.5,
                ),
              ),
              AyoBadge(
                label: l10n?.tagOfflineTranslation ?? 'ऑफ़लाइन अनुवाद',
                variant: AyoBadgeVariant.verified,
                customBgColor: const Color(0xFF5A2226),
                customTextColor: const Color(0xFFE2D4C0),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Text(
            hasText ? _translatedMundariText : (l10n?.translateTargetPlaceholder ?? 'अनुवाद यहां दिखेगा'),
            style: TextStyle(
              fontFamily: AppTypography.headingFontFamily,
              fontSize: isTablet ? 22.0 : 18.0,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              height: 1.3,
            ),
          ),

          if (hasText) ...[
            const SizedBox(height: 12.0),
            const Divider(color: Color(0xFF8B3A3E), thickness: 0.8),
            const SizedBox(height: 4.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () => _copyToClipboard(context, _translatedMundariText),
                  borderRadius: BorderRadius.circular(8.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.copy_rounded, size: 14.0, color: Colors.white),
                        const SizedBox(width: 4.0),
                        Text(
                          l10n?.btnCopy ?? 'कॉपी करें',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 14.0),
                InkWell(
                  onTap: () => _shareTranslation(context, _sourceText, _translatedMundariText),
                  borderRadius: BorderRadius.circular(8.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.share_rounded, size: 14.0, color: Colors.white),
                        const SizedBox(width: 4.0),
                        Text(
                          l10n?.btnShare ?? 'साझा करें',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMicAndTypeArea() {
    final l10n = AppLocalizations.of(context);

    if (_isModelLoading || _isProcessing) {
      return SizedBox(
        height: 120.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.primaryBurgundy),
            const SizedBox(height: 10.0),
            Text(
              _isProcessing ? 'प्रोसेस हो रहा है...' : 'मॉडल लोड हो रहा है...',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13.0,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        GestureDetector(
          onTap: _toggleListening,
          child: Container(
            width: 96.0,
            height: 96.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primaryBurgundy.withValues(alpha: 0.35),
                width: 2.0,
              ),
            ),
            child: Center(
              child: Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  color: _isListening
                      ? const Color(0xFF8B2328)
                      : AppColors.primaryBurgundy,
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x20671D21),
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                  color: Colors.white,
                  size: 38.0,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 10.0),

        OutlinedButton.icon(
          onPressed: () => _showTypeDialog(context),
          icon: const Icon(Icons.keyboard_outlined, size: 18.0, color: AppColors.primaryBurgundy),
          label: Text(
            l10n?.btnTypeInstead ?? 'टाइप करें',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13.0,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryBurgundy,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFE8DECF), width: 1.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTranslationsSection() {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n?.translateRecentTitle ?? 'हाल के अनुवाद',
          style: TextStyle(
            fontFamily: AppTypography.headingFontFamily,
            fontSize: 15.0,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8.0),

        if (_recentHistory.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: const Color(0xFFFDFBF7),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: const Color(0xFFE8DECF), width: 1.0),
            ),
            child: Text(
              l10n?.translateRecentPlaceholder ?? 'आपके अनुवाद यहां दिखेंगे',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTypography.bodyFontFamily,
                fontSize: 12.0,
                color: AppColors.textMuted,
              ),
            ),
          )
        else
          Column(
            children: [
              for (int i = 0; i < _recentHistory.length; i++) ...[
                if (i > 0) const SizedBox(height: 8.0),
                Material(
                  color: const Color(0xFFFDFBF7),
                  borderRadius: BorderRadius.circular(12.0),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _sourceText = _recentHistory[i].hindi;
                        _translatedMundariText = _recentHistory[i].mundari;
                      });
                    },
                    borderRadius: BorderRadius.circular(12.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: const Color(0xFFE8DECF), width: 1.0),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.history_rounded,
                            size: 16.0,
                            color: Color(0xFF8B4B3E),
                          ),
                          const SizedBox(width: 10.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _recentHistory[i].hindi,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  _recentHistory[i].mundari,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: AppTypography.bodyFontFamily,
                                    fontSize: 11.5,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          const Icon(
                            Icons.chevron_right_rounded,
                            size: 18.0,
                            color: AppColors.textMuted,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
      ],
    );
  }
}
