#!/usr/bin/env bash

now=$(date +%s)
jd=$(awk -v t="$now" 'BEGIN { printf "%.10f", t/86400 + 2440587.5 }')
ref_new_moon=2451550.1
synodic=29.53059
age=$(awk -v jd="$jd" -v ref="$ref_new_moon" -v syn="$synodic" 'BEGIN{
  a = jd - ref
  a = a - int(a/syn)*syn
  if (a < 0) a += syn
    printf "%.6f", a
  }')
t1=1.84566
t2=5.53699
t3=9.22831
t4=12.91963
t5=16.61096
t6=20.30228
t7=23.99361
t8=27.68493
new="󰽤"
wax_cres="󰽧"
first_q="󰽡"
wax_gib="󰽨"
full="󰽢"
wan_gib="󰽦"
last_q="󰽣"
wan_cres="󰽥"
icon=$(awk -v a="$age" \
  -v g1="$new" -v g2="$wax_cres" -v g3="$first_q" -v g4="$wax_gib" \
  -v g5="$full" -v g6="$wan_gib" -v g7="$last_q" -v g8="$wan_cres" \
  -v t1="$t1" -v t2="$t2" -v t3="$t3" -v t4="$t4" \
  -v t5="$t5" -v t6="$t6" -v t7="$t7" -v t8="$t8" \
  'BEGIN{
    if (a < t1) print g1;
    else if (a < t2) print g2;
    else if (a < t3) print g3;
    else if (a < t4) print g4;
    else if (a < t5) print g5;
    else if (a < t6) print g6;
    else if (a < t7) print g7;
    else if (a < t8) print g8;
    else print g1;
    }')
echo "$icon"
