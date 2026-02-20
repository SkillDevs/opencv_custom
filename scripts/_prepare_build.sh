#!/bin/bash

set -eux

OPENCV_VERSION=4.13.0
DEPENDENCIES_PATH=.dependencies

rm -rf $DEPENDENCIES_PATH
mkdir -p $DEPENDENCIES_PATH

# OPENCV_SRC_PATH="$DEPENDENCIES_PATH/opencv_src"

pushd $DEPENDENCIES_PATH

# # Download and unpack sources
# wget -O opencv.zip https://github.com/opencv/opencv/archive/$OPENCV_VERSION.zip
wget -q -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/$OPENCV_VERSION.zip
# unzip opencv.zip
unzip -oq opencv_contrib.zip

popd # Dependencies dir

export CONTRIB_DIR="$DEPENDENCIES_PATH/opencv_contrib-$OPENCV_VERSION"
