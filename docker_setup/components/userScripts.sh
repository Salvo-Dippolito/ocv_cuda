#!/bin/bash
set -e
YE='\033[0;33m' # Yellow
NC='\033[0m' # No Color
echo -e $YE

echo "*************************************************************************"
echo "************************* Running user scripts **************************"
echo "*************************************************************************"
echo -e $NC

script_path=$(dirname $(realpath $0))

source "${script_path}/versions"

# Check that this script is not been run as root
if [ "$EUID" -eq 0 ]; then
    echo "This script should not be run as root, switch to a user first!"
    exit 1
fi



echo -e $YE
echo "*************************************************************************"
echo "********************** User scripts completed ***************************"
echo "*************************************************************************"
echo -e $NC