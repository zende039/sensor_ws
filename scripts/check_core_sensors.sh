#!/usr/bin/env bash

set -euo pipefail

WORKSPACE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source /opt/ros/humble/setup.bash
if [[ -f "$WORKSPACE_ROOT/install/setup.bash" ]]; then
  source "$WORKSPACE_ROOT/install/setup.bash"
fi

echo "== Packages =="
ros2 pkg list | grep -E 'spinnaker|flir|xsens|ntrip' || true

echo
echo "== Launch files =="
ros2 launch spinnaker_camera_driver multiple_cameras.launch.py --show-args || true
ros2 launch xsens_mti_ros2_driver xsens_mti_node.launch.py --show-args || true
ros2 launch ntrip ntrip_launch.py --show-args || true
