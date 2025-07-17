#!/bin/bash

set -e

echo "📮 Installing Postman..."

POSTMAN_URL="https://dl.pstmn.io/download/latest/linux64"
INSTALL_DIR="$HOME/.local/share/Postman"
TMP_DIR="/tmp/postman"
BIN_DIR="$HOME/.local/bin"
BIN_LINK="$BIN_DIR/postman"
DESKTOP_FILE="$HOME/.local/share/applications/postman.desktop"

mkdir -p "$TMP_DIR"
cd "$TMP_DIR"

# Verifica se já está instalado
if [ -f "$INSTALL_DIR/Postman" ]; then
  echo "✅ Postman already installed at $INSTALL_DIR"

  mkdir -p "$BIN_DIR"
  if [ ! -f "$BIN_LINK" ]; then
    echo "🔗 Creating symlink: $BIN_LINK"
    ln -sf "$INSTALL_DIR/Postman" "$BIN_LINK"
  fi

  if whiptail --yesno "Postman is already installed. Do you want to launch it now?" 10 60; then
    "$INSTALL_DIR/Postman" &
  fi
  exit 0
fi

echo "⬇️ Downloading latest Postman..."
wget "$POSTMAN_URL" -O postman.tar.gz

echo "📦 Extracting to $INSTALL_DIR..."
mkdir -p "$INSTALL_DIR"
tar -xzf postman.tar.gz -C "$INSTALL_DIR" --strip-components=1

mkdir -p "$BIN_DIR"
ln -sf "$INSTALL_DIR/Postman" "$BIN_LINK"

echo "🧷 Creating desktop launcher..."
mkdir -p "$(dirname "$DESKTOP_FILE")"
cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Name=Postman
Comment=API Development Environment
Exec=$INSTALL_DIR/Postman
Icon=$INSTALL_DIR/app/resources/app/assets/icon.png
Type=Application
Categories=Development;API;
Terminal=false
EOF

echo "✅ Postman installed!"
echo "🚀 Run it from your application menu or with: postman"
