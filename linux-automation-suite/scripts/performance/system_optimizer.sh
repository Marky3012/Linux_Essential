#!/bin/bash
# System Performance Tuner
# Description: Optimize CPU, memory, I/O, and network settings
# Author: Linux Automation Suite
# Version: 1.0.0

set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
source "${ROOT_DIR}/lib/common.sh"

# Load configuration
CONFIG_FILE="${CONFIG_DIR}/performance.yaml"
if [[ ! -f "$CONFIG_FILE" ]]; then
    error "Configuration file $CONFIG_FILE not found"
    exit 1
fi

# Main function
main() {
    log_info "Starting system performance optimization"
    
    # Initial checks
    check_root
    check_distribution
    
    # Run optimization modules
    optimize_cpu
    optimize_memory
    optimize_io
    optimize_network
    
    log_success "Performance optimization completed"
}

# Optimize CPU settings
optimize_cpu() {
    log_info "Optimizing CPU settings..."
    
    # Set CPU governor to performance
    if [ -d "/sys/devices/system/cpu/cpu0/cpufreq" ]; then
        for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
            echo "performance" | sudo tee "$cpu" > /dev/null 2>&1 || true
        done
    fi
    
    # Set swappiness (default 60, lower for better performance on desktops)
    echo 10 | sudo tee /proc/sys/vm/swappiness > /dev/null
    
    log_success "CPU optimization complete"
}

# Optimize memory settings
optimize_memory() {
    log_info "Optimizing memory settings..."
    
    # Adjust dirty_ratio and dirty_background_ratio
    echo 10 | sudo tee /proc/sys/vm/dirty_ratio > /dev/null
    echo 5 | sudo tee /proc/sys/vm/dirty_background_ratio > /dev/null
    
    # Adjust vfs cache pressure
    echo 50 | sudo tee /proc/sys/vm/vfs_cache_pressure > /dev/null
    
    log_success "Memory optimization complete"
}

# Optimize I/O settings
optimize_io() {
    log_info "Optimizing I/O settings..."
    
    # Get list of block devices
    local devices
    devices=$(lsblk -d -o NAME -n | grep -v loop)
    
    # Set I/O scheduler (deadline for SSDs, cfq for HDDs)
    for device in $devices; do
        if [[ -e "/sys/block/$device/queue/scheduler" ]]; then
            if [[ "$device" == "sd"* ]]; then
                # Assume SSD for sd* devices
                echo "mq-deadline" | sudo tee "/sys/block/$device/queue/scheduler" > /dev/null 2>&1 || true
            else
                echo "bfq" | sudo tee "/sys/block/$device/queue/scheduler" > /dev/null 2>&1 || true
            fi
        fi
    done
    
    # Increase file handles and inotify watches
    echo "fs.file-max = 100000" | sudo tee /etc/sysctl.d/60-file-max.conf
    echo "fs.inotify.max_user_watches = 524288" | sudo tee -a /etc/sysctl.d/60-file-max.conf
    sudo sysctl -p /etc/sysctl.d/60-file-max.conf
    
    log_success "I/O optimization complete"
}

# Optimize network settings
optimize_network() {
    log_info "Optimizing network settings..."
    
    # Basic network optimizations
    local sysctl_conf="/etc/sysctl.d/99-network-optimizations.conf"
    
    cat << EOF | sudo tee "$sysctl_conf" > /dev/null
# Network performance tuning
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_sack = 1
net.ipv4.tcp_no_metrics_save = 1
net.ipv4.tcp_moderate_rcvbuf = 1
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_sack = 1
net.ipv4.tcp_fack = 1
net.ipv4.tcp_ecn = 0
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_keepalive_time = 300
net.ipv4.tcp_keepalive_probes = 5
net.ipv4.tcp_keepalive_intvl = 15
net.ipv4.ip_local_port_range = 1024 65535
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_max_tw_buckets = 2000000
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
net.core.somaxconn = 65535
net.core.netdev_max_backlog = 100000
net.core.netdev_budget = 50000
net.core.netdev_budget_usecs = 5000
net.ipv4.tcp_max_orphans = 262144
net.ipv4.tcp_syn_retries = 2
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_congestion_control = bbr
EOF
    
    # Apply settings
    sudo sysctl -p "$sysctl_conf"
    
    # Enable BBR congestion control if available
    if ! grep -q "tcp_bbr" /etc/modules-load.d/modules.conf; then
        echo "tcp_bbr" | sudo tee -a /etc/modules-load.d/modules.conf > /dev/null
    fi
    
    # Load BBR module if not loaded
    if ! lsmod | grep -q "tcp_bbr"; then
        sudo modprobe tcp_bbr
    fi
    
    log_success "Network optimization complete"
}

# Run main function
main "$@"
