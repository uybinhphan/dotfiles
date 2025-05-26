# ~/.zsh/plugins/eza.plugin.zsh

# Prefer eza over ls, fallback to ls if not available
if command -v eza &> /dev/null; then
  alias ls='eza --icons --group-directories-first'
  alias ll='eza -l --icons --group-directories-first'
  alias la='eza -la --icons --group-directories-first'
  alias l='eza -l --icons --group-directories-first'
  alias lt='eza --tree --level=2 --icons --group-directories-first'
else
  alias ls='ls -G'
  alias ll='ls -lG'
  alias la='ls -laG'
  alias l='ls -lG'
  alias lt='ls -lRG | less'
fi