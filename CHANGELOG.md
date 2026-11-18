# Changelog

This file records meaningful changes and validation outcomes. Entries are not proof of a GitHub push; confirm the remote commit separately.

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
