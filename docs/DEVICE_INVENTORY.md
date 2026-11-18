# Device and build-host inventory

**Status: not collected.** These commands are read-only and do not flash or dump user/EFS/NVRAM data. Do not add root, remount, unlock, relock, wipe, or partition-writing commands to this collection step.

## Host facts to provide

- OS and version: UNKNOWN — clarify Windows or macOS.
- CPU model/architecture: UNKNOWN — x86-64/Intel/AMD versus Apple Silicon/ARM matters.
- Physical RAM: UNKNOWN.
- Free SSD space available to the Linux build filesystem: UNKNOWN.
- Existing WSL2/Linux VM/native Linux/remote builder, if any: UNKNOWN.

We have not chosen or provisioned a build environment yet.

## Device context to provide

- Confirm actual model: user reports SM-A155F.
- Current runtime: stock or exact GSI name/version/build/variant: UNKNOWN.
- User-reported stock vendor/firmware base: `A155FXXS7CYG3`, Android 15 stable.
- Current root, bootloader, recovery, kernel modifications, and modules: UNKNOWN.
- Stock firmware package already available locally: UNKNOWN. Record AP/BL/CP/CSC filenames when available; do not upload personal partitions.

## Read-only collection

Run from **PowerShell** or a **macOS/Linux terminal** with the intended device connected through an already authorized ADB session. If multiple devices are attached, use the correct local `adb -s ...` selection; do not publish the device serial.

```sh
adb shell "getprop ro.product.model; getprop ro.product.device; getprop ro.board.platform; getprop ro.build.fingerprint; getprop ro.vendor.build.fingerprint; getprop ro.vendor.build.security_patch; getprop ro.bootloader; uname -a" > a155f-baseline.txt

adb shell "ls -l /dev/block/by-name; ls -l /dev/block/mapper" > a155f-partitions.txt
```

The ordered fields in the first file are model, device codename, board platform, current system fingerprint, vendor fingerprint, vendor security patch, bootloader property, and kernel version. A missing property may produce a blank line.

Keep permission-denied/missing-path output as evidence; do not escalate privileges just to make the command succeed. Some directory access/layout differs by firmware. Record collection date and whether the output came from stock or a GSI.

## Handling results

- Keep raw results local until reviewed for identifiers, hostnames, private paths, and other personal data.
- Do not upload a full bugreport, all getprop output, modem/EFS/NVRAM dump, or private crash dump by default.
- Sanitized approved evidence can later be tracked under a deliberately reviewed path, with firmware/build context.
- These files are an initial inventory, not enough to diagnose memory growth, thermals, or reset causes. Additional targeted measurements come after the baseline review.

## Received evidence

None. Do not populate a working-feature matrix or invent output.
