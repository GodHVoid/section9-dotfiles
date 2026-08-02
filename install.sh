#!/usr/bin/env bash

set -euo pipefail

repo="$HOME/Git/section9-dotfiles"
config="$HOME/.config"
backup="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
host_profile="${1:-remote-laptop}"

backup_created=false

log() {
    printf '[SECTION 9] %s\n' "$1"
}

create_backup_directory() {
    if [[ "$backup_created" == false ]]; then
        mkdir -p "$backup"
        backup_created=true
    fi
}

link_path() {
    local source_path="$1"
    local target_path="$2"
    local target_parent

    target_parent="$(dirname "$target_path")"

    if [[ ! -e "$source_path" && ! -L "$source_path" ]]; then
        printf 'Skipping missing repository path: %s\n' "$source_path"
        return 0
    fi

    mkdir -p "$target_parent"

    # Already linked correctly
    if [[ -L "$target_path" ]] &&
       [[ "$(readlink -f "$target_path")" == "$(readlink -f "$source_path")" ]]; then
        printf 'Already linked: %s\n' "$target_path"
        return 0
    fi

    if [[ -L "$target_path" ]]; then
        rm "$target_path"
    elif [[ -e "$target_path" ]]; then
        create_backup_directory

        printf 'Backing up %s\n' "$target_path"
        mv "$target_path" "$backup/"
    fi

    ln -s "$source_path" "$target_path"
    printf 'Linked %s -> %s\n' "$target_path" "$source_path"
}

if [[ ! -d "$repo" ]]; then
    printf 'Repository not found: %s\n' "$repo" >&2
    exit 1
fi

log "Installing required packages"

sudo pacman -S --needed \
    zsh \
    starship \
    fastfetch \
    fzf \
    zoxide \
    zsh-autosuggestions \
    zsh-syntax-highlighting \
    kitty \
    git

mkdir -p "$config"

log "Linking desktop configuration"

link_path "$repo/ags"       "$config/ags"
link_path "$repo/hypr"      "$config/hypr"
link_path "$repo/hyprlock"  "$config/hyprlock"
link_path "$repo/kitty"     "$config/kitty"
link_path "$repo/fastfetch" "$config/fastfetch"
link_path "$repo/nvim"      "$config/nvim"

log "Linking terminal configuration"

link_path "$repo/zsh/.zshrc"               "$HOME/.zshrc"
link_path "$repo/starship/starship.toml"   "$config/starship.toml"

# Select the Hyprland host profile when one exists.
host_source="$repo/hosts/$host_profile/hypr/host.conf"
host_target="$repo/hypr/host.conf"

if [[ -e "$host_source" ]]; then
    if [[ -L "$host_target" || -e "$host_target" ]]; then
        rm -f "$host_target"
    fi

    ln -s "$host_source" "$host_target"
    printf 'Selected host profile: %s\n' "$host_profile"
else
    printf 'Host profile not found, leaving host.conf unchanged: %s\n' \
        "$host_source"
fi

if [[ -f "$repo/hypr/scripts/hyprlock.sh" ]]; then
    chmod +x "$repo/hypr/scripts/hyprlock.sh"
fi

# Change the login shell to Zsh.
zsh_path="$(command -v zsh)"

if [[ "${SHELL:-}" != "$zsh_path" ]]; then
    log "Changing login shell to $zsh_path"
    chsh -s "$zsh_path"
else
    log "Zsh is already the login shell"
fi

printf '\nSection 9 configuration installed.\n'

if [[ "$backup_created" == true ]]; then
    printf 'Previous configuration saved in: %s\n' "$backup"
fi

printf '\nStart a new shell with:\n'
printf '  exec zsh\n'
