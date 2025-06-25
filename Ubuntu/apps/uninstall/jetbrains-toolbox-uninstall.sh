#!/bin/bash
set -e

echo "🗑️ Uninstalling JetBrains Toolbox..."

TOOLBOX_DIR="$HOME/.local/share/JetBrains/Toolbox"
[ -d "$TOOLBOX_DIR" ] && rm -rf "$TOOLBOX_DIR"

DESKTOP_ENTRY="$HOME/.local/share/applications/jetbrains-toolbox.desktop"
[ -f "$DESKTOP_ENTRY" ] && rm -f "$DESKTOP_ENTRY"

echo "✅ JetBrains Toolbox removed."
