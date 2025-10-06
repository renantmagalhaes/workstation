#!/usr/bin/env bash
# load.sh
# Safe CPU + disk churn using only native tools (bash + coreutils).
# Usage: ./load.sh [duration_seconds] [disk_mb_per_cycle]
# ./load.sh 3600 256 &
set -euo pipefail

DURATION="${1:-3600}" # default 1 hour
DISK_MB="${2:-256}"   # write size per cycle per worker
TMPDIR="$(mktemp -d /tmp/native-sim-load.XXXXXX)"
CPU_WORKERS="$(nproc || echo 2)"

echo "[*] Starting load for ${DURATION}s, CPU workers: ${CPU_WORKERS}, per-cycle disk MB: ${DISK_MB}"
echo "[*] Temp dir: ${TMPDIR}"

cleanup() {
	echo "[*] Cleaning up…"
	rm -rf "${TMPDIR}" || true
	# Kill any remaining background jobs from this session
	jobs -p | xargs -r kill 2>/dev/null || true
}
trap cleanup EXIT INT TERM

cpu_task() {
	# Hash fixed-size blocks from /dev/zero to exercise CPU without disk I/O
	# Adjust BYTES if you want heavier math per iteration
	local BYTES=$((1 * 1024 * 1024)) # 1 MiB
	while :; do
		head -c "${BYTES}" /dev/zero | sha256sum >/dev/null
	done
}

disk_task() {
	# Repeatedly write and delete a file to churn FS and storage stack
	local idx="$1"
	local file="${TMPDIR}/blk_${idx}.dat"
	while :; do
		# oflag=direct tries to bypass page cache on some systems, ignore if unsupported
		dd if=/dev/zero of="${file}" bs=1M count="${DISK_MB}" oflag=direct 2>/dev/null ||
			dd if=/dev/zero of="${file}" bs=1M count="${DISK_MB}" 2>/dev/null
		sync
		rm -f "${file}"
	done
}

# Start CPU workers
for _ in $(seq 1 "${CPU_WORKERS}"); do
	cpu_task &
done

# Start a small number of disk workers (tune as needed)
for i in $(seq 1 2); do
	disk_task "$i" &
done

sleep "${DURATION}"
echo "[*] Done."
