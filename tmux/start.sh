#!/bin/bash
# Plain-tmux session script (one window per section below; panes are split and
# their commands typed via send-keys). Edit the send-keys lines to change what
# runs in each pane; ./kill.sh stops everything.

SESSION_NAME=simulation

# absolute path to this script's directory; every pane starts here
SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

# commands executed first in every pane
PRE_WINDOW='export UAV_NAME=uav1; export RUN_TYPE=simulation; export UAV_TYPE=x500'
SETUP="cd $SCRIPTPATH; $PRE_WINDOW"

if [ -n "$TMUX" ]; then
  echo "Already inside tmux, detach first."
  exit 1
fi

if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
  echo "Session $SESSION_NAME already exists; attach with 'tmux a -t $SESSION_NAME' or stop it with ./kill.sh."
  exit 1
fi

# ---------------- window: roscore ----------------
read W_roscore P <<< "$(tmux new-session -d -s "$SESSION_NAME" -n "roscore" -x 250 -y 50 -P -F '#{window_id} #{pane_id}')"
tmux send-keys -t "$P" "$SETUP; "'roscore' Enter
tmux select-layout -t "$W_roscore" tiled

# ---------------- window: gazebo ----------------
read W_gazebo P <<< "$(tmux new-window -t "$SESSION_NAME" -n "gazebo" -P -F '#{window_id} #{pane_id}')"
tmux send-keys -t "$P" "$SETUP; "'waitForRos; roslaunch pairs_uav_gazebo_simulation simulation.launch gui:=true world_name:=forest' Enter
P=$(tmux split-window -t "$W_gazebo" -P -F '#{pane_id}')
tmux select-layout -t "$W_gazebo" tiled
tmux send-keys -t "$P" "$SETUP; "'waitForTime; roslaunch pairs_uav_px4_api api.launch' Enter
tmux select-layout -t "$W_gazebo" tiled

# ---------------- window: rviz ----------------
read W_rviz P <<< "$(tmux new-window -t "$SESSION_NAME" -n "rviz" -P -F '#{window_id} #{pane_id}')"
tmux send-keys -t "$P" "$SETUP; "'waitForHw; roslaunch pairs_uav_core rviz.launch' Enter
P=$(tmux split-window -t "$W_rviz" -P -F '#{pane_id}')
tmux select-layout -t "$W_rviz" tiled
tmux send-keys -t "$P" "$SETUP; "'waitForHw; roslaunch pairs_rviz_plugins load_robot.launch' Enter
P=$(tmux split-window -t "$W_rviz" -P -F '#{pane_id}')
tmux select-layout -t "$W_rviz" tiled
tmux send-keys -t "$P" "$SETUP; "'waitForHw; roslaunch pairs_rviz_plugins rviz_interface.launch' Enter
tmux select-layout -t "$W_rviz" tiled

# ---------------- window: spawn ----------------
read W_spawn P <<< "$(tmux new-window -t "$SESSION_NAME" -n "spawn" -P -F '#{window_id} #{pane_id}')"
tmux send-keys -t "$P" "$SETUP; "'waitForGazebo; rosservice call /pairs_drone_spawner/spawn "1 $UAV_TYPE --enable-rangefinder --enable-ouster use_gpu:=True"' Enter
tmux select-layout -t "$W_spawn" tiled

# ---------------- window: takeoff ----------------
read W_takeoff P <<< "$(tmux new-window -t "$SESSION_NAME" -n "takeoff" -P -F '#{window_id} #{pane_id}')"
tmux send-keys -t "$P" "$SETUP; "'waitForTime; roslaunch pairs_uav_autostart automatic_start.launch' Enter
P=$(tmux split-window -t "$W_takeoff" -P -F '#{pane_id}')
tmux select-layout -t "$W_takeoff" tiled
tmux send-keys -t "$P" "$SETUP; "'waitForControl; rosservice call /$UAV_NAME/hw_api/arming 1; sleep 2.0; rosservice call /$UAV_NAME/hw_api/offboard' Enter
tmux select-layout -t "$W_takeoff" tiled

# ---------------- window: status ----------------
read W_status P <<< "$(tmux new-window -t "$SESSION_NAME" -n "status" -P -F '#{window_id} #{pane_id}')"
tmux send-keys -t "$P" "$SETUP; "'waitForHw; roslaunch pairs_uav_status status.launch' Enter
tmux select-layout -t "$W_status" tiled

# ---------------- window: bumper ----------------
read W_bumper P <<< "$(tmux new-window -t "$SESSION_NAME" -n "bumper" -P -F '#{window_id} #{pane_id}')"
tmux send-keys -t "$P" "$SETUP; "'waitForHw; roslaunch pairs_bumper bumper.launch' Enter
tmux select-layout -t "$W_bumper" tiled

# ---------------- window: control ----------------
read W_control P <<< "$(tmux new-window -t "$SESSION_NAME" -n "control" -P -F '#{window_id} #{pane_id}')"
tmux send-keys -t "$P" "$SETUP; "'waitForTime; roslaunch pairs_uav_core core.launch platform_config:=`rospack find pairs_uav_gazebo_simulation`/config/pairs_uav_system/$UAV_TYPE.yaml custom_config:=./config/custom_config.yaml world_config:=./config/world_config.yaml network_config:=./config/network_config.yaml' Enter
tmux select-layout -t "$W_control" tiled

# ---------------- window: gazebo_camera_follow ----------------
read W_gazebo_camera_follow P <<< "$(tmux new-window -t "$SESSION_NAME" -n "gazebo_camera_follow" -P -F '#{window_id} #{pane_id}')"
tmux send-keys -t "$P" "$SETUP; "'waitForHw; gz camera -c gzclient_camera -f uav1; history -s gz camera -c gzclient_camera -f uav1' Enter
P=$(tmux split-window -t "$W_gazebo_camera_follow" -P -F '#{pane_id}')
tmux select-layout -t "$W_gazebo_camera_follow" tiled
tmux send-keys -t "$P" "$SETUP; "'waitForControl; ~/.i3/layout_manager.sh layout.json' Enter
tmux select-layout -t "$W_gazebo_camera_follow" tiled

# ---------------- window: kill (press enter inside to stop the session) ----------------
read W_kill P <<< "$(tmux new-window -t "$SESSION_NAME" -n "kill" -P -F '#{window_id} #{pane_id}')"
tmux send-keys -t "$P" "$SCRIPTPATH/kill.sh"

# mouse support (select panes / scroll with the mouse)
tmux set-option -t "$SESSION_NAME" mouse on

tmux select-window -t "$W_control"
tmux -2 attach-session -t "$SESSION_NAME"
