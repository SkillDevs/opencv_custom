#!/bin/bash

set -eux

# Download and unpack sources
wget -q -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/"$OPENCV_VERSION".zip
unzip -oq opencv_contrib.zip
