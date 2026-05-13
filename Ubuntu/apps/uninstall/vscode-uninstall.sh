#!/bin/bash
set -e

echo "🗑️ Uninstalling VS Code..."

sudo apt remove --purge -y code
sudo rm -f /etc/apt/sources.list.d/vscode.list
sudo rm -f /etc/apt/keyrings/packages.microsoft.gpg

echo "✅ VS Code removed."
