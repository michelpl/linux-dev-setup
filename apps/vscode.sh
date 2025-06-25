#!/bin/bash

set -e

echo "🖥️ Installing Visual Studio Code from Microsoft APT repository..."

# Verifica se já está instalado
if command -v code &> /dev/null; then
  echo "✅ VS Code is already installed. Skipping installation."
  exit 0
fi

echo "📦 Setting up Microsoft APT repository for VS Code..."

# Instala dependências
sudo apt-get update
sudo apt-get install -y wget gpg

# Importa chave GPG
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
rm -f packages.microsoft.gpg

# Adiciona repositório
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
  | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null

# Atualiza e instala
sudo apt-get update
sudo apt-get install -y code

echo "✅ VS Code installed!"
echo "🚀 Run it using: code"
echo "🔎 Or find it in your application launcher."
