import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../../app/responsive/responsive.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/ayo_bottom_nav_bar.dart';
import '../../widgets/ayo_logo.dart';
import '../../widgets/ayo_screen_background.dart';
import '../../pipeline/hindi_stt_service.dart';
import '../../pipeline/demo_cache_manager.dart';
import '../../pipeline/fuzzy_matcher.dart';
import '../../services/speech_to_speech_service.dart';
import '../../services/audio_player_service.dart';

enum TranslationDirection {
  hindiToMundari,
  mundariToHindi,
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
  bool _isModelLoading = true;
  String _translatedText = '';
  StreamSubscription<Amplitude>? _amplitudeSub;
  int _silenceMs = 0;
  double _playbackSpeed = 1.0;
  bool _continuousMode = true;
  Timer? _maxRecordingTimer; // Hard cap: stop after 4s regardless of VAD

  // Dictionary of sample teacher phrases for classroom interaction
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
  };

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
      setState(() {
        _navIndex = index;
      });
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
    
    // Lazy load the heavy on-device speech models only when this screen is opened
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

  // Audio recording state
  final _audioRecorder = AudioRecorder();
  String? _audioPath;

  @override
  void dispose() {
    _amplitudeSub?.cancel();
    _maxRecordingTimer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _toggleListening() async {
    if (_isModelLoading) return;

    final hindiStt = context.read<HindiSttService>();
    final cacheManager = context.read<DemoCacheManager>();
    final audioPlayer = context.read<S2SAudioPlayerService>();

    if (_isListening) {
      // Stop listening and process
      _amplitudeSub?.cancel();
      _maxRecordingTimer?.cancel();
      _silenceMs = 0;
      
      setState(() {
        _isListening = false;
        _translatedText = 'Processing...';
      });

      final stopWatch = Stopwatch()..start();
      final path = await _audioRecorder.stop();
      debugPrint('[UI Latency] _audioRecorder.stop() took ${stopWatch.elapsedMilliseconds}ms');
      
      if (path != null) {
        debugPrint('Recorded audio to: $path');
        
        // 1. Run local ONNX Hindi STT
        stopWatch.reset();
        final transcribedHindi = await hindiStt.transcribe(path);
        debugPrint('[UI Latency] hindiStt.transcribe() took ${stopWatch.elapsedMilliseconds}ms');
        debugPrint('[UI] Transcription result: "$transcribedHindi"');
        
        if (transcribedHindi.isEmpty) {
          setState(() {
            _translatedText = 'बोली नहीं सुनाई दी। फिर कोशिश करें।\n(Could not hear clearly. Try again.)';
          });
          return;
        }

        // Show transcription immediately so user knows STT worked
        setState(() {
          _translatedText = 'सुना: $transcribedHindi\nखोज रहे हैं...';
        });

        // 2. Fuzzy match against corpus (lowered threshold for more flexible matching)
        stopWatch.reset();
        final match = FuzzyMatcher.findBestMatch(transcribedHindi, cacheManager, threshold: 0.4);
        debugPrint('[UI Latency] Fuzzy matching took ${stopWatch.elapsedMilliseconds}ms');
        debugPrint('[UI] Fuzzy match score: ${match.score}, entry: ${match.entry?.hindi}');
        
        if (match.entry != null) {
          // Cache Hit! Play audio and show result
          setState(() {
            _translatedText = '${match.entry!.hindi}\n\n${match.entry!.mundariOdia}';
          });
          
          // Play the pre-recorded audio
          await audioPlayer.playTranslationResult(
            S2STranslationResult(
              hindiText: match.entry!.hindi,
              mundariText: match.entry!.mundariOdia,
              audioBytes: null,
              source: TranslationSource.demoCache,
              audioPath: 'assets/demo_audio/${match.entry!.audioFilename}',
              latencyMs: 0,
            )
          );
          
          // Automatically restart listening if continuous mode is on and we are still mounted
          if (_continuousMode && mounted) {
            _toggleListening();
          }
        } else {
          // Cache Miss - hide the text entirely
          setState(() {
            _translatedText = '';
          });
          
          if (_continuousMode && mounted) {
            _toggleListening();
          }
        }
      }
    } else {
      // Start listening
      if (await _audioRecorder.hasPermission()) {
        final tempDir = await getTemporaryDirectory();
        _audioPath = '${tempDir.path}/live_record_${DateTime.now().millisecondsSinceEpoch}.wav';
        
        // Ensure format is compatible with sherpa_onnx (16kHz mono WAV)
        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.wav,
            sampleRate: 16000,
            numChannels: 1,
          ),
          path: _audioPath!,
        );
        
        setState(() {
          _isListening = true;
          _translatedText = 'Listening...';
        });

        // Start VAD monitoring
        _silenceMs = 0;
        _amplitudeSub = _audioRecorder.onAmplitudeChanged(const Duration(milliseconds: 100)).listen((amp) {
          if (amp.current < -35.0) { // Silence threshold
            _silenceMs += 100;
            if (_silenceMs >= 1500 && _isListening) { // 1.5 seconds of silence
              debugPrint('[VAD] Silence detected, auto-stopping recording.');
              _toggleListening();
            }
          } else {
            _silenceMs = 0; // Reset on speech
          }
        });
        
        // Hard cap: stop after 4s no matter what (keeps audio short for fast decode)
        _maxRecordingTimer = Timer(const Duration(seconds: 4), () {
          if (_isListening) {
            debugPrint('[Timer] 4s cap reached, force-stopping recording.');
            _toggleListening();
          }
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Microphone permission required')),
          );
        }
      }
    }
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Language Direction Toggle and Speed Control
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                              fontSize: 16.0,
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
                                  _translatedText = '';
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDFBF7),
                        borderRadius: BorderRadius.circular(30.0),
                        border: Border.all(color: const Color(0xFFE8DECF), width: 1.0),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<double>(
                          value: _playbackSpeed,
                          icon: const Icon(Icons.speed_rounded, color: AppColors.primaryBurgundy),
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                            color: AppColors.textPrimary,
                          ),
                          items: const [
                            DropdownMenuItem(value: 0.75, child: Text('0.75x')),
                            DropdownMenuItem(value: 1.0, child: Text('1.0x')),
                            DropdownMenuItem(value: 1.25, child: Text('1.25x')),
                            DropdownMenuItem(value: 1.5, child: Text('1.5x')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _playbackSpeed = val;
                              });
                              context.read<S2SAudioPlayerService>().setPlaybackSpeed(val);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
              
              // Big Mic Button
              if (_isModelLoading)
                const SizedBox(
                  height: 120.0,
                  width: 120.0,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryBurgundy,
                    ),
                  ),
                )
              else
                GestureDetector(
                  onTap: _toggleListening,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: _isListening ? 140.0 : 120.0,
                    height: _isListening ? 140.0 : 120.0,
                    decoration: BoxDecoration(
                      color: _isListening ? AppColors.primaryBurgundy.withOpacity(0.8) : AppColors.primaryBurgundy,
                      shape: BoxShape.circle,
                      boxShadow: [
                        if (_isListening)
                          BoxShadow(
                            color: AppColors.primaryBurgundy.withOpacity(0.5),
                            blurRadius: 30.0,
                            spreadRadius: 10.0,
                          ),
                        const BoxShadow(
                          color: Color(0x26671D21),
                          blurRadius: 10.0,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                      color: Colors.white,
                      size: 60.0,
                    ),
                  ),
                ),
              
              const SizedBox(height: 60),

              // Full screen translated text
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 500),
                      opacity: _translatedText.isEmpty ? 0.0 : 1.0,
                      child: Text(
                        _translatedText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppTypography.headingFontFamily,
                          fontSize: isTablet ? 64.0 : 42.0,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ),
                ),
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
}
