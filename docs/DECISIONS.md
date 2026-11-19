# Decision record

Statuses: **Accepted requirement**, **Proposed**, **Deferred**, or **Rejected**. Proposed items are not final merely because an assistant suggested them.

## D001 — Device scope

- Date: 2026-11-16
- Status: **Accepted requirement**
- Decision: Samsung Galaxy A15 4G / SM-A155F is the initial target. SM-A156x / A15 5G is outside scope.
- Basis: User's explicit device identification. Actual device inventory remains pending.

## D002 — Product direction

- Date: 2026-11-16; amended 2026-11-18
- Status: **Accepted requirement (amended)**
- Decision (2026-11-16): LineageOS-based, privacy-focused, GrapheneOS-inspired, with optional genuine sandboxed Google Play support and a usable Play-free default.
- Amendment (2026-11-18, owner): the ROM base changes to **RestlessOS** (unofficial GrapheneOS-fork GSI) made device-specific via the matched A155F kernel and stock-matched vendor drivers — see **D009**. The "not merely another GSI" intent survives as device-matched packaging and validation gates rather than a from-scratch LineageOS device tree; the LineageOS path is not closed if the GSI approach fails its gates.
- Unchanged: sandboxed-Play requirement (GmsCompat lineage is preserved by RestlessOS); conventional privileged GApps or microG cannot silently replace it. No official GrapheneOS affiliation or equivalent-security claims.

## D003 — Durable development record

- Date: 2026-11-16
- Status: **Accepted requirement**
- Decision: Keep code/configuration, state, decisions, and changelogs in the owner's GitHub repository, with a portable master prompt for new chats.
- Consequence: Each session needs a truthful checkpoint and remote publication result. No repository URL or authenticated write route has yet been supplied.

## D004 — Initial firmware reference

- Date: 2026-11-16
- Status: **Accepted user-reported starting point; verification pending**
- Decision: Use `A155FXXS7CYG3` / Android 15 stable as the stated starting reference.
- Consequence: Do not mix kernels/modules/firmware casually or infer on-device contents from the build name. This is not a decision to release with an old vendor security baseline indefinitely.

## D005 — Initial Lineage branch

- Date: 2026-11-16
- Status: **Proposed**
- Proposal: Consider `lineage-22.2` / Android 15 to reduce initial bring-up variables.
- Open: Verify current upstream status and device dependencies; evaluate a newer framework where supported. Existing public A155F scaffolding was on `lineage-23.0`, not a validated 22.2 port.

## D006 — Separate hardware and privacy workstreams

- Date: 2026-11-16
- Status: **Proposed engineering approach**
- Proposal: Establish a minimal stable device-specific baseline before adding privacy/framework compatibility patches; retain matched stock kernel/modules/vendor components initially where practical.
- Reason: Reduce regression ambiguity. This is not a claim that stock components require no adaptation.

## D007 — Host and publishing workflow

- Date: 2026-11-16; updated 2026-11-18
- Status: **Partially resolved** — publishing leg resolved; host leg still open.
- Resolved (2026-11-18): destination repository `https://github.com/MuhammedAliMizrakTR/GrapheneOS-SM-A155-`, base branch `main`, review-branch workflow with authenticated push from the Arena session. No force-push.
- Open: Windows versus macOS, CPU architecture, RAM/storage for the build host.

## D009 — ROM source direction: RestlessOS GSI + device-matched kernel ("device-specific-ized GSI")

- Date: 2026-11-18
- Status: **Accepted (owner-confirmed 2026-11-18)** — supersedes the LineageOS-first reading of D002; see amendment note there.
- Decision: use `cawilliamson/treble_restlessos` (unofficial GrapheneOS-fork GSI, `android-17.0`) as the ROM base, and make it device-specific by pairing it with the A155F-matched kernel (`poqdavid/android_kernel_samsung_sma155f`, `main` stock-optimized) and the stock CYG3-matched vendor/driver stack. Owner's words: embed the A155F kernel and drivers into the GSI rather than ship a bare generic image.
- Practical packaging: device-targeted bundle = RestlessOS system image + A155F-matched `boot.img` (our kernel) + explicit firmware/vendor baseline (CYG3) + flashing/rollback instructions. A full self-built RestlessOS (forked GitHub Actions + EC2 pipeline) is a later phase; initial validation may use upstream RestlessOS prebuilt releases (arm64-ab) where lawful and version-appropriate.
- Trust model (unchanged from R009): no GrapheneOS-equivalent claims; vendor partition/firmware remain Samsung's; AVB re-sign uses our own keys (bootloader unlocked, user-reported).
- Consequence: VINTF/ABI compatibility of an Android 17 GSI with the Android 15 CYG3 vendor must be validated on-device (first boot gate). MTK 4.14/4.19 BPF bug is not applicable (5.10 kernel).

## D008 — Release security, licensing, and branding

- Date: 2026-11-16; updated 2026-11-18
- Status: **License sub-item resolved** — owner confirmed on 2026-11-18: **Apache-2.0 is the project license**, matching the `LICENSE` file the repository was created with. Remaining items below stay deferred.
- Open: Maintained framework/vendor baseline, exact privacy feature list, threat model, signing/update design, project name/branding, and distribution rights.
- Constraint: Do not claim GrapheneOS-equivalent security or safe custom-key bootloader relocking without evidence. No third-party source or binaries were copied into the documentation bootstrap. Preserve upstream licenses and attribution when code is introduced; this repository cannot relicense imported material.
