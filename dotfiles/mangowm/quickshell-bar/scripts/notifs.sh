#!/usr/bin/env bash
# Emit mako's notification count and do-not-disturb state as JSON.
#
# mako owns org.freedesktop.Notifications, so QuickShell cannot run its own
# NotificationServer alongside it -- there is no event stream either, hence the
# poll. `makoctl list` prints plain text, one "Notification <id>: <summary>"
# header per notification.
set -uo pipefail

count=$(makoctl list 2>/dev/null | grep -c '^Notification ' || true)
modes=$(makoctl mode 2>/dev/null | tr '\n' ' ')

dnd=false
case " $modes " in
  *" do-not-disturb "*) dnd=true ;;
esac

printf '{"count":%d,"dnd":%s}\n' "${count:-0}" "$dnd"
