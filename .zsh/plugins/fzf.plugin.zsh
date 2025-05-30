# Enable fzf keybindings and fuzzy completion
source <(fzf --zsh)

# Exclude common hidden directories from fzf
export FZF_DEFAULT_COMMAND="fd --follow -E .DS_Store"

export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Set FZF_DEFAULT_OPTS for better experience
export FZF_DEFAULT_OPTS="--height 60% --layout=reverse --border
  --info=inline
  --preview='bat --style=numbers --color=always {} || cat {}'
  --preview-window=right:30%:wrap
  --walker-skip=.git,node_modules,.venv,.obsidian,.cache,target
  --bind='ctrl-/:change-preview-window(down|hidden|)'"



