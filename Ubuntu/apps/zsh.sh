#!/bin/bash

set -e

echo "🐚 Installing and configuring Zsh and Oh My Zsh..."

sudo apt update
sudo apt install -y zsh

OMZ_DIR="$HOME/.oh-my-zsh"
if [ ! -d "$OMZ_DIR" ]; then
  echo "📦 Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  echo "🔄 Updating Oh My Zsh..."
  if git -C "$OMZ_DIR" pull --ff-only 2>/dev/null; then
    echo "✅ Oh My Zsh updated."
  else
    echo "⚠️ Could not update Oh My Zsh (network, conflict, or already up to date). Continuing."
  fi
fi

touch "$HOME/.zshrc"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
ALIAS_FILE_PATH="$SCRIPT_DIR/../configs/aliases.zsh"

if [ ! -f "$ALIAS_FILE_PATH" ]; then
  echo "❌ ERROR: aliases file not found: $ALIAS_FILE_PATH"
  exit 1
fi

TARGET_ALIAS="$HOME/.aliases.zsh"
echo "🔗 Updating symlink: $TARGET_ALIAS → $ALIAS_FILE_PATH"
ln -sf "$ALIAS_FILE_PATH" "$TARGET_ALIAS"

if ! grep -qF ".aliases.zsh" "$HOME/.zshrc"; then
  echo "📥 Adding alias file sourcing to ~/.zshrc"
  echo >>"$HOME/.zshrc"
  echo '[[ -f ~/.aliases.zsh ]] && source ~/.aliases.zsh' >>"$HOME/.zshrc"
fi

chsh -s "$(command -v zsh)"

echo "🔍 Verifying aliases load with ~/.zshrc..."
if ! zsh -ic 'whence projects' >/dev/null 2>&1; then
  echo "❌ ERROR: the \"projects\" alias is not available after loading ~/.zshrc."
  exit 1
fi
echo "✅ Aliases verified."

echo "✅ Zsh and aliases configured. Open a new terminal or run: refresh-zsh"
