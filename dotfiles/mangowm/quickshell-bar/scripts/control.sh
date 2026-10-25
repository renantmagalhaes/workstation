#!/usr/bin/env bash
# Backend for the island's control centre.
#
# Quickshell's own Quickshell.Networking and Quickshell.Bluetooth modules are
# compiled into this build but report nothing on this system (zero devices,
# null adapter) even though NetworkManager and bluez are both active on DBus,
# so state and actions go through nmcli/bluetoothctl instead.
#
#   control.sh                  -> JSON state snapshot
#   control.sh wifi on|off
#   control.sh wifi-list        -> JSON list of visible networks
#   control.sh wifi-connect SSID
#   control.sh bt on|off
#   control.sh bt-connect MAC | bt-disconnect MAC
#   control.sh dnd on|off
#   control.sh profile NAME
set -uo pipefail

bt() { timeout 4 bluetoothctl "$@" 2>/dev/null; }

state() {
  local radio wifi_dev wifi_state ssid eth_dev eth_state powered dnd profile
  radio=$(nmcli -t radio wifi 2>/dev/null)

  # First wifi / ethernet device, ignoring docker bridges and p2p shims.
  IFS=: read -r wifi_dev _ wifi_state _ < <(
    nmcli -t -f DEVICE,TYPE,STATE,CONNECTION device 2>/dev/null | awk -F: '$2=="wifi"{print; exit}'
  )
  IFS=: read -r eth_dev _ eth_state _ < <(
    nmcli -t -f DEVICE,TYPE,STATE,CONNECTION device 2>/dev/null | awk -F: '$2=="ethernet"{print; exit}'
  )
  ssid=$(nmcli -t -f NAME,TYPE connection show --active 2>/dev/null | awk -F: '$2 ~ /wireless/{print $1; exit}')

  # Gather detailed ethernet properties for the primary internal cable adapter
  local eth_carrier=false eth_speed=0 eth_mac="" eth_ip="" eth_gateway="" eth_model="" eth_uuid=""
  if [ -n "${eth_dev:-}" ]; then
    [ "$(cat "/sys/class/net/$eth_dev/carrier" 2>/dev/null)" = "1" ] && eth_carrier=true
    eth_speed=$(cat "/sys/class/net/$eth_dev/speed" 2>/dev/null || echo 0)
    eth_mac=$(cat "/sys/class/net/$eth_dev/address" 2>/dev/null || echo "")
    eth_ip=$(ip -j addr show dev "$eth_dev" 2>/dev/null | jq -r '.[0].addr_info[]? | select(.family=="inet") | .local + "/" + (.prefixlen|tostring)' | head -1)
    eth_gateway=$(ip route show default dev "$eth_dev" 2>/dev/null | awk '/default/{print $3; exit}')
    eth_uuid=$(nmcli -t -f DEVICE,UUID connection show --active 2>/dev/null | awk -F: -v d="$eth_dev" '$1==d{print $2; exit}')
    [ -z "$eth_uuid" ] && eth_uuid=$(nmcli -t -f DEVICE,UUID device 2>/dev/null | awk -F: -v d="$eth_dev" '$1==d{print $2; exit}')
    
    local raw_model pat='\(([^)]+)\)'
    raw_model=$(udevadm info -p "/sys/class/net/$eth_dev" 2>/dev/null | awk -F= '$1=="E: ID_MODEL_FROM_DATABASE"{print $2; exit}')
    if [[ "$raw_model" =~ $pat ]]; then
      eth_model="${BASH_REMATCH[1]}"
    elif [ -n "$raw_model" ]; then
      eth_model="$raw_model"
    else
      eth_model="Onboard Gigabit Ethernet"
    fi
  fi

  powered=$(bt show | awk '/Powered:/{print ($2=="yes")?"true":"false"; exit}')
  [ -z "$powered" ] && powered=false

  # Paired devices plus their connection state. One info call each, so keep the
  # list short.
  local devices="[]"
  if [ "$powered" = "true" ]; then
    devices=$(bt devices | head -8 | while read -r _ mac name; do
      [ -z "$mac" ] && continue
      local conn
      conn=$(bt info "$mac" | awk '/Connected:/{print ($2=="yes")?"true":"false"; exit}')
      jq -cn --arg mac "$mac" --arg name "$name" --argjson connected "${conn:-false}" \
        '{mac:$mac, name:$name, connected:$connected}'
    done | jq -sc '.')
    [ -z "$devices" ] && devices="[]"
  fi

  dnd=false
  case " $(makoctl mode 2>/dev/null | tr '\n' ' ') " in *" do-not-disturb "*) dnd=true ;; esac

  profile=$(powerprofilesctl get 2>/dev/null)

  jq -cn \
    --argjson radio "$([ "$radio" = enabled ] && echo true || echo false)" \
    --arg wifiDev "${wifi_dev:-}" --arg wifiState "${wifi_state:-}" --arg ssid "${ssid:-}" \
    --arg ethDev "${eth_dev:-}" --arg ethState "${eth_state:-}" \
    --argjson ethCarrier "$eth_carrier" --arg ethSpeed "$eth_speed" \
    --arg ethMac "$eth_mac" --arg ethIp "${eth_ip:-}" \
    --arg ethGateway "${eth_gateway:-}" --arg ethModel "$eth_model" \
    --arg ethUuid "${eth_uuid:-}" \
    --argjson powered "$powered" --argjson devices "$devices" \
    --argjson dnd "$dnd" --arg profile "${profile:-}" \
    '{wifi:{radio:$radio, device:$wifiDev, state:$wifiState, ssid:$ssid},
      eth:{device:$ethDev, state:$ethState, carrier:$ethCarrier, speed:$ethSpeed, mac:$ethMac, ip:$ethIp, gateway:$ethGateway, model:$ethModel, uuid:$ethUuid},
      bt:{powered:$powered, devices:$devices},
      dnd:$dnd, profile:$profile}'
}

case "${1:-state}" in
  state) state ;;
  wifi) nmcli radio wifi "${2:-on}" >/dev/null 2>&1 ;;
  wifi-list)
    nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY device wifi list 2>/dev/null \
      | awk -F: 'length($2)>0' \
      | jq -Rsc 'split("\n") | map(select(length>0) | split(":")) | unique_by(.[1])
                 | map({active:(.[0]=="*"), ssid:.[1], signal:(.[2]|tonumber? // 0),
                        security:(.[3] // "")})
                 | sort_by(-.signal) | .[0:8]' ;;
  wifi-connect) nmcli connection up id "${2:-}" >/dev/null 2>&1 || nmcli device wifi connect "${2:-}" >/dev/null 2>&1 ;;
  eth-toggle)
    edev="${2:-}"
    if [ -z "$edev" ]; then
      edev=$(nmcli -t -f DEVICE,TYPE device 2>/dev/null | awk -F: '$2=="ethernet"{print $1; exit}')
    fi
    if [ -n "$edev" ]; then
      est=$(nmcli -t -f DEVICE,STATE device 2>/dev/null | awk -F: -v d="$edev" '$1==d{print $2; exit}')
      if [ "$est" = "connected" ]; then
        nmcli device disconnect "$edev" >/dev/null 2>&1
      else
        nmcli device connect "$edev" >/dev/null 2>&1
      fi
    fi
    ;;
  eth-connect)
    edev="${2:-}"
    [ -z "$edev" ] && edev=$(nmcli -t -f DEVICE,TYPE device 2>/dev/null | awk -F: '$2=="ethernet"{print $1; exit}')
    [ -n "$edev" ] && nmcli device connect "$edev" >/dev/null 2>&1
    ;;
  eth-disconnect)
    edev="${2:-}"
    [ -z "$edev" ] && edev=$(nmcli -t -f DEVICE,TYPE device 2>/dev/null | awk -F: '$2=="ethernet"{print $1; exit}')
    [ -n "$edev" ] && nmcli device disconnect "$edev" >/dev/null 2>&1
    ;;
  edit-connection)
    target="${2:-}"
    if [ -n "$target" ]; then
      if [[ "$target" =~ ^[0-9a-fA-F-]{36}$ ]]; then
        nm-connection-editor --edit "$target" >/dev/null 2>&1 &
      else
        u=$(nmcli -t -f DEVICE,UUID connection show --active 2>/dev/null | awk -F: -v d="$target" '$1==d{print $2; exit}')
        [ -z "$u" ] && u=$(nmcli -t -f NAME,UUID connection show 2>/dev/null | awk -F: -v d="$target" '$1==d{print $2; exit}')
        if [ -n "$u" ]; then
          nm-connection-editor --edit "$u" >/dev/null 2>&1 &
        else
          nm-connection-editor >/dev/null 2>&1 &
        fi
      fi
    else
      nm-connection-editor >/dev/null 2>&1 &
    fi
    ;;
  open-editor) nm-connection-editor >/dev/null 2>&1 & ;;
  bt) bt power "${2:-on}" >/dev/null ;;
  bt-connect) bt connect "${2:-}" >/dev/null ;;
  bt-disconnect) bt disconnect "${2:-}" >/dev/null ;;
  dnd) [ "${2:-on}" = on ] && makoctl mode -a do-not-disturb >/dev/null 2>&1 || makoctl mode -r do-not-disturb >/dev/null 2>&1 ;;
  profile) powerprofilesctl set "${2:-balanced}" >/dev/null 2>&1 ;;
  *) echo "unknown: $1" >&2; exit 1 ;;
esac
