# RestlessOS 17 (GrapheneOS fork) — SM-A155F — Odin AP paketi

**İçindekiler / Contents:** RestlessOS `$RTAG` (Android 17, GrapheneOS-fork GSI) **system** olarak • `$KERNEL_VARIANT` kernel (v1.0 release artifact'ı, sha256-doğrulamalı, yeniden derlenmedi) • stok `$FW_VERSION` ($FW_REGION) vendor/product/odm = **tüm sürücüler** (Mali GPU, kamera, ses, modem arayüzü) • verification-disabled vbmeta • SIM-fix modülü (gömülü).

> ⚠️ **İLK CİHAZ TESTİ YAPILMADI.** Build temiz üretildi ama kimse bu paketi cihazda boot etmedi. Odin + stok firmware ile geri dönebilecek durumda değilsen flaşlama. Android 17 GSI ↔ Android 15 vendor uyumu ilk boot'ta belli olacak.

## Kurulum / Install

1. **Önce stok kur:** Odin ile orijinal **$FW_VERSION** (bölge fark etmez) 4-dosya (BL+AP+CP+CSC) flaşla, cihaz açılsın.
2. Bu release'in parçalarını indir ve birleştir:
   - Windows: `copy /b ${APBASE}.tar.md5.00+${APBASE}.tar.md5.01+${APBASE}.tar.md5.02 ${APBASE}.tar.md5`
   - Linux/macOS: `cat ${APBASE}.tar.md5.* > ${APBASE}.tar.md5`
   - SHA256SUMS.txt ile doğrula.
3. Download Mode'a gir → Odin → dosyayı **AP** slotuna koy → flaşla.
4. **Format data** şart (recovery'den Wipe data/factory reset) — GSI'ya ilk geçişte userdata temizlenmeli.
5. Root'lu varyantta: açılıştan sonra root yöneticisi → Modules → Install from storage → `/system/etc/a155f-extras/RILFix_A15.zip` (SIM fix'i aktive eder).

## SIM bug (şebeke 6-7 saatte düşme) fix

$SIMFIX_LINE

## Ne var ne yok

| Var ✅ | Yok ❌ |
|---|---|
| RestlessOS: sandboxed Google Play (GmsCompat), per-app network/sensors izinleri, Seedvault, TrebleApp | Verified boot / hardware attestation (GSI yapısı gereği) |
| Stok vendor sürücüleri (kamera, GPU, ses, GPS, FM, sensörler) | GrapheneOS kernel hardening (Pixel'e özel) |
| Bizim v1.0 kernel: BBRv3, BBG, NTSync, Droidspaces, WireGuard | VoLTE garantisi (MTK IMS, GSI'larda genelde çalışmaz) |
| SIM-fix modülü (gömülü, rooted varyantlarda) | Samsung OTA güncellemeleri |
| `aarch64`/`arm64-ab`, Treble resmi | Cihaza özel RRO overlay'ler (phase 2'de) |

## Doğrulama

- Kernel: v1.0 release artifact'ı, build sırasında pinned SHA-256 ile doğrulandı (yeniden derlenmedi).
- GSI: upstream `cawilliamson/treble_restlessos` `$RTAG`, sha512sum ile doğrulandı.
- Firmware: Samsung FUS'tan `samloader` ile indirildi (enc4 CRC doğrulamalı).
- Tüm parçaların SHA-256'sı `SHA256SUMS.txt` içinde.

## Bilinen sınırlar / Known limitations

- Cihazda test edilmedi; ilk boot gate: logo → launcher → ADB → RIL → ses/kamera.
- SIM fix kök-neden çözümü değil (ril-daemon'ın ~7sa25dk runtime takılması; Samsung/MTK tarafında). Modül ~6 saatte bir restart atar.
- EFS/NVRAM/IMEI yedeği almadan hiçbir şey flaşlama.

---

**EN:** Odin AP package pairing RestlessOS `$RTAG` (Android 17 GrapheneOS-fork GSI) with the project's v1.0 `$KERNEL_VARIANT` kernel and the stock `$FW_VERSION` driver stack. Flash stock first, then this file in the AP slot, then format data. Root variants embed the community-proven ril-daemon restart module (`/system/etc/a155f-extras/RILFix_A15.zip`) for the unlocked-bootloader SIM-drop bug. Build-tested only — not device-tested. All hashes in SHA256SUMS.txt.

Built $BUILD_DATE by GitHub Actions (`build-rom.yml`). Sources: RestlessOS by cawilliamson (GrapheneOS fork), kernel by poqdavid, firmware by Samsung.
