#!/bin/bash

set -e

echo "🟣 .NET SDK Installer (Multiple Versions)"

while true; do

  SELECTED_VERSION=$(whiptail --title ".NET SDK Installer" --inputbox \
  "Enter the version of the .NET SDK you want to install (e.g. 6.0.100, 7.0.400, 8.0.100, 9.0.100):" \
  10 60 3>&1 1>&2 2>&3)

  if [ -z "$SELECTED_VERSION" ]; then
    echo "⚠️ No version entered. Returning to main menu."
    break
  fi

  if ! whiptail --title "Confirm Installation" --yesno \
  "Install .NET SDK version $SELECTED_VERSION?" 10 60; then
    echo "❌ Installation cancelled by user."
    break
  fi

  DOTNET_INSTALL_DIR="$HOME/.dotnet"
  DOTNET_INSTALL_SCRIPT="dotnet-install.sh"

  if [ ! -f "$DOTNET_INSTALL_SCRIPT" ]; then
    echo "📥 Downloading dotnet-install.sh..."
    wget -q https://dot.net/v1/dotnet-install.sh -O "$DOTNET_INSTALL_SCRIPT"
    chmod +x "$DOTNET_INSTALL_SCRIPT"
  fi

  echo "📥 Installing .NET SDK $SELECTED_VERSION to $DOTNET_INSTALL_DIR..."
  ./$DOTNET_INSTALL_SCRIPT --version "$SELECTED_VERSION" --install-dir "$DOTNET_INSTALL_DIR" --no-path

  # Add to PATH if not already present (avoid duplicating lines)
  for SHELL_RC in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [ -f "$SHELL_RC" ]; then
      grep -qxF 'export DOTNET_ROOT="$HOME/.dotnet"' "$SHELL_RC" || echo 'export DOTNET_ROOT="$HOME/.dotnet"' >> "$SHELL_RC"
      grep -qxF 'export PATH="$HOME/.dotnet:$PATH"' "$SHELL_RC" || echo 'export PATH="$HOME/.dotnet:$PATH"' >> "$SHELL_RC"
      grep -qxF 'export PATH="$HOME/.dotnet/tools:$PATH"' "$SHELL_RC" || echo 'export PATH="$HOME/.dotnet/tools:$PATH"' >> "$SHELL_RC"
    fi
  done

  export DOTNET_ROOT="$HOME/.dotnet"
  export PATH="$HOME/.dotnet:$HOME/.dotnet/tools:$PATH"

  INSTALLED_VERSION=$("$DOTNET_INSTALL_DIR/dotnet" --list-sdks | grep "^$SELECTED_VERSION" | head -n 1)

  if [ -n "$INSTALLED_VERSION" ]; then
    echo "✅ .NET SDK $SELECTED_VERSION installed successfully."
  else
    echo "⚠️ Failed to confirm installation of version $SELECTED_VERSION."
  fi

  if ! whiptail --title "Install Another?" --yesno \
  "Do you want to install another .NET SDK version?" 10 60; then
    echo "👉 Installation finished. If this is your first .NET installation, close and reopen your terminal to ensure the PATH is correct."
    break
  fi

done
