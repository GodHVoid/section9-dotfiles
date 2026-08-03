# =========================================================
# SECTION 9 ZSH CONFIGURATION
# =========================================================

# ---------------------------------------------------------
# History
# ---------------------------------------------------------
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000

setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt EXTENDED_HISTORY
setopt AUTO_CD
setopt INTERACTIVE_COMMENTS

# ---------------------------------------------------------
# Completion
# ---------------------------------------------------------
autoload -Uz compinit
compinit

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# ---------------------------------------------------------
# fzf
#
# Ctrl+R  fuzzy command history
# Ctrl+T  fuzzy file selection
# Alt+C   fuzzy directory selection
# ---------------------------------------------------------
if command -v fzf >/dev/null 2>&1; then
    export FZF_DEFAULT_OPTS="
        --height=45%
        --layout=reverse
        --border=rounded
        --info=inline
        --prompt='SECTION 9 > '
        --pointer='>'
        --marker='*'
    "

    export FZF_CTRL_R_OPTS="
        --prompt='HISTORY > '
        --preview='printf \"%s\n\" {}'
        --preview-window=down:3:wrap
    "

    export FZF_CTRL_T_OPTS="
        --prompt='FILES > '
        --preview='
            target={}
            if [[ -d \"\$target\" ]]; then
                command ls -la -- \"\$target\"
            elif command -v bat >/dev/null 2>&1; then
                bat --color=always --style=numbers --line-range=:200 -- \"\$target\"
            else
                sed -n \"1,200p\" -- \"\$target\"
            fi
        '
    "

    export FZF_ALT_C_OPTS="
        --prompt='DIRECTORY > '
        --preview='command ls -la -- {}'
    "

    source <(fzf --zsh)
fi
# ---------------------------------------------------------
# zoxide
# ---------------------------------------------------------
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi

# ---------------------------------------------------------
# Zsh plugins
# ---------------------------------------------------------
if [[ -r /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

if [[ -r /usr/share/zsh/plugins/zsh-sudo/sudo.plugin.zsh ]]; then
    source /usr/share/zsh/plugins/zsh-sudo/sudo.plugin.zsh
fi

if [[ -r /usr/share/zsh/plugins/zsh-auto-notify/auto-notify.plugin.zsh ]]; then
    source /usr/share/zsh/plugins/zsh-auto-notify/auto-notify.plugin.zsh
fi

# ---------------------------------------------------------
# Fastfetch
# ---------------------------------------------------------
if [[ -o interactive ]] &&
   command -v fastfetch >/dev/null 2>&1; then
    fastfetch
fi

# ---------------------------------------------------------
# Starship prompt
# ---------------------------------------------------------
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
fi

# Syntax highlighting should be loaded last.
if [[ -r /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
