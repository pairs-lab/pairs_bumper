# pairs_bumper

Reactive collision-avoidance sensor fusion for the PAIRS UAV stack. The bumper nodelet fuses range and depth data from several onboard sensors — up/down 1D rangefinders, a depth camera, 3D LiDAR, and a 2D laser scanner — into a single set of obstacle "sectors" around the drone. Other parts of the stack subscribe to these obstacle sectors to keep the UAV from flying into nearby objects.

## Contents

- `pairs_bumper/Bumper` — nodelet that aggregates the sensor inputs and publishes obstacle sectors for reactive collision avoidance (declared in `nodelets.xml`).
- `histogram_displayer` — helper executable that visualizes the depth-map histogram.
- `launch/bumper.launch` — starts the bumper nodelet with per-run-type configs (`config/simulation.yaml`, `config/realworld.yaml`).
- `launch/display_histogram.launch` — runs the histogram displayer.
- `config/Bumper.cfg` — dynamic_reconfigure parameters for live tuning.
- `tmux/` — a Gazebo simulation session that brings up a UAV with the bumper running.

## Branches

- `ros1` — ROS 1 Noetic (catkin)
- `ros2` — ROS 2 Jazzy (ament_cmake)

## Install (ROS 1 Noetic)

```bash
sudo apt install ros-noetic-pairs-bumper
```

## Usage

```bash
roslaunch pairs_bumper bumper.launch
```

Or run the full simulation session:

```bash
cd tmux && ./start.sh
```

## License
BSD 3-Clause. Derived from the CTU-MRS `pairs_bumper` package; the original
copyright is retained in [LICENSE](LICENSE).
