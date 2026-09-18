#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p .build/module-cache dist/FocusScreen.app/Contents/MacOS
swiftc -swift-version 5 -O -warnings-as-errors -module-cache-path .build/module-cache \
  -target "$(uname -m)-apple-macosx13.0" \
  Sources/ScreenGeometry.swift Sources/FocusReader.swift Sources/RefreshScheduler.swift \
  Sources/AppConfig.swift Sources/DimmingMenuView.swift Sources/LoginItemController.swift \
  Sources/DimPanel.swift Sources/main.swift \
  -o dist/FocusScreen.app/Contents/MacOS/FocusScreen
cp Resources/Info.plist dist/FocusScreen.app/Contents/Info.plist
codesign --force --sign - dist/FocusScreen.app
printf 'Built: %s/dist/FocusScreen.app\n' "$PWD"
