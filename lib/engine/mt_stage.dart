import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:dart_sentencepiece_tokenizer/dart_sentencepiece_tokenizer.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:onnxruntime/onnxruntime.dart';
import 'package:path_provider/path_provider.dart';

import 'pipeline.dart' show kDefaultMtThreads, TranslationDirection;
import 'tts_text_frontend.dart';

/// Exception thrown when Machine Translation fails or required models are missing.
class MtException implements Exception {
  final String message;
  const MtException(this.message);

  @override
  String toString() => 'MtException: $message';
}

/// Result of Machine Translation stage.
class MtResult {
  final String displayText;
  final String synthesizeText;
  final double? confidence;
  final bool truncated;

  const MtResult({
    required this.displayText,
    required this.synthesizeText,
    this.confidence,
    this.truncated = false,
  });
}

/// Contract that every MT implementation must satisfy.
abstract class MtStage {
  /// Initialises the MT model.
  Future<void> initModel();

  /// Translate [text] in [direction] and return the target-language text.
  ///
  /// Implementations must be async-safe and must NOT perform UI work.
  Future<MtResult> translate(String text, {TranslationDirection direction = TranslationDirection.hindiToMundari});

  /// Releases resources held by the MT stage.
  void dispose();
}

/// High-performance on-device IndicTrans2 bidirectional Machine Translation implementation.
class RealMtStage implements MtStage {
  final int threads;
  final int maxDecodeTokens;
  final bool collapseAdjacentDuplicates;

  RealMtStage({
    this.threads = kDefaultMtThreads,
    this.maxDecodeTokens = 48,
    this.collapseAdjacentDuplicates = false,
  });

  SentencePieceTokenizer? _tokenizer;
  OrtSessionOptions? _sessionOptions;
  OrtSession? _encoderSession;
  OrtSession? _decoderSession;
  Int32List? _tgtRemapTable;
  Map<String, int> _srcDict = {};

  static const String _spmAsset = 'assets/models/mt/spm.model';
  static const String _srcDictAsset = 'assets/models/mt/dict.SRC.json';
  static const String _encoderAsset = 'assets/models/mt/model_int8.onnx';
  static const String _decoderAsset = 'assets/models/mt/decoder_model_int8_argmax.onnx';
  static const String _remapTableAsset = 'assets/models/mt/tgt_remap_table.bin';

  @override
  Future<void> initModel() async {
    OrtEnv.instance.init();

    _sessionOptions = OrtSessionOptions()
      ..setInterOpNumThreads(1)
      ..setIntraOpNumThreads(threads)
      ..setSessionGraphOptimizationLevel(GraphOptimizationLevel.ortEnableAll);

    dev.log('[RealMtStage] Configured ONNX Runtime with $threads intra-op threads');

    dev.log('[RealMtStage] Loading SentencePiece tokenizer...');
    final spmData = await rootBundle.load(_spmAsset);
    final spmBytes = spmData.buffer.asUint8List(spmData.offsetInBytes, spmData.lengthInBytes);
    _tokenizer = SentencePieceTokenizer.fromBytes(spmBytes);

    try {
      dev.log('[RealMtStage] Loading source dictionary (dict.SRC.json)...');
      final srcDictJson = await rootBundle.loadString(_srcDictAsset);
      final Map<String, dynamic> rawMap = json.decode(srcDictJson);
      _srcDict = rawMap.map((key, value) => MapEntry(key, value as int));
      dev.log('[RealMtStage] Source dictionary loaded with ${_srcDict.length} entries.');
    } catch (e) {
      dev.log('[RealMtStage] Source dictionary loading failed: $e');
    }

    try {
      dev.log('[RealMtStage] Loading target remap table...');
      final remapData = await rootBundle.load(_remapTableAsset);
      _tgtRemapTable = remapData.buffer.asInt32List(remapData.offsetInBytes, remapData.lengthInBytes ~/ 4);
      dev.log('[RealMtStage] Remap table loaded with ${_tgtRemapTable!.length} entries.');
    } catch (e) {
      dev.log('[RealMtStage] Remap table loading failed: $e');
    }

    Future<OrtSession?> loadSession(String assetKey) async {
      try {
        final dir = await getApplicationSupportDirectory();
        final mtDir = Directory('${dir.path}/mt');
        if (!await mtDir.exists()) await mtDir.create(recursive: true);

        final filename = assetKey.split('/').last;
        final destFile = File('${mtDir.path}/$filename');
        final assetData = await rootBundle.load(assetKey);
        final assetLength = assetData.lengthInBytes;

        if (await destFile.exists()) {
          final destLength = await destFile.length();
          if (destLength == assetLength) {
            dev.log('[RealMtStage] Loading cached $filename (${destLength ~/ 1024} KB)...');
            return OrtSession.fromFile(destFile, _sessionOptions!);
          }
        }

        dev.log('[RealMtStage] Copying $assetKey to application support file: ${destFile.path}...');
        final bytes = assetData.buffer.asUint8List(assetData.offsetInBytes, assetData.lengthInBytes);
        await destFile.writeAsBytes(bytes, flush: true);

        return OrtSession.fromFile(destFile, _sessionOptions!);
      } catch (e) {
        dev.log('[RealMtStage] Session $assetKey failed to load: $e');
        return null;
      }
    }

    _encoderSession = await loadSession(_encoderAsset);
    _decoderSession = await loadSession(_decoderAsset);

    dev.log('[RealMtStage] Models initialization finished.');
  }

  void release() {
    _encoderSession?.release();
    _decoderSession?.release();
    _sessionOptions?.release();
  }

  bool get isInitialized =>
      _tokenizer != null &&
      _encoderSession != null &&
      _decoderSession != null &&
      _tgtRemapTable != null;

  @override
  Future<MtResult> translate(
    String text, {
    TranslationDirection direction = TranslationDirection.hindiToMundari,
  }) async {
    if (_tokenizer == null ||
        _encoderSession == null ||
        _decoderSession == null ||
        _tgtRemapTable == null) {
      throw const MtException(
        'MT stage sessions, tokenizer, or target remap table are not loaded.',
      );
    }

    dev.log('===================== [MT STAGE START] =====================');
    dev.log('[MT-Input] (${direction.label}) text: "$text"');

    // -- 0. Tokenize (Dart SentencePiece + dict.SRC.json mapping) --
    final tokStart = DateTime.now();
    final encoding = _tokenizer!.encode(text, addSpecialTokens: false);
    final pieces = encoding.tokens;
    final List<int> mappedDictIds = pieces.map((p) => _srcDict[p] ?? 3).toList(); // 3 is <unk>
    final tokMs = DateTime.now().difference(tokStart).inMilliseconds;

    // IndicTrans2 input sequence format: [src_lang_id, tgt_lang_id, ...dictIds, eos_id]
    const int hinDevaId = 8;
    const int munDevaId = 122706;
    const int eosId = 2;
    final int srcId = direction == TranslationDirection.mundariToHindi ? munDevaId : hinDevaId;
    final int tgtId = direction == TranslationDirection.mundariToHindi ? hinDevaId : munDevaId;
    final List<int> fullInputIds = [srcId, tgtId, ...mappedDictIds, eosId];

    dev.log('[MT-Stage 0] Tokenized in ${tokMs}ms (${fullInputIds.length} tokens): $fullInputIds');

    // -- 1. Encoder --
    final encStart = DateTime.now();
    final encoderRunOptions = OrtRunOptions();
    final Int64List inputIdsData = Int64List.fromList(fullInputIds);
    final Int64List maskData = Int64List.fromList(List.filled(fullInputIds.length, 1));

    final encoderInputTensor = OrtValueTensor.createTensorWithDataList(inputIdsData, [1, fullInputIds.length]);
    final encoderMaskTensor = OrtValueTensor.createTensorWithDataList(maskData, [1, fullInputIds.length]);

    final Map<String, OrtValue> encInputs = {
      'input_ids': encoderInputTensor,
      'attention_mask': encoderMaskTensor,
    };
    final encOutputs = _encoderSession!.run(encoderRunOptions, encInputs);

    final encoderHiddenStatesValue = encOutputs[0]!;
    final hiddenStatesNested = encoderHiddenStatesValue.value as List<List<List<double>>>;
    final int srcLen = hiddenStatesNested[0].length;
    final int hiddenDim = hiddenStatesNested[0][0].length;

    encoderInputTensor.release();
    encoderMaskTensor.release();
    encoderRunOptions.release();
    for (int i = 1; i < encOutputs.length; i++) {
      encOutputs[i]?.release();
    }

    final encMs = DateTime.now().difference(encStart).inMilliseconds;
    dev.log('[MT-Stage 1] Encoder complete in ${encMs}ms (shape: [1, $srcLen, $hiddenDim])');

    // -- 2. Decoder Loop --
    final decStart = DateTime.now();
    const int bosToken = 2;
    const int eosToken = 2;

    // Note: The decoder has no KV-cache so latency grows quadratically with decoded length.
    final int maxLen = math.min(maxDecodeTokens, srcLen * 2 + 8);

    List<int> decoderInputIds = [bosToken];
    final encoderMaskData = Int64List.fromList(List.filled(srcLen, 1));
    final maskTensor = OrtValueTensor.createTensorWithDataList(encoderMaskData, [1, srcLen]);

    bool hitEos = false;
    final List<double> stepLogprobs = [];

    for (int i = 0; i < maxLen; i++) {
      final stepStart = DateTime.now();
      final decRunOptions = OrtRunOptions();
      final inputIdsTensor = OrtValueTensor.createTensorWithDataList(
        Int64List.fromList(decoderInputIds),
        [1, decoderInputIds.length],
      );

      final Map<String, OrtValue> decInputs = {
        'decoder_input_ids': inputIdsTensor,
        'encoder_hidden_states': encoderHiddenStatesValue,
        'encoder_attention_mask': maskTensor,
      };

      final decOutputs = _decoderSession!.run(decRunOptions, decInputs);
      final rawVal = decOutputs[0]!.value;
      final int nextToken;
      if (rawVal is List && rawVal.isNotEmpty) {
        final firstRow = rawVal[0];
        if (firstRow is List && firstRow.isNotEmpty) {
          nextToken = (firstRow[0] as num).toInt();
        } else {
          nextToken = (firstRow as num).toInt();
        }
      } else {
        nextToken = (rawVal as num).toInt();
      }

      // If decoder session exposes a second output (max_logprob), collect it
      if (decOutputs.length > 1 && decOutputs[1] != null) {
        final rawLogprob = decOutputs[1]!.value;
        if (rawLogprob is List && rawLogprob.isNotEmpty) {
          final firstRow = rawLogprob[0];
          if (firstRow is List && firstRow.isNotEmpty) {
            stepLogprobs.add((firstRow[0] as num).toDouble());
          } else if (firstRow is num) {
            stepLogprobs.add(firstRow.toDouble());
          }
        } else if (rawLogprob is num) {
          stepLogprobs.add(rawLogprob.toDouble());
        }
      }

      decoderInputIds.add(nextToken);
      final stepMs = DateTime.now().difference(stepStart).inMilliseconds;
      dev.log('[MT-Decoder-Step] step $i -> token $nextToken (${stepMs}ms)');

      inputIdsTensor.release();
      decRunOptions.release();
      for (final o in decOutputs) {
        o?.release();
      }

      if (nextToken == eosToken) {
        dev.log('[MT-Decoder-Stop] Stopped on EOS token ($eosToken) at step $i');
        hitEos = true;
        break;
      }

      // Repetition cycle detection (prevents infinite loops on non-canonical text/noise)
      final n = decoderInputIds.length;
      if (n >= 4 &&
          decoderInputIds[n - 1] == decoderInputIds[n - 2] &&
          decoderInputIds[n - 2] == decoderInputIds[n - 3]) {
        dev.log('[MT-Decoder-Stop] Stopped due to 1-gram repetition at step $i');
        break;
      }
      if (n >= 6 &&
          decoderInputIds[n - 1] == decoderInputIds[n - 3] &&
          decoderInputIds[n - 3] == decoderInputIds[n - 5] &&
          decoderInputIds[n - 2] == decoderInputIds[n - 4] &&
          decoderInputIds[n - 4] == decoderInputIds[n - 6]) {
        dev.log('[MT-Decoder-Stop] Stopped due to 2-gram cycle repetition at step $i');
        break;
      }
      if (n >= 9 &&
          decoderInputIds[n - 1] == decoderInputIds[n - 4] &&
          decoderInputIds[n - 4] == decoderInputIds[n - 7] &&
          decoderInputIds[n - 2] == decoderInputIds[n - 5] &&
          decoderInputIds[n - 5] == decoderInputIds[n - 8]) {
        dev.log('[MT-Decoder-Stop] Stopped due to 3-gram cycle repetition at step $i');
        break;
      }

      if (i == maxLen - 1) {
        dev.log('[MT-Decoder-Stop] Reached max length cap ($maxLen)');
      }
    }

    final bool isTruncated = !hitEos;

    encoderHiddenStatesValue.release();
    maskTensor.release();

    final decMs = DateTime.now().difference(decStart).inMilliseconds;
    dev.log('[MT-Stage 2] Decoder complete in ${decMs}ms: $decoderInputIds (truncated: $isTruncated)');

    // -- 3. Detokenizer (Remap via tgt_remap_table & Native Dart SPM Decode) --
    final detokStart = DateTime.now();

    // Drop BOS (and trailing EOS if present)
    List<int> rawTokens = decoderInputIds.sublist(1);
    if (rawTokens.isNotEmpty && rawTokens.last == eosToken) {
      rawTokens = rawTokens.sublist(0, rawTokens.length - 1);
    }

    // Remap: filter special tokens (<= 3) and map into true SentencePiece piece IDs
    final List<int> spmPieceIds = [];
    for (final id in rawTokens) {
      if (id > 3 && id < _tgtRemapTable!.length) {
        spmPieceIds.add(_tgtRemapTable![id]);
      }
    }

    // Native Dart decode on correctly mapped SentencePiece piece IDs
    String devaText = _tokenizer!.decode(spmPieceIds);

    // Optional collapse of adjacent duplicate words (opt-in via flag)
    if (collapseAdjacentDuplicates) {
      devaText = devaText.replaceAll(RegExp(r'\b(\S+)\s*(?:,\s*)?\1\b'), r'$1');
    }

    final detokMs = DateTime.now().difference(detokStart).inMilliseconds;
    dev.log('[MT-Stage 3] Decoded Devanagari text in ${detokMs}ms: "$devaText"');
    dev.log('===================== [MT STAGE END] =====================');

    final String synthText = prepareTtsText(devaText);

    // If second output was present, calculate sequence confidence as exp(mean(logprob))
    double? confidence;
    if (stepLogprobs.isNotEmpty) {
      final meanLogprob =
          stepLogprobs.reduce((a, b) => a + b) / stepLogprobs.length;
      confidence = math.exp(meanLogprob).clamp(0.0, 1.0);
    }

    return MtResult(
      displayText: devaText,
      synthesizeText: synthText,
      confidence: confidence,
      truncated: isTruncated,
    );
  }

  @override
  void dispose() {
    _encoderSession?.release();
    _decoderSession?.release();
    _sessionOptions?.release();
    _encoderSession = null;
    _decoderSession = null;
    _sessionOptions = null;
  }
}
