# Pollinations.ai Reference

## Overview

Pollinations.ai provides image generation through two API surfaces. The **OpenAI-compatible REST API** at `gen.pollinations.ai` offers the best experience with proper POST semantics, or the simple **GET endpoint** for zero-dependency one-liners. Free tier works without any authentication for single-word prompts; a free API key unlocks richer prompts and all models.

## Endpoints

| Endpoint | Method | Description | Auth Required |
|----------|--------|-------------|---------------|
| `https://gen.pollinations.ai/image/{prompt}` | GET | Simple URL-based generation | Single-word prompts: no |
| `https://gen.pollinations.ai/v1/images/generations` | POST | OpenAI-compatible API | Free key recommended |
| `https://gen.pollinations.ai/v1/models` | GET | List available models | No |

## Authentication Tiers

| Tier | Rate Limit | Prompt Length | Models | How to Get |
|------|-----------|--------------|--------|------------|
| **Anonymous** | ~3-5 req/min, then 60s cooldown | Single word only | `flux`, `zimage` | No signup needed |
| **Free (`pk_` key)** | Higher throughput | Full prompts | All models listed below | Sign up at `https://enter.pollinations.ai` |

## Available Image Models

| Model ID | Description | Resolution | Free Tier Access |
|----------|------------|-----------|------------------|
| `flux` | FLUX model, fast generation | 768×768 | Yes (anonymous) |
| `zimage` | High quality, sharper details | 1024×1024 | Yes (anonymous) |
| `grok-imagine` | xAI Grok image generation | Variable | Free key |
| `grok-imagine-pro` | xAI Grok premium | Variable | Free key |
| `gptimage` / `gpt-image-2` | GPT-Image-2 class quality | Variable | Free key |
| `nanobanana` / `nanobanana-2` | Google Nano Banana (Gemini Flash Image) | Variable | Free key |
| `seedream` / `seedream5` | ByteDance Seedream | Variable | Free key |
| `klein` | FLUX.2 Klein variant | Variable | Free key |
| `qwen-image` | Qwen image generation | Variable | Free key |
| `wan-image` | WAN image generation | Variable | Free key |
| `kontext` | FLUX Pro Kontext | Variable | Free key |
| `p-image` | Pollinations image model | 1024×1024 | Free key |
| `nova-canvas` | Canvas generation | Variable | Free key |

## GET Endpoint (Quick One-Liner)

### Anonymous (Single-Word Prompts)

```bash
curl -s "https://gen.pollinations.ai/image/cat?model=flux" -o cat.jpg
```

- Only single-word prompts (no spaces) work without a key — prompt is the URL path segment itself
- Available models on free tier: `flux` (768×768), `zimage` (1024×1024)
- Rate-limited: ~3-5 requests per minute, then 401 response for ~60s

### With Free API Key (Full Prompts, All Models)

```bash
curl -s -H "Authorization: Bearer pk_YOUR_KEY" \
  "https://gen.pollinations.ai/image/cute%20orange%20cat%20sitting%20on%20a%20windowsill?model=gpt-image-2" \
  -o cat.jpg
```

Query parameters:

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `model` | string | Model to use (see table above) | `flux` |
| `width` / `height` | integer | Image dimensions | Varies by model |
| `seed` | integer | Seed for reproducibility | random |
| `nologo` | boolean | Remove watermark | false |

## POST Endpoint (OpenAI-Compatible, Recommended)

The POST endpoint at `/v1/images/generations` follows the OpenAI image generation spec, supports full-length prompts, and works well with a free API key.

```bash
curl -s -X POST "https://gen.pollinations.ai/v1/images/generations" \
  -H "Authorization: Bearer pk_YOUR_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "flux",
    "prompt": "A cute orange cat sitting on a windowsill, digital art style",
    "n": 1
  }' | jq -r '.data[0].b64_json' | base64 -d > cat.jpg
```

### Request Body

| Field | Type | Description | Default |
|-------|------|-------------|---------|
| `model` | string | Model ID from the models table | `flux` |
| `prompt` | string | Text description of the image | Required |
| `n` | integer | Number of images to generate | 1 |
| `width` | integer | Image width | Model default |
| `height` | integer | Image height | Model default |
| `seed` | integer | Random seed for reproducibility | random |

### Response

```json
{
  "created": 1234567890,
  "data": [
    {
      "b64_json": "<base64-encoded-image>",
      "revised_prompt": "..." // present for some models
    }
  ]
}
```

### With Seed (Reproducible Results)

```bash
curl -s -X POST "https://gen.pollinations.ai/v1/images/generations" \
  -H "Authorization: Bearer pk_YOUR_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "flux",
    "prompt": "A cute orange cat sitting on a windowsill",
    "n": 1,
    "seed": 42
  }'
```

## Multi-Image Generation

Generate multiple images with different seeds for variety:

```bash
PROMPT="A cute orange cat sitting on a windowsill, digital art"
SLUG="cat-on-windowsill"
mkdir -p "/tmp/free-image-gen/$SLUG"
for i in 1 2 3 4; do
  SEED=$(( $(date +%s) + i ))
  curl -s -X POST "https://gen.pollinations.ai/v1/images/generations" \
    -H "Authorization: Bearer pk_YOUR_KEY" \
    -H "Content-Type: application/json" \
    -d '{"model": "gpt-image-2", "prompt": "'"${PROMPT}"'", "n": 1, "seed": '"${SEED}"'}' \
    | jq -r '.data[0].b64_json' | base64 -d > "/tmp/free-image-gen/$SLUG/$SLUG-$i.jpg"
  echo "Generated image $i"
done
```

## Getting a Free API Key

1. Visit `https://enter.pollinations.ai`
2. **Sign in with GitHub** — this is the only signup method
3. Create an API key from your dashboard (will start with `pk_` or `sk_`)
4. Use the key in the `Authorization: Bearer YOUR_KEY` header

With a key, all models become accessible and prompt length limits are lifted. Note that `flux` and `zimage` are always free (0 Pollen). Premium models like `gpt-image-2`, `grok-imagine`, `nanobanana` cost a small amount of Pollen — registered accounts receive daily Pollen grants.

## Response Handling

The API returns raw image bytes for GET requests, and base64-encoded JSON for POST:

```bash
# GET: save directly
curl -s -o output.jpg "https://gen.pollinations.ai/image/cat?model=flux"

# POST: decode from JSON
curl -s -X POST "https://gen.pollinations.ai/v1/images/generations" \
  -H "Authorization: Bearer pk_YOUR_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model": "flux", "prompt": "cat", "n": 1}' \
  | jq -r '.data[0].b64_json' | base64 -d > output.jpg
```

## Notes

- The API is the best zero-setup fallback in the skill: no SDK, just curl
- Free tier anonymous requests are rate-limited to ~3-5 single-word prompts per minute
- With a free `pk_` key, all models unlock, rate limits increase, and full-length prompts work
- `zimage` model offers 1024×1024 resolution on free tier (vs 768×768 for `flux`)
- No negative prompt support through the simple GET endpoint
- Response time varies: ~2-10 seconds depending on model and load
- For production workloads, consider Cloudflare Workers AI for consistent throughput
