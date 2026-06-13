# HuggingFace Inference Reference

## Overview

HuggingFace Inference Providers gives every user **$0.10 of free credits per month** (no credit card needed). With FLUX.1-schnell at ~$0.0012/image (4 steps, ~10s compute), that's roughly **83 free images per month**.

PRO users get $2.00/month credits.

## Authentication

- Header: `Authorization: Bearer {HF_TOKEN}`
- Get token:
  1. Go to https://huggingface.co/settings/tokens
  2. Click **Create new token**
  3. Select the **read** tab (inference only needs read access)
  4. Give it a name (e.g., "free-image-gen")
  5. Click **Create token**
  6. Copy the token (starts with `hf_`)
- Use "read" token for inference

## Endpoint

### HuggingFace Inference API (Routed)

The old `api-inference.huggingface.co` endpoint is **deprecated and no longer resolves in DNS**. Use the new router endpoint:

```
POST https://router.huggingface.co/hf-inference/models/{model_id}
```

### curl Example (FLUX.1-schnell)

```bash
curl -s -X POST "https://router.huggingface.co/hf-inference/models/black-forest-labs/FLUX.1-schnell" \
  -H "Authorization: Bearer ${HF_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "inputs": "a cat wearing a spacesuit, digital art",
    "parameters": {
      "num_inference_steps": 4
    }
  }' -o /tmp/free-image-gen/cat/cat-1.jpg
```

### Response Handling

The API returns **image bytes directly** (Content-Type: image/jpeg or image/png) when successful. Just pipe to a file.

If it returns JSON instead, check for an error:
```json
{
  "error": "...",
  "estimated_time": 10.0
}
```

Common errors:
- Model loading: the first call may be slow ("Model is loading")
- Authentication error (bad token)
- Out of credits (monthly $0.10 exhausted)

### Python SDK (Alternative)

```python
from huggingface_hub import InferenceClient

client = InferenceClient(provider="auto", api_key=os.environ["HF_TOKEN"])
image = client.text_to_image(
    "Astronaut riding a horse",
    model="black-forest-labs/FLUX.1-schnell",
)
image.save("astronaut.jpg")
```

## Inference Providers (Newer Approach)

HuggingFace now routes through "Inference Providers" which gives access to multiple compute partners:

```
provider="auto"  # Automatically picks fastest available
provider="fal-ai"  # Explicitly use Fal AI
provider="replicate"  # Explicitly use Replicate
```

### With provider parameter (requires `huggingface_hub` SDK)

```python
client = InferenceClient(provider="auto")
image = client.text_to_image(
    "A serene lake",
    model="black-forest-labs/FLUX.1-schnell",
    provider="auto"
)
```

## Pricing

| Account Type | Monthly Credits | Approx FLUX Images |
|-------------|----------------|-------------------|
| Free | $0.10 | ~83 (at $0.0012/img) |
| PRO | $2.00 | ~1,666 |

Cost estimate per FLUX image:
- GPU cost: ~$0.00012/second
- Typical inference: ~10 seconds
- Per image cost: ~$0.0012

## Notes

- The $0.10/month is shared across all Inference Providers usage, not just image generation
- First call to a model may be slow (cold start). The model needs to load into memory.
- Free credits reset monthly
- FLUX.1-schnell is the fastest/cheapest FLUX variant, designed for 1-4 steps
- For 4-step generation the image quality is still very good
- Some models may be behind a "gated" access wall, but FLUX.1-schnell is open and accessible
