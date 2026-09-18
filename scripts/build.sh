#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p .build/module-cache dist/Sidelit.app/Contents/MacOS dist/Sidelit.app/Contents/Resources
swiftc -swift-version 5 -O -warnings-as-errors -module-cache-path .build/module-cache \
  -target "$(uname -m)-apple-macosx13.0" \
  Sources/ScreenGeometry.swift Sources/FocusReader.swift Sources/RefreshScheduler.swift \
  Sources/AppConfig.swift Sources/DimmingMenuView.swift Sources/LoginItemController.swift \
  Sources/DimPanel.swift Sources/StatusIcon.swift Sources/main.swift \
  -o dist/Sidelit.app/Contents/MacOS/Sidelit
cp Resources/Info.plist dist/Sidelit.app/Contents/Info.plist
cp Resources/AppIcon.icns dist/Sidelit.app/Contents/Resources/AppIcon.icns
codesign --force --sign - dist/Sidelit.app
printf 'Built: %s/dist/Sidelit.app\n' "$PWD"
