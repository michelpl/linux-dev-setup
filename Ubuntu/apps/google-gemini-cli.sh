#!/bin/bash

set -e

echo "✨ Installing Google Gemini CLI..."

# ─────────────────────────────────────────────────────────────

if ! command -v node &>/dev/null; then
  echo "❌ Node.js is not installed. Install it first from the Node.js option in this setup."
  exit 1
fi

if ! command -v npm &>/dev/null; then
  echo "❌ npm is not available. Please check your Node.js installation."
  exit 1
fi

echo "📦 Installing/updating @google/gemini-cli globally via npm..."
sudo npm install -g @google/gemini-cli

# ─────────────────────────────────────────────────────────────

if command -v gemini &>/dev/null; then
  GEMINI_VERSION=$(gemini --version 2>/dev/null || true)
  echo "✅ Google Gemini CLI installed successfully."
  if [ -n "$GEMINI_VERSION" ]; then
    echo "🧾 Version: $GEMINI_VERSION"
  fi
else
  echo "⚠️ Installation finished, but 'gemini' command was not found in PATH."
  echo "💡 Try opening a new terminal session and running: gemini --version"
fi

echo ""
echo "🔐 To authenticate, run: gemini"
echo "👉 Follow the interactive login flow in your terminal."
