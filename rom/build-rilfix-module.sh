#!/usr/bin/env bash
# Builds the RIL-fix root-module zip (community-proven ril-daemon restart
# workaround for the unlocked-bootloader ~7h25m modem hang on SM-A155F) and
# fetches the matching root-manager APK for the chosen kernel variant.
set -euo pipefail
cd "$(dirname "$0")/.."
REPO_ROOT=$(pwd)
mkdir -p out/dist work/manager

( cd rom/simfix/RILFix_A15 && zip -r -X "$REPO_ROOT/out/dist/RILFix_A15.zip" . )
echo "module zip: $(stat -c%s out/dist/RILFix_A15.zip) bytes"

case "$KERNEL_VARIANT" in
  kernelsunext) MGR_REPO="KernelSU-Next/KernelSU-Next"; MGR_PAT='^KernelSU_Next_.*-release\.apk$' ;;
  bakasu)       MGR_REPO="Baka-SU/BakaSU";               MGR_PAT='arm64-v8a.*\.apk$' ;;
  vanilla)      MGR_REPO="";;
  *) echo "unknown KERNEL_VARIANT"; exit 1;;
esac

if [ -n "${MGR_REPO:-}" ]; then
  # NOTE: /releases/latest 404s when every release is a prerelease (BakaSU).
  TAG=$(gh api "repos/$MGR_REPO/releases?per_page=20" --jq '[.[] | select(.draft|not)][0].tag_name')
  [ -n "$TAG" ] && [ "$TAG" != "null" ] || { echo "FATAL: no releases on $MGR_REPO"; exit 1; }
  MLIST=$(gh api "repos/$MGR_REPO/releases/tags/$TAG" --jq '.assets[].name')
  ASSET=$(printf '%s\n' "$MLIST" | grep -E "$MGR_PAT" | grep -v -i spoof | head -1 || true)
  [ -n "$ASSET" ] || { echo "FATAL: no manager apk matching $MGR_PAT; assets:"; printf '%s\n' "$MLIST"; exit 1; }
  echo "manager: $MGR_REPO $TAG / $ASSET"
  gh release download "$TAG" -R "$MGR_REPO" -p "$ASSET" -D work/manager --clobber
  cp "work/manager/$ASSET" out/dist/
else
  echo "vanilla variant: no manager APK (and no SIM fix) — documented in notes"
fi
ls -la out/dist/
