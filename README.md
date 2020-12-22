# kalibr-ros-xenial
It has been tested on amd64 and arm64 (jetson xavier nx) platform.
## Building
docker build --tag kalibr-ros-kinetic-xenial:latest .

## Running
```
docker run --gpus all -it -v /home/pri/workspace/catkin_ws:/catkin_ws kalibr-ros-kinetic-xenial:latest /bin/bash
```
or
```
bash run.bash
```