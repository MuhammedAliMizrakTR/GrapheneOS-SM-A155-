# ⚠️ WITHDRAWN — DO NOT FLASH

**Release 1.1 (tag `rom-v1.0`) is marked as a prerelease and withdrawn from use following a reported first-device flash failure.** The BakaSU package was reported to have an MD5 mismatch and an Odin write failure at `super.img`. The reported log also contains:

```text
SW REV CHECK FAIL [super] Fused 7 > Binary 8
...
super.img
__XmitData_Write
Complete(Write) operation failed.
```

The 1.1 build is **not verified as flashable**. Do not flash any 1.1 variant. The device's firmware/rollback revision must be identified and matched before a replacement is published. Removing the tar MD5 footer or LZ4 encoding alone cannot change the rollback metadata carried by the donor firmware/images.

The original 1.1 assets are retained for investigation and are not being silently replaced. A 1.2 BakaSU test candidate will use the requested format (plain `.tar`, no MD5 footer, no LZ4-compressed members). If Google Drive cannot carry the multi-gigabyte file, numbered transport chunks may be attached, then joined to restore the single TAR. The owner reports CYG4 XSG / binary 7, but the failure log's `Fused 7 > Binary 8` line is inconsistent and must be reconciled before flashing. The 1.2 artifact is not available yet.
