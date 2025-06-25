#!/bin/bash

set -e

echo "🐚 Installing ZSH and Oh My Zsh..."
sudo apt install -y zsh

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

chsh -s "$(which zsh)"

# Copia o arquivo de aliases (ajuste o caminho se necessário)
ALIAS_FILE_PATH="$(dirname "$0")/../configs/aliases.zsh"
TARGET_ALIAS="$HOME/.aliases.zsh"

if [ -f "$ALIAS_FILE_PATH" ]; then
  echo "🔗 Linking aliases to $TARGET_ALIAS"
  ln -sf "$ALIAS_FILE_PATH" "$TARGET_ALIAS"
else
  echo "⚠️ Alias file not found at $ALIAS_FILE_PATH"
fi

# Garante que o .aliases.zsh seja carregado no .zshrc
if ! grep -q ".aliases.zsh" "$HOME/.zshrc"; then
  echo "📥 Adding source command to .zshrc"
  echo '[[ -f ~/.aliases.zsh ]] && source ~/.aliases.zsh' >> "$HOME/.zshrc"
fi

echo "✅ ZSH and aliases configured. Restart your terminal to apply changes."
