#!/bin/bash
# Post-Installation Bootstrap Script
# Description: Complete initial system setup after fresh OS installation
# Author: Linux Automation Suite
# Version: 1.0.0

set -euo pipefail

# Source common functions
source "$(dirname "$0")/../lib/common.sh"

# Load configuration
CONFIG_FILE="${CONFIG_DIR}/bootstrap.yaml"
if [[ ! -f "$CONFIG_FILE" ]]; then
    error "Configuration file $CONFIG_FILE not found"
    exit 1
fi

# Parse YAML configuration
eval "$(parse_yaml "$CONFIG_FILE" "bootstrap_")"

# Main function
main() {
    log_info "Starting system bootstrap process"
    
    # Update system packages
    update_system
    
    # Install essential packages
    install_essentials
    
    # Configure system settings
    configure_system
    
    log_success "Bootstrap process completed successfully"
}

# System update function
update_system() {
    log_info "Updating system packages..."
    
    if command -v apt-get &> /dev/null; then
        sudo apt-get update && sudo apt-get upgrade -y
    elif command -v dnf &> /dev/null; then
        sudo dnf update -y
    elif command -v yum &> /dev/null; then
        sudo yum update -y
    else
        error "Unsupported package manager"
        exit 1
    fi
}

# Install essential packages
install_essentials() {
    log_info "Installing essential packages..."
    
    local packages=(
        "git"
        "curl"
        "wget"
        "vim"
        "htop"
        "tmux"
        "zsh"
        "unzip"
    )
    
    if command -v apt-get &> /dev/null; then
        sudo apt-get install -y "${packages[@]}"
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y "${packages[@]}"
    elif command -v yum &> /dev/null; then
        sudo yum install -y "${packages[@]}"
    fi
}

# System configuration
configure_system() {
    log_info "Configuring system settings..."
    
    # Set timezone
    if [[ -n "${bootstrap_timezone:-}" ]]; then
        sudo timedatectl set-timezone "$bootstrap_timezone"
    fi
    
    # Configure hostname if specified
    if [[ -n "${bootstrap_hostname:-}" ]]; then
        sudo hostnamectl set-hostname "$bootstrap_hostname"
    fi
    
    # Configure locale
    if [[ -n "${bootstrap_locale:-}" ]]; then
        sudo localectl set-locale LANG="$bootstrap_locale"
    fi
}

# Run main function
main "$@"
