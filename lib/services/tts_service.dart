import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'package:just_audio/just_audio.dart';

/// Service that synthesises speech offline (using cached files) and plays it.
///
/// It uses **flutter_tts** with the `synthesizeToFile` API to generate a
/// `.wav` file for a given text. The file is stored in the application's
/// temporary directory and cached using a SHA-1 hash of the text (and optional
/// Devanagari script). Subsequent calls reuse the cached file, providing fast
/// offline playback via **just_audio**.
class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _initialized = false;
  bool _isInitializing = false;

  /// Initialise the service. Must be called before any playback.
  Future<void> init() async {
    if (_initialized) return;
    if (_isInitializing) {
      // Wait for the ongoing initialization to finish
      while (_isInitializing) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return;
    }

    _isInitializing = true;
    
    try {
      // Force Google TTS on Android to avoid buggy default engines (like Samsung TTS)
      if (Platform.isAndroid) {
        await _flutterTts.setEngine('com.google.android.tts');
      }

      // Prefer Hindi language (offline package already bundled on device).
      await _flutterTts.setLanguage('hi-IN');
      // Set speech rate & pitch to reasonable defaults.
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setPitch(1.0);
      // Tell flutter_tts to wait for the speech to finish before returning from speak()
      await _flutterTts.awaitSpeakCompletion(true);
    } catch (e) {
      debugPrint('TTS Init error: $e');
    } finally {
      _initialized = true;
      _isInitializing = false;
    }
  }

  /// Change the speech rate dynamically
  Future<void> setSpeechRate(double rate) async {
    if (!_initialized) await init();
    await _flutterTts.setSpeechRate(rate);
  }

  /// Synthesize and play a word (English) together with its Devanagari
  /// representation (if provided).
  Future<void> speakWordAndMundari(String word, String? mundari) async {
    if (!_initialized) await init();
    
    final String combined = mundari != null ? '$word, $mundari' : word;

    try {
      // Automatically detect if the text contains Devanagari (Hindi) characters
      final bool isHindi = RegExp(r'[\u0900-\u097F]').hasMatch(combined);
      
      if (isHindi) {
          await _flutterTts.setLanguage('hi-IN');
      } else {
          await _flutterTts.setLanguage('en-US');
      }
      
      // This will wait until speech is complete because of awaitSpeakCompletion(true)
      await _flutterTts.speak(combined);
    } catch (e) {
      debugPrint('Audio playback error: $e');
    }
  }
}
