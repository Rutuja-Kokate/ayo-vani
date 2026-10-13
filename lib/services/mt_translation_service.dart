import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:ayo_vani/engine/loanwords.dart';
import 'package:ayo_vani/engine/mt_stage.dart';
import 'package:ayo_vani/engine/pipeline.dart'
    show kDefaultMtThreads, TranslationDirection;

/// Origin of a translation result.
enum MtResultSource {
  glossary,
  nmt,
}

/// Represents the output of a machine translation request.
class MtTranslationResult {
  final String text;
  final MtResultSource source;
  final double? confidence;

  const MtTranslationResult({
    required this.text,
    required this.source,
    this.confidence,
  });

  @override
  String toString() =>
      'MtTranslationResult(text: "$text", source: $source, confidence: $confidence)';

  Map<String, dynamic> toJson() => {
        'text': text,
        'source': source.name,
        if (confidence != null) 'confidence': confidence,
      };
}

/// Typed exception thrown when attempting MT translation while the live speech pipeline is active.
class MtLivePipelineActiveException implements Exception {
  final String message;
  const MtLivePipelineActiveException([
    this.message =
        'Cannot run MT translation while the live speech pipeline is active.',
  ]);

  @override
  String toString() => 'MtLivePipelineActiveException: $message';
}

/// Service managing on-device MT (Machine Translation) Hindi -> Mundari.
/// Acts as a thin adapter over [RealMtStage] with single-word curated glossary overrides,
/// English loanword protection ({ENG:term}), and live-pipeline concurrency safety.
class MtTranslationService {
  static final MtTranslationService instance =
      MtTranslationService._internal();
  factory MtTranslationService() => instance;

  final MtStage _mtStage;
  bool _isModelLoaded = false;
  bool _isTranslating = false;

  /// Global flag set by [SpeechPipeline] while live streaming pipeline is running.
  static bool isLivePipelineActive = false;

  MtTranslationService._internal({MtStage? mtStage})
      : _mtStage = mtStage ?? RealMtStage(threads: kDefaultMtThreads);

  /// Visible for testing to inject mock MT stages.
  @visibleForTesting
  MtTranslationService.withStage(MtStage mtStage) : _mtStage = mtStage;

  bool get isModelLoaded => _isModelLoaded;

  /// Small curated glossary of body parts and classroom words.
  /// Used EXCLUSIVELY as an explicit lexicon override for SINGLE-WORD inputs.
  static const Map<String, String> curatedGlossary = {
    // English body parts
    'feet': 'कटा',
    'foot': 'कटा',
    'leg': 'कटा',
    'legs': 'कटा',
    'hand': 'तिः',
    'hands': 'तिः',
    'arm': 'कीड़ी',
    'arms': 'कीड़ी',
    'head': 'बोहः',
    'eye': 'मेडः',
    'eyes': 'मेडः',
    'ear': 'लुतुर',
    'ears': 'लुतुर',
    'nose': 'मुं',
    'mouth': 'चाबे',
    'skin': 'उरु',
    'shoulder': 'तारन',
    'knee': 'मुकुनी',
    'knees': 'मुकुनी',
    'toe': 'दारो',
    'toes': 'दारो',
    'cheek': 'जोबा',
    'cheeks': 'जोबा',
    'tongue': 'आलांग',
    // Hindi body parts
    'पैर': 'कटा',
    'हाथ': 'तिः',
    'सिर': 'बोहः',
    'आँख': 'मेडः',
    'आंख': 'मेडः',
    'कान': 'लुतुर',
    'नाक': 'मुं',
    'मुँह': 'चाबे',
    'मुंह': 'चाबे',
    'त्वचा': 'उरु',
    'कंधा': 'तारन',
    'घुटना': 'मुकुनी',
    'गाल': 'जोबा',
    'जीभ': 'आलांग',
    // Classroom words
    'किताब': 'पुथी',
    'book': 'पुथी',
    'कलम': 'कलम',
    'स्कूल': 'स्कूल',
    'school': 'स्कूल',
    'कक्षा': 'श्रेणी',
    'class': 'श्रेणी',
    'शिक्षक': 'मास्तर',
    'teacher': 'मास्तर',
  };

  /// Explicitly initializes the resident [RealMtStage] if not already loaded.
  Future<void> loadModel() async {
    if (_isModelLoaded) return;
    await _mtStage.initModel();
    _isModelLoaded = true;
  }

  /// Explicitly unloads the resident [RealMtStage] ONLY under memory pressure.
  /// Never called automatically per batch.
  Future<void> unloadModel() async {
    if (!_isModelLoaded) return;
    _mtStage.dispose();
    _isModelLoaded = false;
  }

  /// Translates a single text sentence, checking single-word glossary overrides and
  /// protected {ENG:term} loanwords.
  Future<MtTranslationResult> translateSentence(String text) async {
    if (isLivePipelineActive) {
      throw const MtLivePipelineActiveException();
    }
    if (_isTranslating) {
      throw StateError(
          'Another MT translation is already in progress.');
    }
    _isTranslating = true;
    try {
      return await _translateSentenceInternal(text);
    } finally {
      _isTranslating = false;
    }
  }

  Future<MtTranslationResult> _translateSentenceInternal(String text) async {
    final clean = text.trim();
    if (clean.isEmpty) {
      return const MtTranslationResult(
        text: '',
        source: MtResultSource.nmt,
        confidence: 1.0,
      );
    }

    // 1. Guard against concurrency with active live speech pipeline
    if (isLivePipelineActive) {
      throw const MtLivePipelineActiveException();
    }

    // 2. Explicit lexicon override for SINGLE-WORD inputs only
    final isSingleWord = !clean.contains(RegExp(r'\s+'));
    if (isSingleWord) {
      final lower = clean.toLowerCase();
      final override = curatedGlossary[lower] ?? curatedGlossary[clean];
      if (override != null) {
        return MtTranslationResult(
          text: override,
          source: MtResultSource.glossary,
          confidence: 1.0,
        );
      }
    }

    // Ensure model is loaded
    await loadModel();

    // 3. Loanword protection: check for {ENG:term} markers
    final engPattern = RegExp(r'\{ENG:([^}]+)\}');
    final matches = engPattern.allMatches(text).toList();

    if (matches.isEmpty) {
      // Standard NMT translation
      final result = await _mtStage.translate(
        clean,
        direction: TranslationDirection.hindiToMundari,
      );
      return MtTranslationResult(
        text: result.displayText,
        source: MtResultSource.nmt,
        confidence: result.confidence,
      );
    }

    // 4. Split around {ENG:term} markers, translate non-loanword segments,
    // and join with Devanagari transliteration of loanword.
    final chunks = <String>[];
    int lastIndex = 0;

    for (final match in matches) {
      final preSegment = text.substring(lastIndex, match.start);
      if (preSegment.isNotEmpty) {
        if (preSegment.trim().isEmpty) {
          chunks.add(preSegment);
        } else {
          final leading = preSegment.substring(
              0, preSegment.length - preSegment.trimLeft().length);
          final trailing =
              preSegment.substring(preSegment.trimRight().length);
          final res = await _mtStage.translate(
            preSegment.trim(),
            direction: TranslationDirection.hindiToMundari,
          );
          chunks.add('$leading${res.displayText}$trailing');
        }
      }

      final term = match.group(1)!;
      final devanagariTerm = getLoanwordDevanagari(term);
      chunks.add(devanagariTerm);
      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      final tailSegment = text.substring(lastIndex);
      if (tailSegment.isNotEmpty) {
        if (tailSegment.trim().isEmpty) {
          chunks.add(tailSegment);
        } else {
          final leading = tailSegment.substring(
              0, tailSegment.length - tailSegment.trimLeft().length);
          final trailing =
              tailSegment.substring(tailSegment.trimRight().length);
          final res = await _mtStage.translate(
            tailSegment.trim(),
            direction: TranslationDirection.hindiToMundari,
          );
          chunks.add('$leading${res.displayText}$trailing');
        }
      }
    }

    return MtTranslationResult(
      text: chunks.join(),
      source: MtResultSource.nmt,
      confidence: 0.9,
    );
  }

  /// Translates a batch of texts sequentially without unloading/reloading models.
  Future<List<MtTranslationResult>> translateBatch(List<String> texts) async {
    if (texts.isEmpty) return [];

    if (isLivePipelineActive) {
      throw const MtLivePipelineActiveException();
    }

    if (_isTranslating) {
      throw StateError(
          'Another MT translation batch is already in progress.');
    }

    _isTranslating = true;
    try {
      await loadModel();
      final results = <MtTranslationResult>[];
      for (final text in texts) {
        final res = await _translateSentenceInternal(text);
        results.add(res);
      }
      return results;
    } finally {
      _isTranslating = false;
    }
  }

  /// Translates a single text and returns raw translated String.
  Future<String> translateToMundari(String text) async {
    final result = await translateSentence(text);
    return result.text;
  }
}
