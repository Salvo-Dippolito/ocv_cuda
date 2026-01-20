FROM ubuntu:latest

SHELL [ "/bin/bash" ]
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV TZ Europe/Rome

COPY components/aptUpdate.sh /tmp/components/aptUpdate.sh
RUN /tmp/components/aptUpdate.sh

##################### Components #####################
# Load component versions (changes on this file will make Docker rebuild all that follows)
COPY components/versions /tmp/components/versions

COPY components/base.sh /tmp/components/base.sh
RUN /tmp/components/base.sh

ARG cuda
COPY components/cuda.sh /tmp/components/cuda.sh
RUN /tmp/components/cuda.sh

ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64
ENV CUDA_HOME /usr/local/cuda

# # nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility

ARG openCV
COPY components/openCV.sh /tmp/components/openCV.sh
RUN /tmp/components/openCV.sh


# ARG openVINO
# COPY components/openVINO.sh /tmp/components/openVINO.sh
# RUN /tmp/components/openVINO.sh




#setting these up for userSetup.sh to write in them:
ARG username
ARG uid
ARG gid 

#user setup, removing root privileges
COPY components/userSetup.sh /tmp/components/userSetup.sh
RUN /tmp/components/userSetup.sh

USER ${username}
ENV PATH "$PATH:/usr/local/bin"
ENV HOME /home/${username}
WORKDIR /home/${username}/ws

# COPY components/userScripts.sh /tmp/components/userScripts.sh
# RUN /tmp/components/userScripts.sh


# Configure user environment
COPY target_bin/tmux.conf /home/${username}/.tmux.conf