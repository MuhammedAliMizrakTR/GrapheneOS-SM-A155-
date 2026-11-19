#!/usr/bin/env bash
# Embeds /system/etc/a155f-extras/ into the GSI: the RIL-fix module zip, the
# root-manager APK (rooted variants) and a README. Handles ext4 and erofs GSIs.
set -euo pipefail
cd "$(dirname "$0")/.."
IMG=work/gsi/gsi.img
GROW=$((96*1024*1024))

payload_dir() {  # $1 = mounted root of the system image
  local base="$1"
  [ -d "$base/etc" ] || base="$base/system"   # SAR vs. nested layout
  sudo mkdir -p "$base/etc/a155f-extras"
  sudo cp out/dist/RILFix_A15.zip "$base/etc/a155f-extras/"
  for f in work/manager/*.apk; do [ -f "$f" ] && sudo cp "$f" "$base/etc/a155f-extras/"; done
  cat > /tmp/a155f-extras-readme.txt <<'EOF'
A155F EXTRAS (embedded by the ROM build)
========================================
RILFix_A15.zip      - KernelSU-Next / BakaSU / Magisk module. Fixes the
                      unlocked-bootloader SIM/network drop (~every 7h25m the
                      stock ril-daemon hangs the modem) by restarting
                      ril-daemon every 6 hours. Install it from your root
                      manager: Modules -> Install from storage -> this file.
Manager APK         - matching root manager for the kernel you flashed
                      (install normally, then install the module above).
Vanilla builds: no root, so no module — the SIM bug is NOT fixed there.
EOF
  sudo cp /tmp/a155f-extras-readme.txt "$base/etc/a155f-extras/README.txt"
  sudo chmod -R a=rX "$base/etc/a155f-extras"
  sudo chown -R 0:2000 "$base/etc/a155f-extras" 2>/dev/null || sudo chown -R 0:0 "$base/etc/a155f-extras"
  ls -la "$base/etc/a155f-extras"
}

FS=$(blkid -o value -s TYPE "$IMG" 2>/dev/null || echo unknown)
echo "GSI filesystem: $FS"
case "$FS" in
  ext4)
    SZ=$(stat -c%s "$IMG"); truncate -s $((SZ + GROW)) "$IMG"
    e2fsck -fy "$IMG" || true
    resize2fs "$IMG"
    mkdir -p /tmp/mnt.gsi
    sudo mount -o loop,rw "$IMG" /tmp/mnt.gsi
    payload_dir /tmp/mnt.gsi
    sync; sudo umount /tmp/mnt.gsi
    e2fsck -fy "$IMG" || true
    resize2fs -M "$IMG"     # shrink back so system stays small
    ;;
  erofs)
    mkdir -p /tmp/gsi.x
    fsck.erofs --extract=/tmp/gsi.x "$IMG"
    rm -f "$IMG"
    payload_dir /tmp/gsi.x 2>/dev/null || {   # extract dir is not root-owned flow
      B=/tmp/gsi.x; [ -d "$B/etc" ] || B="$B/system"
      mkdir -p "$B/etc/a155f-extras"
      cp out/dist/RILFix_A15.zip "$B/etc/a155f-extras/"
      for f in work/manager/*.apk; do [ -f "$f" ] && cp "$f" "$B/etc/a155f-extras/"; done
      cp /tmp/a155f-extras-readme.txt "$B/etc/a155f-extras/README.txt"
      chmod -R a=rX "$B/etc/a155f-extras"
    }
    mkfs.erofs -zlz4hc,9 -T 1230768000 --mount-point /system --fs-config-file /dev/null "$IMG" /tmp/gsi.x 2>/dev/null \
      || mkfs.erofs -zlz4hc "$IMG" /tmp/gsi.x
    rm -rf /tmp/gsi.x
    ;;
  *)
    echo "FATAL: unsupported GSI fs '$FS'"; exit 1;;
esac
echo "gsi.img final: $(stat -c%s "$IMG") bytes"
df -h . | tail -1
