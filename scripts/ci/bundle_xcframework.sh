#!/bin/bash

set -eux

XCFRAMEWORK=opencv2.xcframework

function fix_shallow() {
    platform=$1
    pushd $XCFRAMEWORK/$platform/opencv2.framework

    rm -rf Headers Modules opencv2 Resources

    mv Versions/A/opencv2 .
    mv Versions/A/Resources/* .

    mv Versions/A/Headers .

    rm -rf Versions
    popd
}

rm -rf $XCFRAMEWORK

xcodebuild -create-xcframework \
    -framework build/framework-ios/opencv2.framework \
    -framework build/framework-simulator/opencv2.framework \
    -framework build/framework-macos/opencv2.framework \
    -output $XCFRAMEWORK

fix_shallow ios-arm64
fix_shallow ios-arm64_x86_64-simulator



