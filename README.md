# Dotfiles Setup for macOS

This repository contains a script to automate the setup of dotfiles on macOS, including development tools, Git configuration, and custom system settings. The script is designed to streamline the process of configuring a new macOS machine with a consistent development environment.

## Features

- **Automated Installation**: Installs Xcode Command Line Tools, Homebrew, Git, and Git Credential Manager.
- **Dotfiles Management**: Clones a bare Git repository to manage dotfiles in the home directory without clutter.
- **Backup System**: Automatically backs up existing dotfiles to prevent data loss.
- **Encrypted Files**: Supports `git-crypt` for securely managing sensitive configuration files.
- **Custom macOS Settings**: Applies optional macOS configurations via a `.macos` script.
- **Extensible**: Runs post-install scripts from a `.dotfiles.d` directory for additional customization.
- **Interactive**: Prompts for user input where needed (e.g., Git configuration, terminal restart).

## Prerequisites

- macOS system (the script checks for macOS explicitly)
- Internet connection for downloading tools and cloning the repository
- Optional: A `git-crypt` key file if encrypted files are used

## Installation

Run the following command to execute the setup script:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/uybinhphan/dotfiles/main/setup-dotfiles.sh)"
```

This command downloads and runs the `setup-dotfiles.sh` script from this repository.

### What the Script Does

1. **System Check**: Verifies the system is running macOS.
2. **Tool Installation**:
   - Installs Xcode Command Line Tools.
   - Installs Homebrew (if not present) and updates it.
   - Installs Git and Git Credential Manager.
3. **Git Configuration**:
   - Prompts for Git user name and email (if not already configured).
   - Sets up sensible Git defaults (e.g., `main` as default branch, `vim` as editor).
4. **Dotfiles Setup**:
   - Clones the dotfiles repository to `~/.dotfiles` as a bare Git repository.
   - Backs up existing dotfiles to a timestamped directory (e.g., `~/.dotfiles-backup-YYYYMMDDHHMMSS`).
   - Checks out dotfiles to the home directory.
   - Adds a `dotfiles` alias to `.zshrc` for easy Git management.
5. **Dependencies**:
   - Installs packages listed in a `.Brewfile` (if present).
   - Installs `git-crypt` for encrypted file support.
6. **Encrypted Files**:
   - Checks for `git-crypt` configuration and prompts for a key file to unlock encrypted files (if applicable).
7. **macOS Configuration**:
   - Runs a `.macos` script (if present) to apply system settings.
8. **Post-Install**:
   - Executes any executable scripts in `~/.dotfiles.d/` for additional setup.
9. **Finalization**:
   - Prompts to restart the terminal to apply changes.

## Usage

After installation, manage your dotfiles using the `dotfiles` alias:

```bash
dotfiles status
dotfiles add .zshrc
dotfiles commit -m "Update zsh configuration"
dotfiles push
```

To unlock encrypted files later (if you skipped it during setup):

```bash
dotfiles git-crypt unlock /path/to/key
```

## File Structure

The repository expects certain optional files for advanced configuration:

- `.Brewfile`: Specifies Homebrew packages to install.
- `.macos`: Shell script for macOS system settings.
- `.dotfiles.d/*.sh`: Post-install scripts for additional setup.
- `.gitattributes`: Configures `git-crypt` for encrypted files.

Example structure:

```
.dotfiles/
├── .zshrc
├── .gitconfig
├── .Brewfile
├── .macos
├── .dotfiles.d/
│   ├── install_fonts.sh
│   ├── setup_vscode.sh
```

## Customization

To customize the setup:

1. Fork this repository.
2. Modify `setup-dotfiles.sh` or add your dotfiles.
3. Update the `DOTFILES_REPO` URL in the script to point to your fork.
4. Add a `.Brewfile`, `.macos`, or `.dotfiles.d/` scripts as needed.

Example `.Brewfile`:

```
tap "homebrew/cask"
brew "zsh"
brew "tmux"
cask "visual-studio-code"
```

Example `.macos`:

```bash
# Set Dock size
defaults write com.apple.dock tilesize -int 36
# Restart Dock
killall Dock
```

## Backup

Existing dotfiles are backed up to `~/.dotfiles-backup-YYYYMMDDHHMMSS/` if they would be overwritten. Check this directory if you need to restore any files.

## Troubleshooting

- **Script fails on non-macOS systems**: The script is macOS-specific. Use a macOS machine.
- **Git clone errors**: Ensure you have access to the repository and Git Credential Manager is configured.
- **Checkout conflicts**: Check `~/.dotfiles-backup-*/` for backed-up files and manually resolve conflicts.
- **Missing dependencies**: Verify Homebrew is installed and working (`brew doctor`).

## Contributing

1. Fork the repository.
2. Create a feature branch (`git checkout -b feature/my-feature`).
3. Commit your changes (`git commit -am 'Add my feature'`).
4. Push to the branch (`git push origin feature/my-feature`).
5. Open a Pull Request.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.