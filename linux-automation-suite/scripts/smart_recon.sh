#!/bin/bash
# smart_recon.sh - Prototype for Smart Reconnaissance Tool
# Author: Linux Essentials Project
# Date: 2025-09-17

set -e

# ========== CONFIGURATION ==========
CATEGORIES=("DNS and Domain Intelligence" "Network Infrastructure" "Web Application")
DNS_TOOLS=("dig" "nslookup" "host")
NETWORK_TOOLS=("nmap" "fping")
WEB_TOOLS=("nikto" "whatweb")
REPORT_DIR="recon_reports"
REPORT_FILE="${REPORT_DIR}/report_$(date +%Y%m%d_%H%M%S).md"

# ========== FUNCTIONS ==============
function print_menu() {
    echo "Select a category to scan:"
    for i in "${!CATEGORIES[@]}"; do
        echo "$((i+1)). ${CATEGORIES[$i]}"
    done
    echo "0. Done selecting categories"
}

function select_tools() {
    local category="$1"
    local -n tool_array=$2
    local selected_tools=()
    echo "Select tools for $category (comma separated, e.g. 1,3):"
    for i in "${!tool_array[@]}"; do
        echo "$((i+1)). ${tool_array[$i]}"
    done
    read -p "Your choice: " tool_choices
    IFS=',' read -ra idxs <<< "$tool_choices"
    for idx in "${idxs[@]}"; do
        idx=$((idx-1))
        if [[ $idx -ge 0 && $idx -lt ${#tool_array[@]} ]]; then
            selected_tools+=("${tool_array[$idx]}")
        fi
    done
    echo "${selected_tools[@]}"
}

function run_dns_tools() {
    local target="$1"
    shift
    local tools=("$@")
    for tool in "${tools[@]}"; do
        echo "\n## $tool output for $target" >> "$REPORT_FILE"
        case $tool in
            dig)
                dig "$target" ANY +short >> "$REPORT_FILE" 2>&1
                ;;
            nslookup)
                nslookup "$target" >> "$REPORT_FILE" 2>&1
                ;;
            host)
                host "$target" >> "$REPORT_FILE" 2>&1
                ;;
        esac
    done
}

function run_network_tools() {
    local target="$1"
    shift
    local tools=("$@")
    for tool in "${tools[@]}"; do
        echo "\n## $tool output for $target" >> "$REPORT_FILE"
        case $tool in
            nmap)
                nmap -A "$target" >> "$REPORT_FILE" 2>&1
                ;;
            fping)
                fping -c1 "$target" >> "$REPORT_FILE" 2>&1
                ;;
        esac
    done
}

function run_web_tools() {
    local target="$1"
    shift
    local tools=("$@")
    for tool in "${tools[@]}"; do
        echo "\n## $tool output for $target" >> "$REPORT_FILE"
        case $tool in
            nikto)
                nikto -host "$target" >> "$REPORT_FILE" 2>&1
                ;;
            whatweb)
                whatweb "$target" >> "$REPORT_FILE" 2>&1
                ;;
        esac
    done
}

# ========== MAIN LOGIC =============

mkdir -p "$REPORT_DIR"
echo "# Smart Recon Report" > "$REPORT_FILE"
echo "Date: $(date)" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

read -p "Enter target domain or IP: " TARGET

SELECTED_CATEGORIES=()
SELECTED_TOOLS_DNS=()
SELECTED_TOOLS_NET=()
SELECTED_TOOLS_WEB=()

while true; do
    print_menu
    read -p "Category number: " cat_choice
    if [[ "$cat_choice" == "0" ]]; then
        break
    fi
    case $cat_choice in
        1)
            SELECTED_TOOLS_DNS=( $(select_tools "DNS and Domain Intelligence" DNS_TOOLS) )
            ;;
        2)
            SELECTED_TOOLS_NET=( $(select_tools "Network Infrastructure" NETWORK_TOOLS) )
            ;;
        3)
            SELECTED_TOOLS_WEB=( $(select_tools "Web Application" WEB_TOOLS) )
            ;;
    esac
    SELECTED_CATEGORIES+=("${CATEGORIES[$((cat_choice-1))]}")
done

echo "\n## Target: $TARGET" >> "$REPORT_FILE"
echo "\n## Selected Categories: ${SELECTED_CATEGORIES[*]}" >> "$REPORT_FILE"

if [[ ${#SELECTED_TOOLS_DNS[@]} -gt 0 ]]; then
    echo "\n# DNS and Domain Intelligence" >> "$REPORT_FILE"
    run_dns_tools "$TARGET" "${SELECTED_TOOLS_DNS[@]}"
fi
if [[ ${#SELECTED_TOOLS_NET[@]} -gt 0 ]]; then
    echo "\n# Network Infrastructure" >> "$REPORT_FILE"
    run_network_tools "$TARGET" "${SELECTED_TOOLS_NET[@]}"
fi
if [[ ${#SELECTED_TOOLS_WEB[@]} -gt 0 ]]; then
    echo "\n# Web Application" >> "$REPORT_FILE"
    run_web_tools "$TARGET" "${SELECTED_TOOLS_WEB[@]}"
fi

echo "\n---\nReport saved to $REPORT_FILE"
