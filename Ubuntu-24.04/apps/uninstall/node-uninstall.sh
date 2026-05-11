#!/bin/bash
set -euo pipefail

echo "🧹 Removing Node.js (NVM + npm)..."

NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

remove_nvm_block() {
  local file="$1"
  [ -f "$file" ] || return 0

  if grep -Fq "# >>> nvm auto-load >>>" "$file"; then
    sed -i '/# >>> nvm auto-load >>>/,/# <<< nvm auto-load <<</d' "$file"
    echo "ℹ️ Removed nvm auto-load block from $file"
  fi
}

if [ -d "$NVM_DIR" ]; then
  rm -rf "$NVM_DIR"
  echo "✅ Removed $NVM_DIR"
else
  echo "ℹ️ NVM directory not found at $NVM_DIR"
fi

remove_nvm_block "$HOME/.bashrc"
remove_nvm_block "$HOME/.zshrc"

# Optional: remove global npm cache and config created in user home
if [ -d "$HOME/.npm" ]; then
  rm -rf "$HOME/.npm"
  echo "✅ Removed $HOME/.npm"
fi

if [ -f "$HOME/.npmrc" ]; then
  rm -f "$HOME/.npmrc"
  echo "✅ Removed $HOME/.npmrc"
fi

echo "✅ Node.js/NVM uninstall completed."
