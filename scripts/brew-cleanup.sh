#!/bin/zsh

# brew-cleanup.zsh
# A CLI tool to clean up Homebrew by removing unused dependencies and outdated downloads.

set -euo pipefail

# Initialize flags
VERBOSE=false
DRY_RUN=false
USE_COLOR=true

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      SHOW_HELP=true
      shift
      ;;
    -v|--verbose)
      VERBOSE=true
      shift
      ;;
    -n|--dry-run)
      DRY_RUN=true
      shift
      ;;
    --no-color)
      USE_COLOR=false
      shift
      ;;
    -*)
      echo "Unknown option: $1"
      exit 1
      ;;
    *)
      echo "Unknown argument: $1"
      exit 1
      ;;
  esac
done

# Define color variables based on USE_COLOR
if $USE_COLOR; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  BLUE='\033[0;34m'
  NC='\033[0m' # No Color / Reset
else
  RED=''
  GREEN=''
  YELLOW=''
  BLUE=''
  NC=''
fi

# Function to display help information
show_help() {
  cat << EOF
Usage: brew-cleanup.zsh [options]

Options:
  -h, --help       Show this help message and exit.
  -v, --verbose    Display detailed output.
  -n, --dry-run    Simulate the cleanup process without making changes.
      --no-color   Disable colored output.

Description:
  This script performs the following Homebrew maintenance tasks:
    - Removes unused dependencies.
    - Cleans up outdated downloads and old versions of installed formulae.

Commands Executed:
  brew autoremove
  brew cleanup --prune=all
EOF
}

# Display help if requested
if [[ "${SHOW_HELP:-false}" == true ]]; then
  show_help
  exit 0
fi

# Function to execute or simulate commands
run_cmd() {
  if $DRY_RUN; then
    echo "${YELLOW}[DRY-RUN]${NC} $*"
  else
    if $VERBOSE; then
      echo "${BLUE}[EXECUTING]${NC} $*"
    fi
    eval "$@"
  fi
}

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
  echo "${RED}Error: Homebrew is not installed. Please install Homebrew first.${NC}"
  exit 1
fi

# Perform Homebrew maintenance tasks
echo "${BLUE}Starting Homebrew cleanup process...${NC}"

echo "${YELLOW}Removing unused dependencies...${NC}"
run_cmd brew autoremove

echo "${YELLOW}Cleaning up outdated downloads and old versions...${NC}"
run_cmd brew cleanup --prune=all

echo "${GREEN}Homebrew cleanup process completed successfully.${NC}"
