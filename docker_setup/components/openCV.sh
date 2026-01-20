#!/usr/bin/bash
set -e

if [ -n "$openCV" ]; then

    # Define fancy colors
    MA='\033[0;35m'   # Magenta
    CY='\033[0;36m'      # Cyan
    OR='\033[38;5;214m' # Orange
    NC='\033[0m'           # No Color
    YE='\033[0;33m' # Yellow
    
    echo -e $YE
    echo "*************************************************************************"
    echo "********************** Installing OpenCV Components *********************"
    echo "*************************************************************************"
    echo -e $NC
    script_path=$(dirname $(realpath $0))
    source "${script_path}/versions"

    # --------------------- OpenCV from source ---------------------

    # Check if the cuda module is compiled too
    if [ -n "$cuda" ]; then
        echo -e "${CY} Enabling cuda acceleration${NC}"
        ENABLE_CUDA=ON
    else
        echo -e "${CY} No cuda acceleration${NC}"
    fi

    echo -e "${CY} Removing python3-opencv   ${NC}"
    apt remove -y libopencv-dev python3-opencv

    PYTHON_VERSION=$(python3 --version | awk '{print $2}' | cut -d. -f1,2)
    echo -e "${CY} Installed python version is ${PYTHON_VERSION} ${NC}"
    echo -e "${CY} Installing necessary packages  ${NC}"

    DEBIAN_FRONTEND=noninteractive apt install --no-install-recommends -y \
        i965-va-driver \
        vainfo \
        libva-dev

    # List of packages to install
    packages=(
        "pkg-config"
        "libgtk2.0-dev"
        "libgtk-3-dev"
        "libavcodec-dev"
        "libavformat-dev"
        "libavutil-dev"
        "libswscale-dev"
        "libswresample-dev"
        "libx264-dev"
        "libtbbmalloc2"
        "libtbb-dev"
        "libjpeg-dev"
        "libpng-dev"
        "libtiff-dev"
        "v4l-utils"
        "gstreamer1.0-plugins-base"
        "gstreamer1.0-plugins-base-apps"
        "gstreamer1.0-plugins-good"
        "gstreamer1.0-plugins-bad"
        "gstreamer1.0-plugins-ugly"
        "libgstreamer1.0-dev"
        "libgstreamer-plugins-base1.0-dev"
        "libgstreamer-plugins-good1.0-dev"
        "libgstreamer-plugins-bad1.0-dev"
        "gstreamer1.0-tools"
        "gstreamer1.0-vaapi"
        "gstreamer1.0-libav"
        "gstreamer1.0-opencv"
        "gstreamer1.0-rtsp"
        "libatlas-base-dev"
        "libopenblas64-dev"
        "libopenblas64-0-openmp"
        "libaravis-dev"
        "aravis-tools"
        "aravis-tools-cli"
        "liblapack-dev"
        "tesseract-ocr"
        "libtesseract-dev"
        "libleptonica-dev"
        "python${PYTHON_VERSION}-dev"
        "liblapacke-dev"
        "liblapacke64-dev"
        
    )

    # Start installation process
    for package in "${packages[@]}"; do
        echo -e "${MA}Installing: $package...${NC}"
        if DEBIAN_FRONTEND=noninteractive apt install -y $package; then
            echo -e "${CY}Successfully installed: $package${NC}"
        else
            echo -e "${OR}Warning: Failed to install $package${NC}"
        fi
    done

    echo -e "${CY} Installing numpy with pip3   ${NC}"
    pip3 install numpy --break-system-packages # not from apt, it's different! (2024-07-23)
                                               # added the option here so that I don't need to install it in a specific python environment
                                               # needed for the ubuntu:24.04 image that uses PEP 668 that marks python packages as "externally managed"
    echo -e "${CY} Cloning OpenCV source directories  ${NC}"
    mkdir -p /opencv
    cd /opencv
    test -d opencv-${OPENCV_VERSION} || {
        wget -O opencv.zip https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip
        wget -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/${OPENCV_VERSION}.zip
        unzip opencv.zip
        unzip opencv_contrib.zip
        rm opencv.zip opencv_contrib.zip
    }
    cd opencv-${OPENCV_VERSION}

    #modify this if you need opencv for video processing
    #TO_DO: if this is enabled then you also need to download the nvidia sdk (to be matched with the cuda version on the host machine)
    #       in the docker image and link nvuvid and nvcenc librarie to the cmake command
    ENABLE_VIDEOACC=OFF
    echo -e "${CY} Downgrading g++ and gcc  ${NC}"
    echo -e "${CY}  ----  ${NC}"
    echo -e "${CY} gcc current version: $(gcc --version)  ${NC}"
    echo -e "${CY}  ----  ${NC}"
    echo -e "${CY} g++ current version: $(g++ --version)  ${NC}"
    # if using ubuntu 24 base image we have to downgrade the gcc and g++ compilers:
    DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
        gcc-12 \
        g++-12
    sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-12 100
    sudo update-alternatives --set gcc /usr/bin/gcc-12

    sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-12 100
    sudo update-alternatives --set g++ /usr/bin/g++-12
    echo -e "${YE}  =====  ${NC}"

    echo -e "${OR} gcc version after downgrade: $(gcc --version)  ${NC}"
    echo -e "${CY}  ----  ${NC}"
    echo -e "${OR} g++ version after downgrade: $(g++ --version)  ${NC}"

    echo -e "${CY}  ----  ${NC}"

    echo -e "${CY}  Configuring make file:  ${NC}"


    mkdir -p build && cd build
    cmake   -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib-${OPENCV_CONTRIB_VERSION}/modules \
            -D CMAKE_INSTALL_PREFIX=/usr/local \
            -D ENABLE_FAST_MATH=1 \
            -D OPENCV_GENERATE_PKGCONFIG=ON \
            -D OPENCV_ENABLE_NONFREE=ON  \
            -D WITH_GTK=ON \
            -D WITH_QT=OFF \
            -D WITH_TBB=ON \
            -D WITH_VA=ON \
            -D WITH_VA_INTEL=ON \
            -D WITH_CUDA=${ENABLE_CUDA:-OFF} \
            -D CUDA_ARCH_BIN=${CUDA_ARCH_BIN} \
            -D WITH_NVCUVID=${ENABLE_VIDEOACC} \
            -D WITH_NVCUVENC=${ENABLE_VIDEOACC} \
            -D BUILD_JPEG=ON \
            -D BUILD_OPENJPEG=ON \
            -D WITH_ARAVIS=ON  \
            -D WITH_OPENVINO=ON  \
            -D WITH_OPENNI2=OFF \
            -D WITH_EIGEN=ON  \
            -D WITH_V4L=ON \
            -D WITH_LIBV4L=ON \
            -D WITH_OPENGL=ON \
            -D WITH_IPP=ON \
            -D WITH_GSTREAMER=ON \
            -D WITH_FFMPEG=ON \
            -D WITH_REALSENSE=ON  \
            -D WITH_TESSERACT=ON \
            -D WITH_PYTHON3=ON \
            -D CMAKE_BUILD_TYPE=RELEASE \
            -D CPU_BASELINE=SSE4_2 \
            -D PYTHON3_EXECUTABLE=$(which python3) \
            -D PYTHON3_LIBRARY=/usr/lib/python${PYTHON_VERSION} \
            -D PYTHON3_INCLUDE_DIR=$(python3 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") \
            -D PYTHON3_PACKAGES_PATH=$(python3 -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())")  \
            -D BUILD_opencv_python2=OFF \
            -D BUILD_opencv_python3=ON \
            -D BUILD_PERF_TESTS=OFF \
            -D CMAKE_INCLUDE_PATH="/usr/include;/usr/include/x86_64-linux-gnu" \
            -D LAPACKE_INCLUDE_DIR="/usr/include;/usr/include/x86_64-linux-gnu" \
            -D BLAS_INCLUDE_DIR="/usr/include/x86_64-linux-gnu" \
            -D OPENCV_GENERATE_SETUPVARS=OFF \
            ..
    
    maxproc=$(( $(nproc) < 16 ? $(nproc) : 16 ))

    echo -e "${CY} Building OpenCV:  ${NC}"
    make -j 10 #substitute this numer with the variable above if you're confident
    echo -e "${CY} Installing Libraries:  ${NC}"
    make -j 10  install
    echo -e "${CY} Updating System's shared libraries ${NC}"
    ldconfig
    rm -rf /opencv

    echo -e $YE
    echo "*************************************************************************"
    echo "********************** OpenCV Components Installed **********************"
    echo "*************************************************************************"
    echo -e $NC
fi
