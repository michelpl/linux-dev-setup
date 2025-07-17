#!/bin/bash

set -e

DOTNET_INSTALL_DIR="$HOME/.dotnet"
DOTNET_BIN="$DOTNET_INSTALL_DIR/dotnet"

if [ ! -d "$DOTNET_INSTALL_DIR" ]; then
  echo "No .NET SDK installation found in $DOTNET_INSTALL_DIR."
  exit 0
fi

# List installed versions
INSTALLED_VERSIONS=$($DOTNET_BIN --list-sdks | awk '{print $1}')

if [ -z "$INSTALLED_VERSIONS" ]; then
  echo "No .NET SDK version found to uninstall."
  exit 0
fi

# Selection menu (tag/description pairs)
MENU_OPTIONS=("All versions" "Uninstall all .NET SDK versions")
for v in $INSTALLED_VERSIONS; do
  MENU_OPTIONS+=("$v" "Uninstall .NET SDK version $v")
done

CHOICE=$(whiptail --title ".NET SDK Uninstaller" --menu "Choose the version to uninstall:" 20 70 10 "${MENU_OPTIONS[@]}" 3>&1 1>&2 2>&3)

if [ "$CHOICE" == "All versions" ]; then
  echo "Removing all .NET SDK versions and related files in $DOTNET_INSTALL_DIR..."
  rm -rf "$DOTNET_INSTALL_DIR/sdk" \
         "$DOTNET_INSTALL_DIR/shared" \
         "$DOTNET_INSTALL_DIR/packs" \
         "$DOTNET_INSTALL_DIR/host" \
         "$DOTNET_INSTALL_DIR/templates" \
         "$DOTNET_INSTALL_DIR/dotnet" \
         "$DOTNET_INSTALL_DIR/metadata" \
         "$DOTNET_INSTALL_DIR/"*
  echo "All .NET SDK versions and related files removed."
else
  # Remove only the selected version
  echo "Removing .NET SDK version $CHOICE..."
  # Find and remove the corresponding directory(ies) for the version
  for dir in "$DOTNET_INSTALL_DIR"/sdk/"$CHOICE"*; do
    rm -rf "$dir"
  done
  for dir in "$DOTNET_INSTALL_DIR"/shared/Microsoft.NETCore.App/"$CHOICE"*; do
    rm -rf "$dir"
  done
  for dir in "$DOTNET_INSTALL_DIR"/packs/Microsoft.NETCore.App.Ref/"$CHOICE"*; do
    rm -rf "$dir"
  done
  echo ".NET SDK version $CHOICE removed."
fi

# Clean up if there are no more SDKs
if [ -d "$DOTNET_INSTALL_DIR/sdk" ] && [ -z "$(ls -A $DOTNET_INSTALL_DIR/sdk)" ]; then
  echo "No versions left. Removing directory $DOTNET_INSTALL_DIR."
  rm -rf "$DOTNET_INSTALL_DIR"
fi
