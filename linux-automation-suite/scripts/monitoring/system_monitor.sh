#!/bin/bash
# System Monitoring Script
# Description: Monitor system resources and log performance metrics
# Author: Linux Automation Suite
# Version: 1.0.0

set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
source "${ROOT_DIR}/lib/common.sh"

# Load configuration
CONFIG_FILE="${CONFIG_DIR}/monitoring.yaml"
if [[ ! -f "$CONFIG_FILE" ]]; then
    error "Configuration file $CONFIG_FILE not found"
    exit 1
fi

# Default values
LOG_INTERVAL=300  # 5 minutes
LOG_RETENTION_DAYS=30
ALERT_THRESHOLD=90  # Percentage

# Main function
main() {
    local action="${1:-help}"
    
    case "$action" in
        start)
            start_monitoring
            ;;
        stop)
            stop_monitoring
            ;;
        status)
            check_status
            ;;
        report)
            generate_report
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

# Start monitoring
start_monitoring() {
    log_info "Starting system monitoring..."
    
    # Create log directory if it doesn't exist
    local log_dir="/var/log/system-monitor"
    sudo mkdir -p "$log_dir"
    sudo chown "$USER" "$log_dir"
    
    # Start monitoring in background
    nohup "$SCRIPT_DIR/system_monitor.sh" monitor > "$log_dir/monitor.log" 2>&1 & 
    echo $! > "$log_dir/monitor.pid"
    
    log_success "System monitoring started (PID: $(cat "$log_dir/monitor.pid"))"
}

# Stop monitoring
stop_monitoring() {
    log_info "Stopping system monitoring..."
    
    local pid_file="/var/log/system-monitor/monitor.pid"
    
    if [ -f "$pid_file" ]; then
        local pid
        pid=$(cat "$pid_file")
        
        if ps -p "$pid" > /dev/null; then
            kill -TERM "$pid"
            rm -f "$pid_file"
            log_success "Stopped monitoring (PID: $pid)"
        else
            log_warn "No active monitoring process found"
            rm -f "$pid_file"
        fi
    else
        log_warn "No monitoring process found"
    fi
}

# Check monitoring status
check_status() {
    local pid_file="/var/log/system-monitor/monitor.pid"
    
    if [ -f "$pid_file" ]; then
        local pid
        pid=$(cat "$pid_file")
        
        if ps -p "$pid" > /dev/null; then
            echo "System monitoring is running (PID: $pid)"
            return 0
        else
            echo "System monitoring is not running (stale PID file found)"
            return 1
        fi
    else
        echo "System monitoring is not running"
        return 1
    fi
}

# Monitor system resources
monitor() {
    log_info "Starting system resource monitoring..."
    
    local log_dir="/var/log/system-monitor"
    local log_file="$log_dir/system-metrics-$(date +%Y%m%d).csv"
    
    # Create CSV header if file doesn't exist
    if [ ! -f "$log_file" ]; then
        echo "timestamp,cpu_usage,memory_usage,disk_usage,load_avg,swap_usage" > "$log_file"
    fi
    
    # Main monitoring loop
    while true; do
        # Get current timestamp
        local timestamp
        timestamp=$(date +"%Y-%m-%d %H:%M:%S")
        
        # Get CPU usage (percentage)
        local cpu_usage
        cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}' | cut -d. -f1)
        
        # Get memory usage (percentage)
        local mem_usage
        mem_usage=$(free | grep Mem | awk '{print $3/$2 * 100.0}' | cut -d. -f1)
        
        # Get disk usage (percentage of root partition)
        local disk_usage
        disk_usage=$(df -h / | tail -1 | awk '{print $5}' | tr -d '%')
        
        # Get load average
        local load_avg
        load_avg=$(cat /proc/loadavg | awk '{print $1}')
        
        # Get swap usage (percentage)
        local swap_usage
        swap_total=$(free | grep Swap | awk '{print $2}')
        if [ "$swap_total" -gt 0 ]; then
            swap_usage=$(free | grep Swap | awk '{print $3/$2 * 100.0}' | cut -d. -f1)
        else
            swap_usage=0
        fi
        
        # Log to CSV
        echo "$timestamp,$cpu_usage,$mem_usage,$disk_usage,$load_avg,$swap_usage" >> "$log_file"
        
        # Check for alerts
        check_alerts "$cpu_usage" "$mem_usage" "$disk_usage" "$swap_usage"
        
        # Sleep for the specified interval
        sleep "$LOG_INTERVAL"
    done
}

# Check for alert conditions
check_alerts() {
    local cpu=$1
    local mem=$2
    local disk=$3
    local swap=$4
    
    local alert_file="/var/log/system-monitor/alerts.log"
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    
    # CPU alert
    if [ "$cpu" -ge "$ALERT_THRESHOLD" ]; then
        echo "[$timestamp] WARNING: High CPU usage: ${cpu}%" >> "$alert_file"
        # You could add notification here (e.g., email, push notification)
    fi
    
    # Memory alert
    if [ "$mem" -ge "$ALERT_THRESHOLD" ]; then
        echo "[$timestamp] WARNING: High memory usage: ${mem}%" >> "$alert_file"
    fi
    
    # Disk alert
    if [ "$disk" -ge "$ALERT_THRESHOLD" ]; then
        echo "[$timestamp] WARNING: High disk usage: ${disk}%" >> "$alert_file"
    fi
    
    # Swap alert (only if swap is being used)
    if [ "$swap" -ge 50 ] && [ "$swap" -ne 0 ]; then
        echo "[$timestamp] WARNING: High swap usage: ${swap}%" >> "$alert_file"
    fi
}

# Generate a report
generate_report() {
    local report_dir="/var/log/system-monitor/reports"
    local report_file="${report_dir}/system-report-$(date +%Y%m%d).txt"
    
    mkdir -p "$report_dir"
    
    {
        echo "=== System Health Report ==="
        echo "Generated: $(date)"
        echo "Hostname: $(hostname)"
        echo "Uptime: $(uptime -p)"
        echo ""
        
        echo "=== CPU Usage ==="
        top -bn1 | grep "Cpu(s)" | awk '{print "Total:", $2 "% user, " $4 "% system, " $6 "% idle, " $12 "% iowait"}'
        echo "Load Average: $(cat /proc/loadavg | awk '{print $1 ", " $2 ", " $3}')"
        echo ""
        
        echo "=== Memory Usage ==="
        free -h
        echo ""
        
        echo "=== Disk Usage ==="
        df -h
        echo ""
        
        echo "=== Top Processes (by CPU) ==="
        ps aux --sort=-%cpu | head -n 6
        echo ""
        
        echo "=== Top Processes (by Memory) ==="
        ps aux --sort=-%mem | head -n 6
        echo ""
        
        echo "=== Network Connections ==="
        netstat -tuln
        echo ""
        
        echo "=== Recent Security Events ==="
        tail -n 20 /var/log/auth.log 2>/dev/null || echo "No auth log found"
        
    } > "$report_file"
    
    log_success "Report generated: $report_file"
    
    # Print a summary to console
    echo ""
    head -n 20 "$report_file"
    echo ""
    echo "... (full report saved to $report_file)"
}

# Show help
show_help() {
    cat << EOF
System Monitoring Script

Usage: $(basename "$0") [command]

Commands:
  start       Start monitoring in the background
  stop        Stop monitoring
  status      Check if monitoring is running
  report      Generate a system health report
  help        Show this help message

Monitoring Configuration:
  Log Directory: /var/log/system-monitor/
  Check Interval: $LOG_INTERVAL seconds
  Alert Threshold: $ALERT_THRESHOLD%

Example:
  $(basename "$0") start
  $(basename "$0") status
  $(basename "$0") report
  $(basename "$0") stop
EOF
}

# Run main function
main "$@"
