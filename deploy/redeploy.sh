#!/usr/bin/env bash
set -euo pipefail

# Rebuild the image and restart the container with the same name.
# Usage: ./deploy/redeploy.sh [NAME] [PIC]
#   e.g. ./deploy/redeploy.sh "Alice" "sample-pic.jpeg"

NAME="${1:-Friend}"
PIC="${2:-sample-pic.jpeg}"

echo "Building hbd-card (NAME=$NAME, PIC=$PIC)..."
docker build -t hbd-card \
  --build-arg NAME="$NAME" \
  --build-arg PIC="$PIC" \
  .

echo "Replacing hbd-web container..."
docker rm -f hbd-web 2>/dev/null || true

docker run -d --name hbd-web --restart unless-stopped \
  -p 80:8080 \
  hbd-card

echo "Done. Testing origin..."
sleep 1
curl -I http://localhost/birthday.html
