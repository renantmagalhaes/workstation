#!/usr/bin/env bash

TARGET="dns.insecure.codes"
INITIAL_DELAY=60
PING_COUNT=3
CHECK_INTERVAL=60
LOG_FILE="$HOME/vpn-connection-status.log"

if ! command -v windscribe-cli &> /dev/null; then
    # We can't log to the file yet if we want to be safe, but let's assume it's fine
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Error: windscribe-cli not found. Aborting." >> "$LOG_FILE"
    exit 1
fi

sleep "$INITIAL_DELAY"

while true; do
    if ping -c "$PING_COUNT" "$TARGET" > /dev/null 2>&1; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Ping successful" >> "$LOG_FILE"
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Ping failed, reconnecting Windscribe" >> "$LOG_FILE"

        windscribe-cli disconnect >> "$LOG_FILE" 2>&1
        sleep 5
        windscribe-cli connect >> "$LOG_FILE" 2>&1
    fi

    sleep "$CHECK_INTERVAL"
done
