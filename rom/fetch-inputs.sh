#!/usr/bin/env bash
# Fetches the three ROM inputs, one phase per invocation (or "all"):
#   fetch-inputs.sh kernel|gsi|firmware|all
#
# NO kernel rebuild: the exact v1.0 release artifact is verified against the
# pinned round-2 SHA-256.
#
# Two modes:
#   CI mode (default): downloads via gh (releases) + samloader (Samsung FUS).
#   LOCAL mode (INPUTS_DIR set): copies from a local directory containing:
#     <variant kernel>.tar            (name as in release v1.0)
#     RestlessOS-*.img.xz or gsi.img  (arm64-ab, non-erofs)
#     AP_*.tar[.md5]                  (stock firmware AP package)
set -euo pipefail
cd "$(dirname "$0")/.."
PHASE="${1:-all}"
mkdir -p work/kernel work/gsi work/ap

case "$KERNEL_VARIANT" in
  vanilla)      KTAR="stock_optimized_5.10.226_A155FXXS7CYG4_A15_GKI.tar"
                KSHA="77a3c5477dad2a8b1b7b00ee00cb4f111f2178740ce8ee973333c230502938b4";;
  bakasu)       KTAR="bakasu_35262_susfs_v2.4.0_A155FXXS7CYG4_A15_GKI.tar"
                KSHA="a963a7250e182a45d4d6dc5cea1553c59e8d403b3edbd30d404e95404279d0cf";;
  kernelsunext) KTAR="kernelsunext_33548_susfs_v2.4.0_A155FXXS7CYG4_A15_GKI.tar"
                KSHA="0d8e6d4d4efb0f03e04282421009d74f5be599b7cacd9fae82a42d13bf8e15b4";;
  *) echo "unknown KERNEL_VARIANT=$KERNEL_VARIANT"; exit 1;;
esac

do_kernel() {
  echo "=== kernel: $KTAR ==="
  if [ -n "${INPUTS_DIR:-}" ]; then
    cp "$INPUTS_DIR/$KTAR" work/kernel/
  else
    gh release download v1.0 -R "${GITHUB_REPOSITORY:-MuhammedAliMizrakTR/GrapheneOS-SM-A155-}" \
      -p "$KTAR" -D work/kernel --clobber
  fi
  echo "$KSHA  work/kernel/$KTAR" | sha256sum -c -
  echo "kernel integrity: OK (round-2 pinned hash)"
  BOOT_MEMBER=$(tar -tf "work/kernel/$KTAR" | grep -m1 -E '(^|/)boot\.img$' || tar -tf "work/kernel/$KTAR" | grep -m1 '\.img$')
  tar -xf "work/kernel/$KTAR" -C work/kernel "$BOOT_MEMBER"
  cp "work/kernel/$BOOT_MEMBER" work/kernel/boot.img
  rm -f "work/kernel/$KTAR" "work/kernel/$BOOT_MEMBER"
  echo "boot.img: $(stat -c%s work/kernel/boot.img) bytes"
  df -h . | tail -1
}

do_gsi() {
  echo "=== RestlessOS GSI (arm64-ab, non-erofs) ==="
  if [ -n "${INPUTS_DIR:-}" ]; then
    G=$(ls "$INPUTS_DIR"/RestlessOS-arm64-ab-*.img.xz 2>/dev/null | grep -v -i erofs | head -1 || true)
    if [ -n "$G" ]; then
      S=$(ls "$INPUTS_DIR"/*.sha512sum 2>/dev/null | head -1 || true)
      if [ -n "$S" ]; then ( cd "$INPUTS_DIR" && grep "$(basename "$G")" "$(basename "$S")" | sha512sum -c - ); fi
      xz -dc "$G" > work/gsi/gsi.img
    elif [ -f "$INPUTS_DIR/gsi.img" ]; then
      cp "$INPUTS_DIR/gsi.img" work/gsi/gsi.img
    else
      echo "FATAL: no GSI in $INPUTS_DIR"; exit 1
    fi
    echo "local" > work/gsi/TAG
  else
    RREPO="cawilliamson/treble_restlessos"
    RREF="$RESTLESS_REF"
    [ -z "$RREF" ] && RREF=$(gh api "repos/$RREPO/releases/latest" --jq .tag_name)
    echo "restlessos tag: $RREF"
    GASSET=$(gh api "repos/$RREPO/releases/tags/$RREF" --jq '.assets[].name' \
      | grep -E '^RestlessOS-arm64-ab-.*\.img\.xz$' | grep -v -i erofs | head -1)
    SUMF=$(gh api "repos/$RREPO/releases/tags/$RREF" --jq '.assets[].name' | grep -m1 '\.sha512sum$' || true)
    [ -n "$GASSET" ] || { echo "no plain arm64-ab img.xz asset found"; exit 1; }
    gh release download "$RREF" -R "$RREPO" -p "$GASSET" -D work/gsi --clobber
    if [ -n "$SUMF" ]; then
      gh release download "$RREF" -R "$RREPO" -p "$SUMF" -D work/gsi --clobber
      ( cd work/gsi && grep "$(basename "$GASSET")" "$SUMF" | sha512sum -c - )
    fi
    xz -dc "work/gsi/$GASSET" > work/gsi/gsi.img
    rm -f "work/gsi/$GASSET" "work/gsi/$SUMF"
    echo "$RREF" > work/gsi/TAG
  fi
  echo "gsi.img: $(stat -c%s work/gsi/gsi.img) bytes, fs: $(blkid -o value -s TYPE work/gsi/gsi.img 2>/dev/null || echo unknown)"
  df -h . | tail -1
}

do_firmware() {
  echo "=== stock firmware $FW_VERSION ($FW_REGION) ==="
  if [ -n "${INPUTS_DIR:-}" ]; then
    A=$(ls "$INPUTS_DIR"/AP_*.tar.md5 "$INPUTS_DIR"/AP_*.tar 2>/dev/null | head -1 || true)
    [ -n "$A" ] || { echo "FATAL: no AP_*.tar[.md5] in $INPUTS_DIR"; exit 1; }
    cp "$A" work/ap/
    echo "AP: $(basename "$A") ($(stat -c%s "$A") bytes)"
    sha256sum "$A" | tee work/ap/INPUT_AP.sha256
    return
  fi
  mkdir -p work/fw
  # Samsung FUS needs the full quad AP/CSC/CP/AP — expand short forms:
  # A155FXXS7CYG4 -> A155FXXS7CYG4/A155FOXM7CYG4/A155FXXS7CYG4/A155FXXS7CYG4
  CANDIDATES=()
  if [[ "$FW_VERSION" == */* ]]; then
    CANDIDATES+=("$FW_VERSION")
  else
    CSC=$(echo "$FW_VERSION" | sed -E 's/^(.{5})XXS(.+)$/\1OXM\2/')
    CANDIDATES+=("$FW_VERSION/$CSC/$FW_VERSION/$FW_VERSION" "$FW_VERSION")
  fi
  ok=""
  for c in "${CANDIDATES[@]}"; do
    echo "trying FUS version: $c"
    if samloader -m SM-A155F -r "$FW_REGION" download -v "$c" -O work/fw -D -M; then ok=1; break; fi
  done
  if [ -z "$ok" ]; then
    echo "FUS download failed; latest available for SM-A155F/$FW_REGION:"
    samloader -m SM-A155F -r "$FW_REGION" checkupdate || true
    exit 1
  fi
  ls -la work/fw/
}

case "$PHASE" in
  kernel)   do_kernel;;
  gsi)      do_gsi;;
  firmware) do_firmware;;
  all)      do_kernel; do_gsi; do_firmware;;
  *) echo "usage: $0 kernel|gsi|firmware|all"; exit 1;;
esac
echo "=== phase '$PHASE' done ==="
