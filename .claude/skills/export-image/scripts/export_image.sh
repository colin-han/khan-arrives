#!/bin/bash
# 把话题目录下的 image.html 用 Chrome headless 导出为 image.png（放在同一目录）。
# 导出时去掉预览用的灰底与外边距，只截 1080×1440 画布本身。
# 用法: export_image.sh <话题目录或image.html路径> [scale]
#   scale 默认 2（输出 2160×2880，手机上更清晰）；传 1 输出 1080×1440。
set -euo pipefail

CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
TARGET="${1:?用法: export_image.sh <话题目录或image.html路径> [scale]}"
SCALE="${2:-2}"

if [ -d "$TARGET" ]; then
  HTML="$TARGET/image.html"
else
  HTML="$TARGET"
fi
[ -f "$HTML" ] || { echo "找不到 $HTML" >&2; exit 1; }

DIR="$(cd "$(dirname "$HTML")" && pwd)"
OUT="$DIR/image.png"

# 注入覆盖样式：去掉画布外边距和预览灰底，让画布顶满 1080×1440 视口
TMPDIR_EXPORT="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_EXPORT"' EXIT
sed 's|</head>|<style>html,body{background:none !important;margin:0 !important;padding:0 !important}.canvas{margin:0 !important}</style></head>|' \
  "$HTML" > "$TMPDIR_EXPORT/export.html"

"$CHROME" --headless --disable-gpu --hide-scrollbars \
  --window-size=1080,1440 \
  --force-device-scale-factor="$SCALE" \
  --screenshot="$OUT" \
  "file://$TMPDIR_EXPORT/export.html" 2>/dev/null

[ -f "$OUT" ] || { echo "截图失败" >&2; exit 1; }
echo "已导出: $OUT"
sips -g pixelWidth -g pixelHeight "$OUT" | tail -2
