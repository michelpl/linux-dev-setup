#!/bin/bash

set -e

echo "🐙 Installing and configuring GitHub CLI (gh)..."

# ─────────────────────────────────────────────────────────────

if ! command -v gh &> /dev/null; then
  echo "📦 Installing GitHub CLI from official repo..."

  sudo apt update
  sudo apt install -y curl gpg

  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | \
    sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg

  sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg

  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] \
https://cli.github.com/packages stable main" | \
    sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

  sudo apt update
  sudo apt install -y gh
else
  echo "✅ GitHub CLI is already installed."
fi

# ─────────────────────────────────────────────────────────────

if gh auth status &>/dev/null; then
  echo "🔐 Already authenticated with GitHub CLI."
else
  echo "🔑 Starting authentication with GitHub..."
  gh auth login
fi

echo ""
echo "🧾 GitHub CLI Auth Status:"
gh auth status
