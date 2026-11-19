#!/usr/bin/env bash
# Generates verification-disabled vbmeta images (flags=3 = disable verification
# + disable verity) — the standard "vbmeta_disabled" the A15 GSI guides flash.
# One per vbmeta* member present in the stock AP tar.
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p work/vbmeta
grep -E '^vbmeta[^/]*\.img(\.lz4)?$' work/ap/members.txt | while read -r m; do
  base="${m%.lz4}"
  python3 tools/avb/avbtool.py make_vbmeta_image --flags 3 --output "work/vbmeta/$base"
  echo "$m -> disabled ($base, $(stat -c%s "work/vbmeta/$base") bytes)"
done
ls -la work/vbmeta/
[ -f work/vbmeta/vbmeta.img ] || { echo "FATAL: stock AP has no vbmeta.img member?!"; exit 1; }
