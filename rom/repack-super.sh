#!/usr/bin/env bash
# Rebuilds super: decompress/unsparse stock super, dump layout, unpack the
# logical partitions, then lpmake a new sparse super with the GSI as system.
set -euo pipefail
cd "$(dirname "$0")/.."

SUPER_MEMBER=$(cat work/ap/super_member.txt)
echo "stock super member: $SUPER_MEMBER"

if [ "$SUPER_MEMBER" = "super.img.lz4" ]; then
  lz4 -d -f work/ap/super.img.lz4 work/ap/super.img 2>/dev/null \
    || lz4 -l -d -f work/ap/super.img.lz4 work/ap/super.img
  rm -f work/ap/super.img.lz4
fi

if python3 -c "import sys; sys.exit(0 if open('work/ap/super.img','rb').read(4)==b'\x3a\xff\x26\xed' else 1)"; then
  echo "stock super is Android-sparse -> simg2img"
  simg2img work/ap/super.img work/ap/super.raw
  rm -f work/ap/super.img
else
  mv work/ap/super.img work/ap/super.raw
fi
df -h . | tail -1

lpdump --json=work/ap/super.json work/ap/super.raw 2>/dev/null || true
if [ ! -s work/ap/super.json ] || ! head -c1 work/ap/super.json | grep -q '{'; then
  lpdump work/ap/super.raw > work/ap/super.json   # text fallback (lp_plan.py parses both)
fi
head -c 2000 work/ap/super.json; echo

mkdir -p work/parts
lpunpack work/ap/super.raw work/parts/
ls -la work/parts/
rm -f work/ap/super.raw          # free the biggest blob
df -h . | tail -1

python3 rom/lp_plan.py work/ap/super.json work/parts work/gsi/gsi.img work/lpmake_cmd.sh work/super_new.img
bash work/lpmake_cmd.sh
ls -la work/super_new.img

# keep only partition images still referenced (lpmake already read them)
rm -rf work/parts work/gsi/gsi.img
df -h . | tail -1
echo "=== super rebuilt ==="
