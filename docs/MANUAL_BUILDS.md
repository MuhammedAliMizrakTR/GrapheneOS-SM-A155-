# Manual kernel and ROM rebuilds

Both workflows are **manual only** (`workflow_dispatch`); upstream updates do not flash devices or publish automatically.

## 1. Build a newer kernel

In GitHub Actions, run **Manual A155F kernel build (latest source → dated release)** and select a flavor:

- `vanilla` → upstream `main` branch, no root
- `bakasu` → upstream `bakasu` branch
- `kernelsunext` → upstream `kernelsunext` branch

Leave `source_ref` as `latest` to fetch the current head of that flavor's source branch when the workflow starts. Or enter a branch, tag, or commit to reproduce a specific source. The action records the resolved commit and build date, compiles the kernel, repacks its Odin TAR, computes SHA-256, and publishes uniquely named assets to a dated **prerelease** such as `kernel-manual-kernelsunext-YYYYMMDD-<commit>-runN`. If that exact commit is already published for the variant, the workflow skips the expensive build by default; set `force_rebuild=true` to rebuild it anyway. It does not modify/delete any existing release assets and does not claim device validation.

There are no automatic polling or push triggers. You choose when to check upstream and start the action.

## 2. Build the ROM with the current inputs

Run **Build A155F ROM** manually after selecting the desired kernel flavor. Set:

- **RestlessOS ref:** leave blank to resolve the latest upstream RestlessOS release at build time, or enter an exact release tag to pin it.
- **Kernel release tag:** `latest` resolves the newest dated manual kernel prerelease for the selected flavor. If no such release exists, it falls back to the repository's SHA-256-pinned v1.0 kernel. Enter an exact `kernel-manual-...` tag to pin a particular kernel build, or `v1.0` to force the pinned legacy kernel.
- **AP donor:** select a checksum-verified existing donor variant, or explicitly choose stock firmware. The default device baseline is `A155FXXS7CYG4` / XSG; do not substitute a different build/CSC without confirming device compatibility.
- **Release tag:** leave `auto` for a unique `rom-v2.0-YYYYMMDD-runN` tag, or enter a new unused tag. Existing releases are additive-only; the workflow will not overwrite same-named assets.

The build resolves and logs exact GSI/kernel sources, verifies GSI SHA-512 when upstream provides it, verifies the kernel TAR against its SHA-256, assembles a plain TAR without MD5 footer or LZ4-compressed members, and uses numbered transport parts only when required by the hosting limit. Each part and joined TAR are covered by the variant's SHA-256 manifest.

## Safety and limits

- CI success validates that the pipeline ran and produced checksum-verified artifacts; it does **not** prove the package boots or that hardware, mobile network, encryption, or root modules work on-device.
- The owner's earlier Odin log included `SW REV CHECK FAIL [super] Fused 7 > Binary 8`, conflicting with the reported binary-7 / `A155FXXS7CYG4` device. Reconcile full device firmware and rollback state before flashing any artifact. TAR compression changes cannot bypass rollback protection.
- Only SM-A155F. Never use these builds on SM-A156x.
- Keep current 1.1 assets withdrawn / DO NOT FLASH. Do not overwrite or delete existing release assets. Keep each release a prerelease until the owner approves its status.
- Known owner-reported module/app incompatibilities are in the README and must be carried forward in release notes.
