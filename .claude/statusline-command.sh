#!/usr/bin/env bash
input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // ""')
five_hour_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_hour_reset=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
seven_day_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
seven_day_reset=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')
cwd=$(echo "$input" | jq -r '.cwd // ""')

# Shorten cwd: replace $HOME with ~
home_dir="$HOME"
cwd="${cwd/#$home_dir/~}"

RESET=$'\033[0m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
RED=$'\033[31m'
BOLD_CYAN=$'\033[1;36m'

rate_color() {
  local pct=$1
  if [ "$(echo "$pct < 50" | bc)" = "1" ]; then
    printf "%s" "$GREEN"
  elif [ "$(echo "$pct < 80" | bc)" = "1" ]; then
    printf "%s" "$YELLOW"
  else
    printf "%s" "$RED"
  fi
}

out="🤖"

# Model
[ -n "$model" ] && out="${out} ${model}"

# Session (5h) usage + reset time
if [ -n "$five_hour_pct" ]; then
  five_int=$(printf "%.0f" "$five_hour_pct")
  color=$(rate_color "$five_hour_pct")
  reset_str=""
  if [ -n "$five_hour_reset" ]; then
    reset_str=" $(date -r "$five_hour_reset" +%H:%M)"
  fi
  out="${out}  ${color}5h:${five_int}%${reset_str}${RESET}"
fi

# Weekly (7d) usage + reset time
if [ -n "$seven_day_pct" ]; then
  seven_int=$(printf "%.0f" "$seven_day_pct")
  color=$(rate_color "$seven_day_pct")
  reset_str=""
  if [ -n "$seven_day_reset" ]; then
    reset_str=" $(date -r "$seven_day_reset" "+%a%d/%m %H:%M")"
  fi
  out="${out}  ${color}7d:${seven_int}%${reset_str}${RESET}"
fi

# Current working directory (bold cyan)
[ -n "$cwd" ] && out="${out}  ${BOLD_CYAN}${cwd}${RESET}"

printf "%s" "$out"
