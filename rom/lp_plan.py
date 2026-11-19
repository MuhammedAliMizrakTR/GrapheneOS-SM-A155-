#!/usr/bin/env python3
"""Reads lpdump output of the stock super + the sizes of extracted partition
images, and emits an lpmake command that rebuilds super with the GSI as the
system partition and stock vendor/product/odm (etc.) untouched.

Usage: lp_plan.py <lpdump.json-or-txt> <parts_dir> <gsi.img> <out_cmd.sh> <super_out>
Exit 1 with a clear message if the layout cannot be rebuilt safely.
"""
import json, os, re, sys

def align(n, a=4096):
    return (n + a - 1) // a * a

dump_path, parts_dir, gsi_path, out_cmd, super_out = sys.argv[1:6]
raw = open(dump_path, encoding="utf-8", errors="replace").read()

meta_max = slots = super_size = None
groups = {}        # name -> max_size
parts = []         # (name, group, readonly)

# --- try JSON first -------------------------------------------------------
try:
    j = json.loads(raw)
    md = j.get("metadata", {})
    meta_max = int(md.get("max_size") or md.get("max_size_bytes"))
    slots = int(md.get("slot_count"))
    for bd in j.get("block_devices", []):
        if bd.get("partition_name") == "super":
            super_size = int(bd.get("size") or bd.get("size_bytes"))
    for g in j.get("groups", []):
        groups[g["name"]] = int(g.get("maximum_size") or 0)
    for p in j.get("partitions", []):
        attr = p.get("attributes", "readonly")
        parts.append((p["name"], p["group"], "readonly" in str(attr)))
except Exception:
    meta_max = None

# --- fall back to text parsing -------------------------------------------
if meta_max is None:
    m = re.search(r"Metadata max size:\s*(\d+)", raw); meta_max = int(m.group(1))
    m = re.search(r"Metadata slot count:\s*(\d+)", raw); slots = int(m.group(1))
    m = re.search(r"^\s*super:\s*(\d+)\s*bytes", raw, re.M)
    if not m:
        m = re.search(r"super\s+(\d+)\s+bytes", raw)
    super_size = int(m.group(1))
    for gm in re.finditer(r"Group(?:\s+\d+)?:\s*(\S+)[\s\S]*?Maximum size:\s*(\d+)", raw):
        groups[gm.group(1)] = int(gm.group(2))
    cur = None
    for line in raw.splitlines():
        pm = re.match(r"\s*Partition\s+\d+:\s*(\S+)", line)
        if pm:
            cur = {"name": pm.group(1), "group": None, "ro": True}
            parts.append(cur)
            continue
        gm = re.match(r"\s*Group name:\s*(\S+)", line)
        if gm and cur is not None:
            cur["group"] = gm.group(1)
        if re.match(r"\s*Attributes:.*(none|readwrite)", line) and cur is not None:
            cur["ro"] = False
    parts = [(p["name"], p["group"], p["ro"]) for p in parts if p.get("group")]

if not (meta_max and slots and super_size and groups and parts):
    print("FATAL: could not parse super layout from lpdump output", file=sys.stderr)
    print(raw[:4000], file=sys.stderr)
    sys.exit(1)

# --- map partitions to files, substitute the GSI for system ---------------
gsi_size = align(os.path.getsize(gsi_path))
entries = []   # (name, group, ro, size, image_path or None)
for name, group, ro in parts:
    base = name.split("_")[0] if name.endswith(("_a", "_b")) else name
    f = os.path.join(parts_dir, name + ".img")
    if base == "system":
        if os.path.getsize(gsi_path) == 0:
            sys.exit("FATAL: gsi.img empty")
        entries.append((name, group, ro, gsi_size, gsi_path))
    elif os.path.exists(f) and os.path.getsize(f) > 0:
        entries.append((name, group, ro, align(os.path.getsize(f)), f))
    else:
        entries.append((name, group, ro, 0, None))   # empty slot/stub partition

# --- capacity check per group --------------------------------------------
need = {}
for name, group, ro, size, _ in entries:
    need[group] = need.get(group, 0) + size
ok = True
for g, n in need.items():
    cap = groups.get(g, 0)
    head = super_size - 4 * 1024 * 1024          # metadata + rounding reserve
    if cap == 0 or n > cap:
        if n <= head:
            print(f"note: raising group {g} max {cap} -> {n} (fits super {super_size})")
            groups[g] = n
        else:
            print(f"FATAL: group {g} needs {n} bytes, super is {super_size}", file=sys.stderr)
            ok = False
if not ok:
    sys.exit(1)

# --- emit the lpmake command ---------------------------------------------
cmd = ["lpmake", "--metadata-size", str(meta_max), "--metadata-slots", str(slots),
       "--device-size", str(super_size), "--sparse", "--output", super_out]
for g, cap in groups.items():
    cmd += ["--group", f"{g}:{cap}"]
for name, group, ro, size, img in entries:
    ro_s = "readonly" if ro else "none"
    cmd += ["--partition", f"{name}:{ro_s}:{size}:{group}"]
    if img:
        cmd += ["--image", f"{name}={img}"]

with open(out_cmd, "w") as fh:
    fh.write("#!/bin/sh\nset -e\n" + " ".join(f"'{c}'" for c in cmd) + "\n")
os.chmod(out_cmd, 0o755)

print(f"super {super_size}, slots {slots}, groups {groups}")
for name, group, ro, size, img in entries:
    print(f"  {name:20s} {size:>12d}  {'<- GSI' if img == gsi_path else (img or '(empty)')}")
print("lpmake plan written to", out_cmd)
