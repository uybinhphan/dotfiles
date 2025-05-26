#!/bin/bash

# shutdown-timer - A modern CLI tool for setting shutdown timers on macOS
# Version: 1.0.0

set -euo pipefail

readonly SCRIPT_NAME="shutdown-timer"
readonly VERSION="1.0.0"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Global variables
SHUTDOWN_TIME=""
CANCEL_MODE=false
STATUS_MODE=false
QUIET_MODE=false

# Error handling
error() {
    echo -e "${RED}Error:${NC} $1" >&2
    exit 1
}

warning() {
    [[ "$QUIET_MODE" == true ]] || echo -e "${YELLOW}Warning:${NC} $1" >&2
}

success() {
    [[ "$QUIET_MODE" == true ]] || echo -e "${GREEN}$1${NC}"
}

info() {
    [[ "$QUIET_MODE" == true ]] || echo -e "${BLUE}$1${NC}"
}

# Help text
show_help() {
    cat << EOF
${SCRIPT_NAME} - Set shutdown timers on macOS

USAGE:
    ${SCRIPT_NAME} [TIME] [OPTIONS]
    ${SCRIPT_NAME} [OPTIONS]

ARGUMENTS:
    TIME    Time until shutdown. Formats:
            - Minutes: 30m, 45m
            - Hours: 1h, 2h30m, 1.5h
            - Specific time: 23:30, 11:30pm
            - Relative: +30m, +2h

OPTIONS:
    -c, --cancel     Cancel any scheduled shutdown
    -s, --status     Show current shutdown status
    -q, --quiet      Suppress non-error output
    -h, --help       Show this help message
    -v, --version    Show version information

EXAMPLES:
    ${SCRIPT_NAME} 30m          # Shutdown in 30 minutes
    ${SCRIPT_NAME} 2h           # Shutdown in 2 hours
    ${SCRIPT_NAME} 23:30        # Shutdown at 11:30 PM
    ${SCRIPT_NAME} 1h30m        # Shutdown in 1 hour 30 minutes
    ${SCRIPT_NAME} --cancel     # Cancel scheduled shutdown
    ${SCRIPT_NAME} --status     # Check shutdown status

NOTES:
    - Requires administrator privileges (will prompt for password)
    - Uses macOS 'shutdown' command internally
    - Canceling requires the same privileges as setting
EOF
}

show_version() {
    echo "${SCRIPT_NAME} version ${VERSION}"
}

# Parse time input and convert to seconds
parse_time() {
    local input="$1"
    local total_seconds=0
    
    # Remove leading + if present (relative time indicator)
    input="${input#+}"
    
    # Handle specific time format (HH:MM or HH:MMam/pm)
    if [[ "$input" =~ ^([0-9]{1,2}):([0-9]{2})(am|pm|AM|PM)?$ ]]; then
        local hour="${BASH_REMATCH[1]}"
        local minute="${BASH_REMATCH[2]}"
        local ampm="${BASH_REMATCH[3],,}"  # Convert to lowercase
        
        # Convert 12-hour to 24-hour format
        if [[ -n "$ampm" ]]; then
            if [[ "$ampm" == "pm" && "$hour" -ne 12 ]]; then
                hour=$((hour + 12))
            elif [[ "$ampm" == "am" && "$hour" -eq 12 ]]; then
                hour=0
            fi
        fi
        
        # Calculate seconds until target time
        local target_seconds=$((hour * 3600 + minute * 60))
        local current_seconds=$(date +%s)
        local current_day_seconds=$(date +%H | sed 's/^0//' | xargs -I {} echo "{} * 3600" | bc)
        current_day_seconds=$((current_day_seconds + $(date +%M | sed 's/^0//' | xargs -I {} echo "{} * 60" | bc)))
        
        if [[ "$target_seconds" -le "$current_day_seconds" ]]; then
            # Target time is tomorrow
            target_seconds=$((target_seconds + 86400))
        fi
        
        total_seconds=$((target_seconds - current_day_seconds))
    else
        # Handle relative time format (combinations of hours and minutes)
        # Extract hours
        if [[ "$input" =~ ([0-9]+\.?[0-9]*)h ]]; then
            local hours="${BASH_REMATCH[1]}"
            # Handle decimal hours (e.g., 1.5h)
            if [[ "$hours" =~ \. ]]; then
                total_seconds=$(echo "$hours * 3600" | bc | cut -d. -f1)
            else
                total_seconds=$((hours * 3600))
            fi
        fi
        
        # Extract minutes
        if [[ "$input" =~ ([0-9]+)m ]]; then
            local minutes="${BASH_REMATCH[1]}"
            total_seconds=$((total_seconds + minutes * 60))
        fi
        
        # If no h or m suffix, assume minutes
        if [[ ! "$input" =~ [hm] && "$input" =~ ^[0-9]+$ ]]; then
            total_seconds=$((input * 60))
        fi
    fi
    
    if [[ "$total_seconds" -le 0 ]]; then
        error "Invalid time format: $1"
    fi
    
    echo "$total_seconds"
}

# Format seconds to human readable time
format_duration() {
    local seconds="$1"
    local hours=$((seconds / 3600))
    local minutes=$(((seconds % 3600) / 60))
    local secs=$((seconds % 60))
    
    local result=""
    [[ "$hours" -gt 0 ]] && result="${hours}h "
    [[ "$minutes" -gt 0 ]] && result="${result}${minutes}m "
    [[ "$secs" -gt 0 && "$hours" -eq 0 ]] && result="${result}${secs}s"
    
    echo "${result% }"  # Remove trailing space
}

# Check if shutdown is scheduled
check_shutdown_status() {
    if pgrep -f "shutdown.*[0-9]" > /dev/null 2>&1; then
        info "Shutdown is currently scheduled"
        return 0
    else
        info "No shutdown currently scheduled"
        return 1
    fi
}

# Cancel scheduled shutdown
cancel_shutdown() {
    if ! check_shutdown_status > /dev/null 2>&1; then
        warning "No shutdown timer is currently set"
        return 0
    fi
    
    info "Canceling scheduled shutdown..."
    if sudo killall shutdown 2>/dev/null; then
        success "Shutdown timer canceled successfully"
    else
        error "Failed to cancel shutdown timer"
    fi
}

# Set shutdown timer
set_shutdown_timer() {
    local seconds="$1"
    local duration_str
    duration_str=$(format_duration "$seconds")
    
    info "Setting shutdown timer for $duration_str..."
    
    # Calculate target time for display
    local target_time
    target_time=$(date -r $(($(date +%s) + seconds)) "+%H:%M:%S on %Y-%m-%d")
    
    # Use shutdown command with timer
    if sudo shutdown -h +"$((seconds / 60))" 2>/dev/null; then
        success "Shutdown scheduled for $target_time"
        info "System will shutdown in $duration_str"
        info "Use '${SCRIPT_NAME} --cancel' to cancel the shutdown"
    else
        error "Failed to schedule shutdown"
    fi
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--version)
                show_version
                exit 0
                ;;
            -c|--cancel)
                CANCEL_MODE=true
                shift
                ;;
            -s|--status)
                STATUS_MODE=true
                shift
                ;;
            -q|--quiet)
                QUIET_MODE=true
                shift
                ;;
            -*)
                error "Unknown option: $1"
                ;;
            *)
                if [[ -n "$SHUTDOWN_TIME" ]]; then
                    error "Multiple time arguments provided"
                fi
                SHUTDOWN_TIME="$1"
                shift
                ;;
        esac
    done
}

# Validate environment
validate_environment() {
    # Check if running on macOS
    if [[ "$(uname)" != "Darwin" ]]; then
        error "This tool is designed for macOS only"
    fi
    
    # Check if shutdown command exists
    if ! command -v shutdown &> /dev/null; then
        error "shutdown command not found"
    fi
}

# Main function
main() {
    validate_environment
    parse_args "$@"
    
    # Handle different modes
    if [[ "$CANCEL_MODE" == true ]]; then
        cancel_shutdown
        exit 0
    fi
    
    if [[ "$STATUS_MODE" == true ]]; then
        check_shutdown_status
        exit $?
    fi
    
    # If no time provided, show help
    if [[ -z "$SHUTDOWN_TIME" ]]; then
        echo "Error: No time specified" >&2
        echo ""
        show_help
        exit 1
    fi
    
    # Parse and set timer
    local seconds
    seconds=$(parse_time "$SHUTDOWN_TIME")
    set_shutdown_timer "$seconds"
}

# Run main function with all arguments
main "$@"