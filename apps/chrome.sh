#!/bin/bash
set -e

echo "🌐 Installing Google Chrome..."

sudo apt-get install -y wget gnupg

# Baixa o pacote .deb mais recente do site oficial
TEMP_DEB="/tmp/google-chrome-stable_current_amd64.deb"
wget -O "$TEMP_DEB" https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb

# Instala o pacote
sudo dpkg -i "$TEMP_DEB" || sudo apt-get install -f -y

# Remove o arquivo temporário
rm -f "$TEMP_DEB"

echo "✅ Google Chrome installed successfully."
