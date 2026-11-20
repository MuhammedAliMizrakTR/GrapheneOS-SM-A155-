# RestlessOS 17 (GrapheneOS fork) for Galaxy A15 4G (SM-A155F) — Odin AP package

**Contents:** RestlessOS `$RTAG` (Android 17, GrapheneOS-fork GSI) as **system** • `$KERNEL_VARIANT` kernel (project v1.0 release artifact, SHA-256-pinned, never rebuilt) • stock `$FW_VERSION` ($FW_REGION) vendor/product/odm = **the full Samsung/MediaTek driver stack** (Mali GPU, camera, audio, modem interface) • verification-disabled vbmeta • embedded SIM-fix module.

## Installation (Odin only)

1. **Flash stock first:** flash the original **$FW_VERSION** 4-file package (BL+AP+CP+CSC) in Odin and let it boot once.
2. Download this release's parts and join them:
   - Windows: `copy /b ${APBASE}.tar.md5.00+${APBASE}.tar.md5.01+${APBASE}.tar.md5.02 ${APBASE}.tar.md5`
   - Linux/macOS: `cat ${APBASE}.tar.md5.* > ${APBASE}.tar.md5`
   - Verify against `SHA256SUMS.txt`.
3. Boot into Download Mode → Odin → place the joined file in the **AP** slot → flash.
4. **Format data is mandatory** (Wipe data/factory reset in recovery) — required on the first switch to a GSI.
5. Rooted variants: after boot, open the root manager → Modules → Install from storage → `/system/etc/a155f-extras/RILFix_A15.zip` (activates the SIM fix).

## SIM bug fix (network drop every ~7 hours)

$SIMFIX_LINE

## What's in / what's out

| In ✅ | Out ❌ |
|---|---|
| RestlessOS: sandboxed Google Play (GmsCompat), per-app network/sensors permissions, Seedvault, TrebleApp | Verified boot / hardware attestation (inherent to GSIs) |
| Stock vendor drivers (camera, GPU, audio, GPS, FM, sensors) | GrapheneOS kernel hardening (Pixel-specific) |
| Our v1.0 kernel: BBRv3, BBG, NTSync, Droidspaces, WireGuard | VoLTE guarantee (MTK IMS — generally not working on GSIs) |
| SIM-fix module (embedded, rooted variants) | Samsung OTA updates |
| `aarch64`/`arm64-ab`, official Treble support | Device-specific RRO overlays (phase 2) |

## Verification

- Kernel: project v1.0 release artifact, pinned SHA-256 verified at build time (never rebuilt).
- GSI: upstream `cawilliamson/treble_restlessos` `$RTAG`, verified against its published sha512sum.
- Firmware: stock Samsung `$FW_VERSION` ($FW_REGION).
- SHA-256 of every part is in `SHA256SUMS.txt`.

## Known limitations

- The SIM fix is a workaround, not a root-cause fix (ril-daemon hangs after ~7h25m of uptime on unlocked-bootloader A15 4G; Samsung/MTK side). The module restarts it every ~6 hours.
- Back up EFS/NVRAM/IMEI before flashing anything.

---

Built $BUILD_DATE by GitHub Actions (`build-rom.yml`). Credits: RestlessOS by cawilliamson (GrapheneOS fork), kernel by poqdavid, stock firmware by Samsung.
