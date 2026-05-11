#!/bin/bash

set -euo pipefail

echo "📦 Node.js Installer (NVM + npm)"

# Instala NVM se necessário (fonte oficial do projeto nvm)
if [ ! -d "$HOME/.nvm" ]; then
  echo "🔧 Installing NVM (Node Version Manager)..."
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
fi

# Carrega NVM
export NVM_DIR="$HOME/.nvm"
# shellcheck source=/dev/null
source "$NVM_DIR/nvm.sh"

if ! command -v nvm >/dev/null 2>&1; then
  echo "❌ NVM was not loaded correctly."
  exit 1
fi

# Busca versões da fonte oficial do Node.js
NODE_INDEX_JSON=$(mktemp)
trap 'rm -f "$NODE_INDEX_JSON"' EXIT

if ! curl -fsSL "https://nodejs.org/dist/index.json" -o "$NODE_INDEX_JSON"; then
  echo "❌ Unable to fetch Node.js versions from https://nodejs.org/dist/index.json"
  exit 1
fi

mapfile -t NODE_VERSIONS < <(
  python3 - "$NODE_INDEX_JSON" <<'PY'
import json
import sys

path = sys.argv[1]
with open(path, 'r', encoding='utf-8') as f:
    data = json.load(f)

versions = []
seen = set()
for entry in data:
    version = entry.get('version', '').lstrip('v')
    if not version or version in seen:
        continue
    seen.add(version)
    versions.append(version)

latest = versions[0] if versions else ''
lts = ''
for entry in data:
    if entry.get('lts'):
        lts = entry.get('version', '').lstrip('v')
        break

majors = []
seen_major = set()
for version in versions:
    major = version.split('.')[0]
    if major not in seen_major:
        seen_major.add(major)
        majors.append(version)
    if len(majors) >= 5:
        break

if latest:
    print(f"latest|Latest current ({latest})")
if lts:
    print(f"lts/*|Latest LTS ({lts})")
for v in majors:
    print(f"{v}|Latest {v.split('.')[0]}.x ({v})")
print("custom|Type a custom version")
PY
)

if [ "${#NODE_VERSIONS[@]}" -eq 0 ]; then
  echo "❌ No Node.js versions were found from the official index."
  exit 1
fi

if command -v node >/dev/null 2>&1; then
  CURRENT_NODE_VERSION=$(node -v)
  echo "ℹ️ Node.js already installed: $CURRENT_NODE_VERSION"

  if whiptail --title "Node.js already installed" --yesno \
    "Node.js $CURRENT_NODE_VERSION is already installed. Do you want to install/switch another version?" 10 75; then
    echo "🔄 Proceeding with Node.js version selection..."
  else
    echo "✅ Keeping current Node.js version: $CURRENT_NODE_VERSION"
    exit 0
  fi
fi

while true; do
  MENU_ARGS=()
  for item in "${NODE_VERSIONS[@]}"; do
    key=${item%%|*}
    label=${item#*|}
    MENU_ARGS+=("$key" "$label")
  done

  SELECTED=$(whiptail --title "Node.js Installer" --menu \
    "Select the Node.js version to install via NVM:" \
    22 78 12 "${MENU_ARGS[@]}" 3>&1 1>&2 2>&3) || {
      echo "⚠️ Version selection cancelled."
      break
    }

  NODE_VERSION="$SELECTED"
  if [ "$SELECTED" = "custom" ]; then
    NODE_VERSION=$(whiptail --title "Custom Node.js version" --inputbox \
      "Type a version supported by nvm (examples: 22, 20.12.2, lts/*, node):" \
      12 78 3>&1 1>&2 2>&3) || {
        echo "⚠️ Custom version input cancelled."
        continue
      }
  fi

  if [ -z "${NODE_VERSION// }" ]; then
    whiptail --title "Invalid value" --msgbox "Version cannot be empty." 8 50
    continue
  fi

  if ! whiptail --title "Confirm Installation" --yesno \
    "Install and set default Node.js version: $NODE_VERSION ?" 10 70; then
    echo "❌ Installation cancelled by user."
    continue
  fi

  echo "📥 Installing Node.js $NODE_VERSION via NVM..."
  nvm install "$NODE_VERSION"

  RESOLVED_VERSION=$(nvm version "$NODE_VERSION")
  if [ "$RESOLVED_VERSION" = "N/A" ]; then
    echo "❌ Unable to resolve installed version for $NODE_VERSION."
    continue
  fi

  nvm use "$RESOLVED_VERSION"
  nvm alias default "$RESOLVED_VERSION"

  INSTALLED_VERSION=$(node -v 2>/dev/null || true)
  if [ -n "$INSTALLED_VERSION" ]; then
    NPM_VERSION=$(npm -v 2>/dev/null || true)
    echo "✅ Node.js $INSTALLED_VERSION ready to use (npm $NPM_VERSION)."
    echo "ℹ️ Default nvm alias now points to $RESOLVED_VERSION."
  else
    echo "⚠️ Node.js version $NODE_VERSION may not have been installed correctly."
  fi

  if ! whiptail --title "Install Another?" --yesno \
    "Do you want to install/switch another Node.js version?" 10 65; then
    echo "👉 Continuing to next setup script..."
    break
  fi
done
