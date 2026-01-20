#!/bin/bash
set -e
YE='\033[0;33m' # Yellow
NC='\033[0m' # No Color

echo -e $YE
echo "*************************************************************************"
echo "********************** Installing Base Components ***********************"
echo "*************************************************************************"
echo -e $NC

DEBIAN_FRONTEND=noninteractive apt update

DEBIAN_FRONTEND=noninteractive apt install --no-install-recommends -y \
    udev \
    wget \
    curl \
    unzip \
    vim \
    lshw \
    gdb \
    libncurses-dev \
    dbus \
    dbus-x11 \
    libcanberra-gtk3-module \
    libcanberra-gtk3-0 \
    packagekit-gtk3-module \
    at-spi2-core \
    gedit \
    screen \
    lm-sensors \
    pciutils \
    python3-pip \
    terminator \
    libeigen3-dev \
    libopencv-dev \
    bash-completion \
    cmake
    # openjdk-8-jdk \
    # netcat \


# Ensure python points to python3
if [ ! -e /usr/bin/python ]; then
    ln -s /usr/bin/python3 /usr/bin/python
fi

DEBIAN_FRONTEND=noninteractive apt -yq --allow-downgrades install \
        lsb-release \
        btop \
        nvtop \
        tmuxinator \
        ranger \
        tzdata \
        git \
        git-lfs \
        vim \
        tmux \
        sudo \
        dialog \
        less \
        libnss3 \
        libboost-thread-dev \
        python3-libtmux

#python3-transforms3d \ isn't available for ubuntu 20.04 apparently




echo -e $YE
echo "*************************************************************************"
echo "********************** Base Components Installed ************************"
echo "*************************************************************************"
echo -e $NC