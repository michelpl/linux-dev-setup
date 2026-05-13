#!/bin/bash
set -e

echo "🗑️ Uninstalling JetBrains Rider..."

RIDER_CONFIG="$HOME/.config/JetBrains"
RIDER_CACHE="$HOME/.cache/JetBrains"
RIDER_APP="$HOME/.local/share/JetBrains"

rm -rf "$RIDER_CONFIG/Rider*" "$RIDER_CACHE/Rider*" "$RIDER_APP/Rider*"

echo "✅ Rider removed."
