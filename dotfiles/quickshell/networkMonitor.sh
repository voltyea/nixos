#!/usr/bin/env bash

dbus-monitor --system "type='signal',sender='org.freedesktop.NetworkManager'" 2>/dev/null |
  while read -r line; do
    if echo "$line" | grep -q -E "AccessPointAdded|AccessPointRemoved|LastScan|Strength|WirelessEnabled"; then
      echo "updated!"
    fi
  done
