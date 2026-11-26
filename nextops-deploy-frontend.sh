#!/usr/bin/env bash
set -Eeuo pipefail
RESOURCE_GROUP="rg-nextops-dev-01"
APP_NAME="nextops-dashboard"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZIP_PATH="$ROOT_DIR/nextops-dashboard-build.zip"

command -v az >/dev/null 2>&1 || { echo "ERROR: Azure CLI required"; exit 1; }
[[ -f "$ZIP_PATH" ]] || { echo "ERROR: Missing $ZIP_PATH"; exit 1; }
az account show >/dev/null 2>&1 || { echo "ERROR: Run az login first"; exit 1; }

echo "Deploying prebuilt frontend ZIP to production slot (default)..."
# No --slot: az webapp deploy targets production by default.
# dist/ is already built; app settings/runtime/startup remain unchanged.
az webapp deploy \
  --resource-group "$RESOURCE_GROUP" \
  --name "$APP_NAME" \
  --src-path "$ZIP_PATH" \
  --type zip \
  --async false \
  --enable-kudu-warmup false
echo "Frontend deployment command completed."
