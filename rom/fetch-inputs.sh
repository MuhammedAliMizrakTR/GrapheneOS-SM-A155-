#!/usr/bin/env bash
# Fetches the three ROM inputs, one phase per invocation (or "all"):
#   fetch-inputs.sh kernel|gsi|firmware|ap-base|all
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
  elif [ -n "${KERNEL_URL:-}" ]; then
    # Direct-URL mode (e.g. public Google Drive link on a runner that can
    # reach Google). Sha256 below is still the hard gate.
    echo "KERNEL_URL mode: $KERNEL_URL"
    curl -fL --retry 3 -o "work/kernel/$KTAR" "$KERNEL_URL"
  else
    KREPO="${GITHUB_REPOSITORY:-MuhammedAliMizrakTR/GrapheneOS-SM-A155-}"
    # Diagnose first: log every asset on the release, then match loosely.
    # (Exact -p match fails hard if the uploaded name differs even slightly
    #  from the Drive filename we pinned.)
    AVAIL=$(gh release view v1.0 -R "$KREPO" --json assets --jq '.assets[].name' || true)
    echo "release v1.0 assets on $KREPO:"
    echo "$AVAIL" | sed 's/^/  - /'
    # Prefer exact name; fall back to variant-prefixed .tar match.
    SEL="$KTAR"
    if ! printf '%s\n' "$AVAIL" | grep -qx "$KTAR"; then
      SEL=$(printf '%s\n' "$AVAIL" | grep -i "^${KERNEL_VARIANT}.*\\.tar\$" | head -1 || true)
      [ -n "$SEL" ] && echo "exact name not on release; using closest match: $SEL"
    fi
    [ -n "$SEL" ] || { echo "FATAL: no ${KERNEL_VARIANT}*.tar asset on release v1.0"; exit 1; }
    gh release download v1.0 -R "$KREPO" -p "$SEL" -D work/kernel --clobber
    [ "$SEL" = "$KTAR" ] || mv "work/kernel/$SEL" "work/kernel/$KTAR"
  fi
  echo "$KSHA  work/kernel/$KTAR" | sha256sum -c -
  echo "kernel integrity: OK (round-2 pinned hash)"
  BOOT_MEMBER=$( { tar -tf "work/kernel/$KTAR" || true; } | grep -m1 -E '(^|/)boot\.img$' || true)
  [ -n "$BOOT_MEMBER" ] || BOOT_MEMBER=$( { tar -tf "work/kernel/$KTAR" || true; } | grep -m1 '\.img$' || true)
  [ -n "$BOOT_MEMBER" ] || { echo "FATAL: no .img member in $KTAR; first members:"; { tar -tf "work/kernel/$KTAR" || true; } | head -20; exit 1; }
  tar -xf "work/kernel/$KTAR" -C work/kernel "$BOOT_MEMBER"
  # BOOT_MEMBER may already be top-level "boot.img" — cp/rm self-destructs then
  if [ "$BOOT_MEMBER" != "boot.img" ]; then
    mv "work/kernel/$BOOT_MEMBER" work/kernel/boot.img
  fi
  rm -f "work/kernel/$KTAR"
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
    RLIST=$(gh api "repos/$RREPO/releases/tags/$RREF" --jq '.assets[].name')
    echo "restlessos assets:"; printf '%s\n' "$RLIST" | sed 's/^/  - /'
    GASSET=$(printf '%s\n' "$RLIST" | grep -E '^RestlessOS-arm64-ab-.*\.img\.xz$' | grep -v -i erofs | head -1 || true)
    SUMF=$(printf '%s\n' "$RLIST" | grep -m1 '\.sha512sum$' || true)
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
  if [ -n "${FW_URL:-}" ]; then
    # Direct-URL mode: full firmware zip from any URL. Google Drive share
    # links are normalized to the direct-download endpoint (confirm=t skips
    # the virus-scan interstitial for multi-GB files).
    U="$FW_URL"
    if [[ "$U" =~ drive\.google\.com/file/d/([^/]+) ]]; then
      U="https://drive.usercontent.google.com/download?id=${BASH_REMATCH[1]}&export=download&confirm=t"
    elif [[ "$U" =~ drive\.google\.com/open\?id=([^&]+) ]]; then
      U="https://drive.usercontent.google.com/download?id=${BASH_REMATCH[1]}&export=download&confirm=t"
    fi
    echo "FW_URL mode: $U"
    curl -fL --retry 3 --retry-delay 20 -C - -o work/fw/firmware.zip "$U"
    ls -la work/fw/
    return
  fi
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
  # FUS sometimes refuses datacenter handshakes (empty nonce / 403) — retry
  # the whole candidate list a few times before giving up.
  for attempt in 1 2 3; do
    for c in "${CANDIDATES[@]}"; do
      echo "attempt $attempt, FUS version: $c"
      if samloader -m SM-A155F -r "$FW_REGION" download -v "$c" -O work/fw -D -M; then ok=1; break; fi
      sleep 45
    done
    [ -n "$ok" ] && break
  done
  if [ -z "$ok" ]; then
    echo "FUS download failed after 3 attempts; latest available for SM-A155F/$FW_REGION:"
    samloader -m SM-A155F -r "$FW_REGION" checkupdate || true
    echo "HINT: Samsung likely blocks this runner IP. Re-dispatch with fw_url set"
    echo "      (a direct link to the stock $FW_VERSION $FW_REGION zip, e.g. a"
    echo "      link-shared Google Drive file)."
    exit 1
  fi
  ls -la work/fw/
}

do_ap_base() {
  BASE_VARIANT="${AP_BASE_VARIANT:-stock}"
  case "$BASE_VARIANT" in
    bakasu|kernelsunext) ;;
    *) echo "FATAL: ap-base requires AP_BASE_VARIANT=bakasu or kernelsunext"; exit 1;;
  esac
  TAG="$RESTLESS_REF"
  if [ -z "$TAG" ]; then
    TAG=$(gh api repos/cawilliamson/treble_restlessos/releases/latest --jq .tag_name)
  fi
  BASE="AP_SM-A155F_RestlessOS-${TAG}_${BASE_VARIANT}_${FW_VERSION}"
  SUM="${BASE}.SHA256SUMS.txt"
  mkdir -p work/ap-base work/ap
  echo "=== using existing $BASE as checksum-verified AP donor ==="
  SOURCE_RELEASE="${AP_BASE_RELEASE_TAG:-rom-v1.0}"
  gh release download "$SOURCE_RELEASE" \
    -p "${BASE}.tar.md5.*" -p "$SUM" -D work/ap-base
  ( cd work/ap-base && sha256sum -c "$SUM" )
  DONOR="work/ap/AP_${FW_VERSION}_donor.tar.md5"
  cat "work/ap-base/${BASE}.tar.md5.00" \
      "work/ap-base/${BASE}.tar.md5.01" \
      "work/ap-base/${BASE}.tar.md5.02" > "$DONOR"
  echo "verified donor AP assembled: $DONOR ($(stat -c%s "$DONOR") bytes)"
}

case "$PHASE" in
  kernel)   do_kernel;;
  gsi)      do_gsi;;
  firmware) do_firmware;;
  ap-base)  do_ap_base;;
  all)      do_kernel; do_gsi; if [ "${AP_BASE_VARIANT:-stock}" = stock ]; then do_firmware; else do_ap_base; fi;;
  *) echo "usage: $0 kernel|gsi|firmware|ap-base|all"; exit 1;;
esac
echo "=== phase '$PHASE' done ==="
