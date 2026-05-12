#!/bin/bash

# Re-exec with bash if called from sh/dash
if [ -z "${BASH_VERSION:-}" ]; then
  exec bash "$0" "$@"
fi

set -e

NVM_DIR="$HOME/.nvm"

remove_profile_entries() {
  local profile="$1"
  if [ ! -f "$profile" ]; then
    return
  fi

  sed -i '/# NVM initialization/,+2d' "$profile" || true
  sed -i '/NVM_DIR.*\.\/nvm.sh/d' "$profile" || true
  sed -i '/bash_completion/d' "$profile" || true
}

main() {
  echo "🧹 Removing NVM and shell configuration..."

  if [ -d "$NVM_DIR" ]; then
    rm -rf "$NVM_DIR"
    echo "🗑️ Removed NVM directory: $NVM_DIR"
  else
    echo "ℹ️ Directory $NVM_DIR not found. Skipping removal."
  fi

  remove_profile_entries "$HOME/.bashrc"
  remove_profile_entries "$HOME/.zshrc"

  if [ -d "$HOME/.npm" ]; then
    rm -rf "$HOME/.npm"
    echo "🗑️ Removed npm cache: $HOME/.npm"
  fi

  if [ -d "$HOME/.node-gyp" ]; then
    rm -rf "$HOME/.node-gyp"
    echo "🗑️ Removed node-gyp cache: $HOME/.node-gyp"
  fi

  echo "✅ NVM removed. Open a new terminal to ensure shell changes apply."
}

main "$@"
