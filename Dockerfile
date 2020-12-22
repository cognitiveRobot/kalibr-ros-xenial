From ubuntu:16.04

RUN rm -rf /var/lib/apt/lists/*
RUN set -xe  \
	&& echo '#!/bin/sh' > /usr/sbin/policy-rc.d  \
	&& echo 'exit 101' >> /usr/sbin/policy-rc.d  \
	&& chmod +x /usr/sbin/policy-rc.d  \
	&& dpkg-divert --local --rename --add /sbin/initctl  \
	&& cp -a /usr/sbin/policy-rc.d /sbin/initctl  \
	&& sed -i 's/^exit.*/exit 0/' /sbin/initctl  \
	&& echo 'force-unsafe-io' > /etc/dpkg/dpkg.cfg.d/docker-apt-speedup  \
	&& echo 'DPkg::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' > /etc/apt/apt.conf.d/docker-clean  \
	&& echo 'APT::Update::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' >> /etc/apt/apt.conf.d/docker-clean  \
	&& echo 'Dir::Cache::pkgcache ""; Dir::Cache::srcpkgcache "";' >> /etc/apt/apt.conf.d/docker-clean  \
	&& echo 'Acquire::Languages "none";' > /etc/apt/apt.conf.d/docker-no-languages  \
	&& echo 'Acquire::GzipIndexes "true"; Acquire::CompressionTypes::Order:: "gz";' > /etc/apt/apt.conf.d/docker-gzip-indexes  \
	&& echo 'Apt::AutoRemove::SuggestsImportant "false";' > /etc/apt/apt.conf.d/docker-autoremove-suggests

ENV TZ=Pacific/Auckland
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN mkdir -p /run/systemd  \
	&& echo 'docker' > /run/systemd/container
CMD ["/bin/bash"]
RUN apt-get update  \
	&& apt-get install -q -y dirmngr gnupg2  \
	&& rm -rf /var/lib/apt/lists/*
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
RUN echo "deb http://packages.ros.org/ros/ubuntu xenial main" > /etc/apt/sources.list.d/ros1-latest.list
RUN apt-get update  \
	&& apt-get install --no-install-recommends -y python-rosdep python-rosinstall python-vcstools  \
	&& rm -rf /var/lib/apt/lists/*
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV ROS_DISTRO=kinetic
RUN rosdep init  \
	&& rosdep update --rosdistro $ROS_DISTRO
RUN apt-get update  \
	&& apt-get install -y ros-kinetic-desktop-full  \
	&& rm -rf /var/lib/apt/lists/*

RUN apt-get update  && apt-get install -y \
    python-setuptools \
    python-rosinstall \
    ipython \
    libeigen3-dev \
    libboost-all-dev \
    doxygen \
    libopencv-dev \
    ros-kinetic-vision-opencv \
    ros-kinetic-image-transport-plugins \
    ros-kinetic-cmake-modules \
    ros-kinetic-rviz \
    v4l-utils \
    python-software-properties \
    software-properties-common \
    libpoco-dev \
    python-matplotlib \
    python-scipy \
    python-git \
    python-pip \
    libtbb-dev \
    libblas-dev \
    liblapack-dev \
    python-catkin-tools \
    libxml2-dev \
    libz-dev    \
    flex \
    bison \
    automake \
    autoconf \
    libtool \
    libv4l-dev \
    wget 
RUN apt-get install -y python-igraph
RUN python -m pip install --upgrade pip; python -m pip install python-igraph

ENV KALIBR_WORKSPACE=/kalibr_workspace
RUN mkdir -p $KALIBR_WORKSPACE/src  \
	&& cd $KALIBR_WORKSPACE  \
	&& catkin init  \
	&& catkin config --extend /opt/ros/kinetic  \
	&& catkin config --cmake-args -DCMAKE_BUILD_TYPE=Release
RUN cd $KALIBR_WORKSPACE/src  \
	&& git clone https://github.com/adujardin/Kalibr.git
RUN cd $KALIBR_WORKSPACE  \
	&& catkin build -DCMAKE_BUILD_TYPE=Release -j4
COPY ros_entrypoint.sh /ros_entrypoint.sh
ENTRYPOINT ["/ros_entrypoint.sh"]

RUN mkdir -p /catkin_ws

# WORKDIR $KALIBR_WORKSPACE