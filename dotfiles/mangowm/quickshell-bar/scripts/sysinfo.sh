#!/usr/bin/env bash
# Emit one compact JSON line of system stats for the QuickShell island.
# Replaces waybar/scripts/sys_info_json.sh, which emitted Pango markup that a
# QML panel cannot render.
set -uo pipefail

read -r load1 _ < /proc/loadavg

read -r mem_used mem_total < <(
  awk '/^MemTotal:/{t=$2} /^MemAvailable:/{a=$2} END{printf "%d %d", (t-a)/1024, t/1024}' /proc/meminfo
)

read -r disk_used disk_total < <(df -B1 --output=used,size / | tail -1)

# Chip names vary by board, so match on prefix rather than the exact bus id.
# Note: jq 1.8 rejects a helper taking the key as a $parameter ("invalid path
# expression"), so each sensor is spelled out.
temps=$(sensors -j 2>/dev/null | jq -c '
  def val(f): [ f | objects | to_entries[] | select(.key|endswith("_input")) | .value ] | first;
  {
    cpu:  val(to_entries[] | select(.key|startswith("k10temp")) | .value.Tctl)
       // val(to_entries[] | select(.key|startswith("coretemp")) | .value["Package id 0"]),
    gpu:  val(to_entries[] | select(.key|startswith("amdgpu"))  | .value.edge),
    nvme: val(to_entries[] | select(.key|startswith("nvme"))    | .value.Composite)
  }' 2>/dev/null)
[ -z "$temps" ] && temps='{"cpu":null,"gpu":null,"nvme":null}'

jq -cn \
  --argjson load1 "${load1:-0}" \
  --argjson cores "$(nproc)" \
  --argjson memUsed "${mem_used:-0}" \
  --argjson memTotal "${mem_total:-0}" \
  --argjson diskUsed "${disk_used:-0}" \
  --argjson diskTotal "${disk_total:-0}" \
  --argjson temps "$temps" \
  '{load1:$load1, cores:$cores, memUsedMib:$memUsed, memTotalMib:$memTotal,
    diskUsed:$diskUsed, diskTotal:$diskTotal, temps:$temps}'
