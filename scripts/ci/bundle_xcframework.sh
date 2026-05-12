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


# The upstream xcframework is "framework type" with macOS-style deep bundles
# in the iOS slices, which iOS rejects when embedding. The binary inside each
# slice is already a static `ar` archive, so the framework wrapping is just
# overhead. Build a derived "library type" xcframework that exposes the
# static archives directly: SPM/Cocoapods link them statically into the app
# binary (no embed, no deep-vs-shallow concern, no Info.plist patching).
# We keep `opencv2.xcframework` untouched so cmake reads it at compile time for headers.
OPENCV_STATIC_XCFRAMEWORK_PATH="$REPO_ROOT/$DEPENDENCIES_PATH/opencv2_static.xcframework"
OPENCV_STATIC_STAGING=$(mktemp -d)

# Cocoapods requires libraries inside an xcframework to share the same name
# across slices, so stage each in its own slice subdir.
mkdir -p "$OPENCV_STATIC_STAGING/ios-arm64" \
         "$OPENCV_STATIC_STAGING/ios-sim" \
         "$OPENCV_STATIC_STAGING/macos"
cp "$OPENCV_XCFRAMEWORK_PATH/ios-arm64/opencv2.framework/opencv2" \
    "$OPENCV_STATIC_STAGING/ios-arm64/libopencv2.a"
cp "$OPENCV_XCFRAMEWORK_PATH/ios-arm64_x86_64-simulator/opencv2.framework/opencv2" \
    "$OPENCV_STATIC_STAGING/ios-sim/libopencv2.a"
cp "$OPENCV_XCFRAMEWORK_PATH/macos-arm64_x86_64/opencv2.framework/opencv2" \
    "$OPENCV_STATIC_STAGING/macos/libopencv2.a"

rm -rf "$OPENCV_STATIC_XCFRAMEWORK_PATH"

xcodebuild -create-xcframework \
    -library "$OPENCV_STATIC_STAGING/ios-arm64/libopencv2.a" \
    -library "$OPENCV_STATIC_STAGING/ios-sim/libopencv2.a" \
    -library "$OPENCV_STATIC_STAGING/macos/libopencv2.a" \
    -output "$OPENCV_STATIC_XCFRAMEWORK_PATH" >/dev/null

rm -rf "$OPENCV_STATIC_STAGING"




