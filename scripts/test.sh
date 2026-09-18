#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
./scripts/test-version.sh
mkdir -p .build/module-cache
swiftc -swift-version 5 -warnings-as-errors -module-cache-path .build/module-cache \
  Sources/ScreenGeometry.swift Sources/ScreenGeometry.test.swift -o .build/geometry-tests
.build/geometry-tests
swiftc -swift-version 5 -warnings-as-errors -module-cache-path .build/module-cache \
  Sources/RefreshScheduler.swift Sources/RefreshScheduler.test.swift -o .build/scheduler-tests
.build/scheduler-tests
swiftc -swift-version 5 -warnings-as-errors -module-cache-path .build/module-cache \
  Sources/AppConfig.swift Sources/LoginItemController.swift Sources/DimmingMenuView.swift \
  Sources/DimPanel.swift Sources/AppSettings.test.swift -o .build/settings-tests
.build/settings-tests
plutil -lint Resources/Info.plist
