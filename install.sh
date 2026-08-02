#!/usr/bin/env bash

set -euo pipefail

repo="$HOME/Git/section9-dotfiles"
config="$HOME/.config"
backup="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"

declare -A links=(
  ["ags"]="$config/ags"
  ["hypr"]="$config/hypr"
  ["hyprlock"]="$config/hyprlock"
  ["kitty"]="$config/kitty"
  ["fastfetch"]="$config/fastfetch"
  ["nvim"]="$config/nvim"
)

if [[ ! -d "$repo" ]]; then
  printf 'Repository not found: %s\n' "$repo" >&2
  exit 1
fi

mkdir -p "$config"

backup_created=false

for source_name in "${!links[@]}"; do
  source_path="$repo/$source_name"
  target_path="${links[$source_name]}"

  if [[ ! -e "$source_path" ]]; then
    printf 'Skipping missing repository path: %s\n' "$source_path"
    continue
  fi

  if [[ -L "$target_path" ]]; then
    rm "$target_path"
  elif [[ -e "$target_path" ]]; then
    if [[ "$backup_created" == false ]]; then
      mkdir -p "$backup"
      backup_created=true
    fi

    printf 'Backing up %s\n' "$target_path"
    mv "$target_path" "$backup/"
  fi

  ln -s "$source_path" "$target_path"
  printf 'Linked %s -> %s\n' "$target_path" "$source_path"
done

chmod +x "$repo/hypr/scripts/hyprlock.sh"

printf '\nSection 9 configuration installed.\n'

if [[ "$backup_created" == true ]]; then
  printf 'Previous configuration saved in: %s\n' "$backup"
fi
