---
name: free-image-generation
description: "Generate images for free using multiple AI providers. Cloudflare Workers AI, Pollinations.ai, HuggingFace Inference, or local ComfyUI/A1111. Trigger when user says 'generate an image', 'create an image', 'make a picture', 'draw me', or any request involving free image generation."
---

# Free Image Generation

Generate images from text prompts using four free AI image providers with automatic fallback. No API keys required for the simplest path (Pollinations.ai), or unlock ~57 free images/day with Cloudflare at 1024x1024 (up to ~231 at 512x512).

**Philosophy:** Tiered fallback from best-free to always-free. Zero config for the user who just wants a picture; deep config for the power user who wants daily limits. Every provider is wrapped in a one-liner curl. No SDKs, no complex setup.

<SUBAGENT-STOP>
If you were dispatched as a subagent, you are NOT running this skill. You are executing a specific task within it. Follow your task prompt.
</SUBAGENT-STOP>

---

## OUTPUT CONTRACT

Read before emitting your response.

### Badge (Mandatory, First Line of Output)

```
🎨 Free Image Gen | {N} images | Provider: {provider} | {model}
```

No other text on this line. One blank line after, then the output begins.

### LAWS (Non-Negotiable)

**LAW 1: Provider Chain is Fixed.** Always try providers in this order of preference:
1. **Cloudflare Workers AI** (if `CLOUDFLARE_API_TOKEN` + `CLOUDFLARE_ACCOUNT_ID` set). ~57 images/day at 1024x1024 4 steps (~231 at 512x512). FLUX.1 Schnell, free plan.
2. **HuggingFace** (if `HF_TOKEN` set). ~83 images/month via $0.10 free credits, FLUX.1-schnell.
3. **Pollinations.ai**. No key needed for single-word prompts. Free `pk_` key unlocks full prompts + all models. Anonymous rate-limited.
4. **Local ComfyUI/A1111** if running on localhost:8188 or localhost:7860.

NEVER try a provider that isn't configured. Check env vars first.

**LAW 2: Save Every Image.** All generated images MUST be saved to disk. Use descriptive filenames with the prompt slug and a sequence number: `/tmp/free-image-gen/{prompt-slug}/{prompt-slug}-{N}.{ext}`. Report the full paths.

**LAW 3: NO Hallucinated API Calls.** Every curl command must match the exact API syntax documented in the reference files at `references/`. If you have not read the reference file for a provider in this conversation, READ it before generating. Do NOT guess API endpoints, parameter names, or auth headers.

**LAW 4: Flag Errors Gracefully.** If a provider returns an error (rate limit, auth failure, model busy), say so clearly with the error message, then fall back to the next provider in the chain. Do NOT retry the same provider more than once unless the error is transient (timeout, 429 with Retry-After).

**LAW 5: Report Generation Parameters.** In the output, always show provider, model, prompt (truncated if long), dimensions, number of steps, and seed if set.

**Post-generation self-check (do this BEFORE emitting):**
- Is the badge on line 1? ✅
- Did I read the reference file(s) for the provider(s) I used? ✅
- Are all images saved to disk with reported paths? ✅
- Is every error gracefully reported with fallback? ✅
- Any raw API responses shown verbatim? Synthesize into a clear message.

---

## Provider Reference Summary

| Provider | Free Limit | Model | Key Needed? | Auth |
|----------|-----------|-------|-------------|------|
| Cloudflare Workers AI | ~57 img/day at 1024x1024 | `@cf/black-forest-labs/flux-1-schnell` | Optional | `CLOUDFLARE_API_TOKEN` + `CLOUDFLARE_ACCOUNT_ID` |
| Pollinations.ai | Unlimited | `flux`, `zimage`, `gpt-image-2`, `grok-imagine`, `seedream`, etc. | Free key for full prompts | `pk_` key from enter.pollinations.ai |
| HuggingFace Inference | ~83 img/mo ($0.10 credits) | `black-forest-labs/FLUX.1-schnell` | Optional | `HF_TOKEN` |
| Local ComfyUI/A1111 | Unlimited | Any model | No | URL check on localhost |

---

## WORKFLOW

```
Stage 0: Pre-Flight (inline)  Parse intent, check env vars, read reference files
Stage 1: Generate (inline)    Tiered fallback across providers
Stage 2: Save and Present (inline)  Save images, display results
```

---

### Stage 0: Pre-Flight

Parse Intent and Check Capabilities.

**What to figure out (ask the user if anything is unclear):**
- **Prompt** - What to generate (required). Be descriptive.
- **Count** - How many images (default: 1, max: 4 for free tiers; many providers cap samples at 4 or charge per tile).
- **Dimensions** - Width x Height (default: 1024x1024). Cloudflare FLUX generates 1024x1024 minimum.
- **Style** - Any style modifiers (photorealistic, anime, oil painting, etc.)
- **Negative prompt** - Things to avoid (supported by Cloudflare)

**Check environment variables to determine available providers:**

The skill loads credentials from `~/.config/free-image-generation/.env`. The setup wizard (`scripts/setup.sh`) creates this file. Alternatively, users can set the vars directly in their shell.

```bash
# Load config if it exists
CONFIG_FILE="$HOME/.config/free-image-generation/.env"
[ -f "$CONFIG_FILE" ] && source <(grep -v '^#' "$CONFIG_FILE")

# Check which providers are configured
echo "CLOUDFLARE_API_TOKEN: ${CLOUDFLARE_API_TOKEN:+set}"
echo "CLOUDFLARE_ACCOUNT_ID: ${CLOUDFLARE_ACCOUNT_ID:+set}"
echo "HF_TOKEN: ${HF_TOKEN:+set}"
echo "POLLINATIONS_API_KEY: ${POLLINATIONS_API_KEY:+set}"
# Check local endpoints
curl -s -o /dev/null -w "%{http_code}" http://localhost:8188 2>/dev/null
curl -s -o /dev/null -w "%{http_code}" http://localhost:7860 2>/dev/null
```

**Read the provider reference file(s) for each provider you might use.** This is mandatory. The reference files contain the exact curl syntax, parameter names, and response handling for each API. Do NOT rely on memory.

```bash
# Create output directory and prompt encoding
PROMPT_SLUG=$(echo "$PROMPT" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//')
OUTDIR="/tmp/free-image-gen/$PROMPT_SLUG"
mkdir -p "$OUTDIR"

# URL-encoded prompt for pollinations GET requests
PROMPT_URL_ENCODED=$(echo "$PROMPT" | sed 's/ /%20/g')
```

```bash
# Read the appropriate reference file(s)
cat references/cloudflare-workers-ai.md   # If Cloudflare is configured
cat references/pollinations.md            # Always read; it is the no-key fallback
cat references/huggingface.md             # If HuggingFace is configured
```

**If ALL providers fail** (no env vars, no local, Pollinations is down):
- Tell the user what to install: sign up for Cloudflare (free, no credit card) and set env vars, OR sign up for a free Pollinations key at enter.pollinations.ai, OR use ComfyUI locally.
- Show the setup commands.

---

### Stage 1: Generate

Tiered Fallback across providers.

#### Option A: Cloudflare Workers AI (Best, ~57/day free at 1024x1024)

```bash
curl -s -X POST "https://api.cloudflare.com/client/v4/accounts/${CLOUDFLARE_ACCOUNT_ID}/ai/run/@cf/black-forest-labs/flux-1-schnell" \
  -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "'"${PROMPT}"'",
    "width": '"${WIDTH}"',
    "height": '"${HEIGHT}"',
    "num_steps": 4,
    "guidance": 3.5
  }'
```

Response: `{ result: { image: "<base64>" } }`. The base64 field contains raw JPEG bytes. Decode and save:
```bash
curl -s -X POST "https://api.cloudflare.com/client/v4/accounts/${CLOUDFLARE_ACCOUNT_ID}/ai/run/@cf/black-forest-labs/flux-1-schnell" \
  -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"prompt": "'"${PROMPT}"'", "width": '"${WIDTH}"', "height": '"${HEIGHT}"', "num_steps": 4}' \
  | jq -r '.result.image' \
  | base64 -d > "$OUTDIR/${PROMPT_SLUG}-1.jpg"
```

For multiple images, call with different `seed` values:
```bash
for i in $(seq 1 $COUNT); do
  SEED=$(( RANDOM + i ))
  curl -s -X POST "https://api.cloudflare.com/client/v4/accounts/${CLOUDFLARE_ACCOUNT_ID}/ai/run/@cf/black-forest-labs/flux-1-schnell" \
    -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
    -H "Content-Type: application/json" \
    -d '{"prompt": "'"${PROMPT}"'", "width": '"${WIDTH}"', "height": '"${HEIGHT}"', "num_steps": 4, "seed": '"${SEED}"'}' \
    | jq -r '.result.image' \
    | base64 -d > "$OUTDIR/${PROMPT_SLUG}-${i}.jpg"
  echo "Generated: $OUTDIR/${PROMPT_SLUG}-${i}.jpg"
done
```

**Cost per image (~4 steps, 1024x1024 = 4 tiles):** ~173 neurons/image. Daily budget: 10,000 neurons = ~57 images/day at 1024x1024 (more at 512x512).

#### Option B: Pollinations.ai (Zero Setup, Full Potential with Free Key)

Pollinations is the ultimate fallback — it works without any configuration for quick one-word prompts, and a free `pk_` key unlocks everything.

**Determine which approach to use:**

- **Anonymous (single-word prompts only):** Use the GET endpoint
- **With free `pk_` key (full prompts, all models):** Use the POST endpoint for best results

```bash
# Quick anonymous single-word GET
curl -s "https://gen.pollinations.ai/image/cat?model=flux" \
  -o "$OUTDIR/${PROMPT_SLUG}-1.jpg"

# Full prompts with a free pk_ key via POST (OpenAI-compatible)
curl -s -X POST "https://gen.pollinations.ai/v1/images/generations" \
  -H "Authorization: Bearer pk_YOUR_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-image-2",
    "prompt": "'"${PROMPT}"'",
    "n": 1
  }' | jq -r '.data[0].b64_json' | base64 -d > "$OUTDIR/${PROMPT_SLUG}-1.jpg"
```

For multiple images with a key:
```bash
for i in $(seq 1 $COUNT); do
  SEED=$(( RANDOM + i ))
  curl -s -X POST "https://gen.pollinations.ai/v1/images/generations" \
    -H "Authorization: Bearer pk_YOUR_KEY" \
    -H "Content-Type: application/json" \
    -d '{"model": "gpt-image-2", "prompt": "'"${PROMPT}"'", "n": 1, "seed": '"${SEED}"'}' \
    | jq -r '.data[0].b64_json' | base64 -d > "$OUTDIR/${PROMPT_SLUG}-${i}.jpg"
  echo "Generated: $OUTDIR/${PROMPT_SLUG}-${i}.jpg"
done
```

**To get a free `pk_` key:** Sign up at `https://enter.pollinations.ai` — no credit card needed.

**Free tier limits (anonymous):** ~3-5 single-word prompts per minute, then ~60s cooldown. Single-word prompts only without a key.

**Free tier limits (with `pk_` key):** Full-length prompts, all models (gpt-image-2, grok-imagine, seedream, nanobanana, etc.), higher throughput.

#### Option C: HuggingFace Inference (~83 images/month)

Using HF Inference Providers with FLUX.1-schnell:
```bash
curl -s -X POST "https://router.huggingface.co/hf-inference/models/black-forest-labs/FLUX.1-schnell" \
  -H "Authorization: Bearer ${HF_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"inputs": "'"${PROMPT}"'", "parameters": {"num_inference_steps": 4}}' \
  -o "$OUTDIR/${PROMPT_SLUG}-1.jpg"
```

**Note:** HF may return the image as raw binary (check Content-Type). If it returns JSON with an error, parse accordingly.

#### Option E: Local ComfyUI/A1111 (Unlimited)

**ComfyUI:**
```bash
curl -s -X POST "http://localhost:8188/prompt" \
  -H "Content-Type: application/json" \
  -d '{"prompt": {...workflow...}}'
```

**A1111:**
```bash
curl -s -X POST "http://localhost:7860/sdapi/v1/txt2img" \
  -H "Content-Type: application/json" \
  -d '{"prompt": "'"${PROMPT}"'", "width": '"${WIDTH}"', "height": '"${HEIGHT}"'}'
```

---

### Stage 2: Save and Present

After all images are generated:

```bash
# List all generated files with sizes
ls -lh "$OUTDIR/"
file "$OUTDIR"/*.jpg "$OUTDIR"/*.png 2>/dev/null
```

**Present the results to the user:**
- Show the badge with provider, count, and model.
- List each file with its full path and file size.
- Summarize the generation parameters used.
- If any provider failed, explain why and what was tried next.

**Cleanup:** Images are in `/tmp/free-image-gen/` and may be cleared on reboot. Suggest moving them if the user wants to keep them.

---

## Quick Reference Card (Cheat Sheet)

### Cloudflare (Best)
```bash
curl -s -X POST "https://api.cloudflare.com/client/v4/accounts/$CF_ACCT/ai/run/@cf/black-forest-labs/flux-1-schnell" \
  -H "Authorization: Bearer $CF_TOKEN" \
  -d '{"prompt":"a cat","width":1024,"height":1024,"num_steps":4}' \
  | jq -r '.result.image' | base64 -d > cat.jpg
```

### Pollinations (Zero Setup)
```bash
# Single word — no key needed
curl -s "https://gen.pollinations.ai/image/cat?model=flux" -o cat.jpg

# Full prompts — get a free pk_ key at enter.pollinations.ai
curl -s -X POST "https://gen.pollinations.ai/v1/images/generations" \
  -H "Authorization: Bearer pk_YOUR_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"gpt-image-2","prompt":"A cute orange cat on a windowsill","n":1}' \
  | jq -r '.data[0].b64_json' | base64 -d > cat.jpg
```

### HuggingFace ($0.10/mo)
```bash
curl -s -X POST "https://router.huggingface.co/hf-inference/models/black-forest-labs/FLUX.1-schnell" \
  -H "Authorization: Bearer $HF_TOKEN" \
  -d '{"inputs":"a cat"}' -o cat.jpg
```

---

## Environment Variables

Credentials live in `~/.config/free-image-generation/.env`. All vars are **optional** — the skill falls back gracefully.

```bash
# Source this in your shell or run the setup wizard:
source <(grep -v '^#' ~/.config/free-image-generation/.env)
```

| Variable | Provider | Get It At |
|----------|----------|-----------|
| `CLOUDFLARE_ACCOUNT_ID` + `CLOUDFLARE_API_TOKEN` | Cloudflare Workers AI (best) | dash.cloudflare.com → API Tokens |
| `HF_TOKEN` | HuggingFace Inference | huggingface.co/settings/tokens |
| `POLLINATIONS_API_KEY` | Pollinations.ai (premium models) | enter.pollinations.ai (GitHub login) |

### First-Run Setup Wizard

```bash
bash scripts/setup.sh
```

This walks you through each provider, stores keys in `~/.config/free-image-generation/.env` (permissions 600), and takes about 60 seconds.
