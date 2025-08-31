#!/bin/bash
# Common functions and utilities for Linux Automation Suite

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Set default values
LOG_LEVEL=${LOG_LEVEL:-"info"}
LOG_FILE="${LOG_FILE:-/var/log/linux-automation-suite.log}"
CONFIG_DIR="${CONFIG_DIR:-$(pwd)/config}"

# Create log directory if it doesn't exist
mkdir -p "$(dirname "$LOG_FILE")"

# Logging functions
log() {
    local level="$1"
    local message="$2"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Log to file
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    
    # Log to console based on log level
    case "${level,,}" in
        debug)
            if [[ "${LOG_LEVEL,,}" == "debug" ]]; then
                echo -e "${BLUE}[DEBUG]${NC} $message"
            fi
            ;;
        info)
            if [[ "${LOG_LEVEL,,}" == "debug" || "${LOG_LEVEL,,}" == "info" ]]; then
                echo -e "${GREEN}[INFO]${NC} $message"
            fi
            ;;
        warn|warning)
            if [[ "${LOG_LEVEL,,}" != "error" ]]; then
                echo -e "${YELLOW}[WARN]${NC} $message"
            fi
            ;;
        error)
            echo -e "${RED}[ERROR]${NC} $message" >&2
            ;;
        *)
            echo -e "$message"
            ;;
    esac
}

# Convenience logging functions
log_debug() { log "DEBUG" "$1"; }
log_info() { log "INFO" "$1"; }
log_warn() { log "WARNING" "$1"; }
log_error() { log "ERROR" "$1"; }
log_success() { log_info "✅ $1"; }

# Error handling
error() {
    log_error "$1"
    [[ "$2" != "noexit" ]] && exit 1
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root. Use 'sudo' or run as root."
    fi
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Parse YAML file
# Usage: eval "$(parse_yaml path/to/file.yaml "prefix_")"
parse_yaml() {
    local prefix=$2
    local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
    sed -ne "s|^\\($s\\)\\($w\\)$s:$s\"\(.*\)\"$s\\$|\\1$fs\\2$fs\\3|p" \
        -e "s|^\\($s\\)\\($w\\)$s:$s\\(.*\\)$s\\$|\\1$fs\\2$fs\\3|p" "$1" |
    awk -F$fs '{
        indent = length($1)/2;
        vname[indent] = $2;
        for (i in vname) {if (i > indent) {delete vname[i]}}
        if (length($3) > 0) {
            vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
            printf("%s%s%s=\"%s\"\n", "'$prefix'", vn, $2, $3);
        }
    }'
}

# Check if running on a supported distribution
check_distribution() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
        VERSION_ID=$VERSION_ID
        DISTRO_FAMILY=""
        
        # Map to distribution families
        case $ID in
            ubuntu|debian|linuxmint|pop)
                DISTRO_FAMILY="debian"
                ;;
            fedora|centos|rhel|amzn|ol|rocky|almalinux)
                DISTRO_FAMILY="rhel"
                ;;
            arch|manjaro)
                DISTRO_FAMILY="arch"
                ;;
            *)
                DISTRO_FAMILY="other"
                ;;
        esac
    else
        error "Could not detect Linux distribution. Unsupported system."
    fi
    
    log_debug "Detected distribution: $DISTRO $VERSION_ID ($DISTRO_FAMILY)"
}

# Install package using the appropriate package manager
install_package() {
    local pkg=$1
    
    if [ -z "$DISTRO_FAMILY" ]; then
        check_distribution
    fi
    
    log_info "Installing package: $pkg"
    
    case $DISTRO_FAMILY in
        debian)
            sudo apt-get update && sudo apt-get install -y "$pkg"
            ;;
        rhel)
            if command -v dnf &> /dev/null; then
                sudo dnf install -y "$pkg"
            else
                sudo yum install -y "$pkg"
            fi
            ;;
        arch)
            sudo pacman -S --noconfirm "$pkg"
            ;;
        *)
            error "Unsupported distribution family: $DISTRO_FAMILY"
            ;;
    esac
}

# Check if a service is running
is_service_running() {
    local service=$1
    if systemctl is-active --quiet "$service"; then
        return 0
    else
        return 1
    fi
}

# Enable and start a service
enable_service() {
    local service=$1
    log_info "Enabling and starting $service service"
    
    if command_exists systemctl; then
        sudo systemctl enable "$service"
        sudo systemctl start "$service"
    elif command_exists service; then
        sudo service "$service" start
        sudo chkconfig "$service" on
    else
        log_warn "Could not enable service $service - service management not found"
        return 1
    fi
}

# Check if a command succeeded
check_success() {
    if [ $? -ne 0 ]; then
        error "Command failed: $1"
    fi
}

# Create a backup of a file with timestamp
backup_file() {
    local file=$1
    local timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)
    
    if [ -f "$file" ]; then
        log_info "Creating backup of $file to ${file}.bak.${timestamp}"
        cp "$file" "${file}.bak.${timestamp}"
    fi
}

# Add line to file if it doesn't exist
add_line_to_file() {
    local line=$1
    local file=$2
    
    if ! grep -qF "$line" "$file" 2>/dev/null; then
        log_info "Adding line to $file: $line"
        echo "$line" | sudo tee -a "$file" > /dev/null
    else
        log_debug "Line already exists in $file: $line"
    fi
}

# Create directory with proper permissions
create_directory() {
    local dir=$1
    local owner=${2:-$USER}
    local perms=${3:-0755}
    
    if [ ! -d "$dir" ]; then
        log_info "Creating directory: $dir"
        sudo mkdir -p "$dir"
        sudo chown "$owner" "$dir"
        sudo chmod "$perms" "$dir"
    else
        log_debug "Directory already exists: $dir"
    fi
}

# Check if a package is installed
is_package_installed() {
    if [ -z "$DISTRO_FAMILY" ]; then
        check_distribution
    fi
    
    case $DISTRO_FAMILY in
        debian)
            dpkg -l "$1" &> /dev/null
            ;;
        rhel|arch)
            rpm -q "$1" &> /dev/null
            ;;
        *)
            command -v "$1" &> /dev/null
            ;;
    esac
}

# Initialize the environment
init_environment() {
    check_distribution
    log_info "Initializing environment for $DISTRO $VERSION_ID"
}
