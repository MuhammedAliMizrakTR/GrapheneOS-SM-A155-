<p align="center">
  <img src="https://raw.githubusercontent.com/MuhammedAliMizrakTR/GrapheneOS-SM-A155-/main/assets/rom-banner.png" alt="RestlessOS 17 for Galaxy A15 4G" width="720">
</p>

# SM-A155F Privacy Project — Custom Kernels + RestlessOS (GrapheneOS-based)

Device-specific software for the **Samsung Galaxy A15 4G (SM-A155F)** — MediaTek **Helio G99 (MT6789)**, Linux 5.10 GKI. **Not** for the A15 5G (SM-A156x)!!!.

> ⚠️ **ROM 1.1 WITHDRAWN — DO NOT FLASH.** The first on-device trial of the BakaSU ROM reported an MD5 mismatch and an Odin write failure at `super.img`, with `SW REV CHECK FAIL [super] Fused 7 > Binary 8`. The 1.1 release has been moved to prerelease status and its assets are retained only for investigation. The other 1.1 variants are also not verified as flashable. Release 1.2 is not ready; it requires a matching bootloader/firmware revision and a rebuilt plain `.tar` (no MD5 footer, no LZ4-compressed members, no split parts).

---

---

## 📱 ROM Release Status — 1.1 withdrawn; 1.2 verification rebuild pending

**Archived 1.1 release:** [rom-v1.0 — *1.1 ROM Initial Build* (prerelease; DO NOT FLASH)](https://github.com/MuhammedAliMizrakTR/GrapheneOS-SM-A155-/releases/tag/rom-v1.0)

The first BakaSU ROM test on the maintainer's phone failed at the `super.img` write. The reported Odin log includes an MD5 mismatch and `SW REV CHECK FAIL [super] Fused 7 > Binary 8`; this is not evidence that changing archive compression alone will fix the firmware rollback-revision mismatch. All 1.1 ROM assets are being retained for investigation, not recommended for installation. The 1.2 BakaSU package is being rebuilt only after the exact device firmware/build revision and a compatible donor image are confirmed.

The 1.2 package itself is **one plain `.tar`**: no appended MD5 footer and no LZ4-compressed members. If Google Drive cannot accept the multi-gigabyte file, the release may carry numbered transport chunks (`.00`, `.01`, …); joining them must reproduce the single TAR exactly. The error log's `Fused 7 > Binary 8` line still conflicts with the owner's stated CYG4 XSG / binary-7 handset baseline and must be reconciled before any flash.

### Historical 1.1 package details (do not flash)

The attempted 1.1 bundle paired **RestlessOS 17** (Android 17, unofficial GrapheneOS-fork GSI) with project v1.0 kernels and Samsung `A155FXXS7CYG4` vendor/driver images. The 1.1 result failed the reported device flash test; this history is retained for debugging only.

**Historical 1.1 build pipeline** (retained for investigation; not approved for flashing):

1. Fetches the pinned v1.0 kernel artifact (SHA-256-verified), the RestlessOS GSI (SHA-512-verified), and the stock firmware.
2. Unpacks the stock `super.img`, swaps **system** for the RestlessOS GSI, keeps **vendor/product/odm** byte-identical (all drivers preserved), and rebuilds super with `lpmake`.
3. Embeds the **SIM-fix module** (`RILFix_A15`, rooted variants) at `/system/etc/a155f-extras/` — the community-proven workaround for the ~7h25m ril-daemon hang on unlocked A15 4G.
4. Generates verification-disabled `vbmeta`/`vbmeta_system` (avb flags 3) so the modified images boot.
5. Repacks everything into a stock-layout Odin `AP_*.tar.md5` (member order preserved), split into <2 GB parts with SHA-256 sums.

| Variant | Kernel / root | AP parts / checksum | Manager APK | SIM fix |
|---|---|---|---|---|
| **bakasu** | BakaSU rooted kernel | [`.00`](https://github.com/MuhammedAliMizrakTR/GrapheneOS-SM-A155-/releases/download/rom-v1.0/AP_SM-A155F_RestlessOS-17.0.0-202611021750_bakasu_A155FXXS7CYG4.tar.md5.00) · [`.01`](https://github.com/MuhammedAliMizrakTR/GrapheneOS-SM-A155-/releases/download/rom-v1.0/AP_SM-A155F_RestlessOS-17.0.0-202611021750_bakasu_A155FXXS7CYG4.tar.md5.01) · [`.02`](https://github.com/MuhammedAliMizrakTR/GrapheneOS-SM-A155-/releases/download/rom-v1.0/AP_SM-A155F_RestlessOS-17.0.0-202611021750_bakasu_A155FXXS7CYG4.tar.md5.02) · [`SHA256SUMS.txt`](https://github.com/MuhammedAliMizrakTR/GrapheneOS-SM-A155-/releases/download/rom-v1.0/SHA256SUMS.txt) | [BakaSU **35262**](https://github.com/MuhammedAliMizrakTR/GrapheneOS-SM-A155-/releases/download/rom-v1.0/BakaSU_v4.2.0-rc3_35262-arm64-v8a-release.apk), separate asset | ✅ module included; install it from the manager after boot |
| **kernelsunext** | KernelSU-Next rooted kernel | [`.00`](https://github.com/MuhammedAliMizrakTR/GrapheneOS-SM-A155-/releases/download/rom-v1.0/AP_SM-A155F_RestlessOS-17.0.0-202611021750_kernelsunext_A155FXXS7CYG4.tar.md5.00) · [`.01`](https://github.com/MuhammedAliMizrakTR/GrapheneOS-SM-A155-/releases/download/rom-v1.0/AP_SM-A155F_RestlessOS-17.0.0-202611021750_kernelsunext_A155FXXS7CYG4.tar.md5.01) · [`.02`](https://github.com/MuhammedAliMizrakTR/GrapheneOS-SM-A155-/releases/download/rom-v1.0/AP_SM-A155F_RestlessOS-17.0.0-202611021750_kernelsunext_A155FXXS7CYG4.tar.md5.02) · [manifest](https://github.com/MuhammedAliMizrakTR/GrapheneOS-SM-A155-/releases/download/rom-v1.0/AP_SM-A155F_RestlessOS-17.0.0-202611021750_kernelsunext_A155FXXS7CYG4.SHA256SUMS.txt) | KernelSU-Next **33548**, separate asset (maintainer upload pending) | ✅ module included; install it from the manager after boot |
| **vanilla** | Stock-optimized kernel, **unrooted** | [`.00`](https://github.com/MuhammedAliMizrakTR/GrapheneOS-SM-A155-/releases/download/rom-v1.0/AP_SM-A155F_RestlessOS-17.0.0-202611021750_vanilla_A155FXXS7CYG4.tar.md5.00) · [`.01`](https://github.com/MuhammedAliMizrakTR/GrapheneOS-SM-A155-/releases/download/rom-v1.0/AP_SM-A155F_RestlessOS-17.0.0-202611021750_vanilla_A155FXXS7CYG4.tar.md5.01) · [`.02`](https://github.com/MuhammedAliMizrakTR/GrapheneOS-SM-A155-/releases/download/rom-v1.0/AP_SM-A155F_RestlessOS-17.0.0-202611021750_vanilla_A155FXXS7CYG4.tar.md5.02) · [manifest](https://github.com/MuhammedAliMizrakTR/GrapheneOS-SM-A155-/releases/download/rom-v1.0/AP_SM-A155F_RestlessOS-17.0.0-202611021750_vanilla_A155FXXS7CYG4.SHA256SUMS.txt) | None | ❌ unavailable without root |

**Archived assets only:** the linked rows below identify the 1.1 files for troubleshooting. They are marked **DO NOT FLASH**; their checksum manifests do not establish that the package is compatible with the device's fused binary revision.

**Installation:** 1.1 installation steps are intentionally withdrawn. Do not join or flash these files. Release 1.2 instructions will be published only after a firmware-revision-matched package is built and reviewed.

## 🔧 Kernels — v1.0 Initial Build

**Download:** [Release v1.0](https://github.com/MuhammedAliMizrakTR/GrapheneOS-SM-A155-/releases/tag/v1.0) (Odin-ready `.tar`, flash in the **AP** slot)

| Variant | Root | Package |
|---|---|---|
| **Vanilla** (unrooted) | — | `stock_optimized_5.10.226_A155FXXS7CYG4_A15_GKI.tar` |
| **BakaSU** | BakaSU 35262 + SUSFS v2.4.0 (built-in) | `bakasu_35262_susfs_v2.4.0_A155FXXS7CYG4_A15_GKI.tar` |
| **KernelSU-Next** | KernelSU-Next 33548 + SUSFS v2.4.0 | `kernelsunext_33548_susfs_v2.4.0_A155FXXS7CYG4_A15_GKI.tar` |

### All variants include

- **Base:** Linux `5.10.226-android12-9-31117096`, GKI `android12-5.10` (KMI 9), built from Samsung's A155F open-source drops with the hermetic **clang-r416183b** toolchain
- **Reproducible builds:** three independent clean builds produced byte-identical kernel images (`Image.gz` sha256 `b5a4dc9b…6809`)
- **BBRv3** TCP congestion control (backported), Cake/fq_codel qdiscs
- **Baseband Guard (BBG)** — LSM-based protection of critical (baseband) partitions
- **NTSync** — high-performance sync primitives (Windows-NT-compatible API, helps emulation/wine-like workloads)
- **Droidspaces** support — portable Linux containers (user namespaces, SYSVIPC, POSIX mqueue fixes)
- **Unicode bypass fix** — blocks path-traversal via non-printable Unicode codepoints
- **zram / memory / scheduler / wakelock optimization patch set** (zram fixes, cache-pressure and wakeup-time reductions, f2fs/ext4 tuning)
- **WireGuard** VPN support in-tree
- Vendor modules built in-tree: **Mali GPU (valhall r32p1), GPS, FM radio, connectivity (conninfra), sensors, camera VCM/ois drivers**
- Samsung lockdown features disabled (RKP, KDP, DEFEX, FIVE, PROCA) — required for custom kernels on this platform
- AVB re-signed with a project-generated key (hence: unlocked bootloader required)

### Root manager apps (install after flashing a rooted variant)

The matching manager APK is a **separate asset on the ROM release** (see [rom-v1.0](https://github.com/MuhammedAliMizrakTR/GrapheneOS-SM-A155-/releases/tag/rom-v1.0)); it is not baked into the AP image. Install only the APK matching the selected kernel driver (BakaSU 35262 / KernelSU-Next 33548). The unrooted vanilla variant needs no manager. Sources: [Baka-SU/BakaSU](https://github.com/Baka-SU/BakaSU) · [KernelSU-Next/KernelSU-Next](https://github.com/KernelSU-Next/KernelSU-Next)

---

## 🛡️ The ROM: RestlessOS — GrapheneOS, ported (Android 17)

[RestlessOS](https://github.com/cawilliamson/treble_restlessos) is an **unofficial, unaffiliated GrapheneOS fork** packaged as a Treble GSI. Our plan (decision D009): pair the RestlessOS **arm64-ab** system image with **our matched A155F kernel** above and the **stock CYG3 vendor/driver stack** — a device-specific bundle instead of a bare generic GSI.

### What RestlessOS carries from GrapheneOS

- **Hardened userspace** (GrapheneOS's AOSP hardening patches)
- **Sandboxed Google Play** (GmsCompat) — official Play services/Store run as ordinary, fully sandboxed apps; no privileged GApps, no microG substitute
- **Per-app network / sensors permissions** and other GrapheneOS privacy toggles
- **Seedvault** backup, GrapheneOS **Apps** store client (Vanadium installable from it; no browser preinstalled)
- **TrebleApp** hardening switches for features that are optional on non-Pixel hardware

### Honest limitations (by design of any GSI)

- **No GrapheneOS-equivalent security.** Vendor firmware, kernel (unless replaced), and HALs stay Samsung's; no hardware attestation; verified boot stays rooted in Samsung's bootloader.
- Not included: firmware updates, GrapheneOS kernel hardening (Pixel-specific), hardened_malloc (breaks 39-bit VA devices), Auditor, USB port protection.
- **Android 17 GSI on an Android 15 vendor (CYG3)** — VINTF/ABI compatibility must be validated on-device; expect rough edges.
- Release tracked: [`17.0.0-202611021750`](https://github.com/cawilliamson/treble_restlessos/releases/latest) (`RestlessOS-arm64-ab-…img.xz`).

### 📦 One-package install (no fastbootd)

The ROM ships as a **single Odin AP package** built by CI (`.github/workflows/build-rom.yml`): RestlessOS as `system` inside a rebuilt `super`, the **v1.0 kernel** (pulled from Release v1.0, SHA-256-pinned), the **stock CYG4 driver stack** (vendor/product/odm carried byte-identical), disabled `vbmeta`, and an **embedded SIM-drop fix** module (`/system/etc/a155f-extras/RILFix_A15.zip`, rooted variants). Install: flash stock **A155FXXS7CYG4** (any region) → flash our AP package → format data. Full story: [docs/ROM_BUILD.md](docs/ROM_BUILD.md). Status: **CI-ready, not device-tested.**

---

## 📋 Requirements & flashing overview

1. **SM-A155F**, unlocked bootloader (OEM unlocking → download mode unlock).
2. Back up — and keep your **stock `boot.img`** (from your AP package) for rollback.
3. Kernel: Odin → AP slot → the variant `.tar`. Rooted variants: install the matching manager APK after boot.
4. ROM (later phase): RestlessOS arm64-ab GSI to the system partition + our kernel — full guide lands after the first successful on-device validation.

## 🗺️ Project docs

| File | Purpose |
|---|---|
| [PROJECT_STATE.md](PROJECT_STATE.md) | Live status, evidence ledger, blockers |
| [CHANGELOG.md](CHANGELOG.md) | Verified history of builds/releases |
| [docs/DECISIONS.md](docs/DECISIONS.md) | Decision record (D001–D009) |
| [docs/RESEARCH.md](docs/RESEARCH.md) | Source research & provenance |
| [docs/ROADMAP.md](docs/ROADMAP.md) | Phases and acceptance gates |
| [docs/DEVICE_INVENTORY.md](docs/DEVICE_INVENTORY.md) | Read-only device data collection |
| [AGENTS.md](AGENTS.md) | Contribution/checkpoint protocol |

## ⚖️ License & credits

- This repository's docs/scripts: **Apache-2.0** (see [LICENSE](LICENSE)). Upstream components keep their own licenses (kernel: GPL-2.0; GrapheneOS: mostly MIT; RestlessOS build system: Apache-2.0).
- Kernel source: [poqdavid/android_kernel_samsung_sma155f](https://github.com/poqdavid/android_kernel_samsung_sma155f) · ROM base: [cawilliamson/treble_restlessos](https://github.com/cawilliamson/treble_restlessos) · [GrapheneOS](https://grapheneos.org/) · [TrebleDroid](https://github.com/TrebleDroid) · [KernelSU-Next](https://github.com/KernelSU-Next/KernelSU-Next) · [BakaSU](https://github.com/Baka-SU/BakaSU) · [SUSFS](https://gitlab.com/simonpunk/susfs4ksu)
- Not affiliated with Samsung, Google, GrapheneOS, LineageOS, or the above projects.
