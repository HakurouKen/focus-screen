#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
version="$(./scripts/version.sh)"
./scripts/build.sh universal
lipo dist/Sidelit.app/Contents/MacOS/Sidelit -verify_arch arm64 x86_64
archive="Sidelit-$version-universal.zip"
package_dir="$(mktemp -d .build/sidelit-package.XXXXXX)"
trap 'rm -rf "$package_dir"' EXIT
ditto -c -k --sequesterRsrc --keepParent dist/Sidelit.app "$package_dir/$archive"
mv "$package_dir/$archive" "dist/$archive"
(
  cd dist
  shasum -a 256 "$archive" > "$archive.sha256"
)
printf 'Packaged: %s/dist/%s\n' "$PWD" "$archive"
