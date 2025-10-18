#!/usr/bin/env bash
# Print 5-minute load average, no shell tricks needed
# shellcheck disable=SC2002
awk '{print $1}' /proc/loadavg
