#!/usr/bin/env bash

SAVE_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SAVE_DIR"
n=1
while [[ -e "$SAVE_DIR/Screenshot-$n.png" ]]; do
  ((n++))
done
FILE="$SAVE_DIR/Screenshot-$n.png"
ACTION="copysave"
TARGET="screen"
OPTIONS=()
for arg in "$@"; do
  case "$arg" in
  copy | save | copysave | edit)
    ACTION="$arg"
    ;;
  active | screen | output | area)
    TARGET="$arg"
    ;;
  *)
    OPTIONS+=("$arg")
    ;;
  esac
done
grimblast "${OPTIONS[@]}" "$ACTION" "$TARGET" "$FILE"
hyprctl notify 1 5000 "rgb(008000)" "Screenshot saved to ~/Pictures/Screenshots"
