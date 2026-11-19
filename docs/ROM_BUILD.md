# ROM build & packaging — RestlessOS 17 + v1.0 kernel → Odin AP (SM-A155F)

Status: **CI-ready, first run pending. Nothing here is device-tested.**

## Goal (owner-directed, 2026-11-19)

End users must never touch fastbootd. Install flow:

1. Flash **stock A155FXXS7CYG4** (any region) with Odin — full 4-file (BL+AP+CP+CSC).
2. Flash **our single AP package** (Odin, AP slot).
3. Format data. Done — RestlessOS 17 (GrapheneOS fork) boots with our kernel,
   the stock driver stack, and the SIM-drop fix embedded.

## Why GitHub Actions builds it (D010)

The sandbox that built the v1.0 kernels cannot download release assets or
Samsung firmware (egress is restricted to github.com/codeload/api.github.com/
pypi/npm). GitHub-hosted runners have unrestricted internet, so the whole
pipeline runs there:

- **Kernel is NOT rebuilt.** The exact v1.0 release artifact is downloaded and
  verified against the pinned round-2 SHA-256 (`rom/fetch-inputs.sh`).
- **GSI** comes from `cawilliamson/treble_restlessos` releases, verified with
  the upstream `.sha512sum`.
- **Stock firmware** is fetched straight from Samsung FUS with
  [`samloader`](https://github.com/nlscc/samloader), version-pinned
  (`-v A155FXXS7CYG4`), enc4-decrypted (CRC-checked).

## Pipeline (`rom/`, driven by `.github/workflows/build-rom.yml`)

| Step | Script | What it does |
|---|---|---|
| 1 | `fetch-inputs.sh` | kernel tar (hash-pinned) → `boot.img`; GSI xz → `gsi.img`; firmware zip (samloader) |
| 2 | `extract-ap.sh` | pulls `AP_*.tar.md5` out of the firmware zip; records member list/order; extracts small members + super |
| 3 | `build-rilfix-module.sh` | zips `simfix/RILFix_A15` (KSU/Magisk module) + downloads the matching root-manager APK |
| 4 | `modify-gsi.sh` | embeds `/system/etc/a155f-extras/` (module zip, manager APK, README) into the GSI (ext4 mount or erofs repack) |
| 5 | `repack-super.sh` + `lp_plan.py` | `lpdump`/`lpunpack` stock super, `lpmake` a new sparse super: **system = GSI**, vendor/product/odm/… = stock bytes, stock geometry preserved |
| 6 | `make-vbmeta.sh` | `avbtool make_vbmeta_image --flags 3` for every `vbmeta*` member (the standard "vbmeta_disabled") |
| 7 | `pack-ap.sh` | reassembles the AP tar with stock member names/order, md5-appends (`.tar.md5`), splits at 1900 MB for release-asset limits, writes SHA256SUMS |
| 8 | `render-notes.sh` | bilingual release notes |

Outputs land in a prerelease (`rom-v1.0` by default): split AP parts,
`SHA256SUMS.txt`, `RILFix_A15.zip`, manager APK, notes.

## Toolchain (no apt needed)

`rom/tools.sh` provisions everything from GitHub sources: static lptools
(lpmake/lpunpack/lpdumps, android-15.0.0_r25), lz4, e2fsprogs
(mke2fs/debugfs/e2fsck/resize2fs), avbtool (LineageOS mirror), plus the
pure-python `rom/simg2img.py`. The whole super repack was round-trip-verified
in-sandbox on 2026-11-19: synthetic stock super → unpack → replan with a fake
GSI → rebuild → unpack → system bytes == GSI, vendor bytes hash-identical.

## Local (sandbox) mode

`INPUTS_DIR=/path/to/inputs rom/fetch-inputs.sh` etc. — expects the variant
kernel tar, a `RestlessOS-arm64-ab-*.img.xz` (or `gsi.img`), and the stock
`AP_*.tar[.md5]` in one directory. Same pipeline as CI, zero downloads.
Sandbox caveat: release-asset hosts and Samsung FUS are egress-blocked here,
so inputs must arrive via git or connector; Drive's connector caps binary
downloads at 100 MB inline, which excludes the GSI/firmware.

## "Drivers and optimizations" — what that means on Treble

On a Treble device the drivers live in **vendor/product/odm**, which we carry
over byte-identical from the stock firmware inside the rebuilt super. So the
GPU (Mali valhall), camera, audio, sensors, GPS/FM, and modem interface are
exactly Samsung's own drivers — nothing generic.

Phase 2 (not in v1): a device RRO overlay (power_profile, brightness curve,
status-bar/corner metrics) built from the stock `framework-res.apk`, plus phh
tunables — needs a first successful boot to calibrate against.

## SIM-drop bug fix (D011)

With an unlocked bootloader, the stock `ril-daemon` hangs the modem after
~7h25m of uptime (XDA 4688638 / 4703177; affects stock ROM and GSIs alike —
it's in the vendor/MTK RIL). The community-proven workaround (rev.s; itsfaris'
`RILFix_Faris.zip`) is restarting ril-daemon on a timer. We ship a clean-room
implementation as a KernelSU/Magisk module, embedded in the ROM at
`/system/etc/a155f-extras/RILFix_A15.zip` and attached to the release.

**Consequence:** the SIM fix requires a rooted kernel variant
(`kernelsunext` default, or `bakasu`). The `vanilla` package cannot carry the
fix — documented in its release notes. The fix is a workaround, not a
root-cause patch; if Samsung/MTK ever fix the RIL, the module becomes
unnecessary.

## Running it

GitHub → Actions → **Build A155F ROM** → Run workflow:

- `kernel_variant`: `kernelsunext` (default) / `bakasu` / `vanilla`
- `fw_version`: `A155FXXS7CYG4` (pinned; bump deliberately)
- `fw_region`: `TUR` default; region only affects which CSC ships the donor
  vendor — users flash their own region's stock first anyway
- `restless_ref`: empty = latest RestlessOS release
- `release_tag`: prerelease that receives the package

Runtime ≈ 30–60 min (firmware download dominates). Runner disk is managed by
streaming deletes (firmware zip → AP member → super raw are dropped as soon as
consumed); peak usage stays under the free-space budget after the cleanup step.

## Failure modes we expect to iterate on

- **First boot fails** (A17 GSI on A15 vendor): VINTF/ABI gaps → inspect
  `adb logcat`/`dmesg`, then decide: different RestlessOS tag, vndklite-style
  shim, or TrebleDroid base swap. This is the known first-boot gate from D009.
- `lpmake` geometry mismatch → `lp_plan.py` fails loudly with sizes; adjust.
- `samloader` can't serve the pinned version (FUS pruned it) → bump
  `fw_version` and tell users to flash that stock instead.
- Super too small for GSI + vendor → fails loudly before packaging.
