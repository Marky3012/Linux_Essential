#!/bin/bash
# smart_recon.sh - Prototype for Smart Reconnaissance Tool
# Author: Linux Essentials Project
# Date: 2025-09-17

set -e

# Safety/test mode: set DRY_RUN=1 in environment to avoid installing/running external tools
DRY_RUN=${DRY_RUN:-0}

# Default report paths
REPORT_DIR=${REPORT_DIR:-"$(pwd)/reports"}
REPORT_FILE=${REPORT_FILE:-"$REPORT_DIR/smart_recon_report.md"}

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
    # Print menu to stderr so command substitution calling this function
    # only captures the final selected tool names (not the menu text).
    echo "Select tools for $category (comma separated, e.g. 1,3):" >&2
    for i in "${!tool_array[@]}"; do
        echo "$((i+1)). ${tool_array[$i]}" >&2
    done
    # Prompt on stderr and read choice from stdin
    echo -n "Your choice: " >&2
    read tool_choices
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
        if [[ "$DRY_RUN" == "1" ]]; then
            echo "DRY_RUN=1: would prompt to install $tool_name — skipping in test mode."
            SKIPPED_TOOLS+=("$tool_name")
            return 1
        fi
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
                if [[ "$DRY_RUN" == "1" ]]; then
                    echo "[DRY_RUN] dig $target ANY +short" >> "$REPORT_FILE"
                else
                    dig "$target" ANY +short >> "$REPORT_FILE" 2>&1
                fi
                ;;
            nslookup)
                if [[ "$DRY_RUN" == "1" ]]; then
                    echo "[DRY_RUN] nslookup $target" >> "$REPORT_FILE"
                else
                    nslookup "$target" >> "$REPORT_FILE" 2>&1
                fi
                ;;
            host)
                if [[ "$DRY_RUN" == "1" ]]; then
                    echo "[DRY_RUN] host $target" >> "$REPORT_FILE"
                else
                    host "$target" >> "$REPORT_FILE" 2>&1
                fi
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
                if [[ "$DRY_RUN" == "1" ]]; then
                    echo "[DRY_RUN] nmap -A $target" >> "$REPORT_FILE"
                else
                    nmap -A "$target" >> "$REPORT_FILE" 2>&1
                fi
                ;;
            fping)
                if [[ "$DRY_RUN" == "1" ]]; then
                    echo "[DRY_RUN] fping -c1 $target" >> "$REPORT_FILE"
                else
                    fping -c1 "$target" >> "$REPORT_FILE" 2>&1
                fi
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
                if [[ "$DRY_RUN" == "1" ]]; then
                    echo "[DRY_RUN] nikto -host $target" >> "$REPORT_FILE"
                else
                    nikto -host "$target" >> "$REPORT_FILE" 2>&1
                fi
                ;;
            whatweb)
                if [[ "$DRY_RUN" == "1" ]]; then
                    echo "[DRY_RUN] whatweb $target" >> "$REPORT_FILE"
                else
                    whatweb "$target" >> "$REPORT_FILE" 2>&1
                fi
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
                if [[ "$DRY_RUN" == "1" ]]; then
                    echo "[DRY_RUN] theharvester -d $target -b all" >> "$REPORT_FILE"
                else
                    theharvester -d "$target" -b all >> "$REPORT_FILE" 2>&1
                fi
                ;;
            infoga)
                if [[ "$DRY_RUN" == "1" ]]; then
                    echo "[DRY_RUN] infoga --domain $target" >> "$REPORT_FILE"
                else
                    infoga --domain "$target" >> "$REPORT_FILE" 2>&1
                fi
                ;;
            h8mail)
                if [[ "$DRY_RUN" == "1" ]]; then
                    echo "[DRY_RUN] h8mail -t $target" >> "$REPORT_FILE"
                else
                    h8mail -t "$target" >> "$REPORT_FILE" 2>&1
                fi
                ;;
            crosslinked)
                if [[ "$DRY_RUN" == "1" ]]; then
                    echo "[DRY_RUN] crosslinked -d $target" >> "$REPORT_FILE"
                else
                    crosslinked -d "$target" >> "$REPORT_FILE" 2>&1
                fi
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
                if [[ "$DRY_RUN" == "1" ]]; then
                    echo "[DRY_RUN] sherlock $target" >> "$REPORT_FILE"
                else
                    sherlock "$target" >> "$REPORT_FILE" 2>&1
                fi
                ;;
            social-analyzer)
                if [[ "$DRY_RUN" == "1" ]]; then
                    echo "[DRY_RUN] social-analyzer -u $target" >> "$REPORT_FILE"
                else
                    social-analyzer -u "$target" >> "$REPORT_FILE" 2>&1
                fi
                ;;
            osintgram)
                if [[ "$DRY_RUN" == "1" ]]; then
                    echo "[DRY_RUN] osintgram -u $target -C all" >> "$REPORT_FILE"
                else
                    osintgram -u "$target" -C all >> "$REPORT_FILE" 2>&1
                fi
                ;;
            toutatis)
                if [[ "$DRY_RUN" == "1" ]]; then
                    echo "[DRY_RUN] toutatis -u $target" >> "$REPORT_FILE"
                else
                    toutatis -u "$target" >> "$REPORT_FILE" 2>&1
                fi
                ;;
            instaloader)
                if [[ "$DRY_RUN" == "1" ]]; then
                    echo "[DRY_RUN] instaloader $target" >> "$REPORT_FILE"
                else
                    instaloader "$target" >> "$REPORT_FILE" 2>&1
                fi
                ;;
            twint)
                if [[ "$DRY_RUN" == "1" ]]; then
                    echo "[DRY_RUN] twint -u $target" >> "$REPORT_FILE"
                else
                    twint -u "$target" >> "$REPORT_FILE" 2>&1
                fi
                ;;
            socialscan)
                if [[ "$DRY_RUN" == "1" ]]; then
                    echo "[DRY_RUN] socialscan $target" >> "$REPORT_FILE"
                else
                    socialscan "$target" >> "$REPORT_FILE" 2>&1
                fi
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
                if [[ "$DRY_RUN" == "1" ]]; then
                    echo "[DRY_RUN] metagoofil -d $target -t pdf,doc,xls,ppt -o ./metagoofil_out" >> "$REPORT_FILE"
                else
                    metagoofil -d "$target" -t pdf,doc,xls,ppt -o ./metagoofil_out >> "$REPORT_FILE" 2>&1
                fi
                ;;
            exiftool)
                if [[ "$DRY_RUN" == "1" ]]; then
                    echo "[DRY_RUN] exiftool $target" >> "$REPORT_FILE"
                else
                    exiftool "$target" >> "$REPORT_FILE" 2>&1
                fi
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
                if [[ "$DRY_RUN" == "1" ]]; then
                    echo "[DRY_RUN] sslscan $target" >> "$REPORT_FILE"
                else
                    sslscan "$target" >> "$REPORT_FILE" 2>&1
                fi
                ;;
            sslyze)
                if [[ "$DRY_RUN" == "1" ]]; then
                    echo "[DRY_RUN] sslyze $target" >> "$REPORT_FILE"
                else
                    sslyze "$target" >> "$REPORT_FILE" 2>&1
                fi
                ;;
            testssl.sh)
                if [[ "$DRY_RUN" == "1" ]]; then
                    echo "[DRY_RUN] testssl.sh $target" >> "$REPORT_FILE"
                else
                    testssl.sh "$target" >> "$REPORT_FILE" 2>&1
                fi
                ;;
        esac
    done
}

# ========== MAIN LOGIC =============

# Usage/help
function usage() {
    cat <<'USAGE'
Usage: smart_recon.sh [options]

Options:
  --target <domain|ip>         Non-interactive target to scan
  --categories <1,2>           Comma-separated category numbers (see script for mapping)
  --tools <t1,t2>              Comma-separated tool names to run (will be filtered per-category)
  --dry-run                    Enable dry-run mode (same as DRY_RUN=1)
  -h, --help                   Show this help

Examples:
  smart_recon.sh --target example.com --categories 1 --tools dig,host --dry-run
USAGE
}

# Parse CLI args for non-interactive runs
CLI_TARGET=""
CLI_CATEGORIES=""
CLI_TOOLS=""
SUMMARIZE=0
while [[ $# -gt 0 ]]; do
    case "$1" in
        --target)
            CLI_TARGET="$2"; shift 2;;
        --categories|--category)
            CLI_CATEGORIES="$2"; shift 2;;
        --tools)
            CLI_TOOLS="$2"; shift 2;;
        --dry-run)
            DRY_RUN=1; shift;;
        --summarize)
            SUMMARIZE=1; shift;;
        -h|--help)
            usage; exit 0;;
        *)
            # unknown / stop parsing
            break;;
    esac
done

mkdir -p "$REPORT_DIR"
printf "# Smart Recon Report\n" > "$REPORT_FILE"
printf "Date: %s\n\n" "$(date)" >> "$REPORT_FILE"

# Prepare selection containers
SELECTED_CATEGORIES=()
SELECTED_TOOLS_DNS=()
SELECTED_TOOLS_NET=()
SELECTED_TOOLS_WEB=()
SELECTED_TOOLS_EMAIL=()
SELECTED_TOOLS_SOCIAL=()
SELECTED_TOOLS_META=()
SELECTED_TOOLS_CERT=()

# Helper: split CSV into array
function split_csv() {
    local IFS=','; read -ra arr <<< "$1"; echo "${arr[@]}"
}

# Non-interactive path when CLI_TARGET is provided
if [[ -n "$CLI_TARGET" || -n "$CLI_CATEGORIES" ]]; then
    TARGET="$CLI_TARGET"
    # if categories specified, process them
    if [[ -n "$CLI_CATEGORIES" ]]; then
        IFS=',' read -ra cat_idxs <<< "$CLI_CATEGORIES"
        # build a set of CLI tools (global)
        declare -A CLI_TOOL_SET
        if [[ -n "$CLI_TOOLS" ]]; then
            for t in $(split_csv "$CLI_TOOLS"); do
                CLI_TOOL_SET["$t"]=1
            done
        fi
        for ci in "${cat_idxs[@]}"; do
            ci_trim=$(echo "$ci" | xargs)
            case "$ci_trim" in
                1)
                    SELECTED_CATEGORIES+=("${CATEGORIES[0]}")
                    if [[ -n "$CLI_TOOLS" ]]; then
                        for t in "${DNS_TOOLS[@]}"; do [[ -n "${CLI_TOOL_SET[$t]}" ]] && SELECTED_TOOLS_DNS+=("$t"); done
                    else
                        SELECTED_TOOLS_DNS=("${DNS_TOOLS[@]}")
                    fi
                    ;;
                2)
                    SELECTED_CATEGORIES+=("${CATEGORIES[1]}")
                    if [[ -n "$CLI_TOOLS" ]]; then
                        for t in "${NETWORK_TOOLS[@]}"; do [[ -n "${CLI_TOOL_SET[$t]}" ]] && SELECTED_TOOLS_NET+=("$t"); done
                    else
                        SELECTED_TOOLS_NET=("${NETWORK_TOOLS[@]}")
                    fi
                    ;;
                3)
                    SELECTED_CATEGORIES+=("${CATEGORIES[2]}")
                    if [[ -n "$CLI_TOOLS" ]]; then
                        for t in "${WEB_TOOLS[@]}"; do [[ -n "${CLI_TOOL_SET[$t]}" ]] && SELECTED_TOOLS_WEB+=("$t"); done
                    else
                        SELECTED_TOOLS_WEB=("${WEB_TOOLS[@]}")
                    fi
                    ;;
                4)
                    SELECTED_CATEGORIES+=("${CATEGORIES[3]}")
                    if [[ -n "$CLI_TOOLS" ]]; then
                        for t in "${EMAIL_TOOLS[@]}"; do [[ -n "${CLI_TOOL_SET[$t]}" ]] && SELECTED_TOOLS_EMAIL+=("$t"); done
                    else
                        SELECTED_TOOLS_EMAIL=("${EMAIL_TOOLS[@]}")
                    fi
                    ;;
                5)
                    SELECTED_CATEGORIES+=("${CATEGORIES[4]}")
                    if [[ -n "$CLI_TOOLS" ]]; then
                        for t in "${SOCIAL_TOOLS[@]}"; do [[ -n "${CLI_TOOL_SET[$t]}" ]] && SELECTED_TOOLS_SOCIAL+=("$t"); done
                    else
                        SELECTED_TOOLS_SOCIAL=("${SOCIAL_TOOLS[@]}")
                    fi
                    ;;
                6)
                    SELECTED_CATEGORIES+=("${CATEGORIES[5]}")
                    if [[ -n "$CLI_TOOLS" ]]; then
                        for t in "${META_TOOLS[@]}"; do [[ -n "${CLI_TOOL_SET[$t]}" ]] && SELECTED_TOOLS_META+=("$t"); done
                    else
                        SELECTED_TOOLS_META=("${META_TOOLS[@]}")
                    fi
                    ;;
                7)
                    SELECTED_CATEGORIES+=("${CATEGORIES[6]}")
                    if [[ -n "$CLI_TOOLS" ]]; then
                        for t in "${CERT_TOOLS[@]}"; do [[ -n "${CLI_TOOL_SET[$t]}" ]] && SELECTED_TOOLS_CERT+=("$t"); done
                    else
                        SELECTED_TOOLS_CERT=("${CERT_TOOLS[@]}")
                    fi
                    ;;
                *)
                    echo "Ignoring unknown category: $ci_trim";;
            esac
        done
    fi
else
    # interactive path
    read -p "Enter target domain or IP: " TARGET
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
fi

printf "\n## Target: %s\n" "$TARGET" >> "$REPORT_FILE"
printf "## Selected Categories: %s\n\n" "${SELECTED_CATEGORIES[*]}" >> "$REPORT_FILE"

if [[ ${#SELECTED_TOOLS_DNS[@]} -gt 0 ]]; then
    printf "# DNS and Domain Intelligence\n" >> "$REPORT_FILE"
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

# If requested, call the summarizer to create an enhanced report
if [[ "$SUMMARIZE" -eq 1 ]]; then
    ENHANCED="$REPORT_DIR/enhanced_$(basename "$REPORT_FILE")"
    if command -v python3 >/dev/null 2>&1; then
        if [[ "$DRY_RUN" == "1" ]]; then
            env DRY_RUN=1 python3 "$(dirname "$0")/summarize_report.py" "$REPORT_FILE" "$ENHANCED"
        else
            python3 "$(dirname "$0")/summarize_report.py" "$REPORT_FILE" "$ENHANCED"
        fi
    else
        echo "Python3 not found; cannot summarize report."
    fi
fi
