# 1.2 ROM Verification & Corruption Fix — RestlessOS 17 for Galaxy A15 4G (SM-A155F)

**Status: prerelease / test candidate.** This rebuild targets the owner's reported `A155FXXS7CYG4` XSG (binary 7) base and changes the AP container format after the failed 1.1 report. It is not claimed device-verified.

**Package:** RestlessOS `$RTAG` (Android 17 GSI) • `$KERNEL_VARIANT` kernel (v1.0 release artifact, SHA-256 pinned) • `$FW_VERSION` donor vendor/driver stack • raw `boot.img`, `super.img`, and other image members. The AP is a plain TAR: **no appended MD5, no LZ4-compressed members**. If release transport is chunked, `.00`, `.01`, … are only transport chunks; joining them restores one TAR.

## Download and verify

- Variant: **BakaSU rooted**
- Download all same-prefix `${APBASE}.tar.00`, `${APBASE}.tar.01`, … parts and `${APBASE}.SHA256SUMS.txt`.
- Linux/macOS: `cat ${APBASE}.tar.* > ${APBASE}.tar`
- Windows: join all `.tar.00`, `.tar.01`, … parts in numeric order using binary concatenation. Use PowerShell or `copy /b` with every part named explicitly.
- Verify each part using the manifest, then verify the joined `${APBASE}.tar` against the first manifest line.

## IMPORTANT firmware / rollback gate

The 1.1 report contained `SW REV CHECK FAIL [super] Fused 7 > Binary 8`. The owner reports the handset is on `A155FXXS7CYG4` XSG / binary 7, which does not obviously agree with that line. **Before flashing, compare the phone's complete model/build/baseband/bootloader information with the donor firmware. Do not proceed if the displayed fused/binary revision is not an exact compatible match.** Removing MD5/LZ4 does not by itself fix Samsung rollback protection.

## Installation (only after the firmware gate is confirmed)

1. On **SM-A155F only**, flash the matching stock four-file BL+AP+CP+CSC firmware in Odin and boot it once.
2. Join the matching parts above into the `.tar`, verify its SHA-256, and select that `.tar` in Odin's AP slot.
3. After a successful flash, format data/factory-reset from recovery before first boot.
4. Install the matching BakaSU **35262** manager APK separately from the release. The manager is not baked into the AP. Install `/system/etc/a155f-extras/RILFix_A15.zip` from the manager's Modules screen only if the rooted SIM workaround is desired.

## Scope and limitations

- This is an unofficial RestlessOS / GrapheneOS-fork GSI package, not an official GrapheneOS port.
- The Samsung/MediaTek vendor and driver stack remains stock; VoLTE/IMS and device-specific hardware functions require on-device validation.
- This release is a **test candidate**, not confirmation that the prior Odin/SW revision issue is resolved. Retest only after checking the exact build/revision and keep a stock recovery path.

Built $BUILD_DATE by GitHub Actions (`build-rom.yml`). Credits: RestlessOS by cawilliamson, A155F kernel by poqdavid, stock firmware by Samsung.
