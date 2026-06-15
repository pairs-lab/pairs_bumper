# pairs_bumper

Reactive collision-avoidance sensor fusion for the PAIRS UAV stack. The bumper component fuses range and depth data from several onboard sensors — up/down 1D rangefinders, a depth camera, 3D LiDAR, and a 2D laser scanner — into a single set of obstacle "sectors" around the drone. Other parts of the stack subscribe to these obstacle sectors to keep the UAV from flying into nearby objects.

## Contents

- `pairs_bumper::Bumper` — composable node (`bumper` executable) that aggregates the sensor inputs and publishes obstacle sectors for reactive collision avoidance.
- `pairs_bumper::HistogramDisplayer` — composable node (`histogram_displayer` executable) that visualizes the depth-map histogram.
- `launch/bumper.launch.py` — starts the bumper component standalone or loads it into an existing container, with per-run-type configs (`config/simulation.yaml`, `config/realworld.yaml`).
- `launch/display_histogram.launch.py` — runs the histogram displayer.
- `tmux/` — a simulation session that brings up a UAV with the bumper running.

## Branches

- `ros1` — ROS 1 Noetic (catkin)
- `ros2` — ROS 2 Jazzy (ament_cmake)

## Install (ROS 2 Jazzy)

```bash
sudo apt install ros-jazzy-pairs-bumper
```

## Usage

```bash
ros2 launch pairs_bumper bumper.launch.py
```

Or run the full simulation session:

```bash
cd tmux && ./start.sh
```

## License
BSD 3-Clause. Derived from the CTU-MRS `pairs_bumper` package; the original
copyright is retained in [LICENSE](LICENSE).
