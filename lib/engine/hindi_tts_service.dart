import 'dart:developer' as dev;
import 'package:flutter_tts/flutter_tts.dart';

/// On-device Hindi Text-to-Speech service using flutter_tts.
///
/// Ensures sequential, complete clause speech with awaitSpeakCompletion(true)
/// to avoid QUEUE_FLUSH cutoffs and premature completion returns.
class HindiTtsService {
  static final HindiTtsService instance = HindiTtsService._();
  HindiTtsService._();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Initializes flutter_tts configured for Hindi (hi-IN).
  Future<bool> init() async {
    if (_isInitialized) return true;

    try {
      await _flutterTts.setLanguage('hi-IN');
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setPitch(1.0);
      await _flutterTts.awaitSpeakCompletion(true);
      _isInitialized = true;
      dev.log('[HindiTtsService] Successfully initialized flutter_tts for hi-IN');
      return true;
    } catch (e) {
      dev.log('[HindiTtsService] Failed to initialize flutter_tts: $e');
      _isInitialized = false;
      return false;
    }
  }

  /// Speaks the given Hindi [text], waiting for playback to finish before returning.
  Future<bool> speak(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return true;

    if (!_isInitialized) {
      final ok = await init();
      if (!ok) return false;
    }

    try {
      final result = await _flutterTts.speak(trimmed);
      return result == 1;
    } catch (e) {
      dev.log('[HindiTtsService] Error speaking Hindi text: $e');
      return false;
    }
  }

  /// Speaks a sequence of [clauses] one after another, ensuring no clause is cut off.
  Future<bool> speakClauses(List<String> clauses) async {
    if (!_isInitialized) {
      final ok = await init();
      if (!ok) return false;
    }

    for (final clause in clauses) {
      final trimmed = clause.trim();
      if (trimmed.isEmpty) continue;
      final ok = await speak(trimmed);
      if (!ok) return false;
    }
    return true;
  }

  /// Stops ongoing speech playback immediately.
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      dev.log('[HindiTtsService] Error stopping TTS: $e');
    }
  }
}
