# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repository Is

Personal macOS dotfiles managed via a **bare Git repository** pattern. Files live directly in `$HOME` — no symlinks. The `dotfiles` alias (`/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME`) is used for all version control operations instead of `git`.

## Managing Dotfiles

```bash
dotfiles status           # see changes
dotfiles add .zshrc       # stage a file
dotfiles commit -m "..."  # commit
dotfiles push             # push to origin
dotfiles log --oneline    # history
```

## Bootstrap / Installation

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/uybinhphan/dotfiles/main/.config/dotfiles/setup-dotfiles.sh)"
```

The setup script (`~/.config/dotfiles/setup-dotfiles.sh`) is macOS-only. It installs Xcode CLT, Homebrew, clones the bare repo, backs up conflicting files to `~/.dotfiles-backup-YYYYMMDDHHMMSS/`, checks out dotfiles, runs `brew bundle`, and executes all scripts in `~/.config/dotfiles/scripts/`.

## Repository Structure

- `.zshrc` — Zsh entry point; sources plugins from `~/.zsh/plugins/`
- `.zsh/plugins/` — custom plugins: `eza.plugin.zsh`, `fzf.plugin.zsh`, `reset-app-permissions.plugin.zsh`, `claude-code-switching.zsh`, `ollama.plugin.zsh`
- `.gitconfig` — git user config and aliases (`lg`, `recent`, `amend`, etc.)
- `.gitignore_global` — exists locally but is neither tracked nor wired up (`core.excludesfile` is unset)
- `.config/starship.toml` — Starship prompt config (minimal: 10 active modules)
- `.config/dotfiles/Brewfile` — Homebrew package list (formulae + casks + VSCode extensions)
- `.config/dotfiles/.macos` — macOS system defaults (Dock, Finder, Keyboard, Save panel, power); run with `bash`, not `source`
- `.config/dotfiles/scripts/` — post-install scripts auto-run by setup
- `scripts/` — standalone utility scripts (not auto-run)
- `.claude/` — Claude Code user config: `CLAUDE.md`, `settings.json`, `statusline-command.sh`, auto-memory under `projects/-Users-uybinh/memory/`
- `.config/yt-dlp/config` — yt-dlp defaults (mp4, h264)
- `.github/workflows/` — CI: `shellcheck.yml` (scripts and setup), `gitleaks.yml` (secret scan)
- `.claude/hooks/guard-bash.sh` — Claude Code PreToolUse guard for Bash
- `.config/dotfiles/hooks/` — git hooks for the bare repo (`core.hooksPath`)

## Key Tools Configured

- **Shell**: Zsh with zsh-autosuggestions, zsh-fast-syntax-highlighting, zsh-history-substring-search, compinit caching (24h TTL)
- **Prompt**: Starship
- **Node**: fnm (Fast Node Manager) — replaces nvm
- **Navigation**: zoxide (`z` command)
- **File listing**: eza (replaces `ls`)
- **Fuzzy finder**: fzf with bat previews
- **Python**: uv
- **JS/TS**: bun

## Custom Plugin Notes

- **eza.plugin.zsh**: Aliases `ls`, `ll`, `la`, `lt` etc. to eza with `--icons --group-directories-first`
- **fzf.plugin.zsh**: Configures CTRL+T / ALT+C; uses bat for file preview; filters out `.git`, `node_modules`, etc.
- **reset-app-permissions.plugin.zsh**: Aliased as `rap`; resets macOS TCC permissions for a named app (e.g. `rap "Google Chrome"`)
- **claude-code-switching.zsh**: `cc` runs Claude Code with the normal login, `ccds` routes it through DeepSeek's Anthropic-compatible API, `ccenv` shows the provider env vars (values hidden)
- **ollama.plugin.zsh**: Ollama env tuning (MLX, flash attention, q8 KV cache) and model-name completion

## Secrets

API keys live in the macOS Keychain and are read only by the function that needs them (e.g. `ccds` runs `security find-generic-password -a "$USER" -s DEEPSEEK_API_KEY -w`). Nothing exports secrets into every shell. Add a key with `security add-generic-password -a "$USER" -s NAME -U -w` (prompts for the value). git-crypt is installed by the Brewfile but not configured (no `.gitattributes`), so nothing in the repo is encrypted.

Guards:
- `.config/dotfiles/hooks/pre-commit` runs gitleaks on staged changes; the bare repo uses it via `core.hooksPath` (set by the setup script). `.github/workflows/gitleaks.yml` scans every push.
- `.claude/hooks/guard-bash.sh` is a Claude Code PreToolUse hook: it blocks catastrophic commands (rm on `/` or `$HOME`, `dd` to devices, `mkfs`, `curl | sh`) and forces a prompt for destructive `dotfiles` commands and Keychain/secret reads.
- `.claude/settings.json` denies reading SSH private keys and `~/.claude/.credentials.json`.
