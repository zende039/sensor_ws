# Sensor Workspace

ROS 2 Humble workspace for the vehicle hardware stack used by the teleoperation pipeline.

This repo is intended to provide the sensor-side packages that the hardware mode in `gopher-tele-op-pipeline` expects, especially:

- FLIR/Spinnaker cameras
- XSens MTi IMU/GNSS
- NTRIP correction client
- RoboSense LiDAR
- Continental ARS-408 radar
- Intel RealSense cameras
- SocketCAN adapter packages
- Dynamic object tracking/message packages

Generated workspace folders such as `build/`, `install/`, and `log/` are intentionally not tracked.
Vendor installers and large data archives are also intentionally not tracked.

## Layout

```text
sensor_ws/
├── src/
│   ├── flir_camera_driver/
│   ├── xsens_mti_ros2_driver/
│   ├── ntrip/
│   ├── rslidar_sdk/
│   ├── rslidar_msg/
│   ├── ars-408/
│   ├── realsense-ros/
│   ├── socketcan_adapter/
│   └── navigation2_dynamic/
├── config/
├── docs/
├── licenses/
└── README.md
```

## System Assumptions

- Ubuntu 22.04
- ROS 2 Humble
- `colcon`, `rosdep`, and normal ROS build tools
- Hardware SDKs installed separately where required

Install common ROS build tools:

```bash
sudo apt update
sudo apt install -y python3-colcon-common-extensions python3-rosdep python3-vcstool
```

Initialize `rosdep` if needed:

```bash
sudo rosdep init 2>/dev/null || true
rosdep update
```

## FLIR / Spinnaker Cameras

The FLIR camera packages live under:

```text
src/flir_camera_driver/
```

The runtime package used by hardware teleop is usually:

```bash
ros2 launch spinnaker_camera_driver multiple_cameras.launch.py
```

Install the Teledyne/FLIR Spinnaker SDK separately on the target machine before building or running the FLIR camera driver.

Official Spinnaker SDK download page:

https://www.teledynevisionsolutions.com/products/spinnaker-sdk/?model=Spinnaker%20SDK&vertical=machine%20vision&segment=iis

For Ubuntu 22.04 on x86_64, download the Linux/Ubuntu Spinnaker SDK package that matches the machine architecture and Python version you plan to use. The local development machine previously used Spinnaker `4.2.0.46` with Python 3.10 artifacts, but this repo intentionally does not commit the `.deb`, PySpin tarballs, or other large vendor archives.

Typical install flow after downloading the SDK archive:

```bash
mkdir -p ~/Downloads/spinnaker
cd ~/Downloads/spinnaker

# Extract the downloaded Teledyne/FLIR archive here, then install the debs.
# Exact filenames vary by SDK version.
tar -xzf spinnaker-*-amd64-*.tar.gz
cd spinnaker-*-amd64
sudo apt install -y ./*.deb
```

If you also need PySpin:

```bash
python3 -m pip install --user numpy matplotlib pillow

# Extract the PySpin archive from the SDK download, then install its wheel/tarball.
# Exact filename varies by SDK version and Python ABI.
python3 -m pip install --user ./spinnaker_python-*.tar.gz
```

After installing Spinnaker, apply USB/GigE camera permissions if the SDK installer did not already do it:

```bash
sudo usermod -aG video "$USER"
sudo usermod -aG dialout "$USER"
```

Log out and back in after changing groups.

After installing Spinnaker, verify camera visibility with the vendor tools first, then build this workspace.

Useful checks:

```bash
SpinView
lsusb
ip link
```

For GigE cameras, make sure the camera network interface has the expected static IP/subnet and that jumbo frames are configured if your camera setup requires them.

## XSens MTi IMU/GNSS

The XSens driver lives at:

```text
src/xsens_mti_ros2_driver/
```

Typical launch:

```bash
ros2 launch xsens_mti_ros2_driver xsens_mti_node.launch.py
```

Expected teleop topics include IMU/GNSS data consumed by the vehicle-side telemetry bridge.

## NTRIP

The NTRIP client package lives at:

```text
src/ntrip/
```

Typical launch:

```bash
ros2 launch ntrip ntrip_launch.py
```

Configure caster credentials and serial/network settings before field use.

## Build

From the workspace root:

```bash
cd ~/sensor_ws
source /opt/ros/humble/setup.bash
rosdep install --from-paths src --ignore-src -r -y
colcon build --symlink-install
source install/setup.bash
```

If you only need the camera, IMU, and NTRIP packages for teleop hardware mode:

```bash
colcon build --symlink-install \
  --packages-up-to \
  spinnaker_camera_driver \
  spinnaker_synchronized_camera_driver \
  flir_camera_msgs \
  flir_camera_description \
  xsens_mti_ros2_driver \
  ntrip
```

## Teleop Integration

The `gopher-tele-op-pipeline` hardware branch expects these packages to be available in the vehicle ROS environment before running:

```bash
source /opt/ros/humble/setup.bash
source ~/sensor_ws/install/setup.bash
```

Hardware mode starts:

```bash
ros2 launch spinnaker_camera_driver multiple_cameras.launch.py
ros2 launch ntrip ntrip_launch.py
ros2 launch xsens_mti_ros2_driver xsens_mti_node.launch.py
```

If those launches work manually, the teleop vehicle startup can use the same environment.

## Quick Checks

Check cameras:

```bash
ros2 topic list | grep -E 'cam|camera|image'
ros2 topic hz /cam_0/image_raw
```

Check IMU/GNSS:

```bash
ros2 topic list | grep -E 'imu|gnss|fix|xsens'
ros2 topic echo /imu/data --once
```

Check NTRIP:

```bash
ros2 topic list | grep -i ntrip
```

## Notes

- `docs/PYSPIN_README.md` and `docs/PYSPIN_README.zh.md` preserve the PySpin vendor readmes that were previously at the workspace root.
- Large archives from the local `Archive/` directory were not published.
- `build/`, `install/`, and `log/` should be regenerated locally with `colcon build`.
