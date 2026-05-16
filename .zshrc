# Alias for managing dotfiles using a bare Git repository
alias dotfiles="/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"

# Initialize Starship prompt
eval "$(starship init zsh)" 

# Navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias ~="cd ~"
alias dl="cd ~/Downloads"
alias dc="cd ~/Documents"

# Misc utilities
alias c="clear"
alias h="history"
alias j="jobs -l"
alias m="less"
alias reload="source ~/.zshrc"
alias path="echo -e ${PATH//:/\\n}"
alias now="date +\"%T\""
alias ip="curl -s ipinfo.io/ip"
alias weather="curl wttr.in"
# Claude Code 
export PATH="$PATH:$HOME/.local/bin" 


# Enable autosuggestions
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Enable syntax highlighting
source /opt/homebrew/opt/zsh-fast-syntax-highlighting/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh

# Enable zsh-completions
# Check if Homebrew is installed and add zsh-completions to FPATH
# This is useful for macOS users who have installed Homebrew
# and want to use zsh-completions
# Check if Homebrew is installed
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

# Optional: case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' menu select
zmodload zsh/complist

# Load personal "plugins"
for file in ~/.zsh/plugins/*.zsh(N); do
    source "$file"
done


# This is useful for macOS users who have installed Docker
# and want to use Docker CLI commands in local user space
# Check if Docker is installed
if type docker &>/dev/null; then
    # Add Docker CLI to PATH
    export PATH=$PATH:~/.docker/bin 
fi
# Then add Docker CLI to PATH


# Initialize fnm (Fast Node Manager)
eval "$(fnm env --use-on-cd --shell zsh)"

# Initialize zoxide 
eval "$(zoxide init zsh)"

export PATH="$PATH:$HOME/.lmstudio/bin"


# Lazy-load pyenv — only initialize when pyenv is first called
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
if [[ -d $PYENV_ROOT ]]; then
    pyenv() {
        unfunction pyenv
        eval "$(command pyenv init -)"
        pyenv "$@"
    }
fi

# Ollama MLX backend
export OLLAMA_USE_MLX=1
export OLLAMA_FLASH_ATTENTION=1
export OLLAMA_KV_CACHE_TYPE=q8_0

# Ollama completion for local model names
if type ollama &>/dev/null && (( $+functions[compdef] )); then
    _ollama_models() {
        local -a models
        models=("${(@f)$(curl -fsS http://127.0.0.1:11434/api/tags 2>/dev/null | tr '{},' '\n' | awk -F\" '/"name":/ {print $4}')}")
        compadd -a models
    }

    _ollama() {
        local -a commands
        commands=(
            'run:run a model'
            'show:show model information'
            'pull:pull a model'
            'rm:remove a model'
            'cp:copy a model'
            'list:list models'
            'ps:list running models'
            'serve:start ollama server'
            'stop:stop a running model'
        )

        if (( CURRENT == 2 )); then
            _describe 'ollama commands' commands
        elif (( CURRENT == 3 )); then
            case "${words[2]}" in
                run|show|rm|cp|stop)
                    _ollama_models
                    ;;
                *)
                    _files
                    ;;
            esac
        else
            _files
        fi
    }

    compdef _ollama ollama
fi

# OpenClaw Completion
source "/Users/uybinh/.openclaw/completions/openclaw.zsh"

# Load private secrets, not committed to GitHub
if [ -f "$HOME/.zsh_secrets" ]; then
  source "$HOME/.zsh_secrets"
fi
# Added by Antigravity
export PATH="/Users/uybinh/.antigravity/antigravity/bin:$PATH"
