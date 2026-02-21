#!/bin/bash

set -eux

python3 platforms/ios/build_framework.py --out "$FRAMEWORK_OUT" \
    --contrib "$CONTRIB_DIR" \
    --iphoneos_deployment_target 13.0 \
    --iphonesimulator_archs arm64,x86_64 \
    --build_only_specified_archs \
    --without objc
