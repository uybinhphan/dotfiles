#!/usr/bin/env bash
set -euo pipefail

echo "🧼 Starting uninstallation of pnpm, corepack, and fnm..."

# Function to remove a line from a file if it exists
remove_line_from_file() {
  local line="$1"
  local file="$2"
  if [ -f "$file" ]; then
    if grep -Fxq "$line" "$file"; then
      echo "🔧 Removing line from $file"
      sed -i.bak "\|$line|d" "$file"
    fi
  fi
}

# ------------------------------
# 1. Uninstall pnpm
# ------------------------------
echo "📦 Uninstalling pnpm..."

# Remove global pnpm packages
if command -v pnpm >/dev/null 2>&1; then
  echo "🔍 Listing global pnpm packages..."
  GLOBAL_PACKAGES=$(pnpm ls -g --depth=0 --json | jq -r '.[].dependencies | keys[]' || true)
  if [ -n "$GLOBAL_PACKAGES" ]; then
    echo "🗑 Removing global pnpm packages..."
    pnpm remove -g $GLOBAL_PACKAGES || true
  fi

  # Remove pnpm store
  echo "🗑 Removing pnpm store..."
  STORE_PATH=$(pnpm store path || echo "")
  if [ -n "$STORE_PATH" ]; then
    rm -rf "$STORE_PATH"
  fi
fi

# Remove pnpm CLI installed via npm
if npm list -g pnpm >/dev/null 2>&1; then
  echo "🗑 Removing pnpm installed via npm..."
  npm uninstall -g pnpm
fi

# Remove pnpm CLI installed via Homebrew
if brew list pnpm >/dev/null 2>&1; then
  echo "🗑 Removing pnpm installed via Homebrew..."
  brew uninstall pnpm
fi

# Remove pnpm CLI installed via standalone script
if [ -n "${PNPM_HOME:-}" ]; then
  echo "🗑 Removing pnpm installed via standalone script..."
  rm -rf "$PNPM_HOME"
fi

# Remove PNPM_HOME from shell configs
echo "🧹 Cleaning PNPM_HOME from shell configuration files..."
for file in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.config/fish/config.fish"; do
  remove_line_from_file 'export PNPM_HOME' "$file"
done

# ------------------------------
# 2. Disable corepack
# ------------------------------
echo "🧰 Disabling corepack..."

if command -v corepack >/dev/null 2>&1; then
  echo "🛑 Disabling corepack..."
  corepack disable || true

  # Remove corepack shims
  echo "🗑 Removing corepack shims..."
  rm -rf "$HOME/.node/corepack"
fi

# ------------------------------
# 3. Uninstall fnm
# ------------------------------
echo "🧹 Uninstalling fnm..."

# Remove fnm installed via Homebrew
if brew list fnm >/dev/null 2>&1; then
  echo "🗑 Removing fnm installed via Homebrew..."
  brew uninstall fnm
fi

# Remove fnm directory
echo "🗑 Removing fnm directory..."
rm -rf "$HOME/.fnm"

# Remove fnm initialization from shell configs
echo "🧹 Cleaning fnm initialization from shell configuration files..."
FNM_INIT='eval "$(fnm env --use-on-cd)"'
for file in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.config/fish/config.fish"; do
  remove_line_from_file "$FNM_INIT" "$file"
done

echo "✅ Uninstallation complete!"
