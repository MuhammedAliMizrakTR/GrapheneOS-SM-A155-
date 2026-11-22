#!/usr/bin/env bash
# Builds a plain Odin AP TAR for 1.2: no appended MD5, no LZ4 members.
# The plain TAR is retained as out/<APBASE>.tar and split only for release
# transport (GitHub's per-asset limit); joining parts reproduces that TAR.
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p work/stage out/dist

RTAG=$(cat work/gsi/TAG)
APBASE="AP_SM-A155F_RestlessOS-${RTAG}_${KERNEL_VARIANT}_${FW_VERSION}"
STAGE=work/stage
OUT_MEMBERS=work/ap/packed-members.txt
: > "$OUT_MEMBERS"

while IFS= read -r m; do
  [ -n "$m" ] || continue
  case "$m" in
    boot.img.lz4|boot.img)
      cp work/kernel/boot.img "$STAGE/boot.img"
      outname=boot.img
      echo "boot.img <- v1.0 kernel ($KERNEL_VARIANT), raw/uncompressed"
      ;;
    super.img.lz4|super.img)
      cp work/super_new.img "$STAGE/super.img"
      outname=super.img
      echo "super.img <- RestlessOS $RTAG + donor vendor stack, raw/uncompressed"
      ;;
    vbmeta*.img.lz4)
      outname="${m%.lz4}"
      cp "work/vbmeta/$outname" "$STAGE/$outname"
      echo "$outname <- verification-disabled, raw/uncompressed"
      ;;
    vbmeta*.img)
      outname="$m"
      cp "work/vbmeta/$outname" "$STAGE/$outname"
      echo "$outname <- verification-disabled, raw/uncompressed"
      ;;
    *.lz4)
      outname="${m%.lz4}"
      src="work/ap/small/$m"
      [ -f "$src" ] || { echo "FATAL: missing compressed member $src"; exit 1; }
      mkdir -p "$(dirname "$STAGE/$outname")"
      lz4 -d -f "$src" "$STAGE/$outname"
      echo "$outname <- stock member decompressed from $m"
      ;;
    *)
      outname="$m"
      if [ -d "work/ap/small/$m" ]; then
        mkdir -p "$STAGE/$outname"
      else
        mkdir -p "$(dirname "$STAGE/$outname")"
        cp "work/ap/small/$m" "$STAGE/$outname"
      fi
      echo "$outname (stock, uncompressed/unchanged)"
      ;;
  esac
  printf '%s\n' "$outname" >> "$OUT_MEMBERS"
done < work/ap/members.txt

if grep -q '\.lz4$' "$OUT_MEMBERS"; then
  echo "FATAL: packed member list still contains LZ4 names"; exit 1
fi
OUT_TAR="out/${APBASE}.tar"
( cd "$STAGE" && tar --no-recursion -cf "$OLDPWD/$OUT_TAR" -T "$OLDPWD/$OUT_MEMBERS" )
# Structural checks: plain TAR, exact ordered member list, and no MD5 trailer.
tar -tf "$OUT_TAR" > work/ap/packed-tar-list.txt
diff -u "$OUT_MEMBERS" work/ap/packed-tar-list.txt
TAR_SHA=$(sha256sum "$OUT_TAR" | cut -d' ' -f1)
printf '%s  %s.tar\n' "$TAR_SHA" "$APBASE" > "out/dist/${APBASE}.SHA256SUMS.txt"
split -b 1900M -d -a 2 "$OUT_TAR" "out/dist/${APBASE}.tar."
( cd out/dist && sha256sum "${APBASE}.tar."[0-9][0-9] >> "${APBASE}.SHA256SUMS.txt" )
echo "Plain AP TAR: $OUT_TAR ($(stat -c%s "$OUT_TAR") bytes), sha256=$TAR_SHA"
echo "Release transport parts (no compression/no MD5):"
ls -lh "out/dist/${APBASE}.tar."*
df -h . | tail -1
echo "=== AP packaged: ${APBASE}.tar (split for transport only; join to restore exactly this TAR) ==="
