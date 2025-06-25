#!/bin/bash

set -e

echo "🟣 .NET SDK Installer (Multiple Versions)"

while true; do

  SELECTED_VERSION=$(whiptail --title ".NET SDK Installer" --inputbox \
  "Enter the version of the .NET SDK you want to install (e.g. 6.0, 7.0, 8.0):" \
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

  if ! dpkg -l | grep -q packages-microsoft-prod; then
    echo "📦 Setting up Microsoft package feed..."
    wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
    sudo dpkg -i packages-microsoft-prod.deb
    rm packages-microsoft-prod.deb
    sudo apt update
  fi

  echo "📥 Installing .NET SDK $SELECTED_VERSION..."
  sudo apt install -y dotnet-sdk-"$SELECTED_VERSION"

  INSTALLED_VERSION=$(dotnet --list-sdks | grep "^$SELECTED_VERSION" | head -n 1)

  if [ -n "$INSTALLED_VERSION" ]; then
    echo "✅ .NET SDK $SELECTED_VERSION installed successfully."
  else
    echo "⚠️ Failed to confirm installation of version $SELECTED_VERSION."
  fi

  if ! whiptail --title "Install Another?" --yesno \
  "Do you want to install another .NET SDK version?" 10 60; then
    echo "👉 Continuing to next setup script..."
    break
  fi

done
