#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p .build/module-cache .build/Sidelit.iconset
swift -swift-version 5 -warnings-as-errors -module-cache-path .build/module-cache \
  scripts/generate-icons.swift .build/Sidelit.iconset
iconutil -c icns .build/Sidelit.iconset -o Resources/AppIcon.icns
printf 'Generated: %s/Resources/AppIcon.icns\n' "$PWD"
