# Cloudflare Workers AI Reference

## API Endpoint

```
POST https://api.cloudflare.com/client/v4/accounts/{ACCOUNT_ID}/ai/run/{MODEL_NAME}
```

## Authentication

- `Authorization: Bearer {CLOUDFLARE_API_TOKEN}`
- Token needs `Workers AI - Read` and `Workers AI - Edit` permissions
- See `references/cloudflare-setup.md` for a step-by-step guide on creating your account, finding your Account ID, and generating an API token

## Available Models

| Model | ID | Cost (neurons/image at 1024x1024, 4 steps) |
|-------|-----|------|
| FLUX.1 Schnell (best free) | `@cf/black-forest-labs/flux-1-schnell` | ~173 neurons |
| Lucid Origin | `@cf/leonardo/lucid-origin` | Higher cost |
| Phoenix 1.0 | `@cf/leonardo/phoenix-1.0` | Higher cost |

## Pricing (Free Plan)

- 10,000 neurons/day free allocation
- FLUX.1 Schnell: 4.8 neurons per 512x512 tile, plus 9.6 neurons per step per tile
- Cost formula: (num_tiles x 4.8) + (num_steps x num_tiles x 9.6)
- 1024x1024 = 4 tiles. At 4 steps: (4 x 4.8) + (4 x 4 x 9.6) = 19.2 + 153.6 = 172.8 neurons
- Daily capacity at 4 steps 1024x1024: ~57 images
- 512x512 = 1 tile. At 4 steps: (1 x 4.8) + (4 x 1 x 9.6) = 4.8 + 38.4 = 43.2 neurons
- Daily capacity at 4 steps 512x512: ~231 images
- Fewer steps cost less and run faster, but produce lower quality. 4 is the default.
- Limits reset daily at 00:00 UTC

## Request Format (FLUX.1 Schnell)

Required field: `prompt` (string, min 1, max 2048 chars)

Optional fields:
- `width` (number): default varies by model, use 1024 for FLUX
- `height` (number): default varies by model, use 1024 for FLUX
- `num_steps` (number): default 4, max 8. Fewer steps are faster but lower quality.
- `guidance` (number): how closely to follow the prompt. Default ~3.5 for FLUX.
- `seed` (number): random seed for reproducibility. Omit or use null for random.
- `negative_prompt` (string): things to avoid (supported but varies by model)

### curl Example (FLUX.1 Schnell)

```bash
curl -s -X POST "https://api.cloudflare.com/client/v4/accounts/${CLOUDFLARE_ACCOUNT_ID}/ai/run/@cf/black-forest-labs/flux-1-schnell" \
  -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "a cat wearing a spacesuit, digital art",
    "width": 1024,
    "height": 1024,
    "num_steps": 4,
    "guidance": 3.5
  }'
```

### Response Format

```json
{
  "result": {
    "image": "<base64-encoded JPEG bytes>"
  },
  "success": true,
  "errors": [],
  "messages": []
}
```

**Important:** The `image` field contains raw base64-encoded JPEG bytes. It is NOT wrapped in a JSON object and it is NOT a URL. Decode with `base64 -d` to get a .jpg file.

### Error Response

```json
{
  "success": false,
  "errors": [{"code": 10000, "message": "..."}],
  "messages": []
}
```

Common errors:
- `10000`: Authentication failure (bad token)
- `10001`: Account ID not found
- `10010`: Rate limited (too many requests)
- `10020`: Daily neuron quota exceeded (wait until 00:00 UTC)

### Saving the Image (Correct Parsing)

```bash
# One-liner: extract image from response, decode, save as JPG
curl -s -X POST "https://api.cloudflare.com/client/v4/accounts/${CLOUDFLARE_ACCOUNT_ID}/ai/run/@cf/black-forest-labs/flux-1-schnell" \
  -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"prompt": "a cat", "width": 1024, "height": 1024, "num_steps": 4}' \
  | jq -r '.result.image' \
  | base64 -d > /tmp/free-image-gen/cat/cat-1.jpg
```

### Multiple Images with Different Seeds

```bash
for seed in 42 123 456 789; do
  curl -s -X POST "https://api.cloudflare.com/client/v4/accounts/${CLOUDFLARE_ACCOUNT_ID}/ai/run/@cf/black-forest-labs/flux-1-schnell" \
    -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "{\"prompt\": \"a cat\", \"width\": 1024, \"height\": 1024, \"num_steps\": 4, \"seed\": $seed}" \
    | jq -r '.result.image' \
    | base64 -d > "/tmp/free-image-gen/cat/cat-${seed}.jpg"
done
```

## Notes

- FLUX.1 Schnell handles negative prompts differently than SD. Use positive phrasing for best results.
- Steps beyond 4 have diminishing returns for schnell, which is designed for 4-8 steps.
- Images are always returned as base64 JPEG regardless of input dimensions.
- There is no way to get PNG format through the API.
- The free plan never requires a credit card. Just create a Cloudflare account.
