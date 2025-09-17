#!/bin/bash
# Security Hardening Script
# Description: Basic Linux security configuration
# Author: Linux Automation Suite
# Version: 1.0.0

set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
source "${ROOT_DIR}/lib/common.sh"

# Load configuration
CONFIG_FILE="${CONFIG_DIR}/security.yaml"
if [[ ! -f "$CONFIG_FILE" ]]; then
    error "Configuration file $CONFIG_FILE not found"
    exit 1
fi

# Main function
main() {
    log_info "Starting security hardening"
    update_system
    configure_ssh
    setup_firewall
    setup_fail2ban
    audit_file_permissions
    configure_audit_logging
    enforce_user_policies
    log_success "Security hardening completed"
}

# Update system packages
update_system() {
    log_info "Updating system..."
    if command -v apt-get &> /dev/null; then
        sudo apt-get update && sudo apt-get upgrade -y
    elif command -v dnf &> /dev/null; then
        sudo dnf update -y
    fi
}

# Configure SSH securely
configure_ssh() {
    log_info "Configuring SSH..."
    local sshd_config="/etc/ssh/sshd_config"
    
    # Backup config
    sudo cp "$sshd_config" "${sshd_config}.bak.$(date +%s)"
    
    # Apply secure settings
    set_sshd_setting "Port" "2222"
    set_sshd_setting "PermitRootLogin" "no"
    set_sshd_setting "PasswordAuthentication" "no"
    set_sshd_setting "X11Forwarding" "no"
    
    # Restart SSH
    if command -v systemctl &> /dev/null; then
        sudo systemctl restart sshd
    else
        sudo service ssh restart
    fi
}

# Helper for SSH config
set_sshd_setting() {
    local key="$1"
    local value="$2"
    local file="/etc/ssh/sshd_config"
    
    if grep -q "^[#\s]*${key}\s" "$file"; then
        sudo sed -i "s/^[#\s]*${key}\s.*/${key} ${value}/" "$file"
    else
        echo "${key} ${value}" | sudo tee -a "$file" > /dev/null
    fi
}

# Setup firewall
setup_firewall() {
    log_info "Setting up firewall..."
    
    # Install UFW if needed
    if ! command -v ufw &> /dev/null; then
        install_package ufw
    fi
    
    # Configure UFW
    sudo ufw --force reset
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    sudo ufw allow 2222/tcp  # SSH
    sudo ufw allow 80/tcp    # HTTP
    sudo ufw allow 443/tcp   # HTTPS
    echo "y" | sudo ufw enable
}

# Setup fail2ban
setup_fail2ban() {
    log_info "Configuring fail2ban..."
    # TODO: Install and configure fail2ban for intrusion prevention
}

# Audit file permissions and ownership
audit_file_permissions() {
    log_info "Auditing file permissions and ownership..."
    # TODO: Check and fix permissions for sensitive files
}

# Configure system audit logging
configure_audit_logging() {
    log_info "Configuring system audit logging..."
    # TODO: Setup auditd or journald as per config
}

# Enforce user account policies
enforce_user_policies() {
    log_info "Enforcing user account policies..."
    # TODO: Set password requirements, lock inactive accounts, etc.
}

# Run main function
main "$@"
