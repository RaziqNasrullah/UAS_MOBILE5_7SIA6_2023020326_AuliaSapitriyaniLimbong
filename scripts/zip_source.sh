#!/usr/bin/env bash
# Membuat ZIP source code untuk dikumpulkan (tanpa build/, .dart_tool/, .idea/, .gradle/, local.properties).
# Pemakaian (Git Bash / Linux / macOS):  bash scripts/zip_source.sh
set -euo pipefail
cd "$(dirname "$0")/.."
OUT="Delights_AuliaSapitriyaniLimbong_2023020326_source.zip"
rm -f "$OUT"
zip -r -q "$OUT" . \
  -x "build/*" "*/build/*" ".dart_tool/*" "*/.dart_tool/*" ".idea/*" "*/.idea/*" \
     ".gradle/*" "*/.gradle/*" "android/local.properties" ".git/*" "*.iml" \
     ".flutter-plugins-dependencies" "$OUT"
echo "Selesai: $OUT ($(du -h "$OUT" | cut -f1))"
