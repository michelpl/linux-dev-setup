#!/bin/bash

set -e

echo "🧰 Installing JetBrains Toolbox..."

INSTALL_DIR="$HOME/.local/share/JetBrains/Toolbox"
TMP_DIR="/tmp/jetbrains-toolbox"
BIN_DIR="$HOME/.local/bin"
BIN_LINK="$BIN_DIR/jetbrains-toolbox"
DESKTOP_FILE="$HOME/.local/share/applications/jetbrains-toolbox.desktop"
AUTOSTART_FILE="$HOME/.config/autostart/jetbrains-toolbox.desktop"

mkdir -p "$TMP_DIR"
cd "$TMP_DIR"

# 🧠 Tenta detectar a versão mais recente
SHA_URL="https://download.jetbrains.com/toolbox/jetbrains-toolbox.tar.gz.sha256"
ACTUAL_URL=$(curl -sI "$SHA_URL" | grep -i location | awk '{print $2}' | tr -d '\r\n')

if [[ "$ACTUAL_URL" =~ jetbrains-toolbox-([0-9.]+)\.tar\.gz ]]; then
  LATEST_VERSION="${BASH_REMATCH[1]}"
  echo "📦 Detected latest version: $LATEST_VERSION"
else
  echo "❌ Failed to detect Toolbox version automatically."
  LATEST_VERSION=$(whiptail --inputbox "Enter JetBrains Toolbox version manually (e.g. 2.6.3.43718):" 10 60 3>&1 1>&2 2>&3)

  if [ -z "$LATEST_VERSION" ]; then
    echo "❌ No version provided. Aborting installation."
    exit 1
  fi
fi

TOOLBOX_FILENAME="jetbrains-toolbox-${LATEST_VERSION}.tar.gz"
DOWNLOAD_URL="https://download.jetbrains.com/toolbox/$TOOLBOX_FILENAME"

# Verifica se já está instalado
if [ -f "$INSTALL_DIR/bin/jetbrains-toolbox" ]; then
  echo "✅ JetBrains Toolbox already installed at $INSTALL_DIR"

  mkdir -p "$BIN_DIR"
  if [ ! -f "$BIN_LINK" ]; then
    echo "🔗 Creating symlink to $BIN_LINK"
    ln -sf "$INSTALL_DIR/bin/jetbrains-toolbox" "$BIN_LINK"
  fi

  if whiptail --yesno "Toolbox is already installed. Do you want to launch it now?" 10 60; then
    "$INSTALL_DIR/bin/jetbrains-toolbox" &
  fi
  exit 0
fi

# Baixa somente se necessário
if [ ! -f "$TOOLBOX_FILENAME" ]; then
  echo "⬇️ Downloading JetBrains Toolbox v$LATEST_VERSION..."
  wget "$DOWNLOAD_URL" -O "$TOOLBOX_FILENAME"
else
  echo "📂 Using cached $TOOLBOX_FILENAME"
fi

echo "📦 Extracting..."
tar -xzf "$TOOLBOX_FILENAME"
cd jetbrains-toolbox-*/

echo "🚀 Running Toolbox installer..."
./jetbrains-toolbox &

# Aguarda instalação
sleep 5

# Cria .desktop launcher
if [ ! -f "$DESKTOP_FILE" ]; then
  echo "🧷 Creating application launcher..."
  mkdir -p "$(dirname "$DESKTOP_FILE")"
  cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=JetBrains Toolbox
Comment=Manage your JetBrains IDEs
Exec=$INSTALL_DIR/bin/jetbrains-toolbox
Icon=$INSTALL_DIR/.install-info/toolbox.svg
Terminal=false
Categories=Development;IDE;
StartupWMClass=jetbrains-toolbox
EOF
fi

# Cria symlink para terminal
mkdir -p "$BIN_DIR"
ln -sf "$INSTALL_DIR/bin/jetbrains-toolbox" "$BIN_LINK"

# Adiciona à inicialização se o usuário quiser
if whiptail --yesno "Do you want JetBrains Toolbox to start automatically on login?" 10 60; then
  mkdir -p "$(dirname "$AUTOSTART_FILE")"
  cp "$DESKTOP_FILE" "$AUTOSTART_FILE"
  echo "✅ Toolbox added to autostart."
fi

echo "✅ JetBrains Toolbox v$LATEST_VERSION installed!"
echo "🚀 You can run it with: jetbrains-toolbox"
echo "🔎 Or find it in your application menu."
