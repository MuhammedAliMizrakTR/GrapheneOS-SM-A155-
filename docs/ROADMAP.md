# Roadmap and acceptance gates

This is a proposed sequence. Nothing below should be read as completed unless `PROJECT_STATE.md` and test evidence say so.

## Phase 0 — Durable repository and evidence baseline

- Establish owner/repository/base branch and secure publishing access.
- Preserve existing contents; contribute through a review branch/PR by default.
- Commit a clear project state, handoff prompt, changelog, and decision record.
- Identify host resources and obtain the read-only device inventory.

**Gate:** a remotely retrievable checkpoint is verified, missing baseline facts are explicit, and no secrets/personal dumps are published.

## Phase 1 — Exact firmware and device-support audit

- Identify matching stock AP/BL/CP/CSC packages and record hashes locally.
- Extract only required stock components using an isolated, documented process.
- Inspect boot headers, ramdisks, DTB/DTBO placement, partition map/super metadata, fstab, and init services.
- Inventory VINTF declarations, HAL/service dependencies, graphics/audio/camera/radio components, SELinux inputs, and kernel/module dependencies.
- Compare the public A155F tree to the actual baseline; classify usable pieces and unsupported assumptions.
- Select a bring-up branch and pin source revisions. `lineage-22.2` is only a candidate.

**Gate:** a documented layout/dependency model and a justified source/branch plan exist. No arbitrary partition sizes or assumed module compatibility.

## Phase 2 — Minimal device-specific reference build

- Introduce device/vendor configuration based on the audit and applicable distribution rights.
- Preserve the matched stock kernel/modules and vendor components initially where feasible.
- Build only the necessary targets; keep privacy patches and unrelated root/kernel modifications out of this reference baseline.
- Review any flash/recovery plan with the owner before device writes.

**Gate:** record the exact source manifest, build commands, artifacts, and build results. A successful build is not a working-device claim.

## Phase 3 — Stable hardware bring-up

- Repeatable boot and ADB; identify critical service restarts and crash/reset causes.
- Measured idle memory/temperature and suspend behavior, with a stock reference where possible.
- Graphics/refresh behavior, touch, audio, sensors, charging, Wi-Fi/Bluetooth, storage/encryption.
- Radio/SIM/data/calls and IMS/VoLTE as applicable; test emergency behavior only through safe, authorized carrier/device procedures, never real unsolicited emergency calls.
- Camera, location, and other peripherals with a recorded working/broken matrix.
- Proper SELinux policy review and enforcing behavior before any release claim; do not use blanket allows or permissive mode as a finished fix.

**Gate:** reproducible tests and known issues are documented. First sub-gate is stable boot/ADB/idle without critical restart loops; full hardware acceptance is a later milestone.

## Phase 4 — Privacy platform and optional sandboxed Play

- Define a threat model and prioritize specific privacy features rather than copying a brand's feature list.
- Select a coherent Android-version-matched compatibility source baseline and preserve attribution.
- Integrate required platform hooks, companion/configuration, settings, installer flow, and trusted update handling.
- Test no-Play operation and Play installation/removal per profile, permission denial behavior, sign-in, FCM, Play Store installs/updates, purchases/licenses, location behavior, and dependent apps.
- Treat Android Auto, payment features, attestation/Play Integrity, and app-specific banking behavior as distinct compatibility questions. Do not promise universal support.

**Gate:** evidence supports the claim that the official Google packages remain regular sandboxed apps without conventional privileged GApps integration. Include regression tests and a compatibility maintenance plan.

## Phase 5 — Release engineering and maintenance

- Select a maintained framework branch and credible vendor/kernel/firmware security-update baseline.
- Establish protected release signing, reproducible source manifests, update verification, and an audited update/recovery design appropriate to the actual partition scheme.
- Decide licensing, branding, distribution rights, supported device variants, and documented limitations.
- Do not assume A/B updates, custom-key relocking, hardware attestation, or GrapheneOS-equivalent hardening is available.

**Gate:** device-tested release criteria, truthful patch/support claims, protected keys, documented recovery, and an achievable ongoing maintenance schedule.
