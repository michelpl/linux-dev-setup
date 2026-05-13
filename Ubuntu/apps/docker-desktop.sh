#!/bin/bash
set -e

echo "🐳 Installing Docker Desktop..."

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Download the latest .deb package from the official website
TEMP_DEB="/tmp/docker-desktop-amd64.deb"
wget -O "$TEMP_DEB" "https://desktop.docker.com/linux/main/amd64/docker-desktop-4.31.0-amd64.deb?utm_source=docker&utm_medium=webreferral&utm_campaign=docs-driven-download-linux-amd64"

# Install the package
sudo dpkg -i "$TEMP_DEB" || sudo apt-get install -f -y

# Remove the temporary file
rm -f "$TEMP_DEB"

echo "✅ Docker Desktop installed successfully."