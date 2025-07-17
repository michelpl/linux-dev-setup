#!/bin/bash

set -e

echo "🖥️ Installing Terminator (terminal emulator)..."

sudo apt update
sudo apt install -y terminator

echo "✅ Terminator installed successfully."
