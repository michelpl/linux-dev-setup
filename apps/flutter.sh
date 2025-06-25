#!/bin/bash

echo "💙 Installing Flutter..."

sudo apt install -y curl git unzip xz-utils

FLUTTER_DIR="$HOME/development/flutter"
mkdir -p "$(dirname "$FLUTTER_DIR")"
git clone https://github.com/flutter/flutter.git -b stable "$FLUTTER_DIR"

export PATH="$FLUTTER_DIR/bin:$PATH"

# Optionally: run flutter doctor
"$FLUTTER_DIR/bin/flutter" doctor

echo "✅ Flutter installed in $FLUTTER_DIR."
