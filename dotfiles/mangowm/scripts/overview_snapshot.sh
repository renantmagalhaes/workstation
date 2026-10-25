#!/usr/bin/env bash
# High-speed parallel window snapshot script for QuickShell Overview on MangoWM
set -eo pipefail

OUT_DIR="${1:-/tmp/quickshell-overview}"
mkdir -p "$OUT_DIR"

if [ -z "$MANGO_INSTANCE_SIGNATURE" ] || [ ! -S "$MANGO_INSTANCE_SIGNATURE" ]; then
    mango_pid=$(pgrep -u "$USER" -x mango | head -n 1)
    if [ -n "$mango_pid" ]; then
        export MANGO_INSTANCE_SIGNATURE="/run/user/$(id -u)/mango-${mango_pid}.sock"
    fi
fi

clients=$(mmsg get all-clients 2>/dev/null || echo '{"clients":[]}')
monitors=$(mmsg get all-monitors 2>/dev/null || echo '{"monitors":[]}')

# Trigger background captures for all mapped toplevels
while read -r tid cid; do
    timeout 1.0 grim -t ppm -T "$tid" "$OUT_DIR/${cid}.ppm" 2>/dev/null &
done < <(jq -r '.clients[] | select(.foreign_toplevel_id != null and .width > 50) | "\(.foreign_toplevel_id) \(.id)"' <<<"$clients" 2>/dev/null)

wait

# Output merged state to stdout for QuickShell
jq -n --argjson c "$clients" --argjson m "$monitors" '{clients: $c.clients, monitors: $m.monitors}'
