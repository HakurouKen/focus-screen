#!/bin/bash
set -euo pipefail

if [[ $# -gt 2 || "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  printf '用法：%s [正方形 PNG/JPG 图片] [输出.icns]\n' "$0"
  printf '默认：Resources/AppIcon.png → Resources/AppIcon.icns\n'
  [[ $# -le 2 ]]
  exit
fi

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
input_path="${1:-$repo_root/Resources/AppIcon.png}"
output_path="${2:-$repo_root/Resources/AppIcon.icns}"
[[ "$input_path" == /* ]] || input_path="$PWD/$input_path"
[[ "$output_path" == /* ]] || output_path="$PWD/$output_path"

if [[ ! -f "$input_path" ]]; then
  printf '找不到图片：%s\n' "$input_path" >&2
  exit 1
fi
if [[ "$input_path" == "$output_path" || "$input_path" -ef "$output_path" || -d "$output_path" || "$output_path" != *.icns ]]; then
  printf '输出必须是独立的 ICNS 文件路径。\n' >&2
  exit 1
fi

properties="$(sips -g format -g pixelWidth -g pixelHeight "$input_path")"
format="$(printf '%s\n' "$properties" | awk '$1 == "format:" {print $2}')"
width="$(printf '%s\n' "$properties" | awk '$1 == "pixelWidth:" {print $2}')"
height="$(printf '%s\n' "$properties" | awk '$1 == "pixelHeight:" {print $2}')"
if [[ "$format" != "png" && "$format" != "jpeg" ]]; then
  printf '仅支持 PNG 或 JPG/JPEG 图片。\n' >&2
  exit 1
fi
if [[ ! "$width" =~ ^[1-9][0-9]*$ || "$width" != "$height" ]]; then
  printf '请使用正方形图片，建议 1024×1024；当前尺寸：%s×%s。\n' "$width" "$height" >&2
  exit 1
fi

# 所有中间文件仅存在于本次转换的临时目录，失败时保留原有输出。
temp_dir="$(mktemp -d "${TMPDIR:-/tmp}/sidelit-icon.XXXXXX")"
trap 'rm -rf "$temp_dir"' EXIT
iconset="$temp_dir/AppIcon.iconset"
mkdir -p "$iconset"
for size in 16 32 128 256 512; do
  for scale in 1 2; do
    pixels=$((size * scale))
    suffix=""
    [[ "$scale" -eq 1 ]] || suffix="@2x"
    sips -s format png -z "$pixels" "$pixels" "$input_path" \
      --out "$iconset/icon_${size}x${size}${suffix}.png" >/dev/null
  done
done
iconutil -c icns "$iconset" -o "$temp_dir/AppIcon.icns"
mkdir -p "$(dirname "$output_path")"
cp "$temp_dir/AppIcon.icns" "$output_path"
printf 'Generated: %s\n' "$output_path"
