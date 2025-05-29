#!/usr/bin/env bash
set -euo pipefail

echo "🔍 Step 1: Remove pnpm (Corepack-based)"
corepack disable pnpm 2>/dev/null || echo "⚠️ Corepack not found or pnpm already disabled"
# Remove pnpm global store and cache directories
rm -rf ~/.cache/pnpm 2>/dev/null || true
rm -rf ~/.local/share/pnpm 2>/dev/null || true
rm -rf ~/.pnpm-store 2>/dev/null || true
# Also remove pnpm home directory if it exists
rm -rf ~/.pnpm 2>/dev/null || true
echo "✅ pnpm directories cleaned"

echo "🧹 Step 2: Remove corepack-managed binaries"
rm -rf ~/.node/corepack 2>/dev/null || true
rm -rf ~/.npm/_npx 2>/dev/null || true
# Also clean up other npm cache locations
rm -rf ~/.npm 2>/dev/null || true

echo "🧨 Step 3: Unload and remove NVM"

# Determine the NVM directory path we intend to operate on and eventually remove.
# Store it in a variable that nvm unload won't touch.
NVM_PATH_TO_REMOVE="${NVM_DIR:-$HOME/.nvm}"

# For nvm.sh to work, NVM_DIR needs to be set and exported.
# If NVM_DIR was already set in the environment, respect that.
# Otherwise, use the default.
if [ -z "${NVM_DIR:-}" ]; then
  export NVM_DIR="$HOME/.nvm"
# else NVM_DIR is already set, ensure it's exported
elif ! (export -p | grep -q "declare -x NVM_DIR"); then
  export NVM_DIR
fi


if [ -s "$NVM_DIR/nvm.sh" ]; then
  echo "⚙️ Sourcing NVM to unregister node versions"
  # Temporarily disable errexit for NVM operations
  set +e
  # shellcheck source=/dev/null # NVM_DIR is dynamic
  source "$NVM_DIR/nvm.sh"

  echo "🗑 Removing installed Node versions"
  nvm deactivate >/dev/null 2>&1 || true # Redirect output as it can be noisy
  nvm unload >/dev/null 2>&1 || true   # This will unset the NVM_DIR environment variable
  
  # Re-enable errexit
  set -e
  
  # Remove node versions directory using the path we saved earlier
  echo "🧹 Removing NVM versions directory: $NVM_PATH_TO_REMOVE/versions"
  rm -rf "$NVM_PATH_TO_REMOVE"/versions/node/* 2>/dev/null || true
  rm -rf "$NVM_PATH_TO_REMOVE"/versions 2>/dev/null || true
else
  echo "⚠️ NVM not found at $NVM_PATH_TO_REMOVE (or NVM_DIR was not set)"
fi

echo "🧹 Step 4: Remove NVM files"
# Use the NVM_PATH_TO_REMOVE variable, as NVM_DIR might have been unset by 'nvm unload'
echo "🗑 Removing NVM directory: $NVM_PATH_TO_REMOVE"
rm -rf "$NVM_PATH_TO_REMOVE" 2>/dev/null || true

echo "🧼 Step 5: Clean shell configs"
# Determine sed in-place command based on OS
SED_INPLACE_CMD="sed -i"
if [[ "$(uname)" == "Darwin" ]]; then
  SED_INPLACE_CMD="sed -i ''"
fi

for config_file in ~/.zshrc ~/.bashrc ~/.bash_profile ~/.profile; do
  if [ -f "$config_file" ]; then
    echo "🧽 Cleaning $config_file"
    # Create backup
    cp "$config_file" "${config_file}.bak.$(date +%Y%m%d_%H%M%S)" || true
    
    eval "$SED_INPLACE_CMD '/^[[:space:]]*export NVM_DIR/d' \"$config_file\"" 2>/dev/null || true
    eval "$SED_INPLACE_CMD '/nvm\\.sh/d' \"$config_file\"" 2>/dev/null || true
    eval "$SED_INPLACE_CMD '/bash_completion\\.d\\/nvm/d' \"$config_file\"" 2>/dev/null || true
    eval "$SED_INPLACE_CMD '/bash_completion/d' \"$config_file\"" 2>/dev/null || true
    eval "$SED_INPLACE_CMD '/corepack enable/d' \"$config_file\"" 2>/dev/null || true
    eval "$SED_INPLACE_CMD '/corepack prepare/d' \"$config_file\"" 2>/dev/null || true
    eval "$SED_INPLACE_CMD '/pnpm.*completion/d' \"$config_file\"" 2>/dev/null || true
    eval "$SED_INPLACE_CMD '/PNPM_HOME/d' \"$config_file\"" 2>/dev/null || true
  fi
done

echo "✅ All NVM, pnpm, and Corepack traces (attempted to be) cleaned. You can now install fnm."
echo "🔔 Note: Please restart your terminal or run something like 'source ~/.zshrc' or 'source ~/.bashrc' to apply changes."