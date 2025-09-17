#!/bin/bash
# smart_recon.sh - Prototype for Smart Reconnaissance Tool
# Author: Linux Essentials Project
# Date: 2025-09-17

set -e

# ========== CONFIGURATION ==========
CATEGORIES=(
    "DNS and Domain Intelligence"
    "Network Infrastructure"
    "Web Application"
    "Email and Contact Information"
    "Social Media Intelligence"
    "Metadata and Document Analysis"
    "Certificate and Cryptographic Intelligence"
)
DNS_TOOLS=("dig" "nslookup" "host" "dnsrecon" "dnsenum" "fierce" "dnswalk" "sublist3r" "subfinder" "amass")
NETWORK_TOOLS=("nmap" "fping" "masscan" "unicornscan" "zmap" "netdiscover" "hping3")
WEB_TOOLS=("nikto" "dirb" "gobuster" "dirsearch" "wfuzz" "whatweb" "wpscan" "sqlmap")
EMAIL_TOOLS=("theharvester" "infoga" "h8mail" "crosslinked")
SOCIAL_TOOLS=("sherlock" "social-analyzer" "osintgram" "toutatis" "instaloader" "twint" "socialscan")
META_TOOLS=("metagoofil" "exiftool")
CERT_TOOLS=("sslscan" "sslyze" "testssl.sh")

SKIPPED_TOOLS=()

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

# ========== TOOL CHECK & INSTALL ==============
function check_and_prompt_install() {
    local tool_name="$1"
    if ! command -v "$tool_name" >/dev/null 2>&1; then
        echo "[!] Tool '$tool_name' is not installed."
        while true; do
            read -p "Do you want to install $tool_name? (y/n): " yn
            case $yn in
                [Yy]*)
                    if command -v apt >/dev/null 2>&1; then
                        sudo apt update && sudo apt install -y "$tool_name"
                    else
                        echo "Please install $tool_name manually. Skipping for now."
                    fi
                    break
                    ;;
                [Nn]*)
                    echo "Skipping $tool_name."
                    SKIPPED_TOOLS+=("$tool_name")
                    return 1
                    ;;
                *) echo "Please answer y or n.";;
            esac
        done
    fi
    return 0
}

function run_dns_tools() {
    local target="$1"
    shift
    local tools=("$@")
    for tool in "${tools[@]}"; do
        check_and_prompt_install "$tool" || continue
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
        check_and_prompt_install "$tool" || continue
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
        check_and_prompt_install "$tool" || continue
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

function run_email_tools() {
    local target="$1"
    shift
    local tools=("$@")
    for tool in "${tools[@]}"; do
        check_and_prompt_install "$tool" || continue
        echo "\n## $tool output for $target" >> "$REPORT_FILE"
        case $tool in
            theharvester)
                theharvester -d "$target" -b all >> "$REPORT_FILE" 2>&1
                ;;
            infoga)
                infoga --domain "$target" >> "$REPORT_FILE" 2>&1
                ;;
            h8mail)
                h8mail -t "$target" >> "$REPORT_FILE" 2>&1
                ;;
            crosslinked)
                crosslinked -d "$target" >> "$REPORT_FILE" 2>&1
                ;;
        esac
    done
}

function run_social_tools() {
    local target="$1"
    shift
    local tools=("$@")
    for tool in "${tools[@]}"; do
        check_and_prompt_install "$tool" || continue
        echo "\n## $tool output for $target" >> "$REPORT_FILE"
        case $tool in
            sherlock)
                sherlock "$target" >> "$REPORT_FILE" 2>&1
                ;;
            social-analyzer)
                social-analyzer -u "$target" >> "$REPORT_FILE" 2>&1
                ;;
            osintgram)
                osintgram -u "$target" -C all >> "$REPORT_FILE" 2>&1
                ;;
            toutatis)
                toutatis -u "$target" >> "$REPORT_FILE" 2>&1
                ;;
            instaloader)
                instaloader "$target" >> "$REPORT_FILE" 2>&1
                ;;
            twint)
                twint -u "$target" >> "$REPORT_FILE" 2>&1
                ;;
            socialscan)
                socialscan "$target" >> "$REPORT_FILE" 2>&1
                ;;
        esac
    done
}

function run_meta_tools() {
    local target="$1"
    shift
    local tools=("$@")
    for tool in "${tools[@]}"; do
        check_and_prompt_install "$tool" || continue
        echo "\n## $tool output for $target" >> "$REPORT_FILE"
        case $tool in
            metagoofil)
                metagoofil -d "$target" -t pdf,doc,xls,ppt -o ./metagoofil_out >> "$REPORT_FILE" 2>&1
                ;;
            exiftool)
                exiftool "$target" >> "$REPORT_FILE" 2>&1
                ;;
        esac
    done
}

function run_cert_tools() {
    local target="$1"
    shift
    local tools=("$@")
    for tool in "${tools[@]}"; do
        check_and_prompt_install "$tool" || continue
        echo "\n## $tool output for $target" >> "$REPORT_FILE"
        case $tool in
            sslscan)
                sslscan "$target" >> "$REPORT_FILE" 2>&1
                ;;
            sslyze)
                sslyze "$target" >> "$REPORT_FILE" 2>&1
                ;;
            testssl.sh)
                testssl.sh "$target" >> "$REPORT_FILE" 2>&1
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
SELECTED_TOOLS_EMAIL=()
SELECTED_TOOLS_SOCIAL=()
SELECTED_TOOLS_META=()
SELECTED_TOOLS_CERT=()

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
        4)
            SELECTED_TOOLS_EMAIL=( $(select_tools "Email and Contact Information" EMAIL_TOOLS) )
            ;;
        5)
            SELECTED_TOOLS_SOCIAL=( $(select_tools "Social Media Intelligence" SOCIAL_TOOLS) )
            ;;
        6)
            SELECTED_TOOLS_META=( $(select_tools "Metadata and Document Analysis" META_TOOLS) )
            ;;
        7)
            SELECTED_TOOLS_CERT=( $(select_tools "Certificate and Cryptographic Intelligence" CERT_TOOLS) )
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
if [[ ${#SELECTED_TOOLS_EMAIL[@]} -gt 0 ]]; then
    echo "\n# Email and Contact Information" >> "$REPORT_FILE"
    run_email_tools "$TARGET" "${SELECTED_TOOLS_EMAIL[@]}"
fi
if [[ ${#SELECTED_TOOLS_SOCIAL[@]} -gt 0 ]]; then
    echo "\n# Social Media Intelligence" >> "$REPORT_FILE"
    run_social_tools "$TARGET" "${SELECTED_TOOLS_SOCIAL[@]}"
fi
if [[ ${#SELECTED_TOOLS_META[@]} -gt 0 ]]; then
    echo "\n# Metadata and Document Analysis" >> "$REPORT_FILE"
    run_meta_tools "$TARGET" "${SELECTED_TOOLS_META[@]}"
fi
if [[ ${#SELECTED_TOOLS_CERT[@]} -gt 0 ]]; then
    echo "\n# Certificate and Cryptographic Intelligence" >> "$REPORT_FILE"
    run_cert_tools "$TARGET" "${SELECTED_TOOLS_CERT[@]}"
fi

if [[ ${#SKIPPED_TOOLS[@]} -gt 0 ]]; then
    echo -e "\n---\n## Skipped Tools\nThe following tools were skipped (not installed):" >> "$REPORT_FILE"
    for tool in "${SKIPPED_TOOLS[@]}"; do
        echo "- $tool" >> "$REPORT_FILE"
    done
fi

echo "\n---\nReport saved to $REPORT_FILE"
