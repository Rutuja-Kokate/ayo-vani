/// Configuration for Ayo-Vani external services and RAG.
///
/// Secrets are injected at build/run time via `--dart-define`, never hardcoded.
///
/// ⚠️ This file must NOT contain real API keys or secrets.
library;

/// Gemini API key, injected at compile/run time via `--dart-define=GEMINI_API_KEY=<key>`.
const String kGeminiApiKey = String.fromEnvironment('GEMINI_API_KEY');

/// Gemini model to use for content generation.
const String kGeminiModel = String.fromEnvironment(
  'GEMINI_MODEL',
  defaultValue: 'gemini-2.5-flash',
);

/// Backend base URL injected at compile/run time via `--dart-define=BACKEND_BASE_URL=<url>`.
const String kBackendBaseUrl = String.fromEnvironment(
  'BACKEND_BASE_URL',
  defaultValue: '',
);

/// Returns true if a valid Gemini API key is configured.
bool get hasGeminiKey => kGeminiApiKey.isNotEmpty;

/// Typed exception thrown when a feature requires the Gemini API key but none is configured.
class MissingApiKeyException implements Exception {
  final String message;

  const MissingApiKeyException([
    this.message =
        'Gemini API key is required but missing. Pass --dart-define=GEMINI_API_KEY=<key> at runtime.',
  ]);

  @override
  String toString() => 'MissingApiKeyException: $message';
}
