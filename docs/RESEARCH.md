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

## Open research questions

- Exact live device/firmware/partition/boot layout and matched kernel/module inventory.
- Reproducible cause of GSI memory/thermal/crash symptoms.
- Current, maintained Lineage branch suitable for this vendor baseline.
- Public tree completeness and legal availability of required source/proprietary components.
- Minimal coherent sandboxed-Play port and the maintenance burden on the chosen branch.
- Full-stack security update path and the A155F's actual verified-boot/custom-key limitations.
