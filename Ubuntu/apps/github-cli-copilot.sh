#!/bin/bash

set -e

echo "🤖 Installing and configuring GitHub Copilot CLI (gh-copilot)..."

# ─────────────────────────────────────────────────────────────

if ! command -v gh &> /dev/null; then
  echo "❌ GitHub CLI (gh) is not installed. Please install it first."
  exit 1
fi

# Install gh-copilot extension if not already installed
if ! gh extension list | grep -q 'copilot'; then
  echo "📦 Installing gh-copilot extension..."
  gh extension install github/gh-copilot
else
  echo "✅ gh-copilot extension is already installed."
fi

# Authenticate if needed
if gh auth status &>/dev/null; then
  echo "🔐 Already authenticated with GitHub CLI."
else
  echo "🔑 Starting authentication with GitHub..."
  gh auth login
fi

echo ""
echo "🧾 GitHub Copilot CLI Status:"
gh copilot status || echo "ℹ️ Run 'gh copilot auth login' if not authenticated."

