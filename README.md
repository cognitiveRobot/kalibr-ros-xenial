# ros-kalibr-xenial
## Building
docker build --tag ros-kinetic-kalibr:v1.0 .

## Running
docker run --gpus all -it -v /home/pri/workspace/catkin_ws:/catkin_ws ros-kinetic-kalibr:v1.0 /bin/bash