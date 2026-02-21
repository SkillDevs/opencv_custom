#!/bin/bash

set -eux

python3 platforms/osx/build_framework.py --out "$FRAMEWORK_OUT" \
    --contrib "$CONTRIB_DIR" \
    --macosx_deployment_target 10.15 \
    --macos_archs arm64,x86_64 \
    --build_only_specified_archs \
    --without objc
