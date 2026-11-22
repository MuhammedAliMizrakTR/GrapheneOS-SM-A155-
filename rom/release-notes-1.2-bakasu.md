# 1.2 ROM Verification & Corruption Fix — BakaSU candidate for Galaxy A15 4G (SM-A155F)

**Prerelease test candidate — not device-verified.** This build changes the AP archive format after the owner reported an MD5 mismatch, LZ4 handling concern, and Odin write failure at `super.img` on 1.1. The candidate is based on the checksum-verified CYG4 XSG donor AP and the BakaSU 35262 kernel.

## Files

The AP is one plain TAR with raw/uncompressed image members: **no appended MD5 footer and no LZ4-compressed members**. Since the TAR is about 9.4 GB and cannot be attached as a single GitHub Release asset, it is provided as five transport chunks. These chunks are not independent Odin files; join them, in order, to recover one `.tar`.

- [`AP_SM-A155F_RestlessOS-17.0.0-202611021750_bakasu_A155FXXS7CYG4.tar.00`](https://github.com/MuhammedAliMizrakTR/GrapheneOS-SM-A155-/releases/download/rom-v1.2/AP_SM-A155F_RestlessOS-17.0.0-202611021750_bakasu_A155FXXS7CYG4.tar.00)
- [`...tar.01`](https://github.com/MuhammedAliMizrakTR/GrapheneOS-SM-A155-/releases/download/rom-v1.2/AP_SM-A155F_RestlessOS-17.0.0-202611021750_bakasu_A155FXXS7CYG4.tar.01)
- [`...tar.02`](https://github.com/MuhammedAliMizrakTR/GrapheneOS-SM-A155-/releases/download/rom-v1.2/AP_SM-A155F_RestlessOS-17.0.0-202611021750_bakasu_A155FXXS7CYG4.tar.02)
- [`...tar.03`](https://github.com/MuhammedAliMizrakTR/GrapheneOS-SM-A155-/releases/download/rom-v1.2/AP_SM-A155F_RestlessOS-17.0.0-202611021750_bakasu_A155FXXS7CYG4.tar.03)
- [`...tar.04`](https://github.com/MuhammedAliMizrakTR/GrapheneOS-SM-A155-/releases/download/rom-v1.2/AP_SM-A155F_RestlessOS-17.0.0-202611021750_bakasu_A155FXXS7CYG4.tar.04)
- [SHA-256 manifest](https://github.com/MuhammedAliMizrakTR/GrapheneOS-SM-A155-/releases/download/rom-v1.2/AP_SM-A155F_RestlessOS-17.0.0-202611021750_bakasu_A155FXXS7CYG4.SHA256SUMS.txt)
- [BakaSU manager 35262 APK](https://github.com/MuhammedAliMizrakTR/GrapheneOS-SM-A155-/releases/download/rom-v1.2/BakaSU_v4.2.0-rc3_35262-arm64-v8a-release.apk)
- [RILFix_A15.zip](https://github.com/MuhammedAliMizrakTR/GrapheneOS-SM-A155-/releases/download/rom-v1.2/RILFix_A15.zip)

> The full asset filenames are shown on the [release page](https://github.com/MuhammedAliMizrakTR/GrapheneOS-SM-A155-/releases/tag/rom-v1.2); the shortened `...tar.0N` links above are only labels.

## Join and verify

**Windows Command Prompt:**

```bat
copy /b AP_SM-A155F_RestlessOS-17.0.0-202611021750_bakasu_A155FXXS7CYG4.tar.00+AP_SM-A155F_RestlessOS-17.0.0-202611021750_bakasu_A155FXXS7CYG4.tar.01+AP_SM-A155F_RestlessOS-17.0.0-202611021750_bakasu_A155FXXS7CYG4.tar.02+AP_SM-A155F_RestlessOS-17.0.0-202611021750_bakasu_A155FXXS7CYG4.tar.03+AP_SM-A155F_RestlessOS-17.0.0-202611021750_bakasu_A155FXXS7CYG4.tar.04 AP_SM-A155F_RestlessOS-17.0.0-202611021750_bakasu_A155FXXS7CYG4.tar
```

**Linux/macOS:**

```sh
cat AP_SM-A155F_RestlessOS-17.0.0-202611021750_bakasu_A155FXXS7CYG4.tar.* > AP_SM-A155F_RestlessOS-17.0.0-202611021750_bakasu_A155FXXS7CYG4.tar
```

Verify individual chunks using manifest entries after the first line (`tail -n +2 <manifest> | sha256sum -c -`). Verify the joined TAR against the first manifest entry (`head -n 1 <manifest> | sha256sum -c -`). No MD5 footer is used or required.

## Critical firmware / rollback warning

The 1.1 Odin log was reported as `SW REV CHECK FAIL [super] Fused 7 > Binary 8`. The owner says the phone is `A155FXXS7CYG4` XSG / binary 7. Those statements do not obviously agree. **Do not flash this candidate until the exact handset model/build/bootloader and the SW REV line have been checked and a compatible binary-7 donor is confirmed.** Removing MD5/LZ4 cannot bypass or correct Samsung rollback protection.

This is a packaging-correction candidate, not proof that the super revision failure is resolved. Keep the bootloader unlocked and preserve a known-good stock recovery path. Only for SM-A155F; never for A15 5G (SM-A156x).
