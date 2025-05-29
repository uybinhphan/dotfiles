fzf_conditional() {
  if [[ "$PWD" == "$HOME" ]]; then
    echo "fzf disabled in home directory"
    return 1
  else
    command fzf "$@"
  fi
}
alias fzf='fzf_conditional'