# Docker Setup for Computer Vision Development

A Docker-based development environment for computer vision applications with **CUDA** and **OpenCV** GPU acceleration support.

## Overview

This repository provides an automated setup for building and deploying a Docker container optimized for computer vision development. The container includes:

- **Ubuntu 24.04** base image
- **CUDA 12.6/12.8** toolkit for GPU acceleration
- **OpenCV 4.10.0** compiled from source with CUDA support
- Pre-configured development tools (tmux, vim, git, etc.)

## Prerequisites

- Linux host system
- Docker installed and configured
- NVIDIA GPU with appropriate drivers (for GPU acceleration)
- [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html) installed

## Repository Structure

```
docker_setup/
├── Dockerfile              # Main Docker image definition
├── setup.sh                # Main build and deployment script
├── components/             # Modular installation scripts
│   ├── aptUpdate.sh        # APT package manager update
│   ├── aptPurge.sh         # APT cleanup utilities
│   ├── base.sh             # Base system packages
│   ├── cuda.sh             # CUDA toolkit installation
│   ├── openCV.sh           # OpenCV compilation from source
│   ├── openVINO.sh         # Intel OpenVINO (optional)
│   ├── userSetup.sh        # User account configuration
│   ├── userScripts.sh      # User environment scripts
│   └── versions            # Version definitions for components
└── target_bin/             # Files copied to container
    ├── testOpenCV.py       # OpenCV test script
    └── tmux.conf           # tmux configuration
```

## Usage

### Building and Creating the Container

Run the setup script with the workspace directory as an argument:

```bash
./setup.sh <workspace_path>
```

**Example:**
```bash
./setup.sh workspace
```

This will:
1. Build a Docker image with the configured modules
2. Create a container with the specified workspace mounted
3. Generate helper scripts in your workspace directory

### Parameters

The script uses several configurable parameters (edit `setup.sh` to customize):

| Parameter | Default | Description |
|-----------|---------|-------------|
| `guest_username` | `salvo_` | Username inside the container |
| `cname` | `ubuntu24_ocv` | Container name |
| `modules` | `cuda,openCV` | Comma-separated list of modules to install |

### Available Modules

Modules are defined in the `components/` directory. Current add-on modules:

- `cuda` - NVIDIA CUDA toolkit (v12.6/12.8)
- `openCV` - OpenCV 4.10.0 with CUDA acceleration
- `openVINO` - Intel OpenVINO toolkit (commented out by default)

### Running the Container

After setup, two helper scripts are created in your workspace:

**Start/attach to the container:**
```bash
./workspace/<container_name>_run.sh
```

**Recreate the container (preserves the image):**
```bash
./workspace/<container_name>_recreate_container.sh
```

## Configuration

### Customizing Versions

Edit [components/versions](components/versions) to change component versions:

```bash
# CUDA Configuration
NV_CUDA_CUDART_VERSION=12.6.77-1
CUDA_BASE_VERSION=12-6
CUDA_ARCH_BIN=8.6  # Match your GPU's compute capability

# OpenCV Configuration
OPENCV_VERSION="4.10.0"
OPENCV_CONTRIB_VERSION="4.10.0"
```

> **Note:** Check your GPU's compute capability at [NVIDIA CUDA GPUs](https://developer.nvidia.com/cuda-gpus) and update `CUDA_ARCH_BIN` accordingly.

### Container Options

The setup script configures the container with:

- **GPU passthrough** (automatically detected NVIDIA GPUs)
- **X11 forwarding** for GUI applications
- **Host networking** for simplified network access
- **Workspace mounting** at `/home/<username>/workspace`
- **Device access** (`/dev/dri`, `/dev/video*`, etc.)

### Memory Configuration

During setup, you'll be prompted to set the container's memory limit. Default is 80% of system RAM.

## Testing the Installation

Inside the container, test OpenCV with CUDA:

```bash
python3 ~/bin/testOpenCV.py
```

Or verify CUDA availability:

```bash
nvcc --version
nvidia-smi
```

Test OpenCV CUDA support in Python:

```python
import cv2
print(cv2.cuda.getCudaEnabledDeviceCount())
```

## Troubleshooting

### Common Issues

**1. GPU not detected in container**
- Ensure NVIDIA Container Toolkit is installed
- Verify `nvidia-smi` works on the host
- Check if `--gpus all` is passed to Docker

**2. X11 display issues**
- Run `xhost +local:docker` on the host before starting the container
- Verify `$DISPLAY` is set correctly

**3. OpenCV CUDA compilation fails**
- Check `CUDA_ARCH_BIN` matches your GPU
- Ensure sufficient disk space (OpenCV build requires ~10GB)

**4. Permission denied errors**
- Verify UID/GID match between host and container user

## Adding Custom Modules

1. Create a new script in `components/` (e.g., `mymodule.sh`)
2. Use the standard pattern:
   ```bash
   #!/bin/bash
   set -e
   if test -n "$mymodule"; then
       # Installation commands here
   fi
   ```
3. Add the module to the `modules` variable in `setup.sh`
4. The module will automatically be detected and available

## License

This project is provided as-is for educational and development purposes.

## Contributing

Feel free to submit issues and pull requests for improvements.
