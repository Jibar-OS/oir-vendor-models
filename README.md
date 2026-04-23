# oir-vendor-models — permissively-licensed model bundle

Git-LFS repository of the baseline models that ship in a reference JibarOS build. Installs to `/product/etc/oir/` via `prebuilt_etc` in `Android.bp`.

## What's included

| File | Capability | License | Size |
|---|---|---|---|
| `qwen2.5-0.5b-instruct-q4_k_m.gguf` | `text.complete` / `text.translate` | Apache 2.0 | ~470 MB |
| `all-MiniLM-L6-v2.Q8_0.gguf` | `text.embed` | Apache 2.0 | ~24 MB |
| `whisper-tiny-en.Q5.bin` | `audio.transcribe` | MIT | ~31 MB |
| `siglip-base-patch16-224.onnx` | `vision.embed` | Apache 2.0 | ~372 MB |
| `voice-sample.wav` | OirDemo `audio.transcribe` demo input | CC0 (sonic/talking.wav resampled) | ~720 KB |

See [`NOTICE`](./NOTICE) for full attribution.

## Deliberately not included

These capabilities are declared in `capabilities.xml` with no platform default — OEMs bake their choice:

| Capability | Why |
|---|---|
| `vision.describe` | VLMs are typically >500 MB; OEMs pick size/perf tradeoff (SmolVLM-500M to LLaVA-7B) |
| `vision.detect` | YOLO family is AGPL; OEMs accept obligations or pick RT-DETR (Apache) |
| `audio.synthesize` | Piper voices need locale-specific G2P sidecars; no universal default |

## Git LFS

Model weights are tracked via Git LFS. To clone:

```bash
git lfs install
git clone https://github.com/jibar-os/oir-vendor-models
```

## Wiring up

In a JibarOS tree, add to your device `PRODUCT_PACKAGES`:

```make
PRODUCT_PACKAGES += \
    oir_default_model \
    oir_minilm_model \
    oir_whisper_tiny_en_model \
    oir_siglip_model \
    oir_voice_sample_wav
```

The reference Cuttlefish device tree ([`device_google_cuttlefish`](https://github.com/jibar-os/device_google_cuttlefish)) already does this.

## See also

[`github.com/Jibar-OS/JibarOS`](https://github.com/Jibar-OS/JibarOS) — why we bundle what we bundle + OEM bake-in guide.

## Migration status

🚧 Repo migration from `rufolangus/oir_vendor_models` in progress. Model binaries will be re-uploaded via Git LFS to the `jibar-os` org.
