#!/bin/bash

set -eux

XCFRAMEWORK=opencv2.xcframework

function edit_xcframework() {
    for i in $( ls $XCFRAMEWORK ); do
        if [ -d $XCFRAMEWORK/$i ]; then
            echo $i

            FOLD="$XCFRAMEWORK/$i/opencv2.framework"

            # without this patch, the local framework works, but not the SPM binary package containing it
            plutil -insert CFBundleExecutable -string opencv2 ${FOLD}/Versions/A/Resources/Info.plist

            # The resources in Versions/A are the correct ones and we move them to the root
            cp $FOLD/Versions/A/Resources/* $FOLD/Resources
        fi
    done

}

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

edit_xcframework
fix_shallow ios-arm64
fix_shallow ios-arm64_x86_64-simulator



