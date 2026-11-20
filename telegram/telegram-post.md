# Telegram post (English) — copy/paste with assets/rom-banner.png as the photo

🛡️ **RestlessOS 17 (GrapheneOS fork) — Galaxy A15 4G (SM-A155F)**
**1.1 ROM Initial Build — "HellioG99" edition** 🔥

GrapheneOS-flavored Android 17, finally on the Helio G99 budget king. Privacy-first: sandboxed Google Play, per-app network & sensor permissions, Seedvault backups — with **every single stock Samsung/MediaTek driver untouched** (camera, Mali GPU, audio, GPS, FM, sensors all work as intended).

📦 **What you get**
• RestlessOS `17.0.0-202611021750` (Android 17) as system
• Our v1.0 kernel — BakaSU + SUSFS root, BBRv3, BBG, NTSync, Droidspaces, WireGuard (SHA-256-pinned, never rebuilt)
• Stock CYG4 vendor/product/odm — full driver stack, zero compromises
• **SIM-fix module embedded** (`/system/etc/a155f-extras/RILFix_A15.zip`) — kills the infamous 7-hour network drop (XDA-proven ril-daemon restart)
• Disabled vbmeta — single Odin **AP** flash, no fastbootd nonsense

⬇️ **Download:** github.com/MuhammedAliMizrakTR/GrapheneOS-SM-A155-/releases/tag/rom-v1.0

📝 **Install (Odin only)**
1. Flash stock `A155FXXS7CYG4` (BL+AP+CP+CSC) first, boot once
2. Join the 3 AP parts (`copy /b` on Windows / `cat` on Linux), verify SHA256SUMS
3. Download Mode → Odin → **AP** slot → flash
4. Format data in recovery (mandatory)
5. Boot, open ReSukiSU → Modules → install `/system/etc/a155f-extras/RILFix_A15.zip` → SIM fix active

⚠️ **Known limits:** no VoLTE (MTK IMS on GSIs), no verified boot, no Samsung OTA. Backup EFS/IMEI before you touch anything.

If you dont like it give me feedback (or js leave) 🗿
Testers needed — if you find a bug give me logs (or gtfo) 🐞

#RestlessOS #GrapheneOS #GalaxyA15 #HelioG99 #SM-A155F
