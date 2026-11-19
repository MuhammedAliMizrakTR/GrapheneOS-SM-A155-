#!/usr/bin/env bash
# Extracts the AP tar from the firmware zip, lists its members (member names
# and ORDER are the Odin/PIT contract we must reproduce), extracts every member
# except super (handled by repack-super.sh) into work/ap/small/.
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p work/ap/small

if ls work/ap/AP_*.tar* >/dev/null 2>&1; then
  # LOCAL mode: AP tar already staged by fetch-inputs.sh
  AP=$(ls work/ap/AP_*.tar* | head -1)
else
  ZIP=$(ls work/fw/*.zip | head -1)
  APMEMBER=$(unzip -Z1 "$ZIP" | grep -m1 '^AP_.*\.tar\.md5$')
  echo "AP member: $APMEMBER"
  unzip -o "$ZIP" "$APMEMBER" -d work/ap/
  rm -f "$ZIP"   # free several GB early
  AP="work/ap/$APMEMBER"
fi
df -h . | tail -1
tar -tf "$AP" > work/ap/members.txt 2>/dev/null || tar -tf "$AP" --ignore-zeros > work/ap/members.txt
echo "--- stock AP members (order is significant) ---"
cat work/ap/members.txt

if grep -qE '^super\.img\.lz4$' work/ap/members.txt; then
  SUPER_MEMBER="super.img.lz4"
elif grep -qE '^super\.img$' work/ap/members.txt; then
  SUPER_MEMBER="super.img"
else
  echo "FATAL: no super.img[.lz4] member in AP tar"; exit 1
fi
echo "$SUPER_MEMBER" > work/ap/super_member.txt

grep -vE "^${SUPER_MEMBER}\$" work/ap/members.txt > work/ap/members.small.txt
tar -xf "$AP" -C work/ap/small -T work/ap/members.small.txt
tar -xf "$AP" -C work/ap "$SUPER_MEMBER"
rm -f "$AP"   # free; small members + super are extracted
ls -la work/ap/small/
df -h . | tail -1
echo "=== AP extracted ==="
