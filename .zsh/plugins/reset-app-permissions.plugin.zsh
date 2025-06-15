# reset-app-permissions.plugin.zsh
# Zsh plugin to reset macOS app permissions (using bash-compatible syntax)

# ANSI Color codes (bash style)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Main function (bash-style syntax)
reset-app-permissions() {
    # Check if app name is provided
    if [ $# -eq 0 ]; then
        print -P "${RED}ERROR:${NC} Usage: reset-app-permissions \"Application Name\""
        print -P "${CYAN}Example:${NC} reset-app-permissions \"Google Chrome\""
        return 1
    fi

    local APP_NAME="$1"

    print -P "${BLUE}Getting bundle identifier for:${NC} ${BOLD}$APP_NAME${NC}"

    # Get bundle identifier using osascript
    local BUNDLE_ID=$(osascript -e "id of app \"$APP_NAME\"" 2>/dev/null)

    # Check if bundle identifier was found (bash style)
    if [ $? -ne 0 ] || [ -z "$BUNDLE_ID" ]; then
        print -P "${RED}ERROR:${NC} Could not find bundle identifier for ${BOLD}'$APP_NAME'${NC}"
        print -P "${YELLOW}Please check that the application name is correct and the app is installed.${NC}"
        return 1
    fi

    print -P "${GREEN}SUCCESS:${NC} Bundle identifier found: ${MAGENTA}$BUNDLE_ID${NC}"
    print
    print -P "${YELLOW}WARNING:${NC} This will reset ${RED}ALL${NC} privacy permissions for ${BOLD}$APP_NAME${NC} (${MAGENTA}$BUNDLE_ID${NC})"
    print -P "${CYAN}INFO:${NC} The app will need to request permissions again when you next use it."
    print

    # Get user confirmation (single keypress)
    local response
    print -n "${WHITE}CONFIRM:${NC} Are you sure you want to reset all permissions for this app? ${BOLD}(y/N):${NC} "
    
    # Read single character without requiring Enter
    if [[ -n "$ZSH_VERSION" ]]; then
        read -k 1 response
    else
        read -n 1 response
    fi
    print  # Add newline after the single character input

    case "$response" in
        [yY]|[yY][eE][sS])
            print -P "${BLUE}PROCESSING:${NC} Resetting permissions for ${BOLD}$APP_NAME${NC}..."
            tccutil reset All "$BUNDLE_ID"
            
            if [ $? -eq 0 ]; then
                print -P "${GREEN}SUCCESS:${NC} Successfully reset permissions for ${BOLD}$APP_NAME${NC}"
                print -P "${CYAN}NOTE:${NC} You may need to quit and restart the application for changes to take effect."
            else
                print -P "${RED}FAILED:${NC} Could not reset permissions. ${YELLOW}You may need to run with sudo.${NC}"
            fi
            ;;
        *)
            print -P "${YELLOW}CANCELLED:${NC} Operation cancelled by user."
            return 0
            ;;
    esac
}

# Alias for shorter command
alias rap='reset-app-permissions'

# Tab completion function (bash-compatible)
_reset_app_permissions() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    
    # For zsh, we need to handle completion differently
    if [[ -n "$ZSH_VERSION" ]]; then
        local context state line
        
        if [[ $CURRENT -eq 2 ]]; then
            # Get list of installed applications
            local apps=()
            
            # Add applications from /Applications
            while IFS= read -r -d '' app; do
                apps+=("$(basename "$app" .app)")
            done < <(find /Applications -maxdepth 2 -name "*.app" -type d -print0 2>/dev/null)
            
            # Add system applications
            while IFS= read -r -d '' app; do
                apps+=("$(basename "$app" .app)")
            done < <(find /System/Applications -maxdepth 2 -name "*.app" -type d -print0 2>/dev/null)
            
            _describe 'applications' apps
        fi
    else
        # Fallback for bash completion
        local apps=$(find /Applications /System/Applications -maxdepth 2 -name "*.app" -type d 2>/dev/null | sed 's|.*/||g' | sed 's|\.app||g' | sort -u)
        COMPREPLY=($(compgen -W "$apps" -- "$cur"))
    fi
}

# Register completion function
if [[ -n "$ZSH_VERSION" ]]; then
    compdef _reset_app_permissions reset-app-permissions
    compdef _reset_app_permissions rap
elif [[ -n "$BASH_VERSION" ]]; then
    complete -F _reset_app_permissions reset-app-permissions
    complete -F _reset_app_permissions rap
fi