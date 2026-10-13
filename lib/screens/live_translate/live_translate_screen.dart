import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../app/responsive/responsive.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../engine/mt_stage.dart';
import '../../engine/pipeline.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/ayo_badges.dart';
import '../../widgets/ayo_bottom_nav_bar.dart';
import '../../widgets/ayo_logo.dart';
import '../../widgets/ayo_screen_background.dart';
import '../../widgets/mundari_audio_text.dart';

class _RecentTranslationItem {
  final String source;
  final String target;
  final DateTime timestamp;

  const _RecentTranslationItem({
    required this.source,
    required this.target,
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
    this.isActive = true,
  });

  final String? initialText;
  final VoidCallback? onBack;
  final ValueChanged<int>? onNavigateTab;
  final bool isShellTab;
  final bool isActive;

  @override
  State<LiveTranslateScreen> createState() => _LiveTranslateScreenState();
}

class _LiveTranslateScreenState extends State<LiveTranslateScreen> {
  int _navIndex = 2;
  TranslationDirection _direction = TranslationDirection.hindiToMundari;
  bool _isListening = false;
  bool _isPlaying = false;
  bool _isProcessing = false;
  bool _isModelLoading = false;
  bool _hasInitialized = false;
  String? _errorMessage;

  String _sourceText = '';
  String _translatedTargetText = '';

  StreamSubscription<LivePipelineEvent>? _liveEventsSub;
  SpeechPipeline? _pipelineRef;

  final List<_RecentTranslationItem> _recentHistory = [];

  final List<String> _quickPhrasesHindi = const [
    'कक्षा शुरू करें',
    'ध्यान दें',
    'अच्छा काम',
    'किताब खोलें',
    'बैठ जाएं',
  ];

  final List<String> _quickPhrasesMundari = const [
    'श्रेणी एतोहोब पे',
    'ध्यान इम पे',
    'बेस कजि',
    'पुथी ओलोल पे',
    'दुब पे',
  ];

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
    if (!widget.isShellTab || widget.isActive) {
      _hasInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initPipeline();
      });
    }
  }

  @override
  void didUpdateWidget(covariant LiveTranslateScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive && !_hasInitialized) {
      _hasInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initPipeline();
      });
    }
  }

  Future<void> _initPipeline() async {
    final pipeline = Provider.of<SpeechPipeline?>(context, listen: false);
    if (pipeline == null) {
      if (mounted) {
        setState(() {
          _isModelLoading = false;
        });
      }
      return;
    }
    _pipelineRef = pipeline;

    await _liveEventsSub?.cancel();
    _liveEventsSub = pipeline.liveEvents.listen(
      _handleLiveEvent,
      onError: (err) {
        if (mounted) {
          setState(() {
            _errorMessage = 'पाइपलाइन त्रुटि: $err';
            _isListening = false;
            _isPlaying = false;
            _isProcessing = false;
          });
        }
      },
    );

    if (mounted) {
      setState(() {
        _isModelLoading = true;
        _errorMessage = null;
      });
    }

    try {
      await pipeline.init();
      await pipeline.setDirection(_direction);
      if (mounted) {
        setState(() {
          _isModelLoading = false;
          _errorMessage = null;
        });

        if (widget.initialText != null && widget.initialText!.trim().isNotEmpty) {
          _translateTypedText(widget.initialText!);
        }
      }
    } catch (e) {
      debugPrint('[LiveTranslate] SpeechPipeline init error: $e');
      if (mounted) {
        setState(() {
          _isModelLoading = false;
          _errorMessage = 'मॉडल लोड करने में त्रुटि: $e';
        });
      }
    }
  }

  void _handleLiveEvent(LivePipelineEvent event) {
    if (!mounted) return;

    switch (event.type) {
      case LiveEventType.sttClause:
        setState(() {
          _sourceText = event.text;
          _isProcessing = true;
        });
        break;
      case LiveEventType.mtClause:
        setState(() {
          _translatedTargetText = event.text;
          _isProcessing = false;
        });
        final source = event.timing.sourceText.isNotEmpty
            ? event.timing.sourceText
            : _sourceText;
        _addTranslationToHistory(source, event.text);
        break;
      case LiveEventType.playbackStarted:
        setState(() {
          _isPlaying = true;
        });
        break;
      case LiveEventType.ttsClause:
        break;
      case LiveEventType.finished:
        setState(() {
          _isPlaying = false;
          _isListening = false;
          _isProcessing = false;
          if (event.clauseIndex == -1 && event.text.startsWith('Pipeline error:')) {
            _errorMessage = event.text;
          }
        });
        break;
    }
  }

  @override
  void dispose() {
    _liveEventsSub?.cancel();
    _pipelineRef?.stopLivePipeline();
    super.dispose();
  }

  Future<void> _playTranslationAudio(String text, {TranslationDirection? direction}) async {
    if (text.trim().isEmpty) return;
    final pipeline = Provider.of<SpeechPipeline?>(context, listen: false);
    if (pipeline == null) return;
    final dir = direction ?? _direction;

    try {
      await pipeline.ensureTtsLoaded();
      await pipeline.ensurePlayerLoaded();

      final ttsResult = await pipeline.ttsStage.synthesize(text, direction: dir);
      if (ttsResult.audioBytes.isNotEmpty) {
        await pipeline.audioPlayer.reset();
        await pipeline.audioPlayer.queueClauseAudio(
          0,
          ttsResult.audioBytes,
          sampleRate: ttsResult.sampleRate,
        );
      }
    } catch (e) {
      debugPrint('[LiveTranslate] Error playing translation audio: $e');
    }
  }

  void _addTranslationToHistory(String source, String target) {
    final cleanSource = source.trim();
    final cleanTarget = target.trim();
    if (cleanSource.isEmpty || cleanTarget.isEmpty) return;

    if (!mounted) return;
    setState(() {
      _sourceText = cleanSource;
      _translatedTargetText = cleanTarget;

      _recentHistory.removeWhere((item) => item.source == cleanSource);
      _recentHistory.insert(
        0,
        _RecentTranslationItem(
          source: cleanSource,
          target: cleanTarget,
          timestamp: DateTime.now(),
        ),
      );

      if (_recentHistory.length > 5) {
        _recentHistory.removeLast();
      }
    });
  }

  Future<void> _toggleListening() async {
    if (_isModelLoading) return;
    final pipeline = Provider.of<SpeechPipeline?>(context, listen: false);
    if (pipeline == null) return;

    if (pipeline.isLiveActive) {
      setState(() {
        _isListening = false;
        _isPlaying = false;
        _isProcessing = false;
      });
      await pipeline.stopLivePipeline();
    } else {
      setState(() {
        _errorMessage = null;
        _isListening = true;
        _isProcessing = false;
        _sourceText = _direction == TranslationDirection.hindiToMundari
            ? 'सुन रहा है... (बोलिए)'
            : 'मुंडारी में सुन रहा है... (कजि पे)';
        _translatedTargetText = '';
      });

      try {
        await pipeline.setDirection(_direction);
        await pipeline.startLivePipeline();
      } catch (e) {
        debugPrint('[LiveTranslate] Error starting live pipeline: $e');
        if (mounted) {
          setState(() {
            _isListening = false;
            _errorMessage = 'माइक्रोफ़ोन या पाइपलाइन शुरू करने में त्रुटि: $e';
          });
        }
      }
    }
  }

  Future<void> _translateTypedText(String typed) async {
    final text = typed.trim();
    if (text.isEmpty) return;

    final pipeline = Provider.of<SpeechPipeline?>(context, listen: false);
    if (pipeline == null) return;
    setState(() {
      _sourceText = text;
      _translatedTargetText = 'अनुवाद हो रहा है...';
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      await pipeline.ensureMtLoaded();
      await pipeline.ensureTtsLoaded();
      await pipeline.ensurePlayerLoaded();

      final mtResult = await pipeline.mtStage.translate(text, direction: _direction);

      if (mounted) {
        setState(() {
          _isProcessing = false;
          _translatedTargetText = mtResult.displayText;
        });
        _addTranslationToHistory(text, mtResult.displayText);
      }

      final ttsResult = await pipeline.ttsStage.synthesize(
        mtResult.synthesizeText,
        direction: _direction,
      );

      if (ttsResult.audioBytes.isNotEmpty) {
        await pipeline.audioPlayer.reset();
        await pipeline.audioPlayer.queueClauseAudio(
          0,
          ttsResult.audioBytes,
          sampleRate: ttsResult.sampleRate,
        );
      }
    } on MtException catch (e) {
      debugPrint('[LiveTranslate] MtException: $e');
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _translatedTargetText = 'अनुवाद त्रुटि';
          _errorMessage = 'अनुवाद मॉडल त्रुटि: ${e.message}';
        });
      }
    } catch (e) {
      debugPrint('[LiveTranslate] Translation error: $e');
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _translatedTargetText = 'त्रुटि हुई';
          _errorMessage = 'अनुवाद विफल: $e';
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
        ),
        title: Text(
          _direction == TranslationDirection.hindiToMundari
              ? (l10n?.typeDialogTitle ?? 'हिंदी वाक्यांश टाइप करें')
              : 'मुंडारी वाक्यांश टाइप करें',
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
            hintStyle: const TextStyle(
              fontFamily: 'Inter',
              color: AppColors.textMuted,
            ),
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
              style: const TextStyle(
                fontFamily: 'Inter',
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final typed = controller.text.trim();
              if (typed.isNotEmpty) {
                Navigator.of(context).pop();
                _translateTypedText(typed);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBurgundy,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
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
            icon: const Icon(
              Icons.chevron_left_rounded,
              size: 30,
              color: AppColors.textPrimary,
            ),
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
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isTablet ? 800.0 : double.infinity,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildLanguageSelector(),
                    const SizedBox(height: 12.0),
                    if (_errorMessage != null) ...[
                      _buildErrorBanner(),
                      const SizedBox(height: 10.0),
                    ],
                    if (_isModelLoading) ...[
                      _buildModelLoadingBanner(),
                      const SizedBox(height: 10.0),
                    ],
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

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xFFEF9A9A), width: 1.0),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFC62828),
            size: 22.0,
          ),
          const SizedBox(width: 10.0),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFFB71C1C),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFFC62828)),
            iconSize: 20.0,
            onPressed: _initPipeline,
            tooltip: 'पुनः प्रयास करें',
          ),
        ],
      ),
    );
  }

  Widget _buildModelLoadingBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xFFFFE082), width: 1.0),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 18.0,
            height: 18.0,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: AppColors.primaryBurgundy,
              value: Platform.environment.containsKey('FLUTTER_TEST') ? 0.7 : null,
            ),
          ),
          SizedBox(width: 12.0),
          Expanded(
            child: Text(
              'ऑफलाइन एआई मॉडल लोड हो रहे हैं...',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF795548),
              ),
            ),
          ),
        ],
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
          icon: const Icon(
            Icons.swap_horiz_rounded,
            color: AppColors.primaryBurgundy,
          ),
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
          onChanged: (val) async {
            if (val != null && val != _direction) {
              setState(() {
                _direction = val;
                _sourceText = '';
                _translatedTargetText = '';
                _errorMessage = null;
              });
              final pipeline = Provider.of<SpeechPipeline?>(context, listen: false);
              await pipeline?.setDirection(val);
            }
          },
        ),
      ),
    );
  }

  Widget _buildQuickPhraseChips() {
    final phrases = _direction == TranslationDirection.hindiToMundari
        ? _quickPhrasesHindi
        : _quickPhrasesMundari;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          for (final phrase in phrases) ...[
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ActionChip(
                label: Text(
                  phrase,
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                backgroundColor: const Color(0xFFFDFBF7),
                side: const BorderSide(color: Color(0xFFE8DECF), width: 1.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                onPressed: () => _translateTypedText(phrase),
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
            _direction == TranslationDirection.hindiToMundari
                ? (l10n?.hindi ?? 'Hindi')
                : 'Mundari',
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
            hasText
                ? _sourceText
                : (l10n?.translateSourcePlaceholder ??
                      'बोलकर या टाइप करके शुरू करें'),
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
    final hasText = _translatedTargetText.isNotEmpty;

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
              Expanded(
                child: Text(
                  _direction == TranslationDirection.hindiToMundari
                      ? 'Mundari'
                      : (l10n?.hindi ?? 'Hindi'),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFE2D4C0),
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8.0),
              AyoBadge(
                label: l10n?.tagOfflineTranslation ?? 'ऑफ़लाइन अनुवाद',
                variant: AyoBadgeVariant.verified,
                customBgColor: const Color(0xFF5A2226),
                customTextColor: const Color(0xFFE2D4C0),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  hasText
                      ? _translatedTargetText
                      : (l10n?.translateTargetPlaceholder ??
                            'अनुवाद यहां दिखेगा'),
                  style: TextStyle(
                    fontFamily: AppTypography.headingFontFamily,
                    fontSize: isTablet ? 22.0 : 18.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
              ),
              if (hasText) ...[
                const SizedBox(width: 8.0),
                MundariAudioButton(
                  text: _translatedTargetText,
                  color: const Color(0xFFFFD700),
                  iconSize: 26.0,
                  onTap: () => _playTranslationAudio(_translatedTargetText),
                ),
              ],
            ],
          ),
          if (hasText) ...[
            const SizedBox(height: 12.0),
            const Divider(color: Color(0xFF8B3A3E), thickness: 0.8),
            const SizedBox(height: 4.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () => _playTranslationAudio(_translatedTargetText),
                  borderRadius: BorderRadius.circular(8.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.volume_up_rounded,
                          size: 16.0,
                          color: Color(0xFFFFD700),
                        ),
                        SizedBox(width: 4.0),
                        Text(
                          'सुनें',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFFD700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 14.0),
                InkWell(
                  onTap: () => _copyToClipboard(context, _translatedTargetText),
                  borderRadius: BorderRadius.circular(8.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.copy_rounded,
                          size: 14.0,
                          color: Colors.white,
                        ),
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
                  onTap: () => _shareTranslation(
                    context,
                    _sourceText,
                    _translatedTargetText,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.share_rounded,
                          size: 14.0,
                          color: Colors.white,
                        ),
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

    return Column(
      children: [
        if (_isListening)
          Container(
            margin: const EdgeInsets.only(bottom: 12.0),
            padding: const EdgeInsets.symmetric(
              horizontal: 14.0,
              vertical: 6.0,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(color: const Color(0xFF81C784)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8.0,
                  height: 8.0,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8.0),
                Text(
                  _isPlaying
                      ? 'अनुवादित ऑडियो बज रहा है...'
                      : (_isProcessing
                          ? 'ऑडियो प्रोसेस हो रहा है...'
                          : 'लाइव सुन रहा है...'),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
          ),
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
          icon: const Icon(
            Icons.keyboard_outlined,
            size: 18.0,
            color: AppColors.primaryBurgundy,
          ),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
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
            padding: const EdgeInsets.symmetric(
              horizontal: 14.0,
              vertical: 12.0,
            ),
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
                        _sourceText = _recentHistory[i].source;
                        _translatedTargetText = _recentHistory[i].target;
                      });
                      _playTranslationAudio(_recentHistory[i].target);
                    },
                    borderRadius: BorderRadius.circular(12.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 10.0,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: const Color(0xFFE8DECF),
                          width: 1.0,
                        ),
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
                                  _recentHistory[i].source,
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
                                  _recentHistory[i].target,
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
                          MundariAudioButton(
                            text: _recentHistory[i].target,
                            color: AppColors.primaryBurgundy,
                            iconSize: 22.0,
                            onTap: () => _playTranslationAudio(
                              _recentHistory[i].target,
                            ),
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
