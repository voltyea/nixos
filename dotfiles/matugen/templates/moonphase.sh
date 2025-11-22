#!/usr/bin/env bash

year=$(date +%Y)
month=$(date +%m)
day=$(date +%d)

# Conway's moon phase algorithm
if [ "$month" -le 2 ]; then
  year=$((year - 1))
  month=$((month + 12))
fi
A=$((year / 100))
B=$((A / 4))
C=$((2 - A + B))
E=$((36525 * (year + 4716) / 100))
F=$((306 * (month + 1) / 10))
julian_day=$((C + day + E + F - 1524))
phase=$(((julian_day - 2451550) % 29))
if [ "$phase" -lt 0 ]; then
  phase=$((phase + 29))
fi
if [ $phase -eq 0 ]; then
  name="󰽤 "
elif [ $phase -lt 7 ]; then
  name="󰽧"
elif [ $phase -eq 7 ]; then
  name="󰽡"
elif [ $phase -lt 15 ]; then
  name="󰽨"
elif [ $phase -eq 15 ]; then
  name="󰽢 "
elif [ $phase -lt 22 ]; then
  name="󰽦"
elif [ $phase -eq 22 ]; then
  name="󰽣"
else
  name="󰽥"
fi
echo "$name"
