#!/bin/bash
set -euo pipefail
repo_root="$(cd "$(dirname "$0")/.." && pwd)"
version="$(cat "$repo_root/VERSION")"
if [[ ! "$version" =~ ^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$ ]]; then
  printf 'VERSION 必须是三段数字版本，例如 0.1.0，不带 v 前缀或预发布后缀。\n' >&2
  exit 1
fi
if [[ $# -gt 1 || ( $# -eq 1 && "$1" != "$version" ) ]]; then
  printf '输入版本必须与 VERSION 一致：%s\n' "$version" >&2
  exit 1
fi
printf '%s\n' "$version"
