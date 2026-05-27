#!/usr/bin/env bash
set -euo pipefail

if docker compose version >/dev/null 2>&1; then
  echo "Docker Compose v2 is already available:"
  docker compose version
else
  echo "Installing Docker..."
  curl -fsSL https://get.docker.com -o get-docker.sh
  sh get-docker.sh
  rm -f get-docker.sh
fi

if ! groups "$USER" | grep -q '\bdocker\b'; then
  echo "Adding $USER to the docker group..."
  sudo usermod -aG docker "$USER"
  echo "You may need to log out and back in to use Docker without sudo."
fi

echo "Enabling Docker service..."
sudo systemctl enable --now docker

if ! docker compose version >/dev/null 2>&1; then
  echo "ERROR: docker compose v2 is not available after installation." >&2
  exit 1
fi

echo "Docker is ready:"
docker compose version
