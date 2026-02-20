#!/bin/bash
set -eux

# Builds a OpenCV XCFramework for iOS/iOS-Simulator and macOS development

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd $REPO_ROOT

OPENCV_VERSION=4.13.0
DEPENDENCIES_PATH=.dependencies

rm -rf $DEPENDENCIES_PATH
mkdir -p $DEPENDENCIES_PATH

# OPENCV_SRC_PATH="$DEPENDENCIES_PATH/opencv_src"

pushd $DEPENDENCIES_PATH

# # Download and unpack sources
# wget -O opencv.zip https://github.com/opencv/opencv/archive/$OPENCV_VERSION.zip
wget -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/$OPENCV_VERSION.zip
# unzip opencv.zip
unzip opencv_contrib.zip

popd # Dependencies dir

CONTRIB_DIR="$DEPENDENCIES_PATH/opencv_contrib-$OPENCV_VERSION"

XCFRAMEWORK_OUT_DIR="build_xcframework"

python3 platforms/apple/build_xcframework.py --out $XCFRAMEWORK_OUT_DIR \
--contrib $CONTRIB_DIR \
--iphoneos_deployment_target 13.0 \
--iphoneos_archs arm64 \
--iphonesimulator_archs arm64,x86_64 \
--macosx_deployment_target 10.15 \
--macos_archs arm64,x86_64 \
--build_only_specified_archs \
--disable-bitcode \
--without objc

ls -R $XCFRAMEWORK_OUT_DIR
