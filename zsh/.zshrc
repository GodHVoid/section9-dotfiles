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
# PATH
# ---------------------------------------------------------
export PATH="$HOME/Git/section9-dotfiles/bin:$PATH"

# ---------------------------------------------------------
# Aliases
# ---------------------------------------------------------
command -v bat   >/dev/null 2>&1 && alias cat='bat --paging=never'
command -v fd    >/dev/null 2>&1 && alias find='fd'
command -v rg    >/dev/null 2>&1 && alias grep='rg'
command -v procs >/dev/null 2>&1 && alias ps='procs'
command -v dust  >/dev/null 2>&1 && alias du='dust'
command -v duf   >/dev/null 2>&1 && alias df='duf'
command -v btop  >/dev/null 2>&1 && alias top='btop'
command -v delta >/dev/null 2>&1 && alias diff='delta'

if command -v eza >/dev/null 2>&1; then
    alias ls='eza --icons=always --group-directories-first'
    alias ll='eza -lah --icons=always --group-directories-first'
    alias la='eza -a --icons=always --group-directories-first'
    alias tree='eza --tree --icons=always'
    alias lt='eza --tree --level=2 --icons=always'
    alias lta='eza --tree --level=3 --all --icons=always'
    alias lg='eza -lah --git --icons=always --group-directories-first'
    alias newest='eza -lah --sort=modified --reverse --icons=always'
fi

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
    if command -v fd >/dev/null 2>&1; then
        export FZF_DEFAULT_COMMAND='fd --hidden --strip-cwd-prefix --exclude .git'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export FZF_ALT_C_COMMAND='fd --type d --hidden --strip-cwd-prefix --exclude .git'
    fi

    export FZF_DEFAULT_OPTS="
        --height=70%
        --layout=reverse
        --border=rounded
        --info=inline
        --prompt='SECTION 9 > '
        --pointer='>'
        --marker='*'
        --preview-window=right:60%
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
                if command -v eza >/dev/null 2>&1; then
                    eza --tree --level=2 --icons=always --color=always -- \"\$target\"
                else
                    command ls -la -- \"\$target\"
                fi
            elif command -v bat >/dev/null 2>&1; then
                bat --color=always --style=numbers --line-range=:300 -- \"\$target\"
            else
                sed -n \"1,300p\" -- \"\$target\"
            fi
        '
    "

    export FZF_ALT_C_OPTS="
        --prompt='DIRECTORY > '
        --preview='
            if command -v eza >/dev/null 2>&1; then
                eza --tree --level=2 --icons=always --color=always -- {}
            else
                command ls -la -- {}
            fi
        '
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
