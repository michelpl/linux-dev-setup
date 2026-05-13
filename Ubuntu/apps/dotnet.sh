#!/bin/bash

set -euo pipefail

echo "🟣 .NET SDK Installer (Multiple Versions)"

DOTNET_INSTALL_DIR="$HOME/.dotnet"
DOTNET_INSTALL_SCRIPT="dotnet-install.sh"
RELEASE_INDEX_URL="https://dotnetcli.blob.core.windows.net/dotnet/release-metadata/releases-index.json"

RELEASE_INDEX_JSON=$(mktemp)
trap 'rm -f "$RELEASE_INDEX_JSON"' EXIT

if ! curl -fsSL "$RELEASE_INDEX_URL" -o "$RELEASE_INDEX_JSON"; then
  echo "❌ Unable to fetch .NET release index from $RELEASE_INDEX_URL"
  exit 1
fi

mapfile -t DOTNET_OPTIONS < <(
  python3 - "$RELEASE_INDEX_JSON" <<'PY'
import json
import sys

path = sys.argv[1]
with open(path, 'r', encoding='utf-8') as f:
    data = json.load(f)

releases = data.get('releases-index', [])
if not releases:
    raise SystemExit(0)

# releases-index is sorted by newest channel first
latest_channel = releases[0]
latest_sts = next((r for r in releases if r.get('support-phase', '').lower() == 'active' and not r.get('lts')), None)
latest_lts = next((r for r in releases if r.get('lts')), None)

seen = set()
def emit(tag, label):
    if tag and tag not in seen:
        seen.add(tag)
        print(f"{tag}|{label}")

if latest_channel.get('channel-version'):
    ch = latest_channel['channel-version']
    emit(f"channel:{ch}", f"Latest channel ({ch})")

if latest_lts and latest_lts.get('channel-version'):
    ch = latest_lts['channel-version']
    latest_sdk = latest_lts.get('latest-sdk', 'latest')
    emit(f"channel:{ch}", f"Latest LTS channel ({ch}, SDK {latest_sdk})")

if latest_sts and latest_sts.get('channel-version'):
    ch = latest_sts['channel-version']
    latest_sdk = latest_sts.get('latest-sdk', 'latest')
    emit(f"channel:{ch}", f"Latest STS channel ({ch}, SDK {latest_sdk})")

for rel in releases[:6]:
    ch = rel.get('channel-version')
    if not ch:
        continue
    phase = rel.get('support-phase', 'unknown')
    latest_sdk = rel.get('latest-sdk', 'latest')
    emit(f"channel:{ch}", f"Channel {ch} ({phase}, latest SDK {latest_sdk})")

emit("custom", "Type a custom SDK version")
PY
)

if [ "${#DOTNET_OPTIONS[@]}" -eq 0 ]; then
  echo "❌ No .NET release channels were found from the official source."
  exit 1
fi

ensure_dotnet_script() {
  echo "📥 Downloading official dotnet-install.sh..."
  curl -fsSL "https://dot.net/v1/dotnet-install.sh" -o "$DOTNET_INSTALL_SCRIPT"
  chmod +x "$DOTNET_INSTALL_SCRIPT"
}

persist_dotnet_env() {
  for SHELL_RC in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [ -f "$SHELL_RC" ]; then
      grep -qxF 'export DOTNET_ROOT="$HOME/.dotnet"' "$SHELL_RC" || echo 'export DOTNET_ROOT="$HOME/.dotnet"' >> "$SHELL_RC"
      grep -qxF 'export PATH="$HOME/.dotnet:$PATH"' "$SHELL_RC" || echo 'export PATH="$HOME/.dotnet:$PATH"' >> "$SHELL_RC"
      grep -qxF 'export PATH="$HOME/.dotnet/tools:$PATH"' "$SHELL_RC" || echo 'export PATH="$HOME/.dotnet/tools:$PATH"' >> "$SHELL_RC"
    fi
  done
}

while true; do
  MENU_ARGS=()
  for item in "${DOTNET_OPTIONS[@]}"; do
    key=${item%%|*}
    label=${item#*|}
    MENU_ARGS+=("$key" "$label")
  done

  SELECTED=$(whiptail --title ".NET SDK Installer" --menu \
    "Select the .NET SDK version/channel to install:" \
    22 90 14 "${MENU_ARGS[@]}" 3>&1 1>&2 2>&3) || {
      echo "⚠️ Selection cancelled. Returning to main menu."
      break
    }

  INSTALL_ARGS=()
  DESCRIPTION=""

  if [ "$SELECTED" = "custom" ]; then
    CUSTOM_VERSION=$(whiptail --title "Custom .NET SDK version" --inputbox \
      "Type a .NET SDK version (example: 8.0.204, 9.0.100):" \
      11 78 3>&1 1>&2 2>&3) || {
        echo "⚠️ Custom version input cancelled."
        continue
      }

    if [ -z "${CUSTOM_VERSION// }" ]; then
      whiptail --title "Invalid value" --msgbox "Version cannot be empty." 8 50
      continue
    fi

    INSTALL_ARGS=(--version "$CUSTOM_VERSION")
    DESCRIPTION="SDK version $CUSTOM_VERSION"
  else
    CHANNEL="${SELECTED#channel:}"
    if [ -z "$CHANNEL" ] || [ "$CHANNEL" = "$SELECTED" ]; then
      echo "❌ Invalid channel selection: $SELECTED"
      continue
    fi
    INSTALL_ARGS=(--channel "$CHANNEL")
    DESCRIPTION="latest SDK from channel $CHANNEL"
  fi

  if ! whiptail --title "Confirm Installation" --yesno \
    "Install $DESCRIPTION using official dotnet-install.sh?" 11 78; then
    echo "❌ Installation cancelled by user."
    continue
  fi

  ensure_dotnet_script

  echo "📥 Installing $DESCRIPTION to $DOTNET_INSTALL_DIR..."
  ./$DOTNET_INSTALL_SCRIPT "${INSTALL_ARGS[@]}" --install-dir "$DOTNET_INSTALL_DIR" --no-path

  persist_dotnet_env

  export DOTNET_ROOT="$HOME/.dotnet"
  export PATH="$HOME/.dotnet:$HOME/.dotnet/tools:$PATH"

  if ! command -v dotnet >/dev/null 2>&1; then
    echo "❌ dotnet command not found after installation."
    continue
  fi

  DOTNET_VERSION=$(dotnet --version 2>/dev/null || true)
  SDK_LIST=$(dotnet --list-sdks 2>/dev/null || true)

  if [ -n "$DOTNET_VERSION" ] && [ -n "$SDK_LIST" ]; then
    echo "✅ .NET SDK installation completed. Active SDK: $DOTNET_VERSION"
  else
    echo "⚠️ Installation finished, but SDK verification was inconclusive."
  fi

  if ! whiptail --title "Install Another?" --yesno \
    "Do you want to install another .NET SDK version/channel?" 10 70; then
    echo "👉 Installation finished. Reopen terminal if PATH updates are not reflected yet."
    break
  fi
done
