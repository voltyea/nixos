#!/usr/bin/env bash

nmcli -t -f ACTIVE,SSID,SIGNAL device wifi list |
  awk -F: '
BEGIN {
  print "["
}
length($2) > 0 {
  if (!seen[$2] || $1 == "yes") {
    active[$2] = ($1 == "yes") ? "true" : "false"
    signal[$2] = $3
    if (!seen[$2]) {
      order[++count] = $2
    }
    seen[$2] = 1
  }
}
END {
  for (i = 1; i <= count; i++) {
    s = order[i]
    printf "%s  { \"ssid\": \"%s\", \"signalStrength\": %s, \"active\": %s }",
           (i > 1 ? ",\n" : ""), s, signal[s], active[s]
  }
  print "\n]"
}'
