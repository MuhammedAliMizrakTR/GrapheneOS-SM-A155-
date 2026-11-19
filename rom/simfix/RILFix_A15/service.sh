#!/system/bin/sh
# A15 RIL Watchdog Fix — service loop.
# Background: on SM-A155F with an unlocked bootloader, the stock ril-daemon
# errors out after ~7h25m of runtime and the modem enters a state that only a
# reboot clears (XDA threads 4688638/4703177). Restarting ril-daemon before
# that window keeps the modem alive. This is a workaround, not a root-cause
# fix (root cause is in Samsung/MTK RIL).
MODDIR=${0%/*}
LOG="$MODDIR/rilfix.log"
INTERVAL=21600   # 6h — safely below the 7h25m crash window

echo "[$(date)] rilfix service started" >> "$LOG"

# let telephony settle after boot
while [ "$(getprop sys.boot_completed)" != "1" ]; do sleep 10; done
sleep 120

while true; do
  # only restart when the radio stack is actually running
  if pidof ril-daemon >/dev/null 2>&1 || pidof rild >/dev/null 2>&1; then
    stop ril-daemon
    sleep 5
    start ril-daemon
    echo "[$(date)] ril-daemon restarted" >> "$LOG"
  else
    echo "[$(date)] ril-daemon not running, skip" >> "$LOG"
  fi
  sleep "$INTERVAL"
done
