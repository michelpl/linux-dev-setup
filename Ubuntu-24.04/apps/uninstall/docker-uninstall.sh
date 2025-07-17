#!/bin/bash
set -e

echo "🧹 Removing Docker..."

# Remove Docker and dependencies
sudo apt-get purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo apt-get autoremove -y --purge docker-ce docker-ce-cli containerd.io

# Remove docker group if it exists
if getent group docker > /dev/null 2>&1; then
    sudo groupdel docker
fi

# Remove residual directories and files
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd

# Remove temporary script if it exists
rm -f ~/get-docker.sh

# Final message
echo "✅ Docker successfully removed." 