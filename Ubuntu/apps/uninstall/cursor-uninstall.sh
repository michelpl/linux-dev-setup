#!/bin/bash
set -e

# --- Variables ---
CURSOR_EXTRACT_DIR="/opt/Cursor"
DESKTOP_ENTRY_PATH="/usr/share/applications/cursor.desktop"

# Remove Cursor installation directory
if [ -d "$CURSOR_EXTRACT_DIR" ]; then
    echo "🧹 Removing Cursor installation directory..."
    sudo rm -rf "$CURSOR_EXTRACT_DIR"
else
    echo "ℹ️ Cursor installation directory not found. Skipping."
fi

# Remove .desktop entry
if [ -f "$DESKTOP_ENTRY_PATH" ]; then
    echo "🧹 Removing desktop entry..."
    sudo rm -f "$DESKTOP_ENTRY_PATH"
else
    echo "ℹ️ Desktop entry not found. Skipping."
fi

# Optionally remove icon if it was copied elsewhere (not needed if only in /opt/Cursor)

# Final message
echo "✅ Cursor successfully removed."
