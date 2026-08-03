#!/usr/bin/env bash

set -Eeuo pipefail

repo="${SECTION9_REPO:-$HOME/Git/section9-dotfiles}"
config="$HOME/.config"
host_profile="${1:-remote-laptop}"
backup="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"

official_list="$repo/packages/official.txt"
aur_list="$repo/packages/aur.txt"

backup_created=false

log() {
    printf '\n\033[1;36m[SECTION 9]\033[0m %s\n' "$*"
}

warn() {
    printf '\033[1;33m[WARNING]\033[0m %s\n' "$*" >&2
}

die() {
    printf '\033[1;31m[ERROR]\033[0m %s\n' "$*" >&2
    exit 1
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
        warn "Repository path missing; skipping: $source_path"
        return 0
    fi

    mkdir -p "$target_parent"

    if [[ -L "$target_path" ]]; then
        if [[ "$(readlink -f "$target_path")" == \
              "$(readlink -f "$source_path")" ]]; then
            printf 'Already linked: %s\n' "$target_path"
            return 0
        fi

        rm "$target_path"
    elif [[ -e "$target_path" ]]; then
        create_backup_directory

        local backup_target="$backup/$(basename "$target_path")"

        # Prevent collisions if multiple targets share a basename.
        if [[ -e "$backup_target" ]]; then
            backup_target="$backup/$(basename "$target_path").$(date +%s)"
        fi

        printf 'Backing up %s -> %s\n' "$target_path" "$backup_target"
        mv "$target_path" "$backup_target"
    fi

    ln -s "$source_path" "$target_path"
    printf 'Linked %s -> %s\n' "$target_path" "$source_path"
}

install_official_packages() {
    [[ -f "$official_list" ]] ||
        die "Official package list missing: $official_list"

    log "Synchronizing Arch package databases"
    sudo pacman -Syu --needed

    log "Installing official desktop dependencies"

    mapfile -t packages < <(
        sed \
            -e 's/[[:space:]]*#.*$//' \
            -e '/^[[:space:]]*$/d' \
            "$official_list" |
        sort -u
    )

    ((${#packages[@]} > 0)) ||
        die "No packages found in $official_list"

    sudo pacman -S --needed "${packages[@]}"
}

install_yay() {
    if command -v yay >/dev/null 2>&1; then
        printf 'yay already installed: %s\n' "$(command -v yay)"
        return 0
    fi

    log "Installing yay AUR helper"

    local build_dir
    build_dir="$(mktemp -d)"

    git clone https://aur.archlinux.org/yay-bin.git \
        "$build_dir/yay-bin"

    (
        cd "$build_dir/yay-bin"
        makepkg -si --needed
    )

    rm -rf "$build_dir"
}

install_aur_packages() {
    if [[ ! -f "$aur_list" ]]; then
        warn "AUR package list missing; skipping: $aur_list"
        return 0
    fi

    mapfile -t packages < <(
        sed \
            -e 's/[[:space:]]*#.*$//' \
            -e '/^[[:space:]]*$/d' \
            "$aur_list" |
        sort -u
    )

    if ((${#packages[@]} == 0)); then
        warn "AUR package list is empty"
        return 0
    fi

    install_yay

    log "Installing AUR desktop dependencies"
    yay -S --needed "${packages[@]}"
}

configure_services() {
    log "Enabling system services"

    sudo systemctl enable NetworkManager.service
    sudo systemctl enable bluetooth.service
    sudo systemctl enable power-profiles-daemon.service
    sudo systemctl enable sddm.service
}

configure_sddm() {
    local theme_source="$repo/sddm/section9"
    local theme_target="/usr/share/sddm/themes/section9"

    if [[ ! -d "$theme_source" ]]; then
        warn "Section 9 SDDM theme missing; skipping"
        return 0
    fi

    log "Installing Section 9 SDDM theme"

    sudo rm -rf "$theme_target"
    sudo cp -a "$theme_source" "$theme_target"

    sudo mkdir -p /etc/sddm.conf.d

    sudo tee /etc/sddm.conf.d/theme.conf >/dev/null <<'SDDMEOF'
[Theme]
Current=section9
SDDMEOF
}

configure_host_profile() {
    local host_source="$repo/hosts/$host_profile/hypr/host.conf"
    local host_target="$repo/hypr/host.conf"

    if [[ ! -e "$host_source" ]]; then
        warn "Host profile not found: $host_source"
        return 0
    fi

    rm -f "$host_target"
    ln -s "$host_source" "$host_target"

    printf 'Selected Hyprland host profile: %s\n' "$host_profile"
}

link_configuration() {
    log "Linking Section 9 configuration"

    mkdir -p "$config"

    link_path "$repo/ags"       "$config/ags"
    link_path "$repo/hypr"      "$config/hypr"
    link_path "$repo/hyprlock"  "$config/hyprlock"
    link_path "$repo/kitty"     "$config/kitty"
    link_path "$repo/fastfetch" "$config/fastfetch"
    link_path "$repo/nvim"      "$config/nvim"

    link_path \
        "$repo/starship/starship.toml" \
        "$config/starship.toml"

    link_path \
        "$repo/zsh/.zshrc" \
        "$HOME/.zshrc"
}

configure_shell() {
    local zsh_path
    zsh_path="$(command -v zsh)"

    if [[ "$SHELL" != "$zsh_path" ]]; then
        log "Changing login shell to $zsh_path"
        chsh -s "$zsh_path"
    else
        printf 'Zsh is already the login shell.\n'
    fi
}

set_script_permissions() {
    log "Setting script permissions"

    if [[ -d "$repo/hypr/scripts" ]]; then
        find "$repo/hypr/scripts" \
            -maxdepth 1 \
            -type f \
            -name '*.sh' \
            -exec chmod +x {} +
    fi
}

validate_installation() {
    log "Validating installation"

    local failed=false

    local commands=(
        Hyprland
        ags
        kitty
        starship
        fastfetch
        fzf
        zoxide
        hyprlock
    )

    for command_name in "${commands[@]}"; do
        if command -v "$command_name" >/dev/null 2>&1; then
            printf 'OK: %-12s %s\n' \
                "$command_name" \
                "$(command -v "$command_name")"
        else
            warn "Command unavailable: $command_name"
            failed=true
        fi
    done

    printf '\nConfiguration links:\n'

    local targets=(
        "$config/ags"
        "$config/hypr"
        "$config/hyprlock"
        "$config/kitty"
        "$config/fastfetch"
        "$config/nvim"
        "$config/starship.toml"
        "$HOME/.zshrc"
    )

    for target in "${targets[@]}"; do
        if [[ -L "$target" ]]; then
            printf 'OK: %s -> %s\n' \
                "$target" \
                "$(readlink -f "$target")"
        else
            warn "Not linked: $target"
            failed=true
        fi
    done

    if [[ "$failed" == true ]]; then
        warn "Installation completed with validation warnings"
    fi
}

main() {
    [[ "$EUID" -ne 0 ]] ||
        die "Run this script as your normal user, not as root"

    [[ -d "$repo/.git" ]] ||
        die "Section 9 repository not found: $repo"

    install_official_packages
    install_aur_packages
    configure_host_profile
    link_configuration
    configure_sddm
    configure_services
    configure_shell
    set_script_permissions
    validate_installation

    log "Section 9 installation complete"

    if [[ "$backup_created" == true ]]; then
        printf 'Previous configurations were saved to:\n%s\n' "$backup"
    fi

    printf '\nStart the configured shell with:\n'
    printf '  exec zsh\n'

    printf '\nA reboot is recommended after confirming there were no errors:\n'
    printf '  sudo reboot\n'
}

main "$@"
