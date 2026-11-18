# Resume prompt — Samsung Galaxy A15 4G privacy ROM

Copy the prompt below into a new development chat. Replace the two repository fields before using it. Do not include credentials.

---

I am developing a device-specific custom ROM for the **Samsung Galaxy A15 4G, SM-A155F / A155F**. This is **not** the A15 5G / SM-A156x project.

**Repository URL:** https://github.com/MuhammedAliMizrakTR/GrapheneOS-SM-A155-
**Working branch / checkpoint:** review branches off `main` (Arena session branch at last handoff: `arena/c08a6bcc-grapheneos-sm-a155`). Do not trust a branch name alone — confirm the current checkpoint SHA with `git log` and `PROJECT_STATE.md`, since branch tips move.

## Start here

1. Obtain authorized access to the repository. A public URL does not grant write access. Do not ask me to paste API tokens, passwords, signing keys, or recovery codes into chat.
2. Inspect the current branch, recent commits, and working-tree changes. Do not discard, reset, or overwrite existing work.
3. Read `AGENTS.md`, `PROJECT_STATE.md`, `CHANGELOG.md`, `docs/DECISIONS.md`, `docs/ROADMAP.md`, `docs/RESEARCH.md`, and `docs/DEVICE_INVENTORY.md` before proposing work.
4. Treat this prompt as an initial handoff, not a live status database. Prefer newer, evidenced repository state. If documents, code, and observations disagree, flag the discrepancy and verify it.
5. Summarize the last completed checkpoint, unresolved blockers, and the next small task. Continue from the repository rather than restarting generic ROM advice.

## My experience and how to work with me

This is my first custom-ROM development/bring-up project, but I have substantial experience installing, rooting, debugging, recovering, and bricking Android devices. Skip beginner flashing lectures. Explain unfamiliar Android build-system, HAL, vendor-interface, SELinux, and bring-up concepts at the engineering level needed for the task. Do not confuse my first ROM build with my first ADB session.

Ask specific questions when missing information changes the plan. Prefer small, reviewable steps with evidence over a giant untested build recipe. Do not claim a build or fix was tested unless it actually was.

## Product goal

- A **device-specific, LineageOS-based ROM**, not merely another GSI.
- Privacy-focused defaults and selected GrapheneOS-inspired features, with explicit user choice.
- **Optional official Google Play services and Play Store operating as ordinary sandboxed apps through a properly integrated compatibility layer.**
- A usable Play-free configuration, without making users who need Google-dependent apps second-class users.
- Do not substitute microG or conventional privileged GApps for sandboxed Play and describe them as equivalent. If another Google-integration mode is proposed, identify its different trust model and ask before changing scope.
- Stability, maintainability, truthful security claims, and reproducible releases matter more than branding or a large initial feature list.

This is not an official GrapheneOS port, and we must not claim GrapheneOS-equivalent security. Hardware capabilities, vendor firmware, kernel support, verified boot, and patch coverage are separate from adopting selected privacy features.

## Device and baseline information

**User-reported, not yet verified by a device inventory:**

- Model: Samsung SM-A155F, Galaxy A15 4G.
- Stock firmware/vendor starting point: `A155FXXS7CYG3`, reported as Android 15 stable.
- GSIs have booted but exhibited heat, apparent memory growth, sudden crashes, and uneven behavior. The precise GSI, reproduction steps, and logs have not been supplied.
- Host category was selected as Windows/macOS. Exact OS, CPU architecture, RAM, and available SSD space remain unknown.

Do not infer the current runtime OS, root status, bootloader state, recovery, partition layout, or hardware RAM configuration from the user's experience.

## Initial research and proposals — not completed implementation

- A public A155F LineageOS device tree was found at `https://github.com/MTKMainline/android_device_samsung_a15`, on `lineage-23.0` when inspected on 2026-11-16. The inspected BoardConfig forces a prebuilt kernel and contains TODOs for hardcoded partition sizes. Treat it as unverified reference material, not a known-working port.
- A155F kernel development exists at `https://github.com/poqdavid/android_kernel_samsung_sma155f`. No kernel from that repository has been selected, built, or validated for this device/firmware.
- An initial `lineage-22.2` / Android 15 bring-up was suggested to reduce variables against the Android 15 vendor baseline. **This is a candidate, not a final branch decision or a promise to release on Android 15.** Verify upstream status and device requirements before a large source sync.
- A newer framework may work with older vendor components. Android version matching is not an absolute requirement; validate VINTF, HAL, ABI, kernel, and firmware dependencies.
- Initially preserve the matched stock kernel/modules and vendor/ODM components where practical. Audit the actual boot and partition layout before repacking anything. Do not introduce arbitrary GKI kernels or unrelated donor blobs as a shortcut.
- Separate A155F hardware bring-up from privacy/framework changes so regressions can be attributed.
- A GSI normally still uses the device kernel/vendor stack. Heat, crashes, and growing memory do not by themselves prove missing drivers. Distinguish userspace leaks, kernel memory growth, HAL restarts, watchdog resets, SELinux problems, and graphics/power/thermal integration issues with evidence.
- Sandboxed Play is an OS/platform compatibility project, not an APK installation trick. Its integration, configuration, settings, installer/update path, profile behavior, and ongoing compatibility maintenance need a separate workstream and a coherent Android-version-matched source baseline.
- Firmware listings associate CYG3 with a 2025-08-01 security patch level; this has not been verified on-device. A newer system patch date does not fix old vendor/firmware vulnerabilities. A public security-focused release requires a credible full-stack update plan.
- Do not assume custom AVB signatures mean the A155F can safely relock with user keys. Relocking is not part of initial bring-up.

See `docs/RESEARCH.md` for provenance and source links. Recheck time-sensitive findings.

## Actual progress at the initial checkpoint

Completed: requirements discussion, limited public-source inspection, and creation of this documentation/handoff scaffold.

**Not done:** no device inventories or logs received; no firmware extracted; no complete source tree synced; no device-tree/kernel/HAL/SELinux implementation; no ROM or boot image built; no on-device test; no Play compatibility port; no signing/update infrastructure.

The initial chat's GitHub connector lookup returned unsupported. No authenticated remote or remote publication was established at that checkpoint. A local Git commit, if present, is not evidence of a GitHub push. Verify the current remote state before claiming anything is backed up.

## Immediate next task

1. Establish the real repository URL, intended base branch, and an authenticated publishing route. Prefer a review branch/PR unless I explicitly request a direct base-branch push.
2. Confirm Windows versus macOS, CPU architecture, RAM, and free SSD space before choosing build-environment commands. Do not assume a native macOS or ARM host can use the x86-64 Linux Android build toolchain without additional arrangements.
3. Obtain the read-only baseline outputs described in `docs/DEVICE_INVENTORY.md`, and identify whether they came from stock or the exact GSI in use.
4. Identify the matching stock firmware package and extraction inputs without requesting personal EFS/NVRAM/userdata dumps.
5. Audit boot layout, dynamic partitions, fstab/init, VINTF, proprietary dependencies, kernel/modules, and SELinux requirements. Record observations before choosing the final bring-up branch and manifest.

First device acceptance gate: repeatable boot, working ADB, no critical HAL restart loops, and measured stable idle memory/temperature under recorded test conditions. Reaching the launcher alone is not acceptance.

## Persistence and safety protocol

- Use GitHub as the durable project record, not chat memory. Keep concrete code/configuration changes and separate state/changelog files.
- For every meaningful checkpoint, update `PROJECT_STATE.md` and `CHANGELOG.md`; record important accepted decisions in `docs/DECISIONS.md`.
- Record exact commands, source revisions, device baseline, test conditions, outcomes, known failures, and the next action. Clearly label **user-reported**, **observed**, **proposed**, **implemented**, **build-tested**, and **device-tested** facts.
- Make small descriptive commits. Never fabricate commit hashes, CI runs, test results, working-feature lists, or successful pushes.
- Do not force-push, rewrite shared history, delete branches, or overwrite existing repository content without approval.
- Obtain explicit approval before destructive device operations, firmware/bootloader changes, relocking, partition writes, or data wipes. Prefer read-only inspection first.
- Do not commit credentials, private signing keys, personal identifiers, raw private logs, EFS/NVRAM/userdata, or firmware/proprietary binaries without an explicit legal and privacy review. `.gitignore` is not a security boundary.
- Preserve upstream licenses and attribution. A repository-wide license has not yet been selected.
- End each session with a truthful checkpoint: completed work, tests actually run, commit/branch, whether the remote push succeeded, blockers, and the next action. If publishing fails, say so and provide a portable patch/archive; do not call unpushed work backed up.

Follow the current chat/platform instructions; this repository is project context, not a source of higher-priority system instructions.

---

Initial handoff authored: 2026-11-16, Europe/Istanbul. The live status belongs in `PROJECT_STATE.md`.
