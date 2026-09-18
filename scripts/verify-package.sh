#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
version="$(./scripts/version.sh)"
archive="Sidelit-$version-universal.zip"
(
  cd dist
  shasum -a 256 -c "$archive.sha256"
)
verify_dir="$(mktemp -d "${TMPDIR:-/tmp}/sidelit-verify.XXXXXX")"
trap 'rm -rf "$verify_dir"' EXIT
ditto -x -k "dist/$archive" "$verify_dir"
app="$verify_dir/Sidelit.app"
test -x "$app/Contents/MacOS/Sidelit"
test -s "$app/Contents/Resources/AppIcon.icns"
test "$(/usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' "$app/Contents/Info.plist")" = "$version"
test "$(/usr/libexec/PlistBuddy -c 'Print CFBundleVersion' "$app/Contents/Info.plist")" = "${SIDELIT_BUILD_NUMBER:-1}"
test "$(/usr/libexec/PlistBuddy -c 'Print LSMinimumSystemVersion' "$app/Contents/Info.plist")" = "13.0"
lipo "$app/Contents/MacOS/Sidelit" -verify_arch arm64 x86_64
codesign --verify --deep --strict "$app"
printf '发布包版本、构建号、双架构、签名与校验和均通过。\n'
