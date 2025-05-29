#!/usr/bin/env zsh
set -euo pipefail

echo "🍺 Checking Homebrew..."
if ! command -v brew >/dev/null; then
  echo "❌ Homebrew not found. Please install Homebrew first: https://brew.sh"
  exit 1
fi

echo "📦 Installing fnm via Homebrew..."
brew install fnm

# --- Shell Configuration ---
SHELL_NAME="$(basename "$SHELL")"
FNM_INIT='eval "$(fnm env --use-on-cd --shell zsh)"'
SHELL_CONFIG_FILE=SHELL_CONFIG_FILE="$HOME/.zshrc"

echo "🔧 Configuring fnm for your shell..."

# Ensure the shell configuration file exists
if [ ! -f "$SHELL_CONFIG_FILE" ]; then
  echo "ℹ️  Creating shell configuration file: $SHELL_CONFIG_FILE"
  mkdir -p "$(dirname "$SHELL_CONFIG_FILE")"
  touch "$SHELL_CONFIG_FILE"
fi

# Add fnm initialization if not already present
if ! grep -Fxq "$FNM_INIT" "$SHELL_CONFIG_FILE"; then
  echo "🔧 Adding fnm initialization to $SHELL_CONFIG_FILE"
  echo -e "\n# Initialize fnm (Fast Node Manager)" >> "$SHELL_CONFIG_FILE"
  echo "$FNM_INIT" >> "$SHELL_CONFIG_FILE"
  echo "✅ fnm initialization added to $SHELL_CONFIG_FILE."
else
  echo "✅ fnm initialization already present in $SHELL_CONFIG_FILE"
fi

# Apply fnm to current shell session
echo "🚀 Applying fnm to current shell session..."
eval "$FNM_INIT"

echo "📥 Installing latest LTS version of Node.js..."
if ! fnm list | grep -q 'lts-latest'; then
  fnm install lts-latest
fi

echo "🌍 Setting latest LTS as default Node version..."
fnm default lts-latest 

echo "📦 Using latest LTS Node in current session..."
fnm use lts-latest

echo "🧪 Verifying Node and npm..."
node -v
npm -v

echo "🧹 Enabling Corepack (built into Node >=16.10)..."
corepack enable

echo "📦 Installing pnpm via Corepack (no global pollution)..."
corepack prepare pnpm@latest --activate

echo ""
echo "🎉 Setup Complete! 🎉"
echo "  - fnm version:     $(fnm --version)"
echo "  - Node.js version: $(node -v)"
echo "  - npm version:     $(npm -v)"
echo "  - pnpm version:    $(pnpm -v)"
echo ""
echo "👉 IMPORTANT: To ensure fnm is available in all new terminal sessions:"
echo "   - Open a new terminal window, or"
echo "   - Source your shell configuration file:"
echo "     source $SHELL_CONFIG_FILE"