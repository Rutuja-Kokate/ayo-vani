"""add_argmax_to_decoder.py

Utility to append ArgMax and LogSoftmax + Gather (max_logprob) nodes to the
IndicTrans2 quantized ONNX decoder graph.

Graph Modifications:
1. Gathers the last timestep from the decoder logits:
   last_timestep_logits = Gather(logits, -1, axis=1)  # [batch_size, vocab_size]
2. Computes the argmax token ID:
   token_id = ArgMax(last_timestep_logits, axis=-1, keepdims=1)  # [batch_size, 1] (INT64)
3. Computes the log-probabilities over the vocabulary:
   last_timestep_log_probs = LogSoftmax(last_timestep_logits, axis=-1)  # [batch_size, vocab_size] (FLOAT)
4. Gathers the log-probability corresponding to the argmax token:
   max_logprob = GatherElements(last_timestep_log_probs, token_id, axis=-1)  # [batch_size, 1] (FLOAT)

Outputs:
- Output 0: 'token_id' (INT64, shape [batch_size, 1])
- Output 1: 'max_logprob' (FLOAT, shape [batch_size, 1])
"""

import os
import sys
import onnx
from onnx import helper, TensorProto


def add_argmax_and_logprob_to_decoder(
    input_path: str,
    output_path: str,
) -> None:
    print(f"Loading ONNX model from: {input_path} ({os.path.getsize(input_path)/1e6:.1f} MB)...")
    model = onnx.load(input_path)
    graph = model.graph

    # Identify original output name
    orig_output_names = [o.name for o in graph.output]
    print(f"Original graph outputs: {orig_output_names}")
    assert "logits" in orig_output_names, f"Expected 'logits' in outputs, got {orig_output_names}"

    # 1. Create initializer for last timestep index (-1)
    last_idx_name = "last_timestep_idx"
    idx_tensor = helper.make_tensor(
        name=last_idx_name,
        data_type=TensorProto.INT64,
        dims=[],
        vals=[-1],
    )
    graph.initializer.append(idx_tensor)

    # 2. Create Gather node: logits[:, -1, :] on axis=1
    last_logits_name = "last_timestep_logits"
    gather_node = helper.make_node(
        op_type="Gather",
        inputs=["logits", last_idx_name],
        outputs=[last_logits_name],
        name="gather_last_timestep",
        axis=1,
    )
    graph.node.append(gather_node)

    # 3. Create ArgMax node on last_logits along axis=-1 (vocab dimension)
    token_id_name = "token_id"
    argmax_node = helper.make_node(
        op_type="ArgMax",
        inputs=[last_logits_name],
        outputs=[token_id_name],
        name="argmax_token_id",
        axis=-1,
        keepdims=1,
    )
    graph.node.append(argmax_node)

    # 4. Create LogSoftmax node over vocabulary axis
    log_probs_name = "last_timestep_log_probs"
    log_softmax_node = helper.make_node(
        op_type="LogSoftmax",
        inputs=[last_logits_name],
        outputs=[log_probs_name],
        name="log_softmax_vocab",
        axis=-1,
    )
    graph.node.append(log_softmax_node)

    # 5. Create GatherElements node to extract max_logprob at the argmax index
    max_logprob_name = "max_logprob"
    gather_logprob_node = helper.make_node(
        op_type="GatherElements",
        inputs=[log_probs_name, token_id_name],
        outputs=[max_logprob_name],
        name="gather_max_logprob",
        axis=-1,
    )
    graph.node.append(gather_logprob_node)

    # 6. Replace graph outputs with [token_id, max_logprob]
    token_id_info = helper.make_tensor_value_info(
        token_id_name,
        TensorProto.INT64,
        ["batch_size", 1],
    )
    max_logprob_info = helper.make_tensor_value_info(
        max_logprob_name,
        TensorProto.FLOAT,
        ["batch_size", 1],
    )

    while len(graph.output) > 0:
        graph.output.pop()

    graph.output.append(token_id_info)
    graph.output.append(max_logprob_info)
    print(f"Updated graph outputs: {[o.name for o in graph.output]}")

    # 7. Check and save model
    print("Checking modified model validity...")
    onnx.checker.check_model(model)

    print(f"Saving modified model to: {output_path}...")
    onnx.save(model, output_path)
    print(f"✅ Successfully saved: {output_path} ({os.path.getsize(output_path)/1e6:.1f} MB)")


if __name__ == "__main__":
    src = sys.argv[1] if len(sys.argv) > 1 else "assets/models/mt/decoder_model_int8.onnx"
    dst = sys.argv[2] if len(sys.argv) > 2 else "assets/models/mt/decoder_model_int8_argmax.onnx"
    add_argmax_and_logprob_to_decoder(src, dst)
