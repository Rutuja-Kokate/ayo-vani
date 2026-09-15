import 'dart:io';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;

/// Service that runs the local Hindi CTC-ONNX model on-device.
/// Model: Conformer/CTC, inputs: 80-dim mel-spectrogram, outputs: log_probs over 5633 tokens.
class HindiSttService {
  static final HindiSttService _instance = HindiSttService._internal();
  factory HindiSttService() => _instance;
  HindiSttService._internal();

  bool _isInitialized = false;
  String? _modelPath;
  String? _tokensPath;
  
  SendPort? _isolateCommandPort;

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      debugPrint('[STT] Initializing Hindi CTC recognizer...');

      // sherpa_onnx requires real filesystem paths, not asset:// URIs.
      final appDir = await getApplicationDocumentsDirectory();
      final modelDir = Directory('${appDir.path}/stt_model');
      await modelDir.create(recursive: true);

      final modelPath = '${modelDir.path}/model.int8.onnx';
      final tokensPath = '${modelDir.path}/tokens.txt';

      // For dev: model can be pre-pushed via ADB to /data/local/tmp/
      // to avoid re-extracting from assets on every hot restart.
      const adbModelPath = '/data/local/tmp/model.int8.onnx';
      const adbTokensPath = '/data/local/tmp/tokens.txt';

      if (!File(modelPath).existsSync()) {
        if (File(adbModelPath).existsSync()) {
          debugPrint('[STT] Using ADB-pushed model...');
          await File(adbModelPath).copy(modelPath);
        } else {
          debugPrint('[STT] Extracting model from assets (first run, ~30s)...');
          await _copyAssetToFile('assets/models/model.int8.onnx', modelPath);
        }
        debugPrint('[STT] Model ready ✓');
      }

      if (!File(tokensPath).existsSync()) {
        if (File(adbTokensPath).existsSync()) {
          await File(adbTokensPath).copy(tokensPath);
        } else {
          await _copyAssetToFile('assets/models/tokens.txt', tokensPath);
        }
        debugPrint('[STT] Tokens ready ✓');
      }

      _modelPath = modelPath;
      _tokensPath = tokensPath;
      
      // Start persistent background worker isolate
      debugPrint('[STT] Spawning background isolate...');
      final initPort = ReceivePort();
      await Isolate.spawn(_isolateWorker, [initPort.sendPort, _modelPath!, _tokensPath!]);
      
      // Wait for the worker to send back its command port
      _isolateCommandPort = await initPort.first as SendPort;
      
      _isInitialized = true;
      debugPrint('[STT] Hindi recognizer isolate ready ✓');
    } catch (e, st) {
      debugPrint('[STT] Initialization error: $e\n$st');
      // Don't rethrow — app still works with fallback (cache miss shows empty)
    }
  }

  /// Copies a Flutter asset to a real file path on disk.
  Future<void> _copyAssetToFile(String assetPath, String destPath) async {
    final data = await rootBundle.load(assetPath);
    final bytes = data.buffer.asUint8List();
    await File(destPath).writeAsBytes(bytes, flush: true);
  }

  /// Transcribes a WAV audio file to Hindi Devanagari text.
  /// [wavPath] must be a 16kHz mono WAV file path on the device filesystem.
  Future<String> transcribe(String wavPath) async {
    if (!_isInitialized || _isolateCommandPort == null) {
      debugPrint('[STT] Recognizer isolate not ready, returning empty');
      return '';
    }

    try {
      // Send job to persistent isolate and wait for reply
      final responsePort = ReceivePort();
      _isolateCommandPort!.send([responsePort.sendPort, wavPath]);
      
      final text = await responsePort.first as String;
      debugPrint('[STT] Transcribed: "$text"');
      return text;
    } catch (e) {
      debugPrint('[STT] Transcription error: $e');
      return '';
    }
  }

  /// Persistent background isolate worker. 
  /// Loads the model once into memory and handles subsequent requests.
  static void _isolateWorker(List<dynamic> args) {
    final SendPort initReplyPort = args[0];
    final String modelPath = args[1];
    final String tokensPath = args[2];

    debugPrint('[STT Worker] Booting up...');
    
    // Initialize native bindings in the new isolate
    sherpa.initBindings();

    final modelConfig = sherpa.OfflineNemoEncDecCtcModelConfig(model: modelPath);
    final config = sherpa.OfflineRecognizerConfig(
      model: sherpa.OfflineModelConfig(
        nemoCtc: modelConfig,
        tokens: tokensPath,
        debug: false,
        numThreads: 2, // 2 threads balances performance vs UI responsiveness
      ),
      decodingMethod: 'greedy_search',
    );

    final recognizer = sherpa.OfflineRecognizer(config);
    final commandPort = ReceivePort();
    
    // Reply back with our command port so main thread can send us tasks
    initReplyPort.send(commandPort.sendPort);
    debugPrint('[STT Worker] Model loaded, listening for tasks.');

    // Listen forever for audio transcription jobs
    commandPort.listen((message) {
      if (message is List) {
        final SendPort replyTo = message[0];
        final String wavPath = message[1];
        
        try {
          final stopwatch = Stopwatch()..start();
          
          final stream = recognizer.createStream();
          final wave = sherpa.readWave(wavPath);
          debugPrint('[STT Worker] readWave took ${stopwatch.elapsedMilliseconds}ms');
          
          stream.acceptWaveform(samples: wave.samples, sampleRate: wave.sampleRate);
          final acceptTime = stopwatch.elapsedMilliseconds;
          debugPrint('[STT Worker] acceptWaveform took ${acceptTime}ms');
          
          recognizer.decode(stream);
          final decodeTime = stopwatch.elapsedMilliseconds;
          debugPrint('[STT Worker] decode took ${decodeTime - acceptTime}ms');

          final result = recognizer.getResult(stream);
          stream.free();
          
          stopwatch.stop();
          debugPrint('[STT Worker] Total processing took ${stopwatch.elapsedMilliseconds}ms. Result: "${result.text}"');
          
          replyTo.send(result.text.trim());
        } catch (e) {
          debugPrint('[STT Worker] Error: $e');
          replyTo.send(''); // Send empty on failure to unblock UI
        }
      }
    });
  }

  void dispose() {
    _isInitialized = false;
    _isolateCommandPort = null;
  }
}
