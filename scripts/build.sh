#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
version="$(./scripts/version.sh)"
build_number="${SIDELIT_BUILD_NUMBER:-1}"
if [[ ! "$build_number" =~ ^[1-9][0-9]{0,3}$ ]]; then
  printf 'SIDELIT_BUILD_NUMBER 必须是 1～9999 的整数。\n' >&2
  exit 1
fi
if [[ $# -gt 1 ]]; then
  printf '用法：%s [native|universal]\n' "$0" >&2
  exit 1
fi
case "${1:-native}" in
  native) architectures=("$(uname -m)") ;;
  universal) architectures=(arm64 x86_64) ;;
  *) printf '构建架构必须为 native 或 universal。\n' >&2; exit 1 ;;
esac
mkdir -p .build/module-cache dist/Sidelit.app/Contents/MacOS dist/Sidelit.app/Contents/Resources
sources=(
  Sources/ScreenGeometry.swift Sources/FocusReader.swift Sources/RefreshScheduler.swift
  Sources/AppConfig.swift Sources/DimmingMenuView.swift Sources/LoginItemController.swift
  Sources/DimPanel.swift Sources/StatusIcon.swift Sources/main.swift
)
build_dir="$(mktemp -d .build/sidelit-build.XXXXXX)"
trap 'rm -rf "$build_dir"' EXIT
binaries=()
for architecture in "${architectures[@]}"; do
  binary="$build_dir/Sidelit-$architecture"
  swiftc -swift-version 5 -O -warnings-as-errors -module-cache-path .build/module-cache \
    -target "$architecture-apple-macosx13.0" "${sources[@]}" -o "$binary"
  binaries+=("$binary")
done
if [[ ${#binaries[@]} -eq 1 ]]; then
  cp "${binaries[0]}" dist/Sidelit.app/Contents/MacOS/Sidelit
else
  lipo -create "${binaries[@]}" -output dist/Sidelit.app/Contents/MacOS/Sidelit
fi
cp Resources/Info.plist dist/Sidelit.app/Contents/Info.plist
/usr/libexec/PlistBuddy -c "Add CFBundleShortVersionString string $version" dist/Sidelit.app/Contents/Info.plist
/usr/libexec/PlistBuddy -c "Add CFBundleVersion string $build_number" dist/Sidelit.app/Contents/Info.plist
cp Resources/AppIcon.icns dist/Sidelit.app/Contents/Resources/AppIcon.icns
codesign --force --sign - dist/Sidelit.app
codesign --verify --deep --strict dist/Sidelit.app
printf 'Built: %s/dist/Sidelit.app (%s, build %s)\n' "$PWD" "$version" "$build_number"
