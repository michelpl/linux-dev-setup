#!/bin/bash
set -e

echo "🗑️ Uninstalling Zsh and related files..."

sudo apt remove --purge -y zsh
rm -rf ~/.oh-my-zsh ~/.aliases.zsh
sed -i '/.aliases.zsh/d' ~/.zshrc || true

echo "✅ Zsh removed."
