#!/bin/bash
set -e

echo "🌐 Installing Google Chrome..."

sudo apt-get install -y wget gnupg
# Download the latest .deb package from the official website
TEMP_DEB="/tmp/google-chrome-stable_current_amd64.deb"
wget -O "$TEMP_DEB" https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb

# Install the package
sudo dpkg -i "$TEMP_DEB" || sudo apt-get install -f -y

# Remove the temporary file
rm -f "$TEMP_DEB"

echo "✅ Google Chrome installed successfully."
