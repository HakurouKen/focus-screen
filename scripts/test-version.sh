#!/bin/bash
set -euo pipefail
repo_root="$(cd "$(dirname "$0")/.." && pwd)"
test_dir="$(mktemp -d "${TMPDIR:-/tmp}/sidelit-version.XXXXXX")"
trap 'rm -rf "$test_dir"' EXIT
mkdir -p "$test_dir/scripts"
cp "$repo_root/scripts/version.sh" "$test_dir/scripts/version.sh"
for version in 0.1.0 1.0.0 12.34.56; do
  printf '%s\n' "$version" > "$test_dir/VERSION"
  test "$("$test_dir/scripts/version.sh" "$version")" = "$version"
done
for version in '' 1.0 v1.0.0 01.0.0 1.02.0 1.0.03 1.0.0-beta '1.0.0 ' $'1.0.0\n2.0.0'; do
  printf '%s\n' "$version" > "$test_dir/VERSION"
  if "$test_dir/scripts/version.sh" >/dev/null 2>&1; then
    printf '错误地接受了版本：%s\n' "$version" >&2
    exit 1
  fi
done
printf '0.1.0\n' > "$test_dir/VERSION"
if "$test_dir/scripts/version.sh" 0.2.0 >/dev/null 2>&1; then
  printf '未拒绝与 VERSION 不一致的输入。\n' >&2
  exit 1
fi
printf '版本格式与发布输入校验通过。\n'
