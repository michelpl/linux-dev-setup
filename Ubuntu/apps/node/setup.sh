#!/bin/bash

# Re-exec with bash if called from sh/dash
if [ -z "${BASH_VERSION:-}" ]; then
  exec bash "$0" "$@"
fi

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NVM_DIR="$HOME/.nvm"
NVM_INSTALL_URL="https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh"

ask_node_version() {
  local default_version="lts/*"
  local versions_list=""

  # Try to get Node versions from Node.js API
  if command -v curl >/dev/null 2>&1; then
    echo "📡 Fetching available Node.js versions..."
    versions_list=$(curl -s https://nodejs.org/dist/index.json | grep -o '"version":"[^"]*"' | sed 's/"version":"//;s/"//' | head -20)
  fi

  if [ -n "$versions_list" ] && command -v whiptail >/dev/null 2>&1; then
    # Create menu options
    local menu_options=""
    local count=1

    # Add LTS option
    menu_options+="\"lts/*\" \"Latest LTS (recommended)\" "
    count=$((count + 1))

    # Add stable option
    menu_options+="\"stable\" \"Latest stable\" "
    count=$((count + 1))

    # Add recent versions
    echo "$versions_list" | head -10 | while read -r version; do
      # Remove 'v' prefix if present
      version=$(echo "$version" | sed 's/^v//')
      menu_options+="\"$version\" \"Node.js $version\" "
      count=$((count + 1))
    done

    # Add manual entry option
    menu_options+="\"manual\" \"Enter version manually\" "

    # Create the whiptail menu
    NODE_VERSION=$(eval "whiptail --title \"Select Node.js Version\" --menu \
      \"Choose Node.js version to install:\" 20 70 12 \
      $menu_options \
      3>&1 1>&2 2>&3")

    if [ "$NODE_VERSION" = "manual" ]; then
      NODE_VERSION=$(whiptail --title "Node.js Version" --inputbox \
        "Enter the Node.js version to install:\nExamples: lts/*, stable, 20.0.0" 10 60 "$default_version" 3>&1 1>&2 2>&3)
    fi

  elif [ -n "$versions_list" ]; then
    echo "Available Node.js versions (recent):"
    echo "1) lts/* - Latest LTS (recommended)"
    echo "2) stable - Latest stable"
    local count=3
    echo "$versions_list" | head -10 | while read -r version; do
      version=$(echo "$version" | sed 's/^v//')
      echo "$count) $version"
      count=$((count + 1))
    done
    echo "0) Enter manually"

    read -r -p "Select version number [1]: " choice
    choice="${choice:-1}"

    case $choice in
      1) NODE_VERSION="lts/*" ;;
      2) NODE_VERSION="stable" ;;
      0) read -r -p "Enter the Node.js version [$default_version]: " NODE_VERSION
         NODE_VERSION="${NODE_VERSION:-$default_version}" ;;
      *) NODE_VERSION=$(echo "$versions_list" | sed -n "${choice}p" | sed 's/^v//') ;;
    esac

  else
    # Fallback to simple input
    read -r -p "Enter the Node.js version to install [$default_version]: " NODE_VERSION
    NODE_VERSION="${NODE_VERSION:-$default_version}"
  fi

  NODE_VERSION="${NODE_VERSION:-$default_version}"
}

ensure_prerequisites() {
  echo "🔧 Installing prerequisites..."
  sudo apt update
  sudo apt install -y curl git ca-certificates build-essential libssl-dev
}

append_nvm_init() {
  local profile="$1"
  if [ ! -f "$profile" ]; then
    touch "$profile"
  fi

  if grep -q 'NVM_DIR' "$profile"; then
    return
  fi

  cat >> "$profile" <<'RC'
# NVM initialization
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
RC
}

install_nvm() {
  if [ -d "$NVM_DIR" ]; then
    echo "ℹ️ NVM already appears installed at $NVM_DIR"
  else
    echo "⬇️ Downloading and installing NVM..."
    curl -fsSL "$NVM_INSTALL_URL" | bash
  fi

  export NVM_DIR="$NVM_DIR"
  # shellcheck source=/dev/null
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

  if ! command -v nvm >/dev/null 2>&1; then
    echo "❌ Failed to load nvm. Check $NVM_DIR"
    exit 1
  fi
}

install_node() {
  echo "⬇️ Installing Node.js $NODE_VERSION via NVM..."
  nvm install "$NODE_VERSION"
  nvm alias default "$NODE_VERSION"
  nvm use default
}

show_success() {
  echo "✅ Node.js installed successfully!"
  command -v nvm >/dev/null 2>&1 && nvm --version && echo "nvm available"
  command -v node >/dev/null 2>&1 && node -v && echo "node available"
  command -v npm >/dev/null 2>&1 && npm -v && echo "npm available"
  echo "⚠️ Open a new terminal to load NVM automatically or run: source ~/.bashrc or source ~/.zshrc"
}

main() {
  ask_node_version
  ensure_prerequisites
  install_nvm
  append_nvm_init "$HOME/.bashrc"
  if [ -n "${ZSH_VERSION:-}" ] || [ -f "$HOME/.zshrc" ]; then
    append_nvm_init "$HOME/.zshrc"
  fi
  install_node
  show_success
}

main "$@"
