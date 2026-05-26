#!/usr/bin/env bash

set -euo pipefail

WORKSPACE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$WORKSPACE_ROOT"
source /opt/ros/humble/setup.bash

rosdep install --from-paths src --ignore-src -r -y

colcon build --symlink-install \
  --packages-up-to \
  spinnaker_camera_driver \
  spinnaker_synchronized_camera_driver \
  flir_camera_msgs \
  flir_camera_description \
  xsens_mti_ros2_driver \
  ntrip
