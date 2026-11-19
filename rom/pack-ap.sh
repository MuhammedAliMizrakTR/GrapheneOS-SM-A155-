#!/usr/bin/env bash
# Assembles the final Odin AP tar: stock member names and order, with our
# kernel (boot), the rebuilt super, and disabled vbmeta images swapped in.
# Appends the md5 (Samsung .tar.md5 convention), splits for the 2 GB
# release-asset limit, and writes SHA256SUMS.
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p work/stage out/dist

RTAG=$(cat work/gsi/TAG)
APBASE="AP_SM-A155F_RestlessOS-${RTAG}_${KERNEL_VARIANT}_${FW_VERSION}"
STAGE=work/stage

while read -r m; do
  [ -n "$m" ] || continue
  case "$m" in
    boot.img.lz4)
      lz4 -l -9 -f work/kernel/boot.img "$STAGE/boot.img.lz4" \
        || { lz4 -f work/kernel/boot.img "$STAGE/boot.img.lz4"; }
      echo "boot.img.lz4   <- OUR v1.0 kernel ($KERNEL_VARIANT, lz4-legacy)"
      ;;
    boot.img)
      cp work/kernel/boot.img "$STAGE/boot.img"
      echo "boot.img       <- OUR v1.0 kernel ($KERNEL_VARIANT, raw)"
      ;;
    super.img.lz4)
      lz4 -l -9 -f work/super_new.img "$STAGE/super.img.lz4" \
        || lz4 -9 -f work/super_new.img "$STAGE/super.img.lz4"
      echo "super.img.lz4  <- RestlessOS $RTAG system + stock vendor stack"
      ;;
    super.img)
      cp work/super_new.img "$STAGE/super.img"
      echo "super.img      <- RestlessOS $RTAG system + stock vendor stack"
      ;;
    vbmeta*.img|vbmeta*.img.lz4)
      base="${m%.lz4}"
      cp "work/vbmeta/$base" "$STAGE/$m"
      echo "$m -> disabled (flags=3)"
      ;;
    *)
      cp "work/ap/small/$m" "$STAGE/$m"
      echo "$m (stock, untouched)"
      ;;
  esac
done < work/ap/members.txt

OUT_TAR="out/${APBASE}.tar"
( cd "$STAGE" && tar -cf "$OLDPWD/$OUT_TAR" -T "$OLDPWD/work/ap/members.txt" )
MD5=$(md5sum "$OUT_TAR" | cut -d' ' -f1)
printf '%s  %s\n' "$MD5" "${APBASE}.tar.md5" >> "$OUT_TAR"
mv "$OUT_TAR" "out/${APBASE}.tar.md5"
echo "AP tar: $(stat -c%s "out/${APBASE}.tar.md5") bytes, md5=$MD5"

split -b 1900M -d "out/${APBASE}.tar.md5" "out/dist/${APBASE}.tar.md5."
rm -f "out/${APBASE}.tar.md5"
( cd out/dist && sha256sum * > SHA256SUMS.txt )
ls -la out/dist/
df -h . | tail -1
echo "=== AP packaged: ${APBASE}.tar.md5 (split into $(ls out/dist/${APBASE}.tar.md5.* | wc -l) parts) ==="
