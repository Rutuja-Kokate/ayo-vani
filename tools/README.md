# ONNX MT Decoder Graph Modification Tools

This directory contains tooling for post-processing the IndicTrans2 ONNX decoder graph to output both the greedy token ID and its token-level log-probability for confidence computation.

## `add_argmax_to_decoder.py`

Appends:
1. `Gather` for the last timestep: `[batch_size, -1, vocab_size]`
2. `ArgMax` over vocabulary axis: outputs `token_id` (`[batch_size, 1]`, INT64)
3. `LogSoftmax` over vocabulary axis: outputs `last_timestep_log_probs`
4. `GatherElements` of the selected argmax token: outputs `max_logprob` (`[batch_size, 1]`, FLOAT32)

### Graph Outputs
* **`token_id`**: Next predicted token piece ID (`INT64`, `[batch_size, 1]`).
* **`max_logprob`**: Log-probability $\ln P(w_t \mid w_{<t}, X)$ of the selected token (`FLOAT`, `[batch_size, 1]`).

### Regeneration Instructions

To regenerate `decoder_model_int8_argmax.onnx`:

1. Ensure Python with `onnx` is installed:
   ```bash
   pip install onnx
   ```

2. Run the script against the base quantized decoder model:
   ```bash
   python tools/add_argmax_to_decoder.py \
     assets/models/mt/decoder_model_int8.onnx \
     assets/models/mt/decoder_model_int8_argmax.onnx
   ```

3. Deploy the resulting file to `assets/models/mt/decoder_model_int8_argmax.onnx`. When loaded in Dart, `RealMtStage` will automatically detect the second output and compute sequence confidence as:
   $$\text{confidence} = \exp\left(\frac{1}{T}\sum_{t=1}^T \text{max\_logprob}_t\right)$$
