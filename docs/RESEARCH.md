# Research notes and provenance

Initial inspection date: **2026-11-16**. These are public-source observations and engineering interpretations, not build/device test results. URLs and upstream status may change; recheck before acting. No complete Android source tree was cloned for this research.

## R001 — Public A155F device-tree scaffolding

- Repository: https://github.com/MTKMainline/android_device_samsung_a15
- Branch observed: `lineage-23.0`.
- Latest commit shown during inspection: `1ba6181e1ed2a90d73c8d742a07fd944c335c8c4` (2026-01-08).
- Files read: README, BoardConfig.mk, device.mk, and the repository page.
- BoardConfig source inspected: https://raw.githubusercontent.com/MTKMainline/android_device_samsung_a15/refs/heads/lineage-23.0/BoardConfig.mk
- Device configuration source inspected: https://raw.githubusercontent.com/MTKMainline/android_device_samsung_a15/refs/heads/lineage-23.0/device.mk
- Observed: forced prebuilt-kernel configuration, MT6789 platform declaration, and TODOs for hardcoded super/dynamic partition sizes.
- Interpretation: useful reference material; not sufficient evidence of a complete, correct, buildable, or usable device port. Do not copy partition values without checking actual metadata.
- Not established: working features, successful build, firmware match, SELinux readiness, or device stability.

## R002 — A155F-specific kernel development

- Repository: https://github.com/poqdavid/android_kernel_samsung_sma155f
- Related thread: https://xdaforums.com/t/kernel-gki-a15-4g-sm-a155f-mt6789-kernelsu-next-kernelsu-susfs.4795576/
- Repository describes SM-A155F / MediaTek MT6789 / Helio G99 and Linux 5.10 GKI-derived kernel work.
- Published requirements mention firmware-specific builds; do not assume CYG1/CYG4 artifacts match the user's CYG3 modules or boot layout.
- Interpretation: source/reference availability, not evidence of full ROM support or a selected kernel for this project. Root/hiding modifications are not required by the stated product goal and are not adopted.

## R003 — Firmware baseline and patch age

- Firmware listing: https://samfw.com/firmware/SM-A155F/XID
- Additional listing: https://www.sammobile.com/samsung/galaxy-a15/firmware/SM-A155F/THL/
- Listings associate `A155FXXS7CYG3` with Android 15; the SamFW listing shows security patch level 2025-08-01.
- Qualification: these are third-party listings, not a verified extraction or live-device report. The user's exact regional package/CSC and installed components remain unknown.
- Implication: an initial fixed baseline is useful for debugging, but a newer system security date alone would not patch an old vendor/kernel/firmware stack. Evaluate update coverage before any security-focused release.

## R004 — Genuine sandboxed Google Play

- Official usage documentation: https://grapheneos.org/usage
- Official project overview: https://grapheneos.org/
- Official companion source: https://github.com/GrapheneOS/platform_packages_apps_GmsCompat
- Compatibility configuration releases: https://github.com/GrapheneOS/platform_packages_apps_GmsCompat/releases
- Official design: a platform compatibility layer allows official Google Play releases to operate as regular apps in the standard app sandbox, without the normal privileged system integration. Installation is profile-specific.
- Interpretation: not equivalent to installing a GApps ZIP, just putting Play in a work profile, adding a single companion APK, or replacing it with microG.
- Maintenance implication: compatibility behavior/configuration changes over time. A port needs a coherent Android-version-matched baseline, dependency review, a trusted update strategy, and regression testing.
- Do not import current default branches into an older framework blindly. Scope and privileged exceptions, such as Android Auto support, need separate review. Sandboxed Play does not guarantee every banking/payment/attestation-dependent app will work.

## R005 — GrapheneOS security scope

- Official FAQ: https://grapheneos.org/faq#device-support
- Official production support and security requirements are device-specific; the A155F is not established as a supported production target here.
- Interpretation: adopting selected features does not establish equivalent hardware hardening, firmware updates, verified boot, exploit mitigation, or support guarantees. Do not call the project an official GrapheneOS port.

## R006 — Build environment

- AOSP workstation requirements: https://source.android.com/docs/setup/start/requirements
- LineageOS example build documentation: https://wiki.lineageos.org/devices/taimen/build/
- The inspected AOSP requirements specify an x86-64 Linux workstation, at least 400 GB free disk, and 64 GB RAM for the current platform baseline.
- Qualification: requirements vary with branch and build parallelism; this is not a measured A155F build requirement. WSL2, VM, native Linux, or remote builder selection is pending the actual host architecture/resources.
- Do not treat an unrelated device's build/install instructions as A155F instructions. No source branch has been synced and no environment installed for this project.

## R007 — Initial GitHub tool availability

- On 2026-11-16, the initial session's `github` connector lookup returned `unsupported`.
- This describes that tool lookup, not a permanent statement that GitHub can never be accessed by another authorized mechanism or in a later chat.
- No destination repository, authenticated Git remote, API call, PR, or remote push was established at the initial checkpoint.

## R008 — Kernel repository hands-on verification (2026-11-18)

- Repository cloned (`main` branch, depth 1): ~3.9 GB working tree, ~93k files.
- Branch/variant map confirmed from README and `.github/workflows/build.yml`: `main` = **stock optimized, no root** (release prefix `STOCK_OPTIMIZED_`); `kernelsu`, `kernelsunext`, `kernelsunext-lkm`, `bakasu`/`resukisu` = root-oriented variants. The no-root `main` branch matches this project's stated goal (RESEARCH R002: root is not required).
- Kernel content: `kernel-5.10/` imported from Samsung Open Source drops (latest import commit references `SM-A155F_15_Opensource_A155FXXS7CYG4`); GKI `android12-5.10`, KMI generation 9; defconfig `a15_00_defconfig` (+`entry_level.config` overlay).
- Build is **hermetic**: bundled prebuilts provide clang-r416183b (`prebuilts-master/clang`), AOSP build-tools (bison/flex/bc/m4/make…), `magiskboot`/`avbtool` (`scripts/bin`). System packages listed in the README are largely redundant with the hermetic path.
- Build entry points: `./build.sh -j N` (stock) then `./scripts/repack` (repacks `repackfiles/boot.img.lz4`, **re-signs with a freshly generated AVB key** → requires unlocked bootloader; not stock-signed).
- **Firmware mismatch confirmed:** release tags target `A155FXXS7CYG1`/`CYG4`; user baseline is `CYG3`. For a firmware-matched repack, the user's **CYG3 stock `boot.img`** (from the AP package) must replace `repackfiles/boot.img.lz4`.
- Sandbox build findings (2026-11-18): build starts and compiles with the bundled toolchain on a 2-CPU/3.8 GB Debian 12 container. Two environment issues found and worked around locally: (1) `raw.githubusercontent.com` blocked → Baseband-Guard `setup.sh` fetched via the GitHub API instead (script itself clones via `github.com`, which works); (2) distro `mawk` lacks gawk's 3-arg `match()` used by BBG's informational `show_config_lsm_notice` → notice stubbed; the functional steps (clone/symlink/Makefile/Kconfig) succeed. Build result pending at documentation time — see PROJECT_STATE.md.
- Not yet established: completed build artifact, boot on device, or module/vendor compatibility with CYG3.

## R009 — RestlessOS evaluation (owner-proposed ROM source, 2026-11-18)

- Repository: https://github.com/cawilliamson/treble_restlessos — branch `android-17.0` (active; last commit 2026-11-17), 72 releases, latest observed `17.0.0-202611021750` (2026-11-02).
- **What it is:** unofficial, unaffiliated GrapheneOS fork packaged as a **Generic System Image (GSI)** on a TrebleDroid base. This conflicts with D002's "device-specific, not merely a GSI" — recorded as owner-directed scope change in D009, pending confirmation.
- Upstream's own security posture matches this project's truthfulness requirements: explicitly "no security guarantees"; a GSI cannot provide firmware/kernel/HAL updates, GrapheneOS kernel hardening, hardware attestation, or verified-boot control. Removed features include hardened_malloc (39-bit VA boot loops), Auditor, mtectrl, USB port protection; some hardening disabled by default for vendor-driver compatibility (re-enableable in TrebleApp).
- MediaTek BPF bug (ALPS05247589) affects vendor kernels 4.14/4.19 — **not applicable** to this device's 5.10 kernel.
- Build: **no supported local build path** — the GitHub Actions pipeline (`.github/workflows/build.yml`) provisions EC2 spot instances, syncs GrapheneOS manifests, applies patches, builds, signs (private `vendor_cawilliamson-priv` key repo; reference scripts in public `vendor_cawilliamson_keys`), and releases. A fork could run the same pipeline; owner GitHub Actions usage/costs and key custody need consideration.
- Drivers answer for the GSI approach: HALs/drivers come from the **stock vendor partition** (Treble architecture) — no blob extraction needed for basic bring-up, but the vendor/ODm stack must stay firmware-matched (CYG3), and the kernel must remain module-compatible with it.
- Sandboxed Play: GrapheneOS's GmsCompat is part of the upstream feature set a RestlessOS image inherits; exact behavior/configuration on this device still requires on-device validation (Phase 4).

## Open research questions

- Exact live device/firmware/partition/boot layout and matched kernel/module inventory.
- Reproducible cause of GSI memory/thermal/crash symptoms.
- Current, maintained Lineage branch suitable for this vendor baseline.
- Public tree completeness and legal availability of required source/proprietary components.
- Minimal coherent sandboxed-Play port and the maintenance burden on the chosen branch.
- Full-stack security update path and the A155F's actual verified-boot/custom-key limitations.
