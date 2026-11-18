# Project state

Last documentation update: **2026-11-18 — Europe/Istanbul**.

## Current checkpoint

**Stage: documentation bootstrap merged to `main` (PR #1, commit `cee1d02`); kernel source verified and first sandbox build attempted; implementation has not started.**

- 2026-11-18 (session 2): owner directed the kernel source (`poqdavid/android_kernel_samsung_sma155f`, `main` = stock-optimized, no root) and ROM source (`cawilliamson/treble_restlessos`, RestlessOS = unofficial GrapheneOS-fork **GSI**, `android-17.0`). See D009 for the D002 scope conflict; owner confirmation pending.
- Kernel repo hands-on verification done (R008): hermetic toolchain bundled; build flow documented; CYG1/CYG4 vs user's CYG3 mismatch confirmed — repack needs the user's CYG3 stock `boot.img`; repack re-signs with a generated AVB key → unlocked bootloader required.
- First kernel build **succeeded** in this sandbox (2 CPU / 3.8 GB RAM / Debian 12, `-j2`, 44m06s). Two environment workarounds were needed (GitHub API fetch for BBG setup; mawk→gawk notice stub). Artifacts: `Image`/`Image.gz`, signed `boot-repacked-signed.img`, `stock_optimized_5.10.226_A155FXXS7CYG4_A15_GKI.tar` (hashes in CHANGELOG). **Build-tested only — never flashed or device-tested.** The repack base is the repo's shipped CYG4 `boot.img.lz4`; a CYG3-matched repack still needs the user's stock `boot.img`.
- No device data collected yet (user is away from the PC; device baseline still open).

## Verification of the received archive (re-run 2026-11-18)

- All 11 expected files present (`.gitattributes`, `.gitignore`, `AGENTS.md`, `CHANGELOG.md`, `MASTER_PROMPT.md`, `PROJECT_STATE.md`, `README.md`, `docs/{DECISIONS,DEVICE_INVENTORY,RESEARCH,ROADMAP}.md`).
- All files valid UTF-8 with final newlines; all fenced code blocks balanced; all 8 relative Markdown links resolve.
- Credential/secret pattern scan: no matches (limited safeguard, not a security audit).
- Archive SHA cross-check against the original session is not possible (different repository/history); contents match the documented initial checkpoint.

## Discrepancies flagged and resolved at this checkpoint

1. ~~D008 vs `LICENSE`~~ → **Resolved 2026-11-18:** owner confirmed **Apache-2.0** as the project license; D008 updated.
2. ~~Redundant `a155f-project-checkpoint.zip`~~ → **Resolved 2026-11-18:** owner decided to remove it; contents remain tracked directly.
3. Original-session research (RESEARCH.md) is dated 2026-11-16 and unverified by build/device tests; upstream branches and listings may have changed since. (Open)

## Owner inputs received (2026-11-18)

- Build host: **Windows, x86-64** → Linux build environment via WSL2/VM; RAM and free SSD still unknown.
- Device runtime: **stock firmware** (`A155FXXS7CYG3` / Android 15), no root/custom recovery reported → baseline outputs will be interpreted as stock.

## Evidence ledger

| Item | Status | Evidence / qualification |
| --- | --- | --- |
| Target SM-A155F / Galaxy A15 4G | User-reported; accepted scope | User explicitly named A155 / A155F; repo README limits scope to the Helio G99 variant |
| LineageOS-based privacy-focused ROM | User requirement | GrapheneOS-inspired; not an official GrapheneOS port |
| Optional genuine sandboxed Google Play | User requirement | Integration not designed or implemented yet |
| Firmware `A155FXXS7CYG3`, Android 15 stable | User-reported | No getprop or extracted firmware supplied |
| GSI heat, apparent memory growth, crashes | User-reported symptoms | No exact GSI, logs, reproduction, or diagnosis |
| MT6789 / Helio G99 platform | Public-source indication | Not checked on the user's device; see research references |
| Public A155F Lineage tree exists | Web-observed | Inspected selected files only; not build/device validated |
| Destination repository + authenticated publishing | **Established 2026-11-18** | Remote `origin` observed; PR #1 merged to `main` (`cee1d02`); session branch `arena/76b5d892-grapheneos-sm-a155` |
| Kernel source selected | Owner-directed 2026-11-18 | `poqdavid/android_kernel_samsung_sma155f` `main` (stock-optimized, no root); hands-on verified (R008) |
| ROM source selected | Owner-directed 2026-11-18; D002 conflict pending | `cawilliamson/treble_restlessos` RestlessOS GSI (R009); D009 confirmation open |
| Kernel sandbox build | **Build-tested 2026-11-18 (not device-tested)** | Stock variant built OK in 44m06s (2 CPU/3.8 GB sandbox): kernel `5.10.226-android12-9-31117096`, `Image.gz` sha256 `b5a4dc9b…6809`; repack+AVB-sign OK; tar sha256 `c8697ee5…1443`. Repack base is the shipped **CYG4** boot image — not yet matched to user's CYG3 |
| Host platform | User-confirmed 2026-11-18 | Windows, x86-64; RAM and free SSD still unknown |
| Device inventories/logs received | Not done | None supplied |
| Firmware extraction / blob audit | Not done | No matching local package supplied |
| Source sync / ROM implementation | Not done | Documentation files only |
| Build / on-device validation | Not done | No ROM/boot/recovery image produced or flashed |
| GmsCompat integration | Not done | No framework patches or compatibility tests |
| Signing / OTA / relock support | Not done / unknown | No security or compatibility claims justified |

## Proposed engineering approach

These are proposals, not test results:

1. Isolate device support from privacy-platform changes.
2. Keep a matched stock kernel/modules/vendor baseline initially where practical.
3. Audit the public device tree against the exact firmware before adopting configuration.
4. Consider `lineage-22.2` / Android 15 for initial bring-up to reduce variables. Choose the actual branch only after compatibility and upstream-status checks; a newer framework may work with Android 15 vendor components.
5. Port optional sandboxed Play as a separate, maintained platform workstream after a stable reference build exists.
6. Plan current vendor/firmware patch coverage before any security-focused public release.

## Blocking inputs

- [x] Destination repository HTTPS URL and owner-approved base branch. → `MuhammedAliMizrakTR/GrapheneOS-SM-A155-`, base `main`, review branches.
- [x] Publishing method, authentication, and branch/PR authorization. → Authenticated `git`/`gh` push from the Arena session; review-branch workflow.
- [x] License decision. → Apache-2.0 adopted (owner, 2026-11-18); D008 updated.
- [x] Checkpoint archive retention. → Removed (owner, 2026-11-18).
- [x] Host OS/architecture. → Windows, x86-64 (owner, 2026-11-18).
- [ ] Host RAM and free SSD space (decides WSL2 vs VM vs remote builder).
- [x] Device runtime: stock vs GSI. → Stock `A155FXXS7CYG3` / Android 15 (user-reported, 2026-11-18).
- [ ] Read-only device baseline and partition listings from `docs/DEVICE_INVENTORY.md`.
- [ ] Matching stock firmware package identity and availability for local extraction.
- [ ] Verified boot/root/recovery state and current kernel/modules baseline.

## Next action

**Record the sandbox kernel-build outcome, then (owner confirmation of D009 permitting) repack against the user's CYG3 stock `boot.img`.** Still needed from the user: host RAM/free SSD, the read-only device baseline (`docs/DEVICE_INVENTORY.md`), the CYG3 AP package (or at least its `boot.img`), and confirmation of bootloader-unlock state. Do not flash anything without explicit approval.

## First device acceptance gate

Record test conditions and measurements for repeatable boot, usable ADB, absence of critical service restart loops, and stable idle memory/temperature. Reaching the launcher alone is insufficient. No part of this gate has been tested.

## Update protocol

At each checkpoint, replace this live summary with the current evidenced state, append to `CHANGELOG.md`, and update accepted decisions or research as needed. Keep historical entries in those files rather than silently rewriting past outcomes. Record actual commit/branch and remote publication status in the session handoff; do not invent a SHA or embed an impossible self-referential current-file commit hash here.
