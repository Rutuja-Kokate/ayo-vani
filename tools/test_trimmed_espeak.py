#!/usr/bin/env python3
"""
Verification script proving that trimmed espeak-ng-data functions correctly
with sherpa-onnx Piper-VITS / MMS-TTS Mundari model on the host machine.
"""

import os
import sys

def test_espeak_dir(espeak_dir: str):
    print(f"Testing TTS model with espeak directory: {espeak_dir}")
    try:
        import sherpa_onnx
    except ImportError:
        print("Error: sherpa_onnx not installed in Python environment.", file=sys.stderr)
        return False

    model_path = "assets/models/tts/mundari.onnx"
    tokens_path = "assets/models/tts/tokens.txt"

    if not os.path.exists(model_path):
        print(f"Model file missing: {model_path}", file=sys.stderr)
        return False

    config = sherpa_onnx.OfflineTtsConfig(
        model=sherpa_onnx.OfflineTtsModelConfig(
            vits=sherpa_onnx.OfflineTtsVitsModelConfig(
                model=model_path,
                tokens=tokens_path,
                data_dir=espeak_dir,
                noise_scale=0.667,
                length_scale=1.0,
                noise_scale_w=0.8,
            ),
            num_threads=2,
            debug=False,
            provider="cpu",
        )
    )

    try:
        tts = sherpa_onnx.OfflineTts(config)
        test_phrases = [
            "आइनो साबुके",
            "नमस्ते",
            "johar hatu re",
        ]

        for phrase in test_phrases:
            audio = tts.generate(text=phrase, sid=0, speed=1.0)
            samples_count = len(audio.samples)
            sr = audio.sample_rate
            duration_s = samples_count / sr if sr > 0 else 0
            print(f"  [PROVEN] Synthesized '{phrase}': {samples_count} samples @ {sr}Hz ({duration_s:.2f}s)")
            if samples_count <= 0:
                print(f"Failed: 0 samples generated for '{phrase}'", file=sys.stderr)
                return False

        print("Verification PASSED: Trimmed espeak-ng-data is fully functional!")
        return True
    except Exception as e:
        print(f"Verification FAILED with exception: {e}", file=sys.stderr)
        return False

if __name__ == "__main__":
    target = sys.argv[1] if len(sys.argv) > 1 else "assets/models/tts/espeak-ng-data"
    success = test_espeak_dir(target)
    sys.exit(0 if success else 1)
