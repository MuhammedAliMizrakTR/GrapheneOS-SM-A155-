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

## D010 — ROM delivery: Odin AP package built by GitHub Actions (no fastbootd)

- Date: 2026-11-19
- Status: **Accepted (owner-directed 2026-11-19)** — "önce orjinal CYG4, sonra paketlenmiş AP; fastbootd yok".
- Decision: ship the ROM as a single Odin-flashable `AP_*.tar.md5` = stock CYG4 AP member list/order with three swaps: `boot` ← our released v1.0 kernel (pulled from release v1.0, SHA-256-pinned, **never rebuilt**), `super` ← rebuilt with RestlessOS GSI as `system` and stock vendor/product/odm carried byte-identical, `vbmeta*` ← `avbtool --flags 3` (disabled). Users flash stock CYG4 first, then this AP, then format data.
- Why Actions: the build sandbox cannot download release assets or Samsung FUS firmware (egress-limited); GitHub-hosted runners can. Pipeline lives in `.github/workflows/build-rom.yml` + `rom/`; architecture in `docs/ROM_BUILD.md`.
- Consequence: release assets >2 GB must be split (1900 MB parts + SHA256SUMS). Kernel bytes provably identical to the v1.0 round-2 builds via the pinned hashes in `rom/fetch-inputs.sh`.

## D011 — Unlocked-bootloader SIM-drop bug: ship the community ril-restart workaround

- Date: 2026-11-19
- Status: **Accepted (owner-directed 2026-11-19)** — "SimBUG fix'i içine dahil et".
- Finding: on SM-A155F with an unlocked bootloader, stock `ril-daemon` hangs the modem after ~7h25m runtime (XDA 4688638/4703177); affects stock and GSIs (vendor RIL). No root-cause fix exists (Samsung/MTK side; even the A155F kernel devs report none).
- Decision: ship a clean-room KernelSU/Magisk module (`rom/simfix/RILFix_A15`, method per rev.s; concept per itsfaris' RILFix_Faris.zip) that restarts ril-daemon every 6 h, embedded into the ROM at `/system/etc/a155f-extras/` and attached to the release. Default ROM kernel variant = `kernelsunext` because the module needs root; the `vanilla` package is documented as carrying **no** SIM fix.

## D013 — Additive multi-variant ROM release assets; matching root manager stays separate

- Date: 2026-11-18
- Status: **Accepted (owner-directed)** — add Vanilla and KernelSU-Next AP packages to the existing 1.1 ROM release; owner will upload the KernelSU-Next manager APK last.
- Decision: future workflow runs upload only the current variant's split AP parts and a uniquely named checksum file. Existing release metadata/assets are never edited or clobbered by the build job. The combined release description is updated after all AP variants are present.
- Manager APKs are separate release assets and must match the exact kernel driver version (BakaSU 35262; KernelSU-Next 33548). Do not bake old upstream APK versions into a ROM AP/system image. The vanilla variant is unrooted, has no manager, and cannot install the root-dependent SIM fix.
- Acceptance remains pending: both Actions runs succeed, all new parts/checksum files appear, original release assets remain unchanged, then README/release notes are updated. No AP build or upload is claimed yet.

## D012 — Baked A155F GSI presets via the RIL-fix module (rooted variants)

- Date: 2026-11-19
- Status: **Accepted (owner-directed 2026-11-19)** — "derin optimizasyon, sürücüler, sistem kararlılığı".
- Research basis: XDA A15/Samsung GSI guides (threads 4564191, 4646402, 4688239) + TrebleDroid `treble_app` source for exact prop keys. Findings: fingerprint workaround, extended backlight, extra sensors, aux cameras, flash strength, MTK GED KPI, SF GL backpressure disable (prop is inverted), auto-restart-RIL, headset-jack fix.
- Decision: apply them as **non-destructive presets** (`resetprop -n`, user toggles win) inside the RILFix module (`rom/simfix/RILFix_A15/a155f-presets.prop`), NOT by editing `build.prop` inside the GSI — debugfs cannot set SELinux xattrs, and an unlabeled `build.prop` risks property-load failure. Vendor drivers stay Samsung's (carried in super). GPU/scheduler "deep tuning" beyond these props requires a booted device to validate — deferred to phase 2 with on-device measurements.
