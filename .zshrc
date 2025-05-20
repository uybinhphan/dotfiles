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
# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/uybinh/.lmstudio/bin"
# End of LM Studio CLI section

# Enable autosuggestions
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Enable syntax highlighting
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Enable zsh-completions
# Check if Homebrew is installed and add zsh-completions to FPATH
# This is useful for macOS users who have installed Homebrew
# and want to use zsh-completions
# Check if Homebrew is installed
if type brew &>/dev/null; then
    FPATH=$(brew --prefix)/share/zsh-completions:$FPATH

    autoload -Uz compinit
    compinit
fi

# Optional: case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# Load personal "plugins"
for file in ~/.zsh/plugins/*.zsh; do
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

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
