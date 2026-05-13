#!/bin/bash
set -e

echo "🗄️ Installing DBeaver CE..."

# Download the latest .deb package
TEMP_DEB="/tmp/dbeaver-ce-latest.deb"
wget -O "$TEMP_DEB" "https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb"

# Install the package and its dependencies
sudo dpkg -i "$TEMP_DEB" || sudo apt-get install -f -y

# Clean up the temporary file
rm -f "$TEMP_DEB"

echo "✅ DBeaver CE installed successfully."
