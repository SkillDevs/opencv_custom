#!/bin/bash

# Bundles the per-platform opencv2.framework builds (see build_*_framework.sh)
# into a "library type" opencv2.xcframework: one static archive + headers per
# slice. The frameworks produced by build_framework.py are static (the binary
# is an `ar` archive) and use macOS-style deep bundles, which iOS rejects when
# embedding. Exposing the archives directly avoids that: SPM/Cocoapods/CMake
# link them statically into the app, with no embedding or Info.plist patching.

set -eux

XCFRAMEWORK=opencv2.xcframework
STAGING=$(mktemp -d)
trap 'rm -rf "$STAGING"' EXIT

XCODEBUILD_ARGS=()

# Stage one slice from a built framework.
# The framework's Headers dir holds `core.hpp`, `core/...` etc., which clang
# resolves as <opencv2/...> only through the framework name. A library has no
# such namespace, so nest them under `include/opencv2/` to keep
# `#include <opencv2/core.hpp>` working. Cocoapods requires libraries to share
# the same name across slices, so each slice gets its own staging dir.
function stage_slice() {
    local platform=$1
    # The real files live in Versions/A; the top-level entries are symlinks
    # (or copies of them, after a round trip through upload-artifact).
    local fw="build/framework-$platform/opencv2.framework/Versions/A"
    local dest="$STAGING/$platform"

    mkdir -p "$dest/include/opencv2"
    cp -L "$fw/opencv2" "$dest/libopencv2.a"
    cp -RL "$fw/Headers/." "$dest/include/opencv2/"

    XCODEBUILD_ARGS+=(-library "$dest/libopencv2.a" -headers "$dest/include")
}

stage_slice ios
stage_slice simulator
stage_slice macos

rm -rf "$XCFRAMEWORK"

xcodebuild -create-xcframework "${XCODEBUILD_ARGS[@]}" -output "$XCFRAMEWORK"
