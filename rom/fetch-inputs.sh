#!/usr/bin/env bash
# Fetches the three ROM inputs. NO kernel rebuild: the exact v1.0 release
# artifact is pulled and verified against the pinned round-2 SHA-256.
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p work/kernel work/gsi work/fw

OUR_REPO="${GITHUB_REPOSITORY:-MuhammedAliMizrakTR/GrapheneOS-SM-A155-}"

echo "=== [1/3] Kernel variant '$KERNEL_VARIANT' from release v1.0 ==="
case "$KERNEL_VARIANT" in
  vanilla)      KTAR="stock_optimized_5.10.226_A155FXXS7CYG4_A15_GKI.tar"
                KSHA="77a3c5477dad2a8b1b7b00ee00cb4f111f2178740ce8ee973333c230502938b4";;
  bakasu)       KTAR="bakasu_35262_susfs_v2.4.0_A155FXXS7CYG4_A15_GKI.tar"
                KSHA="a963a7250e182a45d4d6dc5cea1553c59e8d403b3edbd30d404e95404279d0cf";;
  kernelsunext) KTAR="kernelsunext_33548_susfs_v2.4.0_A155FXXS7CYG4_A15_GKI.tar"
                KSHA="0d8e6d4d4efb0f03e04282421009d74f5be599b7cacd9fae82a42d13bf8e15b4";;
  *) echo "unknown KERNEL_VARIANT=$KERNEL_VARIANT"; exit 1;;
esac
gh release download v1.0 -R "$OUR_REPO" -p "$KTAR" -D work/kernel --clobber
echo "$KSHA  work/kernel/$KTAR" | sha256sum -c -
echo "kernel tar integrity: OK (matches round-2 build hash)"
BOOT_MEMBER=$(tar -tf "work/kernel/$KTAR" | grep -m1 -E '(^|/)boot\.img$' || tar -tf "work/kernel/$KTAR" | grep -m1 '\.img$')
tar -xf "work/kernel/$KTAR" -C work/kernel "$BOOT_MEMBER"
cp "work/kernel/$BOOT_MEMBER" work/kernel/boot.img
rm -f "work/kernel/$KTAR" "work/kernel/$BOOT_MEMBER"
echo "boot.img: $(stat -c%s work/kernel/boot.img) bytes"
df -h . | tail -1

echo "=== [2/3] RestlessOS GSI (arm64-ab, non-erofs) ==="
RREPO="cawilliamson/treble_restlessos"
RREF="$RESTLESS_REF"
[ -z "$RREF" ] && RREF=$(gh api "repos/$RREPO/releases/latest" --jq .tag_name)
echo "restlessos tag: $RREF"
GASSET=$(gh api "repos/$RREPO/releases/tags/$RREF" --jq '.assets[].name' \
  | grep -E '^RestlessOS-arm64-ab-.*\.img\.xz$' | grep -v -i erofs | head -1)
SUMF=$(gh api "repos/$RREPO/releases/tags/$RREF" --jq '.assets[].name' | grep -m1 '\.sha512sum$')
[ -n "$GASSET" ] || { echo "no plain arm64-ab img.xz asset found"; exit 1; }
echo "GSI asset: $GASSET"
gh release download "$RREF" -R "$RREPO" -p "$GASSET" -p "$SUMF" -D work/gsi --clobber
( cd work/gsi && grep "$(basename "$GASSET")" "$SUMF" | sha512sum -c - )
echo "GSI integrity: OK"
xz -dc "work/gsi/$GASSET" > work/gsi/gsi.img
rm -f "work/gsi/$GASSET" "work/gsi/$SUMF"
echo "$RREF" > work/gsi/TAG
echo "gsi.img: $(stat -c%s work/gsi/gsi.img) bytes, type: $(blkid -o value -s TYPE work/gsi/gsi.img 2>/dev/null || echo unknown)"
df -h . | tail -1

echo "=== [3/3] Stock firmware $FW_VERSION ($FW_REGION) via Samsung FUS (samloader) ==="
samloader -m SM-A155F -r "$FW_REGION" download -v "$FW_VERSION" -O work/fw -D -M
ls -la work/fw/
ZIP=$(ls work/fw/*.zip 2>/dev/null | head -1)
[ -n "$ZIP" ] || { echo "samloader produced no decrypted zip"; exit 1; }
unzip -Z1 "$ZIP" | tee work/fw/zip-contents.txt
grep -q '^AP_.*\.tar\.md5$' work/fw/zip-contents.txt || { echo "no AP tar in firmware zip"; exit 1; }
df -h . | tail -1
echo "=== inputs ready ==="
