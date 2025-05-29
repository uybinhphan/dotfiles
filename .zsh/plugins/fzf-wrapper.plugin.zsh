fzf_conditional() {
  local RED='\033[0;31m'
  local RESET='\033[0m'

  if [[ "$PWD" == "$HOME" ]]; then
    echo -e "${RED}fzf disabled in home directory${RESET}"
    return 1
  else
    command fzf "$@"
  fi
}

alias fzf='fzf_conditional'