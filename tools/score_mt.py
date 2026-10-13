#!/usr/bin/env python3
"""
Evaluation scoring utility for AYOVAANI Machine Translation (Hindi -> Mundari).
Computes chrF++ (word_order=2) and BLEU metrics from an evaluation CSV.

Usage:
    python3 tool/score_mt.py [path_to_csv]
Default CSV: mt_eval_results.csv
"""

import argparse
import csv
import os
import sys

def main():
    parser = argparse.ArgumentParser(description="Compute chrF++ and BLEU for MT evaluation results.")
    parser.add_argument("csv_path", nargs="?", default="mt_eval_results.csv", help="Path to evaluation CSV")
    args = parser.parse_args()

    if not os.path.exists(args.csv_path):
        print(f"Error: Evaluation CSV not found at '{args.csv_path}'", file=sys.stderr)
        sys.exit(1)

    hindi_list = []
    references = []
    hypotheses = []
    latencies = []
    confidences = []
    truncated_count = 0

    with open(args.csv_path, mode="r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            hindi = row.get("hindi", "").strip()
            ref = row.get("reference", "").strip()
            hyp = row.get("output", "").strip()
            ms_str = row.get("ms", "0").strip()
            trunc_str = row.get("truncated", "false").strip().lower()
            conf_str = row.get("confidence", "").strip()

            if ref and hyp:
                hindi_list.append(hindi)
                references.append(ref)
                hypotheses.append(hyp)
                try:
                    latencies.append(float(ms_str))
                except ValueError:
                    pass
                if trunc_str in ("true", "1"):
                    truncated_count += 1
                try:
                    if conf_str and conf_str != "null":
                        confidences.append(float(conf_str))
                except ValueError:
                    pass

    n = len(hypotheses)
    print("=" * 60)
    print(f"AYOVAANI MT EVALUATION SUMMARY ({n} sentences evaluated)")
    print("=" * 60)

    if n == 0:
        print("No valid reference-output pairs found in CSV.")
        sys.exit(0)

    try:
        import sacrebleu

        # Compute BLEU
        bleu = sacrebleu.corpus_bleu(hypotheses, [references])
        print(f"BLEU:      {bleu.score:.2f}")

        # Compute chrF++ (word_order=2)
        chrf = sacrebleu.corpus_chrf(hypotheses, [references], word_order=2)
        print(f"chrF++:    {chrf.score:.2f}")
    except ImportError:
        print("WARNING: sacrebleu package not found. Install via 'pip install sacrebleu'")

    if latencies:
        avg_ms = sum(latencies) / len(latencies)
        sorted_latencies = sorted(latencies)
        p50_ms = sorted_latencies[int(len(latencies) * 0.50)]
        p95_ms = sorted_latencies[min(int(len(latencies) * 0.95), len(latencies) - 1)]
        print(f"Latency:   Mean={avg_ms:.1f}ms | P50={p50_ms:.1f}ms | P95={p95_ms:.1f}ms")

    if confidences:
        avg_conf = sum(confidences) / len(confidences)
        print(f"Confidence (exp(mean_logprob)): Mean={avg_conf:.4f} (across {len(confidences)} items)")
    else:
        print("Confidence: None reported (decoder argmax log-probs not available in inference session)")

    print(f"Truncated: {truncated_count} / {n} ({truncated_count / n * 100:.1f}%)")
    print("=" * 60)

if __name__ == "__main__":
    main()
