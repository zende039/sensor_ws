#!/usr/bin/env bash

set -euo pipefail

WORKSPACE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ -f "$WORKSPACE_ROOT/src/flir_camera_driver/spinnaker_camera_driver/scripts/linux_setup_flir" ]]; then
  echo "[setup_udev_rules] Running FLIR Linux setup helper"
  sudo "$WORKSPACE_ROOT/src/flir_camera_driver/spinnaker_camera_driver/scripts/linux_setup_flir" || true
fi

sudo usermod -aG video "$USER" || true
sudo usermod -aG dialout "$USER" || true

if command -v udevadm >/dev/null 2>&1; then
  sudo udevadm control --reload-rules || true
  sudo udevadm trigger || true
fi

echo "[setup_udev_rules] Added $USER to video/dialout. Log out and back in if this is the first run."

