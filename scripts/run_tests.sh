#!/usr/bin/env bash

set -ex

xcodebuild -version
xcodebuild -project AltTabX.xcodeproj -scheme Release -showBuildSettings | grep SWIFT_VERSION

set -o pipefail && xcodebuild test -project AltTabX.xcodeproj -scheme Test -configuration Release | scripts/xcbeautify
