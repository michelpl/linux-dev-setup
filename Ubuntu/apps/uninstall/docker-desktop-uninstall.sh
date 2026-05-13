#!/bin/bash
set -e

echo "🐳 Uninstalling Docker Desktop..."

sudo apt-get purge -y docker-desktop

# Remove the repository and GPG key
sudo rm /etc/apt/sources.list.d/docker.list
sudo rm /etc/apt/keyrings/docker.asc
sudo apt-get update

echo "✅ Docker Desktop uninstalled successfully."