#!/usr/bin/env bash

mkdir -p "$HOME/Pictures/Recording/"
SAVE_DIR="$HOME/Pictures/Recording/"
BASENAME="Recording"
PID=$(pgrep -x wf-recorder)
if [ -n "$PID" ]; then
  kill "$PID"
  hyprctl notify 1 5000 "rgb(ffa500)" "Recording stopped"
  exit 0
fi
n=1
while [ -f "$SAVE_DIR/$BASENAME-$n.mp4" ]; do
  n=$((n + 1))
done
FILENAME="$SAVE_DIR/$BASENAME-$n.mp4"
wf-recorder -f "$FILENAME" "$@" &
hyprctl notify 1 5000 "rgb(008000)" "Recording started"
