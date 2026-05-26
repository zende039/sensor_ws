#!/usr/bin/env bash

set -euo pipefail

sudo DEBIAN_FRONTEND=noninteractive apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
  build-essential \
  cmake \
  curl \
  git \
  libpcap-dev \
  python3-colcon-common-extensions \
  python3-dev \
  python3-pip \
  python3-rosdep \
  python3-vcstool \
  rsync

if [[ ! -f /etc/ros/rosdep/sources.list.d/20-default.list ]]; then
  sudo rosdep init || true
fi

rosdep update

