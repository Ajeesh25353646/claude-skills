#!/usr/bin/env bash
# free-image-generation: Provider Health Check
# Tests each configured provider to verify it works end-to-end.
# Usage: bash scripts/health-check.sh [provider]
#   provider: cloudflare | pollinations | huggingface | local | all (default)

set -euo pipefail

# Load credentials from config if available
CONFIG_FILE="$HOME/.config/free-image-generation/.env"
[ -f "$CONFIG_FILE" ] && source <(grep -v '^#' "$CONFIG_FILE")

OUTDIR="/tmp/free-image-gen/health-check"
mkdir -p "$OUTDIR"
PROMPT="A cute orange tabby cat sitting on a windowsill, digital art"
PROMPT_SLUG="health-check-cat"
PASS=0
FAIL=0

green() { echo -e "\033[32m$1\033[0m"; }
red()   { echo -e "\033[31m$1\033[0m"; }

check_provider() {
  local name="$1" file="$2"
  if [ -f "$file" ] && [ -s "$file" ]; then
    local size
    size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
    if [ "$size" -gt 1000 ]; then
      green "  ✅ $name: OK (${size} bytes → $file)"
      PASS=$((PASS + 1))
    else
      red "  ❌ $name: File too small (${size} bytes)"
      FAIL=$((FAIL + 1))
    fi
  else
    red "  ❌ $name: No output file"
    FAIL=$((FAIL + 1))
  fi
}

# Cloudflare
test_cloudflare() {
  echo "Testing Cloudflare Workers AI..."
  if [ -z "${CLOUDFLARE_API_TOKEN:-}" ] || [ -z "${CLOUDFLARE_ACCOUNT_ID:-}" ]; then
    echo "  Skipping: CLOUDFLARE_API_TOKEN or CLOUDFLARE_ACCOUNT_ID not set"
    return
  fi
  local out="$OUTDIR/$PROMPT_SLUG-cloudflare.jpg"
  curl -s -X POST "https://api.cloudflare.com/client/v4/accounts/${CLOUDFLARE_ACCOUNT_ID}/ai/run/@cf/black-forest-labs/flux-1-schnell" \
    -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
    -H "Content-Type: application/json" \
    -d '{"prompt": "'"${PROMPT}"'", "width": 512, "height": 512, "num_steps": 4}' \
    | jq -r '.result.image' | base64 -d > "$out" 2>/dev/null
  check_provider "Cloudflare" "$out"
}

# Pollinations
test_pollinations() {
  echo "Testing Pollinations.ai..."
  local out="$OUTDIR/$PROMPT_SLUG-pollinations.jpg"
  # Single-word prompt on gen endpoint (anonymous free tier)
  curl -s "https://gen.pollinations.ai/image/cat?model=flux" -o "$out"
  check_provider "Pollinations" "$out"
}

# HuggingFace
test_huggingface() {
  echo "Testing HuggingFace Inference..."
  if [ -z "${HF_TOKEN:-}" ]; then
    echo "  Skipping: HF_TOKEN not set"
    return
  fi
  local out="$OUTDIR/$PROMPT_SLUG-huggingface.jpg"
  HTTP_CODE=$(curl -s -o "$out" -w "%{http_code}" \
    -X POST "https://router.huggingface.co/hf-inference/models/black-forest-labs/FLUX.1-schnell" \
    -H "Authorization: Bearer ${HF_TOKEN}" \
    -H "Content-Type: application/json" \
    -d '{"inputs": "'"${PROMPT}"'", "parameters": {"num_inference_steps": 4}}')
  if [ "$HTTP_CODE" = "200" ]; then
    check_provider "HuggingFace" "$out"
  else
    # Might have returned JSON error, or loading model
    local size; size=$(stat -f%z "$out" 2>/dev/null || stat -c%s "$out" 2>/dev/null)
    if [ "$size" -gt 1000 ] && file "$out" | grep -qiE "jpeg|png|image"; then
      check_provider "HuggingFace" "$out"
    else
      local msg; msg=$(cat "$out" | head -c 200)
      red "  ❌ HuggingFace: HTTP $HTTP_CODE : $msg"
      FAIL=$((FAIL + 1))
    fi
  fi
}

# Local ComfyUI
test_local_comfyui() {
  echo "Testing local ComfyUI..."
  if ! curl -s -o /dev/null -w "" http://localhost:8188 2>/dev/null; then
    echo "  Skipping: ComfyUI not running on localhost:8188"
    return
  fi
  # ComfyUI requires specific workflow JSON. Just report it is available.
  green "  ✅ ComfyUI: Running on localhost:8188"
  PASS=$((PASS + 1))
}

# Local A1111
test_local_a1111() {
  echo "Testing local A1111..."
  if ! curl -s -o /dev/null -w "" http://localhost:7860 2>/dev/null; then
    echo "  Skipping: A1111 not running on localhost:7860"
    return
  fi
  green "  ✅ A1111: Running on localhost:7860"
  PASS=$((PASS + 1))
}

# Main
echo "🎨 Free Image Generation: Health Check"
echo "========================================"
echo ""

FILTER="${1:-all}"
case "$FILTER" in
  all)           test_cloudflare; test_pollinations; test_huggingface; test_local_comfyui; test_local_a1111 ;;
  cloudflare)    test_cloudflare ;;
  pollinations)  test_pollinations ;;
  huggingface)   test_huggingface ;;
  local)         test_local_comfyui; test_local_a1111 ;;
  *)             echo "Unknown provider: $FILTER"; echo "Usage: $0 [cloudflare|pollinations|huggingface|local|all]"; exit 1 ;;
esac

echo ""
echo "========================================"
echo "Results: $PASS passed, $FAIL failed"
echo "Output dir: $OUTDIR"
[ "$FAIL" -gt 0 ] && exit 1 || exit 0
