#!/usr/bin/env bash
# PreToolUse guard for the Bash tool: block catastrophic commands outright,
# and force a prompt for risky ones even in auto mode.
# Contract: exit 2 + stderr = block; permissionDecision "ask" JSON on stdout = prompt.

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

# Without jq we cannot read the command; fail open rather than break every Bash call.
command -v jq >/dev/null 2>&1 || exit 0

cmd=$(jq -r '.tool_input.command // empty')
[ -z "$cmd" ] && exit 0

deny() { echo "Blocked by guard-bash: $1" >&2; exit 2; }
ask() {
  jq -n --arg r "guard-bash: $1" \
    '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "ask", permissionDecisionReason: $r}}'
  exit 0
}
has() { grep -qE -- "$1" <<<"$cmd"; }

b='(^|[;&|({[:space:]])'   # start of a command word
end='([[:space:];&|)]|$)'
rm_flags='rm[[:space:]]+((-[a-zA-Z]+|--[a-z-]+)[[:space:]]+)*'
# shellcheck disable=SC2016  # literal $HOME: we match the text the agent typed
home='(~|\$HOME|\$\{HOME\}|/Users/[^/[:space:]"'"'"']+)'

has "${b}${rm_flags}[\"']?(/|/\*|${home}/?|${home}/\*|/Users/?)[\"']?${end}" && deny "rm aimed at / or the home folder"
has 'no-preserve-root' && deny "--no-preserve-root"
has "${b}dd[[:space:]][^;&|]*of=[\"']?/dev/" && deny "dd writing to a raw device"
has "${b}mkfs(\.[A-Za-z0-9]+)?${end}" && deny "mkfs"
has "${b}diskutil[[:space:]]+(erase[A-Za-z]*|partitionDisk|zeroDisk|secureErase|apfs[[:space:]]+(delete|erase)[A-Za-z]*)" && deny "diskutil erase/partition"
has "${b}sudo[[:space:]]+(-[a-zA-Z]+[[:space:]]+)*rm${end}" && deny "sudo rm"
has "${b}(curl|wget)[[:space:]][^;&]*\|[[:space:]]*(sudo[[:space:]]+)?(ba|z)?sh${end}" && deny "piping a download into a shell"

# The bare repo's work tree is all of $HOME, so these can overwrite or delete real files.
dot='(dotfiles|([^[:space:]]*/)?git[[:space:]]+(-[^[:space:]]+[[:space:]]+)*--git-dir=[^[:space:]]*\.dotfiles/?)'
has "${b}${dot}[[:space:]]+(.*[[:space:]])?(reset[[:space:]]+(.*[[:space:]])?--hard|checkout[[:space:]]+(.*[[:space:]])?(-f|--force|--[[:space:]]+\.)|clean|push[[:space:]]+(.*[[:space:]])?(-f|--force[a-z-]*))${end}" \
  && ask "destructive dotfiles command (work tree is \$HOME)"
has "${b}security[[:space:]]+(find-(generic|internet)-password[^;&|]*[[:space:]]-w|dump-keychain)" && ask "reads a secret from the Keychain"
has '\.zsh_secrets' && ask "touches ~/.zsh_secrets"

exit 0
