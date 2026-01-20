#!/bin/bash
set -e #exit on error

if test -n "$cuda"; then #cuda has been declared in the Dockerfile with ARG cuda, this checks if the variable has been declared
    script_path=$(dirname $(realpath $0))
    source "${script_path}/versions"

    YE='\033[0;33m' # Yellow
    NC='\033[0m' # No Color
    echo -e $YE
    echo "*************************************************************************"
    echo "*********************** Installing CUDA Components **********************"
    echo "*************************************************************************"
    echo -e $NC

    # --------------------- nvidia/cudagl:11.4.2-base-ubuntu20.04 ---------------------
    # https://gitlab.com/nvidia/container-images/cuda/-/blob/85f465ea3343a2d7f7753a0a838701999ed58a01/dist/12.5.1/ubuntu2204/base/Dockerfile

    # if using ubuntu 24 base image we have to downgrade the gcc and g++ compilers:
    # DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
    #     gcc-12 \
    #     g++-12
    # sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-12 100
    # sudo update-alternatives --set gcc /usr/bin/gcc-12

    # sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-12 100
    # sudo update-alternatives --set g++ /usr/bin/g++-12

    #^^^^ moved this downgrading bit to the openCV.sh

    # NVARCH=x86_64 is set in the versions file
    # Set up the CUDA repository
    DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
        gnupg2 curl ca-certificates
    curl -fsSLO https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/${NVARCH}/cuda-keyring_1.1-1_all.deb
    dpkg -i cuda-keyring_1.1-1_all.deb
    apt update

    # For libraries in the cuda-compat-* package: https://docs.nvidia.com/cuda/eula/index.html#attachment-a
    DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
        cuda-cudart-${CUDA_BASE_VERSION}=${NV_CUDA_CUDART_VERSION} \
        cuda-compat-${CUDA_BASE_VERSION} \
        #nvidia-cuda-toolkit 
    #cuda real time and cuda compatibility libraries

    # Installing cuda toolkit for Ubuntu 24
    wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-ubuntu2404.pin
    mv cuda-ubuntu2404.pin /etc/apt/preferences.d/cuda-repository-pin-600
    wget https://developer.download.nvidia.com/compute/cuda/12.8.0/local_installers/cuda-repo-ubuntu2404-12-8-local_12.8.0-570.86.10-1_amd64.deb
    dpkg -i cuda-repo-ubuntu2404-12-8-local_12.8.0-570.86.10-1_amd64.deb
    cp /var/cuda-repo-ubuntu2404-12-8-local/cuda-*-keyring.gpg /usr/share/keyrings/
    apt-get update
    apt-get -y install cuda-toolkit-12-8
    # ln -s cuda-11.4 /usr/local/cuda # FIXME: what was the purpose of this?

    # Required for nvidia-docker v1
    echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf
    echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf


    echo -e $YE
    echo "*************************************************************************"
    echo "*********************** CUDA Components Installed ***********************"
    echo "*************************************************************************"
    echo -e $NC
fi