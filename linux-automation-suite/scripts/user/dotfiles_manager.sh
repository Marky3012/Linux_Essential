#!/bin/bash
# Dotfiles Management Script
# Description: GNU Stow-based configuration synchronization
# Author: Linux Automation Suite
# Version: 1.0.0

set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
source "${ROOT_DIR}/lib/common.sh"

# Default configuration
DOTFILES_DIR="${HOME}/.dotfiles"
STOW_HOME="${DOTFILES_DIR}/stow"
BACKUP_DIR="${DOTFILES_DIR}/backup/$(date +%Y%m%d_%H%M%S)"

# Ensure stow is installed
ensure_stow() {
    if ! command -v stow &> /dev/null; then
        log_info "Installing GNU Stow..."
        install_package stow
    fi
}

# Create directory structure
setup_directories() {
    log_info "Setting up dotfiles directory structure..."
    
    mkdir -p "${STOW_HOME}"
    mkdir -p "${BACKUP_DIR}"
    
    # Create basic dotfiles structure if it doesn't exist
    if [ ! -d "${STOW_HOME}" ]; then
        mkdir -p "${STOW_HOME}/bash"
        mkdir -p "${STOW_HOME}/git"
        mkdir -p "${STOW_HOME}/vim"
        
        # Create basic configs
        echo "# .bashrc" > "${STOW_HOME}/bash/.bashrc"
        echo "[user]" > "${STOW_HOME}/git/.gitconfig"
        echo "  name = Your Name" >> "${STOW_HOME}/git/.gitconfig"
        echo "  email = your.email@example.com" >> "${STOW_HOME}/git/.gitconfig"
    fi
}

# Backup existing dotfiles
backup_existing() {
    local target=$1
    
    if [ -e "${HOME}/${target}" ] && [ ! -L "${HOME}/${target}" ]; then
        log_info "Backing up ${target}..."
        mkdir -p "$(dirname "${BACKUP_DIR}/${target}")"
        mv "${HOME}/${target}" "${BACKUP_DIR}/${target}"
    fi
}

# Stow a package
stow_package() {
    local package=$1
    local target_dir="${STOW_HOME}/${package}"
    
    if [ ! -d "${target_dir}" ]; then
        log_warn "Package '${package}' not found in ${STOW_HOME}"
        return 1
    fi
    
    log_info "Linking ${package}..."
    
    # Backup existing files
    find "${target_dir}" -type f | while read -r file; do
        local rel_path="${file#${target_dir}/}"
        backup_existing "${rel_path}"
    done
    
    # Create symlinks
    stow -d "${STOW_HOME}" -t "${HOME}" -R "${package}" 2>/dev/null || {
        log_error "Failed to stow ${package}"
        return 1
    }
}

# Unstow a package
unstow_package() {
    local package=$1
    
    if [ ! -d "${STOW_HOME}/${package}" ]; then
        log_warn "Package '${package}' not found"
        return 1
    fi
    
    log_info "Unlinking ${package}..."
    stow -d "${STOW_HOME}" -t "${HOME}" -D "${package}" 2>/dev/null || {
        log_error "Failed to unstow ${package}"
        return 1
    }
}

# List available packages
list_packages() {
    log_info "Available packages in ${STOW_HOME}:"
    find "${STOW_HOME}" -maxdepth 1 -mindepth 1 -type d -exec basename {} \; | sort
}

# Show usage
show_help() {
    echo "Usage: $(basename "$0") [command] [package]"
    echo ""
    echo "Commands:"
    echo "  install <package>  Install/Link a package"
    echo "  remove <package>   Remove/Unlink a package"
    echo "  list               List available packages"
    echo "  init               Initialize dotfiles directory structure"
    echo "  help               Show this help message"
    echo ""
    echo "Examples:"
    echo "  $(basename "$0") init"
    echo "  $(basename "$0") install bash"
    echo "  $(basename "$0") list"
}

# Main function
main() {
    ensure_stow
    
    local command="${1:-help}"
    local package="${2:-}"
    
    case "${command}" in
        install)
            if [ -z "${package}" ]; then
                log_error "No package specified"
                show_help
                exit 1
            fi
            stow_package "${package}"
            ;;
        remove|uninstall)
            if [ -z "${package}" ]; then
                log_error "No package specified"
                show_help
                exit 1
            fi
            unstow_package "${package}"
            ;;
        list)
            list_packages
            ;;
        init)
            setup_directories
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            log_error "Unknown command: ${command}"
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
