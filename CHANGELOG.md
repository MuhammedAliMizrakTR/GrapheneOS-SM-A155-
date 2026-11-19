# Changelog

This file records meaningful changes and validation outcomes. Entries are not proof of a GitHub push; confirm the remote commit separately.

## 2026-11-18 (session 3) — Direction confirmed; draft prerelease approved

### Owner decisions

- **D009 accepted**, D002 amended: RestlessOS GSI made device-specific with the matched A155F kernel + stock CYG3 vendor drivers (owner: "GSI'ı device-specific'e dönüştürelim").
- CYG4-base kernel repack acceptable for now; CYG3-matched repack deferred.
- Bootloader reported **unlocked** — AVB re-signed images are flashable.
- Draft prerelease of the validation kernel tar **approved**.

### Actions

- Sandbox `/tmp` was wiped between turns; full pipeline re-executed in-session: clone → patch workaround → build (**43m59s, success**) → repack+sign (success).
- **Reproducibility evidence:** two independent clean builds produced byte-identical `Image.gz` (sha256 `b5a4dc9b…6809`). Signed boot images differ per run because repack generates a fresh AVB key each time.
- Draft prerelease `kernel-validation-5.10.226-20261118` created with notes+hashes. **Binary asset upload failed** (`uploads.github.com` unreachable from this sandbox, EOF on POST) — the tar is instead served temporarily via the sandbox preview HTTP server; hashes below verify any copy.
- Published-artifact hashes (SHA-256): tar `d1a9f3434a4bc42805cf2487b2a26e780872beefb2bfdedf2e9c8b3ca10612cd`; `boot-repacked-signed.img` `edf694e20a6e9496148d4803786ec408b54b5b1e3b36c9a6c7f90e50e081d8bf`; `Image.gz` `b5a4dc9b0bd62aef4c2cf8266cb2818421d9c2fc149c78f59207f64bbebb6809`.
- Identified RestlessOS latest prebuilt for later device validation: `17.0.0-202611021750`, asset `RestlessOS-arm64-ab-17.0.0-202611021750.img.xz` (943 MB, arm64-ab matches A155F).

---

## 2026-11-18 (session 2b) — Kernel build succeeded in sandbox (build-tested only)

### Built

- `poqdavid/android_kernel_samsung_sma155f` @ `main` (`7a2d6bc`), stock-optimized variant (no root, no SUSFS), hermetic clang-r416183b toolchain, `-j2` on 2 CPU / 3.8 GB RAM: **build completed in 44m06s**.
- Artifacts (SHA-256):
  - `arch/arm64/boot/Image.gz` — `b5a4dc9b0bd62aef4c2cf8266cb2818421d9c2fc149c78f59207f64bbebb6809`
  - `repackfiles/boot-repacked-signed.img` (64 MB) — `dd6413e3d5d48de2874dfcb34a5cc9307150276fbaf03629ab73adb3bcafeeda`
  - `release/stock_optimized_5.10.226_A155FXXS7CYG4_A15_GKI.tar` (67 MB) — `c8697ee51d676a575d7bb16dc594452fad7fe75fcfb4f774996c8f0303ae1443`
- Kernel release string: `5.10.226-android12-9-31117096`; vendor modules (mali, gps, fmradio, connectivity…) built and depmod'd cleanly.
- `lz4` v1.11.1 built from source with the bundled clang for the repack step (no host toolchain changes).

### Environment fixes applied (local, not upstream)

- Baseband-Guard `setup.sh` fetched via GitHub API and invoked locally (`raw.githubusercontent.com` unreachable from this sandbox; the script's own `git clone` via github.com works).
- BBG's informational `show_config_lsm_notice` stubbed (distro `mawk` lacks gawk's 3-arg `match()`); functional BBG steps unaffected.

### Explicitly NOT done

- **Not flashed, not device-tested.** No boot claim.
- Repack base is the shipped **CYG4** boot image — flashing as-is on the user's **CYG3** device is not advised; supply the CYG3 stock `boot.img` for a matched repack.
- Signed with a freshly generated AVB key → flashing requires an unlocked bootloader; key is throwaway sandbox material, not a release key.

### Next

- Owner: CYG3 stock `boot.img` (from AP), bootloader-unlock state, D009 confirmation, and whether to publish this validation artifact (draft prerelease) or keep it local.

---

## 2026-11-18 (session 2) — Kernel/ROM sources selected; first sandbox kernel build attempted

### Changed

- Owner selected sources: kernel `poqdavid/android_kernel_samsung_sma155f` (`main`, stock-optimized no-root), ROM `cawilliamson/treble_restlessos` (RestlessOS GSI, `android-17.0`).
- `docs/RESEARCH.md`: added R008 (kernel repo hands-on verification) and R009 (RestlessOS evaluation, incl. its GSI trust model and CI-only build pipeline).
- `docs/DECISIONS.md`: added D009 (owner-directed GSI direction; conflicts with D002 — confirmation pending).
- `PROJECT_STATE.md`: refreshed; PR #1 merged to `main` (`cee1d02`); new session branch `arena/76b5d892-grapheneos-sm-a155`.

### Evidence / validation

- Kernel repo cloned and inspected (branch map, hermetic toolchain, build/repack flow); findings in R008.
- Kernel build started in this sandbox (stock variant, `-j2`); environment fixes: BBG `setup.sh` fetched via GitHub API (`raw.githubusercontent.com` unreachable), gawk-only notice stubbed for `mawk`. **Build outcome pending at commit time — see PROJECT_STATE.md; no success is claimed yet.**
- No firmware extraction, device test, or RestlessOS build has run.

### Known failures / open items

- D009 needs explicit owner confirmation (GSI vs device-specific LineageOS).
- Kernel release tags target CYG1/CYG4; user's CYG3 stock `boot.img` is required for a matched repack. Repack re-signs AVB with a generated key → unlocked bootloader needed.
- RestlessOS has no supported local build path; its GitHub Actions + EC2 pipeline must be forked/configured (keys, costs) if self-building.

### Publishing

- Committed on `arena/76b5d892-grapheneos-sm-a155` and pushed to `origin`; SHA in `git log` / `git ls-remote`.

### Next

- Record build outcome truthfully; collect CYG3 `boot.img`, bootloader state, host RAM/SSD, and the read-only device baseline.

---

## 2026-11-18 (update) — Owner decisions applied

- **Changed:** D008 license sub-item resolved — Apache-2.0 adopted; `a155f-project-checkpoint.zip` removed (contents remain tracked directly); README/PROJECT_STATE updated to match.
- **Owner inputs:** build host is Windows x86-64 (RAM/free SSD pending); device is on stock `A155FXXS7CYG3` / Android 15.
- **Validation:** documentation-only change; link/fence/UTF-8 checks re-run clean.
- **Publishing:** committed on `arena/c08a6bcc-grapheneos-sm-a155` and pushed; SHA in `git log` / `git ls-remote`.
- **Next:** host RAM/SSD + read-only device baseline from `docs/DEVICE_INVENTORY.md`.

---

## 2026-11-18 — Checkpoint archive merged; destination repository established

### Changed

- Extracted `a155f-project-checkpoint.zip` (uploaded in commit `97d2c0e`) and merged the 11-file documentation bootstrap into the repository root; `docs/` now tracked directly.
- `README.md`: merged — kept the original "Helio G99 variant only" scope note, adopted the bootstrap content, updated publishing status.
- `MASTER_PROMPT.md`: filled the previously `NOT SET` repository URL and branch fields.
- `PROJECT_STATE.md`: refreshed as the live status; added the verification results and discrepancy list below.
- `docs/DECISIONS.md`: D007 publishing leg resolved (host leg still open); D008 annotated with the observed Apache-2.0 `LICENSE` pending owner confirmation.
- Preserved existing `LICENSE` (Apache-2.0) and `a155f-project-checkpoint.zip`; no history rewritten, no force-push.

### Evidence

- Provenance: zip archive comment records original-session local commit `c49fcf537a38fc03637cea1be331457d6ada3492` (not part of this repository's history; this repo's first commit is `97d2c0e`).
- Remote observed: `origin → https://github.com/MuhammedAliMizrakTR/GrapheneOS-SM-A155-.git`; session branch `arena/c08a6bcc-grapheneos-sm-a155` off `main` @ `97d2c0e`.

### Validation

- Re-ran the documented bootstrap checks on the extracted files: 11/11 files present; UTF-8 and final newlines OK; fenced code blocks balanced; 8/8 relative Markdown links resolve; credential-pattern scan clean; `git diff --cached --check` clean.
- No Android build, firmware extraction, runtime diagnosis, hardware test, or Play compatibility test has run.

### Known failures / open items

- D008 conflict: repository carries an Apache-2.0 `LICENSE` while the decision log records licensing as deferred → owner must confirm or replace.
- `a155f-project-checkpoint.zip` is now redundant; keep-or-remove is an owner decision (it stays tracked until then).

### Publishing

- Committed on review branch `arena/c08a6bcc-grapheneos-sm-a155` and pushed to `origin`; exact SHA is in `git log` / `git ls-remote` (branch tips move, no self-referential hash recorded here).

### Next

- Owner confirms license and zip retention; user supplies build-host specs (OS/arch/RAM/free SSD) and the read-only device baseline from `docs/DEVICE_INVENTORY.md`.

---

## 2026-11-16 — Initial documentation checkpoint

### Added

- Project README and current-state/evidence ledger.
- Portable master prompt for resuming in another development chat.
- Agent/contributor checkpoint protocol.
- Phased roadmap, decision log, research references, and read-only inventory instructions.
- Initial ignore and line-ending rules for a documentation-first repository.

### Established requirements

- Target SM-A155F / Galaxy A15 4G, not SM-A156x / A15 5G.
- LineageOS-based privacy-focused ROM with optional genuine sandboxed Google Play support.
- User-reported starting firmware `A155FXXS7CYG3` / Android 15 stable.
- GitHub should be the durable record of code, decisions, progress, and handoffs.

### Validation

- Passed local checks for all 11 required files, UTF-8/final newlines, balanced fenced code blocks, and all 8 relative Markdown links.
- Passed a basic credential-pattern scan and `git diff --cached --check`. These checks are limited safeguards, not a security audit or verification of external research claims.
- No Android build, firmware extraction, runtime diagnosis, hardware test, or Play compatibility test has run.

### Publishing

- Destination repository and write authorization were not supplied at initialization.
- The initial session's GitHub connector lookup returned unsupported.
- No remote push was performed by the assistant for this initial checkpoint.

### Next

- Select repository/access route and publish a reviewed checkpoint.
- Confirm build-host specifications and collect the read-only device baseline.

---

## Future-entry template

### YYYY-MM-DD — Short checkpoint title

- **Changed:** concrete files/configuration/behavior.
- **Evidence:** source revisions, firmware baseline, and sanitized command/log references.
- **Validation:** exact commands/tests run and outcomes; distinguish build-tested from device-tested.
- **Known failures:** unresolved issues and reproduction details.
- **Publishing:** actual branch/commit and push/PR result; say explicitly if unpushed.
- **Next:** one clear next action and required inputs.
