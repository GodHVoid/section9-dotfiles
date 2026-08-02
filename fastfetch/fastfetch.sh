#!/usr/bin/env bash

CACHE_DIR="$HOME/.config/fastfetch/cache"
CONFIG_FILE="$HOME/.config/fastfetch/config.jsonc"

# Select one random image from the Fastfetch cache.
IMAGE_PATH="$(
  find "$CACHE_DIR" -maxdepth 1 -type f \
    \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) \
    2>/dev/null |
  shuf -n 1
)"

# Run without a logo when the cache is empty.
if [[ -z "$IMAGE_PATH" ]]; then
  exec fastfetch --config "$CONFIG_FILE"
fi

exec fastfetch \
  --config "$CONFIG_FILE" \
  --logo-type kitty \
  --logo-recache \
  --logo-height 22 \
  --logo "$IMAGE_PATH"
