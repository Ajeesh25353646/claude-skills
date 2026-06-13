#!/usr/bin/env bash
# free-image-generation: First-Run Setup Wizard
# Creates ~/.config/free-image-generation/.env with your API keys.
# Usage: bash scripts/setup.sh

set -euo pipefail

CONFIG_DIR="$HOME/.config/free-image-generation"
ENV_FILE="$CONFIG_DIR/.env"

# Colors
green() { echo -e "\033[32m$1\033[0m"; }
yellow() { echo -e "\033[33m$1\033[0m"; }
bold() { echo -e "\033[1m$1\033[0m"; }
reset() { echo -e "\033[0m$1"; }

clear
echo "$(bold "╔══════════════════════════════════════════════╗")"
echo "$(bold "║     Free Image Generation — Setup Wizard     ║")"
echo "$(bold "╚══════════════════════════════════════════════╝")"
echo ""
echo "This wizard will help you configure API keys for image generation."
echo "All keys are optional — the skill falls back to providers that"
echo "need no configuration."
echo ""

# Create config directory
mkdir -p "$CONFIG_DIR"
chmod 700 "$CONFIG_DIR"

# Check for existing config
if [ -f "$ENV_FILE" ]; then
  echo "$(yellow "Existing config found at $ENV_FILE")"
  echo "It will be backed up to ${ENV_FILE}.bak"
  cp "$ENV_FILE" "${ENV_FILE}.bak"
  echo ""
fi

# Clear existing, write header
cat > "$ENV_FILE" << 'EOF'
# Free Image Generation — API Keys & Configuration
# Source: source <(grep -v '^#' ~/.config/free-image-generation/.env)
# Created by setup.sh
#
# All variables are OPTIONAL. The skill tries providers in order of
# preference based on what's configured, falling back to Pollinations.ai
# which requires no keys at all.

EOF

echo "$(bold "Provider 1: Cloudflare Workers AI (Best, ~57 free images/day)")"
echo "  Sign up: https://dash.cloudflare.com/sign-up (free, no credit card)"
echo "  Then:    https://dash.cloudflare.com/profile/api-tokens"
echo ""
read -p "Cloudflare Account ID (or leave blank): " CF_ACCT
if [ -n "$CF_ACCT" ]; then
  echo "CLOUDFLARE_ACCOUNT_ID=\"$CF_ACCT\"" >> "$ENV_FILE"
fi
read -p "Cloudflare API Token (or leave blank): " CF_TOKEN
if [ -n "$CF_TOKEN" ]; then
  echo "CLOUDFLARE_API_TOKEN=\"$CF_TOKEN\"" >> "$ENV_FILE"
fi
echo ""

echo "$(bold "Provider 2: HuggingFace Inference (~83 free images/month)")"
echo "  Token: https://huggingface.co/settings/tokens"
echo "  Create a token with 'read' permission (starts with hf_)."
echo ""
read -p "HuggingFace Token (or leave blank): " HF_TOKEN
if [ -n "$HF_TOKEN" ]; then
  echo "HF_TOKEN=\"$HF_TOKEN\"" >> "$ENV_FILE"
fi
echo ""

echo "$(bold "Provider 3: Pollinations.ai (Zero config needed for simple use)")"
echo "  Sign up at https://enter.pollinations.ai (GitHub login) for a free"
echo "  API key that unlocks all models and full-length prompts."
echo ""
read -p "Pollinations API Key (optional, or leave blank): " POLLI_KEY
if [ -n "$POLLI_KEY" ]; then
  echo "POLLINATIONS_API_KEY=\"$POLLI_KEY\"" >> "$ENV_FILE"
fi
echo ""

chmod 600 "$ENV_FILE"

echo "$(green "✅ Setup complete!")"
echo "   Config written to: $ENV_FILE"
echo ""
echo "   To use this skill, make sure the env vars are loaded:"
echo "     source <(grep -v '^#' ~/.config/free-image-generation/.env)"
echo ""
echo "   Or set them in your .bashrc / .zshrc:"
echo "     [ -f ~/.config/free-image-generation/.env ] && source <(grep -v '^#' ~/.config/free-image-generation/.env)"
echo ""
echo "$(bold "Providers configured:")"
grep -c '="[^"]\{3,\}"' "$ENV_FILE" || true
echo "   (plus Pollinations.ai which always works without keys)"
