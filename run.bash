#!/usr/bin/env bash

# Runs a docker container with the image created by build_demo.bash
# Requires
#   docker
#   nvidia-docker2
#   an X server

# Make sure processes in the container can connect to the x server
# Necessary so gazebo can create a context for OpenGL rendering (even headless)
XAUTH=/tmp/.docker.xauth
if [ ! -f $XAUTH ]
then
    xauth_list=$(xauth nlist :0 | sed -e 's/^..../ffff/')
    if [ ! -z "$xauth_list" ]
    then
        echo $xauth_list | xauth -f $XAUTH nmerge -
    else
        touch $XAUTH
    fi
    chmod a+r $XAUTH
fi

docker run -it --rm \
  --runtime=nvidia \
  --env DISPLAY \
  --env QT_X11_NO_MITSHM=1 \
  --env XAUTHORITY=$XAUTH \
  --volume "$XAUTH:$XAUTH" \
  --volume "/tmp/.X11-unix:/tmp/.X11-unix" \
  --device /dev/i2c-8 \
  --device /dev/video0:/dev/video0 \
  --gpus all \
  -v /home/pri/workspace/catkin_ws:/catkin_ws \
  ros-kinetic-kalibr:v1.0 \
  /bin/bash