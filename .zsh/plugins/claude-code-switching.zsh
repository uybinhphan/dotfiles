# Claude Code switching plugin
# Safe to commit: no API keys here.
# Provides `cc` and `ccds` commands to switch between different Claude Code providers (Anthropic, DeepSeek, etc.) by setting/unsetting environment variables.
# Usage:
#   - `cc [args]`: Run `claude` with default environment (Anthropic API or normal login).
#   - `ccds [args]`: Run `claude` with DeepSeek API environment.
#   - `ccenv`: Show current Claude Code related environment variables (with values hidden).


_cc_unset_provider_env() {
  unset ANTHROPIC_BASE_URL
  unset ANTHROPIC_AUTH_TOKEN
  unset ANTHROPIC_API_KEY
  unset ANTHROPIC_MODEL
  unset ANTHROPIC_DEFAULT_OPUS_MODEL
  unset ANTHROPIC_DEFAULT_SONNET_MODEL
  unset ANTHROPIC_DEFAULT_HAIKU_MODEL
  unset CLAUDE_CODE_SUBAGENT_MODEL
  unset CLAUDE_CODE_EFFORT_LEVEL
}

cc() {
  _cc_unset_provider_env

  # Default: use Claude Code normal login/subscription.
  # To force Anthropic API key mode, uncomment:
  # export ANTHROPIC_API_KEY="$CLAUDE_API_KEY"

  command claude "$@"
}

ccds() {
  if [ -z "$DEEPSEEK_API_KEY" ]; then
    echo "Missing DEEPSEEK_API_KEY. Add it to ~/.zsh_secrets"
    return 1
  fi

  ANTHROPIC_BASE_URL="https://api.deepseek.com/anthropic" \
  ANTHROPIC_AUTH_TOKEN="$DEEPSEEK_API_KEY" \
  ANTHROPIC_MODEL="deepseek-v4-pro[1m]" \
  ANTHROPIC_DEFAULT_OPUS_MODEL="deepseek-v4-pro[1m]" \
  ANTHROPIC_DEFAULT_SONNET_MODEL="deepseek-v4-pro[1m]" \
  ANTHROPIC_DEFAULT_HAIKU_MODEL="deepseek-v4-flash" \
  CLAUDE_CODE_SUBAGENT_MODEL="deepseek-v4-flash" \
  CLAUDE_CODE_EFFORT_LEVEL="max" \
  command claude "$@"
}

ccenv() {
  echo "Claude Code related env:"
  env | grep -E 'ANTHROPIC|CLAUDE_CODE|DEEPSEEK' | sed 's/\(KEY=\|TOKEN=\).*/\1[hidden]/'
}