alias dotfiles="/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"
eval "$(starship init zsh)"

# Navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias ~="cd ~"
alias dl="cd ~/Downloads"
alias dc="cd ~/Documents"

# Listing files
alias ls="ls --color=auto"
alias ll="ls -alFh"
alias la="ls -A"
alias l="ls -CF"

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