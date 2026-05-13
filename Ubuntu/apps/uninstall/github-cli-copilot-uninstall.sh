#!/bin/bash

set -e

echo "🗑️ Uninstalling GitHub Copilot CLI (gh-copilot) extension..."

# Check if gh is installed
if ! command -v gh &> /dev/null; then
  echo "❌ GitHub CLI (gh) is not installed. Nothing to do."
  exit 0
fi

# Uninstall gh-copilot extension if installed
if gh extension list | grep -q 'copilot'; then
  echo "🔧 Removing gh-copilot extension..."
  gh extension remove copilot
  echo "✅ gh-copilot extension removed."
else
  echo "ℹ️ gh-copilot extension is not installed."
fi

echo "Done."

