# Project state

Last documentation update: **2026-11-18 — Europe/Istanbul**.

## Current checkpoint

**Stage: documentation bootstrap published to the destination repository; implementation has not started.**

- Requirements discussed and initial public references inspected (2026-11-16).
- Documentation bootstrap created in the original session as local commit `c49fcf537a38fc03637cea1be331457d6ada3492`, transferred as `a155f-project-checkpoint.zip` (archive comment records that SHA). That commit is **not** part of this repository's history; this repository's first commit is `97d2c0e` ("Add files via upload").
- Destination repository established: `https://github.com/MuhammedAliMizrakTR/GrapheneOS-SM-A155-`. Development on review branch `arena/c08a6bcc-grapheneos-sm-a155` (branched from `main` @ `97d2c0e`). This checkpoint's commit SHA is in `git log`; branch tips move.
- Archive contents extracted and merged into the repository root. The pre-existing `LICENSE` (Apache-2.0) and `README.md` scope note ("Helio G99 variant only") were preserved/merged, not replaced blindly.
- Remaining blocking inputs are listed below; no device data has been collected yet.

## Verification of the received archive (re-run 2026-11-18)

- All 11 expected files present (`.gitattributes`, `.gitignore`, `AGENTS.md`, `CHANGELOG.md`, `MASTER_PROMPT.md`, `PROJECT_STATE.md`, `README.md`, `docs/{DECISIONS,DEVICE_INVENTORY,RESEARCH,ROADMAP}.md`).
- All files valid UTF-8 with final newlines; all fenced code blocks balanced; all 8 relative Markdown links resolve.
- Credential/secret pattern scan: no matches (limited safeguard, not a security audit).
- Archive SHA cross-check against the original session is not possible (different repository/history); contents match the documented initial checkpoint.

## Discrepancies flagged at this checkpoint

1. `docs/DECISIONS.md` D008 records "no repository-wide license selected", but the destination repository was created with an **Apache-2.0 `LICENSE`** file. Owner confirmation needed: adopt Apache-2.0 (update D008) or replace the file.
2. `a155f-project-checkpoint.zip` remains tracked but is now redundant (its contents are tracked directly). `.gitignore` excludes `*.zip` going forward, which does not untrack the existing archive. Owner decision needed: keep or remove.
3. Original-session research (RESEARCH.md) is dated 2026-11-16 and unverified by build/device tests; upstream branches and listings may have changed since.

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
| Destination repository + authenticated publishing | **Established 2026-11-18** | Remote `origin` observed; push performed from the Arena session (see CHANGELOG) |
| Host category Windows/macOS | User-selected category | Exact OS/architecture/RAM/storage unknown |
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
- [ ] Owner confirmation: Apache-2.0 license adoption; keep-or-remove decision for `a155f-project-checkpoint.zip`.
- [ ] Exact host OS, CPU architecture, RAM, free SSD space.
- [ ] Whether current phone software is stock or a specific GSI; exact GSI/build if applicable.
- [ ] Read-only device baseline and partition listings from `docs/DEVICE_INVENTORY.md`.
- [ ] Matching stock firmware package identity and availability for local extraction.
- [ ] Verified boot/root/recovery state and current kernel/modules baseline.

## Next action

**Collect the build-host specifications and the read-only device baseline (`docs/DEVICE_INVENTORY.md`).** Do not start a large source sync, create a purportedly complete device manifest, or flash anything before the missing baseline facts are resolved.

## First device acceptance gate

Record test conditions and measurements for repeatable boot, usable ADB, absence of critical service restart loops, and stable idle memory/temperature. Reaching the launcher alone is insufficient. No part of this gate has been tested.

## Update protocol

At each checkpoint, replace this live summary with the current evidenced state, append to `CHANGELOG.md`, and update accepted decisions or research as needed. Keep historical entries in those files rather than silently rewriting past outcomes. Record actual commit/branch and remote publication status in the session handoff; do not invent a SHA or embed an impossible self-referential current-file commit hash here.
