#!/usr/bin/env bash

mkdir -p "$HOME/Pictures/Recording/"
SAVE_DIR="$HOME/Pictures/Recording/"
BASENAME="Recording"

# Check if wf-recorder is already running → stop it
PID=$(pgrep -x wf-recorder)
if [ -n "$PID" ]; then
  kill "$PID"
  hyprctl notify 1 5000 "rgb(ffa500)" "Recording stopped"
  exit 0
fi

# Function: get monitor of currently active audio output (sink)
get_active_output_monitor() {
  local sink
  sink=$(pactl info | awk -F': ' '/Default Sink/ {print $2}')
  echo "${sink}.monitor"
}

AUDIO_ARG=""
PARSED_ARGS=()

# Parse arguments
for arg in "$@"; do
  case "$arg" in
  -a | --audio)
    # Auto-detect current output monitor
    ACTIVE_MONITOR=$(get_active_output_monitor)
    AUDIO_ARG="-a${ACTIVE_MONITOR}"
    ;;
  -a=* | --audio=*)
    # User provided device explicitly → convert to correct wf-recorder syntax
    DEVICE="${arg#*=}"
    AUDIO_ARG="-a${DEVICE}"
    ;;
  *)
    PARSED_ARGS+=("$arg")
    ;;
  esac
done

# Pick next sequential filename
n=1
while [ -f "$SAVE_DIR/$BASENAME-$n.mp4" ]; do
  n=$((n + 1))
done

FILENAME="$SAVE_DIR/$BASENAME-$n.mp4"

# Start recording
wf-recorder -f "$FILENAME" $AUDIO_ARG "${PARSED_ARGS[@]}" &
hyprctl notify 1 5000 "rgb(008000)" "Recording started${AUDIO_ARG:+ with audio}"
