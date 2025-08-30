#!/bin/bash

# Detect shell config file
if [ -n "$ZSH_VERSION" ]; then
    CONFIG_FILE="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
    CONFIG_FILE="$HOME/.bashrc"
else
    echo "Unsupported shell. Please use Bash or Zsh."
    exit 1
fi

echo "Adding aliases to $CONFIG_FILE..."

cat << 'EOF' >> "$CONFIG_FILE"

# === Custom Aliases ===
alias ll='ls -alh'
alias cls='clear'
alias back='cd ..'
alias update='sudo apt update && sudo apt upgrade -y'
alias duf='df -h'
alias psg='ps aux | grep'
alias rm='rm -i'
alias myip="ip addr show | grep inet"
alias gs='git status'
alias gcp='git commit -am "Update" && git push'
alias open='xdg-open .'
alias findf='find . -name'
alias mv='mv -i'
alias free='free -m'
EOF

echo "✅ Aliases added. Please restart your terminal or run: source $CONFIG_FILE"
