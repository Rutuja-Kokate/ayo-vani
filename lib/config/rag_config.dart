/// RAG Pipeline Configuration for Ayo-Vani.
///
/// ⚠️  IMPORTANT: Add `lib/config/rag_config.dart` to your .gitignore
/// before committing. This file contains your API key.
library;

/// Your Google Gemini API key.
/// Get one at: https://aistudio.google.com/app/apikey
const String kGeminiApiKey = 'AIzaSyDXw8e5_bsMdl0Ipnz2W-R68-WXrFj2gMs';

/// Gemini model to use for content generation.
const String kGeminiModel = 'gemini-2.5-flash';

/// Your fine-tuned Mundari MT endpoint URL.
/// Leave empty ('') to use MockMTService (prefixes [MUNDARI] for testing).
const String kMtEndpointUrl = '';
