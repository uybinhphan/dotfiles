#!/usr/bin/env bash
# setup-dotfiles.sh - One-command dotfiles installation script for macOS
# Usage: /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/uybinhphan/dotfiles/main/.config/dotfiles/setup-dotfiles.sh)"

set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
DOTFILES_REPO="https://github.com/uybinhphan/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d%H%M%S)"

# Log functions
log_header() { echo -e "\n${CYAN}==>${NC} ${BLUE}$1${NC}"; }
log_info() { echo -e "${BLUE}INFO:${NC} $1"; }
log_success() { echo -e "${GREEN}SUCCESS:${NC} $1"; }
log_warning() { echo -e "${YELLOW}WARNING:${NC} $1"; }
log_error() { echo -e "${RED}ERROR:${NC} $1"; exit 1; }

# Check if running on macOS
check_macos() {
    log_header "Checking system"
    if [[ "$(uname)" != "Darwin" ]]; then
        log_error "This script is designed for macOS only."
    fi
    log_success "Running on macOS $(sw_vers -productVersion)"
}

# Install Xcode Command Line Tools
install_xcode_tools() {
    log_header "Installing Xcode Command Line Tools"
    
    # Check if already installed
    if xcode-select -p &>/dev/null; then
        log_success "Xcode Command Line Tools already installed"
        return
    fi
    
    # Install Xcode CLI tools
    log_info "Installing Xcode Command Line Tools..."
    xcode-select --install &>/dev/null
    
    # Wait until the tools are installed
    log_info "Waiting for Xcode Command Line Tools installation to complete..."
    until xcode-select -p &>/dev/null; do
        sleep 2
    done
    
    # Accept license
    sudo xcodebuild -license accept
    log_success "Xcode Command Line Tools installed"
}

# Install Homebrew
install_homebrew() {
    log_header "Installing Homebrew"
    
    if command -v brew &>/dev/null; then
        log_success "Homebrew already installed"
    else
        log_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH based on chip architecture
        if [[ "$(uname -m)" == "arm64" ]]; then
            # For Apple Silicon
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            # For Intel
            echo 'eval "$(/usr/local/bin/brew shellenv)"' >> "$HOME/.zprofile"
            eval "$(/usr/local/bin/brew shellenv)"
        fi
        
        log_success "Homebrew installed"
    fi
    
    # Update Homebrew
    log_info "Updating Homebrew..."
    brew update
}

# Install Git
install_git() {
    log_header "Installing Git"
    
    if command -v git &>/dev/null; then
        log_success "Git already installed: $(git --version)"
    else
        log_info "Installing Git..."
        brew install git
        log_success "Git installed: $(git --version)"
    fi
}

install_git_credential_manager() {
    log_header "Installing Git Credential Manager"
    
    if command -v git-credential-manager &>/dev/null; then
        log_success "Git Credential Manager already installed"
    else
        log_info "Installing Git Credential Manager..."
        if ! brew install git-credential-manager; then
            log_error "Failed to install Git Credential Manager"
        fi
        log_success "Git Credential Manager installed"
    fi

    # Check if GCM is already configured as a credential helper
    log_info "Configuring Git to use Git Credential Manager..."
    if git config --global --get-all credential.helper | grep -q "manager"; then
        log_success "Git Credential Manager already configured as a credential helper"
    else
        if ! git config --global --add credential.helper manager; then
            log_error "Failed to configure Git Credential Manager as a credential helper"
        fi
        log_success "Git Credential Manager added as a credential helper"
    fi
}

clone_dotfiles() {
    log_header "Setting up dotfiles repository"
    
    # Define the dotfiles alias
    function dotfiles {
        /usr/bin/git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" "$@"
    }
    
    # Export the function for subshells
    export -f dotfiles

    # Verify GCM is configured
    if ! git config --global --get-all credential.helper | grep -q "manager"; then
        log_warning "Git Credential Manager not configured. Attempting to configure now..."
        if ! git config --global --add credential.helper manager; then
            log_error "Failed to configure Git Credential Manager"
        fi
    fi
    
    if [[ -d "$DOTFILES_DIR" ]]; then
        log_warning "Dotfiles directory already exists at $DOTFILES_DIR"
        read -p "Would you like to remove it and clone again? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            log_info "Removing existing dotfiles directory..."
            rm -rf "$DOTFILES_DIR"
        else
            log_info "Using existing dotfiles directory"
            # Verify the existing directory is a valid bare repository
            if ! dotfiles rev-parse --is-bare-repository &>/dev/null; then
                log_error "Existing $DOTFILES_DIR is not a valid bare Git repository"
            fi
            # Configure the existing repository
            dotfiles config --local status.showUntrackedFiles no
            log_success "Using existing dotfiles repository"
            return
        fi
    fi
    
    log_info "Cloning dotfiles repository to $DOTFILES_DIR..."
    if ! git clone --bare "$DOTFILES_REPO" "$DOTFILES_DIR"; then
        log_error "Failed to clone dotfiles repository. Please check your credentials and repository URL."
    fi
    
    
    # Hide untracked files
    dotfiles config --local status.showUntrackedFiles no
    
    log_success "Dotfiles repository cloned"
}

# Backup existing dotfiles
backup_existing_dotfiles() {
    log_header "Checking for conflicts with existing dotfiles"
    
    # Check if dotfiles command is available and repository exists
    if ! command -v dotfiles &>/dev/null || ! [[ -d "$DOTFILES_DIR" ]] || ! dotfiles rev-parse --is-bare-repository &>/dev/null; then
        log_error "Dotfiles repository not set up correctly at $DOTFILES_DIR. Cannot check for conflicts."
    fi
    
    # Get a list of tracked files in the dotfiles repo
    local tracked_files
    tracked_files=$(dotfiles ls-tree -r main --name-only 2>/dev/null || dotfiles ls-tree -r master --name-only)
    
    if [[ -z "$tracked_files" ]]; then
        log_warning "No tracked files found in the repository. Is the repository empty?"
        return
    fi
    
    # Check each tracked file for conflicts
    local has_conflicts=false
    while IFS= read -r file; do
        file="$HOME/$file"
        if [[ -e "$file" && ! -L "$file" ]]; then
            has_conflicts=true
            break
        fi
    done <<< "$tracked_files"
    
    # If we found conflicts
    if [[ "$has_conflicts" == "true" ]]; then
        log_warning "Found existing dotfiles that would be overwritten"
        mkdir -p "$BACKUP_DIR"
        
        while IFS= read -r file; do
            local full_path="$HOME/$file"
            if [[ -e "$full_path" && ! -L "$full_path" ]]; then
                log_info "Backing up $full_path to $BACKUP_DIR/"
                mkdir -p "$(dirname "$BACKUP_DIR/$file")"
                mv "$full_path" "$BACKUP_DIR/$file"
            fi
        done <<< "$tracked_files"
        
        log_success "Existing dotfiles backed up to $BACKUP_DIR"
    else
        log_success "No conflicts found"
    fi
}

# Apply dotfiles
apply_dotfiles() {
    log_header "Applying dotfiles"
    
    log_info "Checking out dotfiles to home directory..."
    if ! dotfiles checkout; then
        log_error "Failed to checkout dotfiles. Please check for conflicts."
    fi

    log_success "Dotfiles applied successfully"
}

# Set up dotfiles alias
setup_dotfiles_alias() {
    log_header "Setting up dotfiles alias"
    
    local shell_config="$HOME/.zshrc"
    if [[ ! -f "$shell_config" ]]; then
        log_info "Creating .zshrc file..."
        touch "$shell_config"
    fi
    
    if ! grep -q "alias dotfiles=" "$shell_config"; then
        log_info "Adding dotfiles alias to $shell_config..."
        echo 'alias dotfiles="/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"' >> "$shell_config"
        log_success "Dotfiles alias added to $shell_config"
    else
        log_success "Dotfiles alias already exists in $shell_config"
    fi
}

# Install additional dependencies
install_dependencies() {
    log_header "Installing additional dependencies"
    
    # Check if Brewfile exists
    if [[ -f "$HOME/.config/dotfiles/Brewfile" ]]; then
        log_info "Installing packages from Brewfile..."
        brew bundle --file="$HOME/.config/dotfiles/Brewfile"
        log_success "Brewfile packages installed"
    else
        log_warning "No Brewfile found at $HOME/.config/dotfiles/Brewfile"
    fi
    
    # Install git-crypt for encrypted files
    if ! command -v git-crypt &>/dev/null; then
        log_info "Installing git-crypt for encrypted files..."
        brew install git-crypt
        log_success "git-crypt installed"
    else
        log_success "git-crypt already installed"
    fi


}

# Install uv
install_uv() {
    log_header "Installing uv"

    if brew list uv &>/dev/null; then
        log_success "uv already installed"
    else
        log_info "Installing uv..."
        brew install uv
        log_success "uv installed"
    fi
}

# Set up encrypted files
setup_encrypted_files() {
    log_header "Setting up encrypted files"
    
    # Check if git-crypt is initialized in the repository
    if dotfiles ls-files | grep -q ".gitattributes" && dotfiles show HEAD:.gitattributes | grep -q "filter=git-crypt"; then
        log_info "Repository has git-crypt configured"
        
        # Ask for the encryption key
        log_info "To unlock encrypted files, you need the git-crypt key"
        read -p "Do you have the git-crypt key file? (y/n) " -n 1 -r
        echo
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            read -p "Enter the path to your git-crypt key file: " key_path
            
            if [[ -f "$key_path" ]]; then
                log_info "Unlocking encrypted files..."
                dotfiles git-crypt unlock "$key_path"
                log_success "Encrypted files unlocked"
            else
                log_error "Key file not found at $key_path"
            fi
        else
            log_warning "Encrypted files will remain locked"
            log_info "To unlock later, use: dotfiles git-crypt unlock /path/to/key"
        fi
    else
        log_info "No git-crypt configuration found in the repository"
    fi
}

# Configure macOS settings
configure_macos() {
    log_header "Configuring macOS settings"
    
    if [[ -f "$HOME/.config/dotfiles/.macos" ]]; then
        log_info "Applying macOS settings from .macos script..."
        source "$HOME/.config/dotfiles/.macos"
        log_success "macOS settings applied"
    else
        log_warning "No .macos configuration script found"
    fi
}

# Run post-install hooks
run_post_install() {
    log_header "Running post-installation scripts"
    
    if [[ -d "$HOME/.config/dotfiles/scripts" ]]; then
        for script in "$HOME/.config/dotfiles/scripts"/*.sh; do
            if [[ -f "$script" && -x "$script" ]]; then
                log_info "Running post-install script: $(basename "$script")..."
                "$script"
                log_success "Completed: $(basename "$script")"
            fi
        done
    else
        log_info "No post-installation scripts found"
    fi
}

# Main function
main() {
    echo -e "${CYAN}=======================================${NC}"
    echo -e "${CYAN}     macOS Dotfiles Bootstrap Script    ${NC}"
    echo -e "${CYAN}=======================================${NC}"
    
    # Initial setup
    check_macos
    install_xcode_tools
    install_homebrew
    install_git
    install_git_credential_manager

    # Dotfiles setup
    clone_dotfiles
    backup_existing_dotfiles
    apply_dotfiles
    setup_dotfiles_alias
    
    # Additional setup
    install_dependencies
    install_uv
    setup_encrypted_files
    configure_macos
    run_post_install
    
    log_header "Bootstrap complete!"
    log_success "Your dotfiles have been set up successfully."
    log_info "To use your new configuration, restart your terminal or run:"
    echo -e "    ${YELLOW}source ~/.zshrc${NC}"
    
    # Ask if the user wants to restart the terminal
    read -p "Would you like to restart your terminal now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        exec "$SHELL" -l
    fi
}

# Run the main function
main "$@"