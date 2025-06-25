#!/bin/bash
set -e

echo "🗑️ Uninstalling Postman..."

sudo rm -rf /opt/Postman
rm -f ~/.local/share/applications/postman.desktop

echo "✅ Postman removed."
