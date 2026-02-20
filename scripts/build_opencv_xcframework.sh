#!/bin/bash
set -eux

# Builds a OpenCV XCFramework for iOS/iOS-Simulator and macOS development

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd $REPO_ROOT

./_prepare_build.sh

XCFRAMEWORK_OUT_DIR="build_xcframework"

python3 platforms/apple/build_xcframework.py --out $XCFRAMEWORK_OUT_DIR \
--contrib "$CONTRIB_DIR" \
--iphoneos_deployment_target 13.0 \
--iphoneos_archs arm64 \
--iphonesimulator_archs arm64,x86_64 \
--macosx_deployment_target 10.15 \
--macos_archs arm64,x86_64 \
--build_only_specified_archs \
--without objc

echo "Built to $XCFRAMEWORK_OUT_DIR"
