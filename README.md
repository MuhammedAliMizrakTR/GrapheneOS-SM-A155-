# Samsung Galaxy A15 4G (SM-A155F) — privacy ROM project

A device-specific, LineageOS-based ROM project for **Samsung SM-A155F / A155F** — the **MediaTek Helio G99 (MT6789) variant only** — with privacy-first defaults and optional sandboxed Google Play compatibility.

**This is not the SM-A156x / Galaxy A15 5G project** (different SoC, Dimensity 6100+). Do not import A15 5G configuration by name similarity. This project is not affiliated with LineageOS, GrapheneOS, Samsung, or Google.

**Status: research/planning and documentation only. There is no flashable release, validated device tree, or tested Play compatibility port in this repository.**

## Goals

- Stable device-specific hardware integration rather than relying on an unadapted GSI.
- A usable Play-free default with optional official Play services/Store as regular sandboxed apps through a maintained compatibility layer.
- User choice without misrepresenting privileged GApps, microG, and sandboxed Play as the same design.
- Reproducible development, honest security claims, and durable handoffs between development chats.

GrapheneOS-inspired features do not imply GrapheneOS-equivalent security or official support. Device firmware, kernel, hardware features, verified boot, and update coverage must be assessed independently.

## Start here

| File | Purpose |
| --- | --- |
| [PROJECT_STATE.md](PROJECT_STATE.md) | Live status, evidence, blockers, and the next action |
| [MASTER_PROMPT.md](MASTER_PROMPT.md) | Copy/paste handoff for a new development chat |
| [AGENTS.md](AGENTS.md) | Contributor/agent workflow and persistence rules |
| [CHANGELOG.md](CHANGELOG.md) | Human-readable history of meaningful changes |
| [docs/ROADMAP.md](docs/ROADMAP.md) | Phases and acceptance gates |
| [docs/DECISIONS.md](docs/DECISIONS.md) | Accepted, proposed, and deferred decisions |
| [docs/RESEARCH.md](docs/RESEARCH.md) | Public references, findings, and uncertainty |
| [docs/DEVICE_INVENTORY.md](docs/DEVICE_INVENTORY.md) | Read-only data collection and missing device/host facts |

## Initial baseline

User-reported device/firmware: **SM-A155F**, `A155FXXS7CYG3`, Android 15 stable. This has not yet been independently checked with device output. The current runtime, bootloader/root/recovery state, GSI version, and build-host specifications are still unknown.

## Repository and publishing status

- Destination repository: `https://github.com/MuhammedAliMizrakTR/GrapheneOS-SM-A155-` (established 2026-11-18).
- Development happens on review branches; the durable record is GitHub. See `PROJECT_STATE.md` for the current branch/commit and push status.
- The original documentation bootstrap arrived as `a155f-project-checkpoint.zip` (2026-11-16); its contents are now tracked directly in this repository and the archive was removed by owner decision (2026-11-18).
- Project license: **Apache-2.0** (owner-confirmed 2026-11-18; see `LICENSE` and `docs/DECISIONS.md` D008). Preserve third-party attribution when code is introduced; this repository cannot relicense imported material.

## Source and distribution policy

No ROM sources, third-party code, firmware images, proprietary blobs, signing keys, or device dumps are included at this stage. Preserve upstream licenses and attribution when code is introduced; do not assume this repository can relicense imported material.

There are deliberately no flashing instructions or release claims at this stage.
