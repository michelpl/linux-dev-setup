#!/bin/bash

echo "🐳 Installing Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
sudo usermod -aG docker $USER
rm get-docker.sh

echo "✅ Docker installed. You may need to restart your session to use Docker without sudo."
