#!/usr/bin/env bash
set -Eeuo pipefail
RESOURCE_GROUP="rg-nextops-dev-01"
APP_NAME="nextops-be"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZIP_PATH="$ROOT_DIR/nextops-backend.zip"

command -v az >/dev/null 2>&1 || { echo "ERROR: Azure CLI required"; exit 1; }
[[ -f "$ZIP_PATH" ]] || { echo "ERROR: Missing $ZIP_PATH"; exit 1; }
az account show >/dev/null 2>&1 || { echo "ERROR: Run az login first"; exit 1; }

echo "Deploying backend ZIP to production slot (default)..."
# No --slot: az webapp deploy targets production by default.
# App settings/runtime/startup remain managed by Terraform.
az webapp deploy \
  --resource-group "$RESOURCE_GROUP" \
  --name "$APP_NAME" \
  --src-path "$ZIP_PATH" \
  --type zip \
  --async false \
  --enable-kudu-warmup false
echo "Backend deployment command completed."
