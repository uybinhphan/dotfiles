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

parts="🤖"

# Model
[ -n "$model" ] && parts="${parts} ${model}"

# Session (5h) usage + reset time
if [ -n "$five_hour_pct" ]; then
  five_int=$(printf "%.0f" "$five_hour_pct")
  reset_str=""
  if [ -n "$five_hour_reset" ]; then
    reset_str=" $(date -r "$five_hour_reset" +%H:%M)"
  fi
  parts="${parts}  5h:${five_int}%${reset_str}"
fi

# Weekly (7d) usage + reset time
if [ -n "$seven_day_pct" ]; then
  seven_int=$(printf "%.0f" "$seven_day_pct")
  reset_str=""
  if [ -n "$seven_day_reset" ]; then
    reset_str=" $(date -r "$seven_day_reset" "+%a%d/%m %H:%M")"
  fi
  parts="${parts}  7d:${seven_int}%${reset_str}"
fi

# Current working directory
[ -n "$cwd" ] && parts="${parts}  ${cwd}"

printf "%s" "$parts"
