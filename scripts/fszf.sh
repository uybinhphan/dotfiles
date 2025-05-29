#!/bin/bash

# fszf — Fuzzy search folder sizes
# Requirements: fzf, du, awk, sort

# Generate list of folders with sizes
folder_list=$(du -sh .[^.]* * 2>/dev/null | sort -h)

# Use fzf to fuzzy search with preview
echo "$folder_list" | fzf --ansi \
  --prompt="📁 Folder Search > " \
  --header="Select a folder to open or copy its path" \
  --preview='echo {}' \
  --preview-window=up:3:wrap \
  --bind='enter:execute-silent(echo {2..} | xargs open)' \
  --layout=reverse --height=80%
