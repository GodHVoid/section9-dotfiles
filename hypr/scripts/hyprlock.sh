#!/usr/bin/env bash

set -u

lock_config="$HOME/.config/hyprlock/section9.conf"
mode="${1:-lock}"

if [[ ! -f "$lock_config" ]]; then
  printf 'Hyprlock config missing: %s\n' "$lock_config" >&2
  exit 1
fi

case "$mode" in
  lock)
    exec hyprlock \
      --config "$lock_config" \
      --immediate-render
    ;;

  suspend)
    hyprlock \
      --config "$lock_config" \
      --immediate-render \
      --no-fade-in &

    lock_pid=$!
    sleep 0.5

    systemctl suspend
    wait "$lock_pid"
    ;;

  *)
    printf 'Usage: %s [lock|suspend]\n' "$0" >&2
    exit 2
    ;;
esac
