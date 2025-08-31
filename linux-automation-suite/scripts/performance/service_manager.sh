#!/bin/bash
# Service Management Script
# Description: Manage system services for optimal performance
# Author: Linux Automation Suite
# Version: 1.0.0

set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
source "${ROOT_DIR}/lib/common.sh"

# Load configuration
CONFIG_FILE="${CONFIG_DIR}/services.yaml"
if [[ ! -f "$CONFIG_FILE" ]]; then
    error "Configuration file $CONFIG_FILE not found"
    exit 1
fi

# Main function
main() {
    local action="${1:-help}"
    
    case "$action" in
        start|stop|restart|enable|disable|status)
            manage_services "$action"
            ;;
        optimize)
            optimize_services
            ;;
        list)
            list_services
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            error "Unknown action: $action"
            show_help
            exit 1
            ;;
    esac
}

# Manage services based on action
manage_services() {
    local action=$1
    local service_list
    
    # Load service configuration
    if ! command -v yq &> /dev/null; then
        error "yq is required but not installed. Please install yq (https://github.com/mikefarah/yq)"
        exit 1
    fi
    
    # Get list of services from config
    service_list=$(yq e '.services[]?.name' "$CONFIG_FILE" 2>/dev/null || true)
    
    if [ -z "$service_list" ]; then
        log_warn "No services configured in $CONFIG_FILE"
        return 0
    fi
    
    for service in $service_list; do
        local enabled
        enabled=$(yq e ".services[] | select(.name == \"$service\") | .enabled" "$CONFIG_FILE" 2>/dev/null || true)
        
        if [ "$enabled" = "true" ]; then
            log_info "${action^}ing service: $service"
            
            # Handle different service managers
            if command -v systemctl &> /dev/null; then
                sudo systemctl "$action" "$service" || log_warn "Failed to $action $service"
                
                # Special handling for enable/disable
                if [ "$action" = "enable" ] || [ "$action" = "disable" ]; then
                    sudo systemctl "$action" "$service"
                fi
            elif command -v service &> /dev/null; then
                sudo service "$service" "$action" || log_warn "Failed to $action $service"
                
                if [ "$action" = "enable" ] || [ "$action" = "disable" ]; then
                    sudo chkconfig "$service" "$action"
                fi
            else
                error "No supported service manager found"
                exit 1
            fi
        else
            log_debug "Skipping disabled service: $service"
        fi
    done
}

# Optimize services based on system role
optimize_services() {
    log_info "Optimizing services for best performance..."
    
    # Get system role from config or detect
    local role
    role=$(yq e '.system.role // "desktop"' "$CONFIG_FILE" 2>/dev/null || echo "desktop")
    
    log_info "Configuring services for role: $role"
    
    # Common services to disable for all roles
    local common_disable=(
        "avahi-daemon"
        "cups"
        "bluetooth"
        "ModemManager"
        "pulseaudio"
    )
    
    # Role-specific optimizations
    case "$role" in
        server)
            local disable_services=(
                "${common_disable[@]}"
                "accounts-daemon"
                "anacron"
                "apport"
                "cron"  # Consider using systemd timers instead
                "cups-browsed"
                "debug-shell"
                "ModemManager"
                "networkd-dispatcher"
                "paxctld"
                "rsyslog"  # Consider using journald
                "snapd"
                "spice-vdagentd"
                "ssh"  # Only if not needed
                "unattended-upgrades"
                "user@"  # User manager instances
                "vboxservice"
                "whoopsie"
            )
            ;;
        desktop)
            local disable_services=(
                "${common_disable[@]}"
                "anacron"
                "apport"
                "cups-browsed"
                "debug-shell"
                "modemmanager"
                "snapd"
                "unattended-upgrades"
                "whoopsie"
            )
            ;;
        laptop)
            local disable_services=(
                "${common_disable[@]}"
                "anacron"
                "apport"
                "cups-browsed"
                "debug-shell"
                "unattended-upgrades"
                "whoopsie"
            )
            ;;
        *)
            log_warn "Unknown role: $role. Using desktop profile."
            local disable_services=("${common_disable[@]}")
            ;;
    esac
    
    # Disable unnecessary services
    for service in "${disable_services[@]}"; do
        if systemctl list-unit-files | grep -q "^$service\."; then
            log_info "Disabling service: $service"
            sudo systemctl disable --now "$service" 2>/dev/null || true
            sudo systemctl mask "$service" 2>/dev/null || true
        fi
    done
    
    # Enable useful services
    local enable_services=(
        "apparmor"
        "auditd"
        "cron"
        "dbus"
        "irqbalance"
        "network-manager"
        "rsyslog"
        "ssh"
        "systemd-journald"
        "systemd-timesyncd"
        "ufw"
    )
    
    for service in "${enable_services[@]}"; do
        if systemctl list-unit-files | grep -q "^$service\."; then
            log_info "Enabling service: $service"
            sudo systemctl enable --now "$service" 2>/dev/null || true
        fi
    done
    
    log_success "Service optimization complete"
}

# List all services with status
list_services() {
    log_info "Listing system services:"
    
    if command -v systemctl &> /dev/null; then
        systemctl list-unit-files --type=service --no-pager
    elif command -v service &> /dev/null; then
        service --status-all
    else
        error "No supported service manager found"
        exit 1
    fi
}

# Show help
show_help() {
    cat << EOF
Service Management Script

Usage: $(basename "$0") [command]

Commands:
  start <service>    Start a service
  stop <service>     Stop a service
  restart <service>  Restart a service
  enable <service>   Enable a service to start on boot
  disable <service>  Disable a service from starting on boot
  status <service>   Show status of a service
  optimize           Optimize services based on system role
  list               List all services
  help               Show this help message

Configuration:
  Edit $CONFIG_FILE to configure services
  
Example:
  $(basename "$0") optimize
  $(basename "$0") status sshd
  $(basename "$0") disable bluetooth
EOF
}

# Run main function
main "$@"
