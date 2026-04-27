#!/bin/bash
# Fetch the JibarOS reference model bundle.
#
# Usage:
#   ./tools/fetch-models.sh [--target models]
#
# Populates models/ with permissively-licensed model binaries from their
# canonical upstream homes. Verifies SHA256 after each download; re-running
# is idempotent (skips files that already match the expected hash).
#
# Run this after `repo sync` on a fresh JibarOS tree — the AOSP build
# references these paths via oir-vendor-models/Android.bp prebuilt_etc
# entries.

set -euo pipefail

TARGET="${1:-models}"
mkdir -p "$TARGET"

# Manifest: filename | URL | SHA256 | license
#
# When bumping a model: update URL + hash together. CI validates that the
# declared hash matches what the URL returns.
MANIFEST=(
    "qwen2.5-0.5b-instruct-q4_k_m.gguf|https://huggingface.co/Qwen/Qwen2.5-0.5B-Instruct-GGUF/resolve/main/qwen2.5-0.5b-instruct-q4_k_m.gguf|74a4da8c9fdbcd15bd1f6d01d621410d31c6fc00986f5eb687824e7b93d7a9db|Apache-2.0"
    "all-MiniLM-L6-v2.Q8_0.gguf|https://huggingface.co/leliuga/all-MiniLM-L6-v2-GGUF/resolve/main/all-MiniLM-L6-v2.Q8_0.gguf|e5ec722e8c82dc4ffaf965175ca472f5da3f97b695590b5b0780bdbfa29bcaf3|Apache-2.0"
    "whisper-tiny-en.Q5.bin|https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-tiny.en-q5_1.bin|c77c5766f1cef09b6b7d47f21b546cbddd4157886b3b5d6d4f709e91e66c7c2b|MIT"
    "siglip-base-patch16-224.onnx|https://huggingface.co/Xenova/siglip-base-patch16-224/resolve/main/onnx/vision_model.onnx|f89d41bac7f4d4b87e010a467d93f98689d708916ed22f5a07f96fdfa26f475f|Apache-2.0"
    "rtdetr-r50vd-coco.onnx|https://huggingface.co/onnx-community/rtdetr_r50vd_coco_o365/resolve/main/onnx/model_fp16.onnx|a8e6536d749e30b56f4d56c78bc30c2b991425edbccce414cc4aa60505d3a0df|Apache-2.0"
)

fetch_one() {
    local entry=$1
    local name=$(echo "$entry" | cut -d"|" -f1)
    local url=$(echo  "$entry" | cut -d"|" -f2)
    local hash=$(echo "$entry" | cut -d"|" -f3)
    local license=$(echo "$entry" | cut -d"|" -f4)
    local dst="$TARGET/$name"

    if [ -f "$dst" ] && [ "$hash" != "__${name%%.*}_SHA__" ]; then
        local have=$(sha256sum "$dst" | awk '{print $1}')
        if [ "$have" = "$hash" ]; then
            echo "  [ok] $name (hash match)"
            return 0
        fi
    fi

    echo "  [fetch] $name ($license) ← $url"
    curl -fL --retry 3 --retry-delay 5 -o "$dst.part" "$url"
    mv "$dst.part" "$dst"

    if [ "$hash" != "__${name%%.*}_SHA__" ]; then
        local got=$(sha256sum "$dst" | awk '{print $1}')
        if [ "$got" != "$hash" ]; then
            echo "  [FAIL] $name hash mismatch: expected $hash got $got" >&2
            exit 1
        fi
    fi
}

echo "==> Fetching JibarOS reference model bundle into $TARGET/"
for entry in "${MANIFEST[@]}"; do
    fetch_one "$entry"
done
echo "==> Done. Run \`m\` from the AOSP root to build with these models."
