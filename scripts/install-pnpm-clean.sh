#!/usr/bin/env bash

# CURRENTLY NOT USING IN MY SETUP
# Using `fnm` so won't use `nvm` 

set -e

# Optional: Use NVM if available
if [ -s "$HOME/.nvm/nvm.sh" ]; then
  echo "🔁 Loading NVM..."
  source "$HOME/.nvm/nvm.sh"
  nvm use --lts
fi

echo "🔍 Node version: $(node -v)"
echo "🔍 NPM version: $(npm -v)"

# Step 1: Enable Corepack (comes with Node >=16.10)
echo "✅ Enabling Corepack..."
corepack enable

# Step 2: Install PNPM via Corepack (user-scoped)
echo "📦 Installing pnpm via corepack..."
corepack prepare pnpm@latest --activate

# Confirm installation
echo "🎯 pnpm version: $(pnpm -v)"
echo "🎉 pnpm installed successfully (user-local, no global pollution)"
