alias dotfiles="/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"

eval "$(starship init zsh)"

# Navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias ~="cd ~"
alias dl="cd ~/Downloads"
alias dc="cd ~/Documents"

# Utilities
alias c="clear"
alias h="history"
alias j="jobs -l"
alias m="less"
alias reload="source ~/.zshrc"
alias path="echo -e ${PATH//:/\\n}"
alias now="date +\"%T\""
alias ip="curl -s ipinfo.io/ip"
alias weather="curl wttr.in"

export PATH="$PATH:$HOME/.local/bin"
export HOMEBREW_BUNDLE_FILE="$HOME/.config/dotfiles/Brewfile"

# History
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_DUPS HIST_IGNORE_SPACE SHARE_HISTORY HIST_VERIFY

source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/opt/zsh-fast-syntax-highlighting/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh

# History substring search — load after syntax highlighting
source /opt/homebrew/share/zsh-history-substring-search/zsh-history-substring-search.zsh
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Completions
if type brew &>/dev/null; then
    FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
    autoload -Uz compinit
    # Cache compinit dump; regenerate only if missing or older than 24h
    _zcompdump_fresh=(${ZDOTDIR:-$HOME}/.zcompdump(Nmh-24))
    if (( ${#_zcompdump_fresh} )); then
        compinit -C
    else
        compinit
    fi
    unset _zcompdump_fresh
fi

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' menu select
zmodload zsh/complist

# Load plugins
for file in ~/.zsh/plugins/*.zsh(N); do
    source "$file"
done

if type docker &>/dev/null; then
    export PATH="$PATH:$HOME/.docker/bin"
fi

eval "$(fnm env --use-on-cd --shell zsh)"
eval "$(zoxide init zsh)"

export PATH="$PATH:$HOME/.lmstudio/bin"

source "$HOME/.openclaw/completions/openclaw.zsh"
