#!/usr/bin/env bash
# Renders the bilingual (TR/EN) prerelease notes for the ROM package.
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p out
export RTAG=$(cat work/gsi/TAG 2>/dev/null || echo "$RESTLESS_REF")
export APBASE="AP_SM-A155F_RestlessOS-${RTAG}_${KERNEL_VARIANT}_${FW_VERSION}"
export BUILD_DATE=$(date -u +%Y-%m-%d)
export SIMFIX_LINE
if [ "$KERNEL_VARIANT" = "vanilla" ]; then
  SIMFIX_LINE="**YOK — vanilla kernel rootsuzdur, SIM-fix modülü kurulamaz.** Şebeke ~7 saatte bir düşer; telefonu yeniden başlatmak gerekir. SIM fix için kernelsunext/bakasu paketini kullan."
else
  SIMFIX_LINE="**DAHİLİ** — \`/system/etc/a155f-extras/RILFix_A15.zip\` ROM'un içinde gömülü. Kurulumdan sonra root yöneticisini aç (APK da aynı klasörde), Modules → Install from storage → \`/system/etc/a155f-extras/RILFix_A15.zip\`. Modül her 6 saatte bir ril-daemon'ı yeniden başlatır (XDA'da kanıtlanmış geçici çözüm; ~7sa25dakikalık modem takılmasını önler)."
fi
envsubst '$RTAG $APBASE $KERNEL_VARIANT $FW_VERSION $FW_REGION $BUILD_DATE $SIMFIX_LINE' \
  < rom/release-notes-template.md > out/RELEASE_NOTES.md
cp out/RELEASE_NOTES.md out/dist/RELEASE_NOTES.md
echo "--- notes ---"; head -30 out/RELEASE_NOTES.md
