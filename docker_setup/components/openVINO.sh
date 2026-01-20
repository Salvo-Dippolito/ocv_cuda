#!/bin/bash
set -e

if [ -n "$openVINO" ]; then
    YE='\033[0;33m' # Yellow
    NC='\033[0m' # No Color
    echo -e $YE

    echo "*************************************************************************"
    echo "********************** Installing OpenVINO Components *******************"
    echo "*************************************************************************"
    echo -e $NC

    # --------------------- OpenCV from source ---------------------
    # Instruction from https://docs.openvinotoolkit.org/latest/openvino_docs_install_guides_installing_openvino_linux.html

    # Step 1: Download the GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB. You can also use the following command
    echo "Downloading OpenVINO GPG key"
    wget https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB

    # Step 2: Add this key to the system keyring
    echo "Adding OpenVINO GPG key"
    apt-key add GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB

    # Step 3: Add the repository via the following command
    echo "Adding OpenVINO repository"
    releaseName=$(lsb_release -cs)
    majorRel=$(lsb_release -rs | cut -f1 -d.)

    echo "Running Ubuntu ${majorRel} (${releaseName})"
    echo "deb https://apt.repos.intel.com/openvino/2024 ubuntu${majorRel} main" | tee /etc/apt/sources.list.d/intel-openvino-2024.list
    apt update

    # Step 4: Install OpenVINO Runtime
    apt-cache search openvino && \
        DEBIAN_FRONTEND=noninteractive apt install -y openvino-2024.2.0 || \
        $( echo "OpenVINO not found" && exit 1 )

    # -------------------- GPU Out-Of-Tree driver --------------------
    # Ref: https://dgpu-docs.intel.com/driver/client/overview.html

    wget -qO - https://repositories.intel.com/gpu/intel-graphics.key | \
        gpg --yes --dearmor --output /usr/share/keyrings/intel-graphics.gpg
    echo "deb [arch=amd64,i386 signed-by=/usr/share/keyrings/intel-graphics.gpg] https://repositories.intel.com/gpu/ubuntu ${releaseName} client" | \
        tee /etc/apt/sources.list.d/intel-gpu-${releaseName}.list
    apt update || { echo "Ubuntu ${releaseName} seems not supported. Exiting."; exit 1; }

    DEBIAN_FRONTEND=noninteractive apt install -y \
        intel-opencl-icd \
        intel-media-va-driver-non-free \
        libmfx1 \
        libmfxgen1 \
        libvpl2 \
        libigdgmm12 \
        libxatracker2 \
        mesa-va-drivers \
        vainfo \
        hwinfo \
        clinfo \
        intel-level-zero-gpu \
        level-zero \
        intel-level-zero-gpu-raytracing \
        va-driver-all \

    echo -e $YE
    echo "*************************************************************************"
    echo "********************** OpenVINO Components Installed ********************"
    echo "*************************************************************************"
    echo -e $NC
fi
