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

# Git workflow shortcuts
alias ga='git add'
alias gaa='git add .'
alias gc='git commit -m'
alias gp='git push'
alias gl='git log --oneline'
alias gco='git checkout'
alias gcb='git checkout -b'

# Node.js/NPM shortcuts  
alias ni='npm install'
alias nrs='npm run start'
alias nrt='npm run test'
alias ya='yarn add'

# Python development
alias py='python3'
alias venv='python3 -m venv'
alias activate='source venv/bin/activate'
alias freeze='pip freeze > requirements.txt'


# Docker shortcuts
alias dps='docker ps'
alias dex='docker exec -it'
alias dlog='docker logs'
alias dcup='docker-compose up'

# Kubernetes shortcuts
alias k='kubectl'
alias kpods='kubectl get pods'
alias klog='kubectl logs'

# Cloud tools
alias tf='terraform'
alias aws='aws'


# System services
alias start='sudo systemctl start'
alias stop='sudo systemctl stop'
alias restart='sudo systemctl restart'
alias status='sudo systemctl status'

# Process monitoring
alias pscpu='ps auxf | sort -nr -k 3'  # Top CPU processes
alias psmem='ps auxf | sort -nr -k 4'  # Top memory processes
alias btop='btop || htop || top'       # Best available process viewer


# Enhanced network info
alias myip4="ip addr show | grep 'inet ' | grep -v '127.0.0.1' | awk '{print \$2}' | cut -d/ -f1"
alias publicip='curl -s ifconfig.me'
alias ports='netstat -tulanp'
alias listening='lsof -i -P -n | grep LISTEN'

# Security shortcuts
alias firewall='sudo ufw status verbose'
alias perm644='chmod 644'
alias perm755='chmod 755'


# Local servers
alias serve='python3 -m http.server 8000'
alias phpserve='php -S localhost:8000'
alias nodeserve='npx http-server'

# Web utilities
alias jsonpp='python3 -m json.tool'  # Pretty print JSON
alias header='curl -I'               # Check HTTP headers


# PostgreSQL
alias pgstart='sudo systemctl start postgresql'
alias pglogin='sudo -u postgres psql'

# MySQL
alias mysqlstart='sudo systemctl start mysql'
alias mysqllogin='mysql -u root -p'

# MongoDB
alias mongostart='sudo systemctl start mongod'


# Enhanced text operations
alias count='wc -l'
alias head10='head -n 10'
alias tail10='tail -n 10'
alias lower='tr "[:upper:]" "[:lower:]"'
alias upper='tr "[:lower:]" "[:upper:]"'


# System logs
alias logs='sudo journalctl -f'
alias syslog='sudo tail -f /var/log/syslog'
alias authlog='sudo tail -f /var/log/auth.log'
alias nginxlog='sudo tail -f /var/log/nginx/error.log'


# Smart extraction function
alias extract='function _extract() { 
  case "$1" in 
    *.tar.bz2) tar xjf "$1" ;;
    *.tar.gz) tar xzf "$1" ;; 
    *.zip) unzip "$1" ;;
    *.rar) unrar e "$1" ;;
    *) echo "Unknown format" ;;
  esac
}; _extract'


# Quick shortcuts
alias weather='curl wttr.in'
alias todo='nano ~/todo.txt'
alias timer='echo "Timer started. Press Ctrl+C to stop."; time read'
alias backup='function _backup(){ cp "$1" "$1.backup.$(date +%Y%m%d_%H%M%S)"; }; _backup'

# Directory shortcuts
alias projects='cd ~/Projects'
alias downloads='cd ~/Downloads'
alias www='cd /var/www'

EOF

echo "✅ Aliases added. Please restart your terminal or run: source $CONFIG_FILE"
