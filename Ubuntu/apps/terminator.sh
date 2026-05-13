#!/bin/bash

set -e

echo "🖥️ Installing Terminator (terminal emulator)..."

sudo apt update
sudo apt install -y terminator

echo "🔗 Setting Terminator as the default system terminal (x-terminal-emulator)..."
TERMINATOR_BIN="$(command -v terminator)"
if [ -z "$TERMINATOR_BIN" ]; then
  echo "⚠️ terminator command not found in PATH."
else
  if sudo update-alternatives --set x-terminal-emulator "$TERMINATOR_BIN" 2>/dev/null; then
    echo "✅ Default terminal: $TERMINATOR_BIN"
  elif sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator "$TERMINATOR_BIN" 50 \
    && sudo update-alternatives --set x-terminal-emulator "$TERMINATOR_BIN"; then
    echo "✅ Default terminal registered and set: $TERMINATOR_BIN"
  else
    echo "⚠️ Could not set the default terminal via update-alternatives."
  fi
fi

if [ -n "$TERMINATOR_BIN" ] && command -v gsettings >/dev/null 2>&1; then
  if gsettings set org.gnome.desktop.default-applications.terminal exec "$TERMINATOR_BIN" 2>/dev/null; then
    echo "✅ GNOME: default terminal application updated."
  fi
fi

echo "✅ Terminator installed successfully."
