#!/bin/bash

set -e

echo "📦 Node.js Installer (Multiple Versions via NVM)"

# Instala NVM se necessário
if [ ! -d "$HOME/.nvm" ]; then
  echo "🔧 Installing NVM (Node Version Manager)..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
fi

# Carrega NVM
export NVM_DIR="$HOME/.nvm"
# shellcheck source=/dev/null
source "$NVM_DIR/nvm.sh"

while true; do
  # Input com dica clara
  NODE_VERSION=$(whiptail --title "Node.js Installer" --inputbox \
  "Enter the version of Node.js you want to install.\n\nExamples:\n  - '20' (latest 20.x)\n  - '16.19.1' (specific version)\n  - 'lts' (latest stable version)\n" \
  15 70 3>&1 1>&2 2>&3)

  if [ -z "$NODE_VERSION" ]; then
    echo "⚠️ No version entered. Returning to main menu."
    break
  fi

  if ! whiptail --title "Confirm Installation" --yesno \
  "Install Node.js version: $NODE_VERSION?" 10 60; then
    echo "❌ Installation cancelled by user."
    break
  fi

  echo "📥 Installing Node.js $NODE_VERSION via NVM..."
  nvm install "$NODE_VERSION"
  nvm use "$NODE_VERSION"
  nvm alias default "$NODE_VERSION"

  INSTALLED_VERSION=$(node -v 2>/dev/null)
  if [[ "$INSTALLED_VERSION" == v$NODE_VERSION* || "$NODE_VERSION" == "lts" ]]; then
    echo "✅ Node.js $INSTALLED_VERSION installed successfully."
    npm -v
  else
    echo "⚠️ Node.js version $NODE_VERSION may not have been installed properly."
  fi

  if ! whiptail --title "Install Another?" --yesno \
  "Do you want to install another Node.js version?" 10 60; then
    echo "👉 Continuing to next setup script..."
    break
  fi

done
