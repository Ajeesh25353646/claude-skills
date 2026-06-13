# Cloudflare Workers AI - Setup Guide

## Prerequisites

- A web browser
- An email address (no credit card required at any point)

## Step 1: Create a Cloudflare Account

1. Go to https://dash.cloudflare.com/sign-up/workers-and-pages
2. Enter your email and create a password
3. Verify your email address (check your inbox)
4. You will be asked to add a domain. Skip this — you do not need a domain for Workers AI. Click **Explore Dashboard** or **Skip** to proceed.

## Step 2: Go to Workers AI and Get Your Credentials

The fastest path: Cloudflare gives you both your API token and Account ID on the same page.

1. Open the Workers AI page: https://dash.cloudflare.com/?to=/:account/ai/workers-ai
2. Click **Use REST API**

### Get Your API Token

1. Click **Create a Workers AI API Token**
2. You will see a form with:
   - **Token name** — default is "Workers AI"
   - **Permissions** section with two rows:
     - Row 1: Resources = Account, Permissions = Workers AI, Type = Read
     - Row 2: Resources = Account, Permissions = Workers AI, Type = Edit
   - **Account Resources** section: Include → your account email
3. If the permissions rows are not there, click **Add** to add them:
   - Select **Account** for Resources
   - Select **Workers AI** for Permissions
   - Select **Read** for the first row
   - Add another row and select **Edit** for the second row
4. Make sure your account is listed under **Account Resources** → **Include**
5. Click **Create API Token** (bottom of form)
6. Click **Copy** to copy the token (starts with `cfut_`)
7. Save the token somewhere safe. You will set it as `CLOUDFLARE_API_TOKEN`.

**Important:** The token is shown only once on this screen. If you lose it, you will need to delete and recreate it.

### Get Your Account ID

On the same **Use REST API** page, look for the **Account ID** field. Click **Copy** to copy it. It is a long hex string like `f8a9b7c6d5e4f3a2b1c0d9e8f7a6b5c4`.

**Alternative:** You can also find your Account ID on the Account home page (https://dash.cloudflare.com) by clicking the menu button (three dots) next to your account name and selecting **Copy account ID**.

Save this value. You will set it as `CLOUDFLARE_ACCOUNT_ID`.

## Step 3: Verify Setup

Run a quick test to confirm everything works:

```bash
# Replace with your actual values
export CLOUDFLARE_API_TOKEN="your-api-token"
export CLOUDFLARE_ACCOUNT_ID="your-account-id"

# Test: generate a tiny 512x512 image
curl -s -X POST "https://api.cloudflare.com/client/v4/accounts/${CLOUDFLARE_ACCOUNT_ID}/ai/run/@cf/black-forest-labs/flux-1-schnell" \
  -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"prompt":"a cat","width":512,"height":512,"num_steps":4}' \
  | jq -r '.result.image' | base64 -d > /tmp/cf-test.jpg

# Check if the file was created and is valid
file /tmp/cf-test.jpg
ls -lh /tmp/cf-test.jpg
```

If you see `JPEG image data` and a reasonable file size (>1KB), the setup is working.

## Troubleshooting

| Problem | Likely Cause | Fix |
|---------|-------------|------|
| `"success": false` with `code: 10000` | Invalid or expired token | Regenerate the token on the Workers AI > Use REST API page |
| `"success": false` with `code: 10001` | Wrong Account ID | Double-check your Account ID from the Workers AI > Use REST API page |
| `"success": false` with `code: 10020` | Daily quota exceeded | Wait until 00:00 UTC for the reset, or use 512x512 images to stretch your quota |
| `curl: (6) Could not resolve host` | Network issue | Check your internet connection |
| `jq: command not found` | jq not installed | Install jq: `apt install jq` (Linux) or `brew install jq` (macOS) |
| `base64: invalid input` | Response was not a valid image | Run `curl -s ... | jq .` to see the raw error response |

## Environment Variables

Add these to your `.bashrc`, `.zshrc`, or `.env` file:

```bash
export CLOUDFLARE_API_TOKEN="your-api-token"
export CLOUDFLARE_ACCOUNT_ID="your-account-id"
```

## Free Plan Limits

- 10,000 neurons per day, reset at 00:00 UTC
- FLUX.1 Schnell at 1024x1024 (4 steps): ~173 neurons/image, ~57 images/day
- FLUX.1 Schnell at 512x512 (4 steps): ~43 neurons/image, ~231 images/day
- No credit card required at any point
