#!/bin/bash
set -e

# apt cleanup
DEBIAN_FRONTEND=noninteractive apt clean -y
DEBIAN_FRONTEND=noninteractive apt autoremove --purge -y

# pip cleanup
command -v pip && pip cache purge

# deeper cleanup
rm -rf /var/lib/apt/lists/*
rm -rf /tmp/*

# user cleanup
rm -rf /root/*
rm -rf /home/${username}/.cache
