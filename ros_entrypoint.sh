#!/bin/bash
set -e

# setup ros environment
export KALIBR_MANUAL_FOCAL_LENGTH_INIT=1
source "$KALIBR_WORKSPACE/devel/setup.bash"
# source "/catkin_ws/devel/setup.bash"
exec "$@"
