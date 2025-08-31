# Enhanced Alias Setup Script Documentation

## Overview

The `alias_setup.sh` script is a comprehensive bash utility that automatically adds a collection of **200+ useful command-line aliases** to your shell configuration file. It supports both Bash and Zsh shells and provides convenient shortcuts for common Linux/Unix operations across multiple user types and workflows.

## Features

- **Shell Detection**: Automatically detects whether you're using Bash or Zsh
- **Safe Installation**: Appends aliases to the appropriate configuration file
- **Comprehensive Coverage**: 200+ aliases organized by user type and workflow
- **Multi-User Support**: Aliases for developers, system administrators, DevOps engineers, and general users
- **Git Integration**: Complete git workflow shortcuts for version control
- **System Utilities**: Extensive system monitoring and administration aliases
- **Development Tools**: Support for Node.js, Python, Docker, Kubernetes, and more
- **Network Operations**: Advanced network diagnostics and security tools
- **Database Management**: Quick access to PostgreSQL, MySQL, and MongoDB operations
- **Text Processing**: Advanced text manipulation and file operations
- **Archive Management**: Smart extraction and compression utilities
- **Productivity Tools**: Time-saving utilities and shortcuts

## Prerequisites

- Linux or Unix-based operating system
- Bash or Zsh shell
- Basic command-line permissions
- Optional packages for extended functionality (noted in relevant sections)

## Installation

### Step 1: Download and Setup
```bash
# Make the script executable
chmod +x alias_setup.sh
```

### Step 2: Run the Script
```bash
# Execute the script
./alias_setup.sh
```

### Step 3: Apply Changes
```bash
# Reload your shell configuration
source ~/.bashrc    # For Bash users
# OR
source ~/.zshrc     # For Zsh users
```

Alternatively, restart your terminal to apply the changes.

## How It Works

1. **Shell Detection**: The script checks the `$ZSH_VERSION` and `$BASH_VERSION` environment variables to determine your shell
2. **Config File Selection**: Based on the detected shell, it selects either `~/.zshrc` (Zsh) or `~/.bashrc` (Bash)
3. **Enhanced Alias Installation**: Appends all 200+ aliases to the configuration file using a heredoc
4. **Category Organization**: Aliases are organized by functionality and user type
5. **Confirmation**: Provides feedback on successful installation with usage tips

## Included Aliases

### Basic Navigation & File Operations
| Alias | Command | Description |
|-------|---------|-------------|
| `ll` | `ls -alh` | List all files in long format with human-readable sizes |
| `la` | `ls -A` | List all files including hidden (except . and ..) |
| `l` | `ls -CF` | List files in columns with indicators |
| `cls` / `c` | `clear` | Clear terminal screen |
| `back` / `..` | `cd ..` | Navigate to parent directory |
| `...` | `cd ../..` | Navigate up two directories |
| `....` | `cd ../../..` | Navigate up three directories |
| `~` / `home` | `cd ~` | Navigate to home directory |
| `-` | `cd -` | Navigate to previous directory |
| `root` | `cd /` | Navigate to root directory |

### Enhanced File & Directory Management
| Alias | Command | Description |
|-------|---------|-------------|
| `mkdir` | `mkdir -pv` | Create directories recursively with verbose output |
| `rm` | `rm -i` | Remove files with confirmation prompt |
| `mv` | `mv -i` | Move files with confirmation for overwrites |
| `cp` | `cp -i` | Copy files with confirmation for overwrites |
| `ln` | `ln -i` | Create links with confirmation |
| `chmod` | `chmod --preserve-root` | Change permissions with root protection |
| `chown` | `chown --preserve-root` | Change ownership with root protection |
| `open` | `xdg-open .` | Open current directory in file manager |
| `findf` | `find . -name` | Find files by name in current directory |
| `findp` | `find . -type f -perm` | Find files by permissions |
| `tree` | `tree -C` | Display directory tree with colors |
| `dus` | `du -sh * \| sort -rh` | Show directory sizes sorted by size |
| `dsize` | `du -sh` | Show directory size |

### System Information & Monitoring
| Alias | Command | Description |
|-------|---------|-------------|
| `update` | `sudo apt update && sudo apt upgrade -y` | Update system packages (Debian/Ubuntu) |
| `install` | `sudo apt install` | Install packages |
| `search` | `apt search` | Search for packages |
| `duf` | `df -h` | Display disk usage in human-readable format |
| `free` | `free -h` | Show memory usage in human-readable format |
| `psg` | `ps aux \| grep` | Search running processes |
| `pscpu` | `ps auxf \| sort -nr -k 3` | Show processes sorted by CPU usage |
| `psmem` | `ps auxf \| sort -nr -k 4` | Show processes sorted by memory usage |
| `meminfo` | `cat /proc/meminfo` | Display detailed memory information |
| `cpuinfo` | `cat /proc/cpuinfo` | Display CPU information |
| `distro` | `cat /etc/*-release` | Show distribution information |
| `kernel` | `uname -r` | Show kernel version |
| `arch` | `uname -m` | Show system architecture |
| `btop` | `btop \|\| htop \|\| top` | Launch best available process viewer |

### Network & Connectivity
| Alias | Command | Description |
|-------|---------|-------------|
| `myip` | `ip addr show \| grep inet` | Display all IP addresses |
| `myip4` | `ip addr show \| grep 'inet ' \| grep -v '127.0.0.1' \| awk '{print $2}' \| cut -d/ -f1` | Show IPv4 addresses only |
| `myip6` | `ip addr show \| grep 'inet6 ' \| grep -v '::1' \| awk '{print $2}' \| cut -d/ -f1` | Show IPv6 addresses only |
| `publicip` | `curl -s ifconfig.me` | Show public IP address |
| `localip` | `hostname -I` | Show local IP addresses |
| `ports` | `netstat -tulanp` | Show all listening ports |
| `listening` | `lsof -i -P -n \| grep LISTEN` | Show listening services |
| `ping` | `ping -c 5` | Ping with 5 packets |
| `fastping` | `ping -c 100 -s.2` | Fast ping test |
| `firewall` | `sudo ufw status verbose` | Show firewall status |
| `iptlist` | `sudo iptables -L -n -v --line-numbers` | List iptables rules |
| `iptlistin` | `sudo iptables -L INPUT -n -v --line-numbers` | List input iptables rules |
| `iptlistout` | `sudo iptables -L OUTPUT -n -v --line-numbers` | List output iptables rules |

### Git Operations (Development)
| Alias | Command | Description |
|-------|---------|-------------|
| `gs` | `git status` | Show git repository status |
| `ga` | `git add` | Add files to staging |
| `gaa` | `git add .` | Add all files to staging |
| `gc` | `git commit -m` | Commit with message |
| `gca` | `git commit -am` | Add all and commit with message |
| `gcp` | `git commit -am "Update" && git push` | Quick commit and push |
| `gp` | `git push` | Push to remote repository |
| `gpl` | `git pull` | Pull from remote repository |
| `gl` | `git log --oneline` | Show compact git log |
| `glo` | `git log --oneline --graph --decorate --all` | Show detailed git log with graph |
| `gb` | `git branch` | Show git branches |
| `gco` | `git checkout` | Checkout branch or file |
| `gcb` | `git checkout -b` | Create and checkout new branch |
| `gd` | `git diff` | Show git differences |
| `gdc` | `git diff --cached` | Show staged differences |
| `grs` | `git reset --soft HEAD~1` | Soft reset to previous commit |
| `grh` | `git reset --hard HEAD~1` | Hard reset to previous commit |
| `gst` | `git stash` | Stash changes |
| `gstp` | `git stash pop` | Apply and remove latest stash |
| `gclone` | `git clone` | Clone repository |
| `gfetch` | `git fetch` | Fetch from remote |
| `gmerge` | `git merge` | Merge branches |
| `grebase` | `git rebase` | Rebase current branch |

### Docker & Containerization (DevOps)
| Alias | Command | Description |
|-------|---------|-------------|
| `dps` | `docker ps` | Show running containers |
| `dpsa` | `docker ps -a` | Show all containers |
| `di` | `docker images` | Show docker images |
| `dex` | `docker exec -it` | Execute command in container |
| `dlog` | `docker logs` | Show container logs |
| `dlogf` | `docker logs -f` | Follow container logs |
| `dstop` | `docker stop` | Stop container |
| `dstart` | `docker start` | Start container |
| `drm` | `docker rm` | Remove container |
| `drmi` | `docker rmi` | Remove image |
| `dprune` | `docker system prune -f` | Clean up unused resources |
| `dpruneall` | `docker system prune -a -f` | Clean up all unused resources |
| `dvolumes` | `docker volume ls` | List docker volumes |
| `dnetworks` | `docker network ls` | List docker networks |
| `dcompose` | `docker-compose` | Docker compose command |
| `dcup` | `docker-compose up` | Start docker-compose services |
| `dcdown` | `docker-compose down` | Stop docker-compose services |
| `dcbuild` | `docker-compose build` | Build docker-compose services |
| `dclogs` | `docker-compose logs` | Show docker-compose logs |

### Kubernetes (DevOps)
| Alias | Command | Description |
|-------|---------|-------------|
| `k` | `kubectl` | Kubernetes command shortcut |
| `kg` | `kubectl get` | Get kubernetes resources |
| `kd` | `kubectl describe` | Describe kubernetes resources |
| `kdel` | `kubectl delete` | Delete kubernetes resources |
| `kpods` | `kubectl get pods` | Show pods |
| `ksvc` | `kubectl get services` | Show services |
| `kns` | `kubectl get namespaces` | Show namespaces |
| `kctx` | `kubectl config current-context` | Show current context |
| `klog` | `kubectl logs` | Show pod logs |
| `kexec` | `kubectl exec -it` | Execute command in pod |
| `kapply` | `kubectl apply -f` | Apply kubernetes configuration |

### Web Development
| Alias | Command | Description |
|-------|---------|-------------|
| `serve` | `python3 -m http.server 8000` | Start HTTP server on port 8000 |
| `serve8080` | `python3 -m http.server 8080` | Start HTTP server on port 8080 |
| `phpserve` | `php -S localhost:8000` | Start PHP development server |
| `nodeserve` | `npx http-server` | Start Node.js HTTP server |
| `liveserver` | `live-server --port=3000` | Start live-reload server |
| `webtest` | `curl -I` | Test web response |
| `header` | `curl -I` | Check HTTP headers |
| `jsonpp` | `python3 -m json.tool` | Pretty print JSON |
| `urlencode` | `python3 -c "import sys, urllib.parse; print(urllib.parse.quote(sys.argv[1]))"` | URL encode string |
| `urldecode` | `python3 -c "import sys, urllib.parse; print(urllib.parse.unquote(sys.argv[1]))"` | URL decode string |

### Text Processing & Editing
| Alias | Command | Description |
|-------|---------|-------------|
| `grep` | `grep --color=auto` | Grep with color highlighting |
| `egrep` | `egrep --color=auto` | Extended grep with colors |
| `fgrep` | `fgrep --color=auto` | Fixed grep with colors |
| `vi` | `vim` | Use vim as default vi |
| `edit` | `nano` | Use nano as default editor |
| `count` | `wc -l` | Count lines in file |
| `countw` | `wc -w` | Count words in file |
| `countc` | `wc -c` | Count characters in file |
| `tail10` | `tail -n 10` | Show last 10 lines |
| `head10` | `head -n 10` | Show first 10 lines |
| `middle` | `sed -n "5,10p"` | Show lines 5-10 |
| `replace` | `sed -i` | Replace text in file |
| `lower` | `tr "[:upper:]" "[:lower:]"` | Convert text to lowercase |
| `upper` | `tr "[:lower:]" "[:upper:]"` | Convert text to uppercase |
| `trim` | `awk "{gsub(/^[ \\t]+|[ \\t]+$/,\"\")}1"` | Trim whitespace |

### Archive & Compression
| Alias | Command | Description |
|-------|---------|-------------|
| `tarzip` | `tar -czf` | Create gzipped tar archive |
| `tarunzip` | `tar -xzf` | Extract gzipped tar archive |
| `tarbzip` | `tar -cjf` | Create bzip2 tar archive |
| `tarunbzip` | `tar -xjf` | Extract bzip2 tar archive |
| `zipdir` | `zip -r` | Create zip archive recursively |
| `extract` | Smart extraction function | Auto-detect and extract any archive format |

### Node.js/NPM Development
| Alias | Command | Description |
|-------|---------|-------------|
| `ni` | `npm install` | Install npm packages |
| `nid` | `npm install --save-dev` | Install dev dependencies |
| `nig` | `npm install -g` | Install global packages |
| `nus` | `npm uninstall --save` | Uninstall npm package |
| `nud` | `npm uninstall --save-dev` | Uninstall dev dependency |
| `nug` | `npm uninstall -g` | Uninstall global package |
| `nrs` | `npm run start` | Run start script |
| `nrb` | `npm run build` | Run build script |
| `nrt` | `npm run test` | Run test script |
| `nrd` | `npm run dev` | Run development script |
| `nls` | `npm list` | List installed packages |
| `nout` | `npm outdated` | Show outdated packages |
| `nup` | `npm update` | Update packages |
| `ya` | `yarn add` | Add yarn package |
| `yad` | `yarn add --dev` | Add dev dependency with yarn |
| `yr` | `yarn remove` | Remove yarn package |
| `ys` | `yarn start` | Yarn start script |
| `yb` | `yarn build` | Yarn build script |
| `yt` | `yarn test` | Yarn test script |
| `yd` | `yarn dev` | Yarn development script |

### Python Development
| Alias | Command | Description |
|-------|---------|-------------|
| `py` | `python3` | Python 3 shortcut |
| `python` | `python3` | Python 3 alias |
| `pip` | `pip3` | Pip 3 shortcut |
| `venv` | `python3 -m venv` | Create virtual environment |
| `activate` | `source venv/bin/activate` | Activate virtual environment |
| `deactivate` | `deactivate` | Deactivate virtual environment |
| `freeze` | `pip freeze > requirements.txt` | Save package list |
| `pipi` | `pip install` | Install Python package |
| `pipir` | `pip install -r requirements.txt` | Install from requirements |
| `pipu` | `pip uninstall` | Uninstall Python package |
| `pipup` | `pip install --upgrade` | Upgrade Python package |
| `piplist` | `pip list` | List installed packages |
| `pipout` | `pip list --outdated` | Show outdated packages |

### Database Operations
| Alias | Command | Description |
|-------|---------|-------------|
| `pgstart` | `sudo systemctl start postgresql` | Start PostgreSQL |
| `pgstop` | `sudo systemctl stop postgresql` | Stop PostgreSQL |
| `pgrestart` | `sudo systemctl restart postgresql` | Restart PostgreSQL |
| `pgstatus` | `sudo systemctl status postgresql` | PostgreSQL status |
| `pglogin` | `sudo -u postgres psql` | Login to PostgreSQL |
| `mysqlstart` | `sudo systemctl start mysql` | Start MySQL |
| `mysqlstop` | `sudo systemctl stop mysql` | Stop MySQL |
| `mysqlrestart` | `sudo systemctl restart mysql` | Restart MySQL |
| `mysqlstatus` | `sudo systemctl status mysql` | MySQL status |
| `mysqllogin` | `mysql -u root -p` | Login to MySQL |
| `mongostart` | `sudo systemctl start mongod` | Start MongoDB |
| `mongostop` | `sudo systemctl stop mongod` | Stop MongoDB |
| `mongologin` | `mongo` | Login to MongoDB |

### System Services Management
| Alias | Command | Description |
|-------|---------|-------------|
| `services` | `systemctl list-units --type=service` | List all services |
| `start` | `sudo systemctl start` | Start system service |
| `stop` | `sudo systemctl stop` | Stop system service |
| `restart` | `sudo systemctl restart` | Restart system service |
| `reload` | `sudo systemctl reload` | Reload service configuration |
| `status` | `sudo systemctl status` | Show service status |
| `enable` | `sudo systemctl enable` | Enable service at boot |
| `disable` | `sudo systemctl disable` | Disable service at boot |
| `mask` | `sudo systemctl mask` | Mask service |
| `unmask` | `sudo systemctl unmask` | Unmask service |
| `daemon-reload` | `sudo systemctl daemon-reload` | Reload systemd daemon |

### Log Analysis & System Monitoring
| Alias | Command | Description |
|-------|---------|-------------|
| `logs` | `sudo journalctl -f` | Follow system logs |
| `syslog` | `sudo tail -f /var/log/syslog` | Follow system log file |
| `authlog` | `sudo tail -f /var/log/auth.log` | Follow authentication logs |
| `kernlog` | `sudo tail -f /var/log/kern.log` | Follow kernel logs |
| `apachelog` | `sudo tail -f /var/log/apache2/error.log` | Follow Apache error logs |
| `nginxlog` | `sudo tail -f /var/log/nginx/error.log` | Follow Nginx error logs |
| `iotop` | `sudo iotop` | Monitor I/O usage |
| `nethogs` | `sudo nethogs` | Monitor network usage by process |
| `iftop` | `sudo iftop` | Monitor network traffic |
| `watch` | `watch -n 1` | Watch command output every second |
| `whoisport` | `sudo lsof -i :` | Find process using specific port |

### Process Management
| Alias | Command | Description |
|-------|---------|-------------|
| `killall` | `killall` | Kill all processes by name |
| `pkill` | `pkill` | Kill processes by pattern |
| `pgrep` | `pgrep` | Find processes by pattern |
| `jobs` | `jobs -l` | List active jobs |
| `nohup` | `nohup` | Run command immune to hangups |
| `bg` | `bg` | Put job in background |
| `fg` | `fg` | Bring job to foreground |
| `disown` | `disown -h` | Remove job from shell job table |

### Security & Permissions
| Alias | Command | Description |
|-------|---------|-------------|
| `perm644` | `chmod 644` | Set file permissions to 644 |
| `perm755` | `chmod 755` | Set file permissions to 755 |
| `perm777` | `chmod 777` | Set file permissions to 777 |
| `permdir` | `chmod 755` | Set directory permissions |
| `permfile` | `chmod 644` | Set file permissions |
| `permexec` | `chmod +x` | Make file executable |
| `chownwww` | `sudo chown -R www-data:www-data` | Change owner to www-data |
| `chownuser` | `sudo chown -R $USER:$USER` | Change owner to current user |
| `showusers` | `cut -d: -f1 /etc/passwd` | Show all system users |
| `showgroups` | `cut -d: -f1 /etc/group` | Show all system groups |

### Quick File Operations
| Alias | Command | Description |
|-------|---------|-------------|
| `touch` | `touch` | Create empty file or update timestamp |
| `which` | `which` | Locate command |
| `locate` | `locate` | Find files by name |
| `updatedb` | `sudo updatedb` | Update locate database |
| `type` | `type` | Display command type |
| `file` | `file` | Determine file type |
| `stat` | `stat` | Display file status |
| `lsattr` | `lsattr` | List file attributes |
| `chattr` | `chattr` | Change file attributes |

### Package Management (Multi-distro)
| Alias | Command | Description |
|-------|---------|-------------|
| `aptupdate` | `sudo apt update` | Update package list (Debian/Ubuntu) |
| `aptupgrade` | `sudo apt upgrade` | Upgrade packages (Debian/Ubuntu) |
| `aptinstall` | `sudo apt install` | Install package (Debian/Ubuntu) |
| `aptremove` | `sudo apt remove` | Remove package (Debian/Ubuntu) |
| `aptpurge` | `sudo apt purge` | Purge package (Debian/Ubuntu) |
| `aptsearch` | `apt search` | Search packages (Debian/Ubuntu) |
| `aptshow` | `apt show` | Show package info (Debian/Ubuntu) |
| `aptlist` | `apt list --installed` | List installed packages (Debian/Ubuntu) |
| `aptclean` | `sudo apt autoremove && sudo apt autoclean` | Clean package cache (Debian/Ubuntu) |
| `yumupdate` | `sudo yum update` | Update packages (RHEL/CentOS) |
| `yuminstall` | `sudo yum install` | Install package (RHEL/CentOS) |
| `yumremove` | `sudo yum remove` | Remove package (RHEL/CentOS) |
| `yumsearch` | `yum search` | Search packages (RHEL/CentOS) |

### Quick Directory Navigation
| Alias | Command | Description |
|-------|---------|-------------|
| `downloads` | `cd ~/Downloads` | Navigate to Downloads folder |
| `documents` | `cd ~/Documents` | Navigate to Documents folder |
| `desktop` | `cd ~/Desktop` | Navigate to Desktop folder |
| `projects` | `cd ~/Projects` | Navigate to Projects folder |
| `www` | `cd /var/www` | Navigate to web directory |
| `etc` | `cd /etc` | Navigate to etc directory |
| `var` | `cd /var` | Navigate to var directory |
| `tmp` | `cd /tmp` | Navigate to temp directory |
| `opt` | `cd /opt` | Navigate to opt directory |
| `usr` | `cd /usr` | Navigate to usr directory |

### History & Command Management
| Alias | Command | Description |
|-------|---------|-------------|
| `h` | `history` | Show command history |
| `hgrep` | `history \| grep` | Search command history |
| `hclear` | `history -c` | Clear command history |
| `reload` | `source ~/.bashrc` | Reload bash configuration |
| `editbash` | `nano ~/.bashrc` | Edit bash configuration |
| `editzsh` | `nano ~/.zshrc` | Edit zsh configuration |
| `aliases` | `alias \| sort` | Show all aliases sorted |

### Productivity Utilities
| Alias | Command | Description |
|-------|---------|-------------|
| `weather` | `curl wttr.in` | Show weather information |
| `qr` | `qrencode -t ansiutf8` | Generate QR code |
| `shorten` | `curl -F"shorten=" https://rel.ink` | Shorten URL |
| `dict` | `dict` | Dictionary lookup |
| `calc` | `bc -l` | Calculator |
| `timer` | Timer function | Simple command-line timer |
| `stopwatch` | Stopwatch function | Command-line stopwatch |
| `random` | `shuf -i 1-100 -n 1` | Generate random number |
| `uuid` | `uuidgen` | Generate UUID |
| `epoch` | `date +%s` | Show current epoch time |
| `timestamp` | `date "+%Y-%m-%d %H:%M:%S"` | Show formatted timestamp |
| `isodate` | `date -Iseconds` | Show ISO formatted date |

### Clipboard Operations (if xclip is installed)
| Alias | Command | Description |
|-------|---------|-------------|
| `copy` | `xclip -selection clipboard` | Copy to clipboard |
| `paste` | `xclip -selection clipboard -o` | Paste from clipboard |
| `copyfile` | `xclip -selection clipboard <` | Copy file content to clipboard |

### SSH & Remote Operations
| Alias | Command | Description |
|-------|---------|-------------|
| `sshconfig` | `nano ~/.ssh/config` | Edit SSH configuration |
| `sshkey` | `ssh-keygen -t rsa -b 4096` | Generate SSH key |
| `sshcopy` | `ssh-copy-id` | Copy SSH key to remote |
| `sshtest` | `ssh -T` | Test SSH connection |
| `tunnel` | `ssh -L` | Create SSH tunnel |
| `sshhostcheck` | `ssh -o StrictHostKeyChecking=no` | SSH without host checking |

### Resource Monitoring
| Alias | Command | Description |
|-------|---------|-------------|
| `temp` | `sensors` | Show temperature sensors |
| `battery` | `upower -i /org/freedesktop/UPower/devices/BAT0` | Show battery status |
| `cpufreq` | `cat /proc/cpuinfo \| grep "cpu MHz"` | Show CPU frequencies |
| `loadavg` | `cat /proc/loadavg` | Show load average |
| `uptime` | `uptime` | Show system uptime |
| `whoami` | `whoami` | Show current user |
| `id` | `id` | Show user and group IDs |
| `groups` | `groups` | Show user groups |

### Smart Functions
| Alias | Function | Description |
|-------|----------|-------------|
| `mkcd` | `mkdir -p "$1" && cd "$1"` | Create directory and enter it |
| `backup` | `cp "$1" "$1.backup.$(date +%Y%m%d_%H%M%S)"` | Create timestamped backup |
| `extract_here` | Extract function | Extract archive to new directory |
| `weather_city` | `curl "wttr.in/$1"` | Show weather for specific city |

### Miscellaneous Utilities
| Alias | Command | Description |
|-------|---------|-------------|
| `todo` | `nano ~/todo.txt` | Open todo list |
| `notes` | `nano ~/notes.txt` | Open notes file |
| `journal` | `echo "$(date): " >> ~/journal.txt && nano ~/journal.txt` | Add journal entry |
| `pomodoro` | `sleep 1500 && notify-send "Pomodoro" "25 minutes completed!"` | 25-minute timer |
| `matrix` | `cmatrix` | Matrix screensaver effect |
| `starwars` | `telnet towel.blinkenlights.nl` | ASCII Star Wars |
| `fortune` | `fortune` | Random fortune |
| `cowsay` | `cowsay` | Cow saying text |

### Quick System Fixes
| Alias | Command | Description |
|-------|---------|-------------|
| `fixpermissions` | `find . -type f -exec chmod 644 {} \\; && find . -type d -exec chmod 755 {} \\;` | Fix file permissions |
| `fixowner` | `sudo chown -R $USER:$USER` | Fix ownership to current user |
| `resetnetwork` | `sudo systemctl restart networking` | Reset network configuration |
| `flushdns` | `sudo systemctl restart systemd-resolved` | Flush DNS cache |
| `cleancache` | `sudo apt clean && sudo apt autoremove` | Clean package cache |
| `diskclean` | `sudo apt clean && sudo apt autoremove && sudo journalctl --vacuum-time=3d` | Clean disk space |

## Configuration Files

The enhanced script modifies one of the following files based on your shell:

- **Bash**: `~/.bashrc`
- **Zsh**: `~/.zshrc`

## Safety Features

- **Interactive Removal**: The `rm` alias includes the `-i` flag for confirmation prompts
- **Move Protection**: The `mv` alias includes the `-i` flag to prevent accidental overwrites
- **Copy Protection**: The `cp` alias includes the `-i` flag to prevent accidental overwrites
- **Root Protection**: System commands like `chmod` and `chown` include `--preserve-root` flags
- **Non-destructive**: Script only appends to configuration files, doesn't modify existing content
- **Organized Structure**: Aliases are clearly organized and commented for easy management

## User Type Benefits

### 🎓 **Students & Beginners**
- Basic navigation shortcuts reduce typing by 60-80%
- Safe file operations with confirmation prompts
- Easy system information access
- Simple text processing tools

### 💻 **Software Developers**
- Complete Git workflow (22+ aliases save 70% keystrokes)
- Language-specific shortcuts (Python, Node.js)
- Development server shortcuts
- Code editing and file management

### 🔧 **System Administrators**
- Service management shortcuts (11+ systemctl aliases)
- Log monitoring and analysis tools
- System information at fingertips
- Security and permissions management

### ☁️ **DevOps Engineers**
- Docker and Kubernetes shortcuts (30+ aliases save 75% typing)
- Infrastructure management tools
- Database administration shortcuts
- Network diagnostics and monitoring

### 🌐 **Web Developers**
- Local development servers
- HTTP testing and debugging tools
- JSON processing utilities
- Web-specific file operations

## Package Dependencies

Some aliases require additional packages for full functionality:

```bash
# Enhanced monitoring tools
sudo apt install htop btop iotop nethogs iftop tree

# Network tools
sudo apt install net-tools curl wget lsof

# Development tools
sudo apt install git nodejs npm python3-pip

# Archive tools
sudo apt install zip unzip p7zip-full

# System monitoring
sudo apt install lm-sensors

# Clipboard operations
sudo apt install xclip

# Fun utilities
sudo apt install fortune cowsay figlet lolcat cmatrix

# QR code generation
sudo apt install qrencode

# Dictionary lookup
sudo apt install dict
```

## Customization

### Adding Personal Aliases
After running the script, add your personal aliases:

```bash
# Edit your shell configuration file
nano ~/.bashrc    # or ~/.zshrc

# Add personal aliases at the end
alias work='cd ~/work && code .'
alias deploy='./deploy.sh && git push'
alias myserver='ssh user@myserver.com'
```

### Modifying Existing Aliases
```bash
# Override any alias by redefining it
alias ll='ls -la --color=auto'  # Add colors to ll
alias update='sudo dnf update'  # Change for Fedora
```

### Creating Custom Functions
```bash
# Add complex functions
mkproject() {
    mkdir -p "$1" && cd "$1" && git init && npm init -y
}
```

## Troubleshooting

### Unsupported Shell Error
If you see "Unsupported shell. Please use Bash or Zsh":
- Check your current shell: `echo $SHELL`
- Switch to Bash: `bash`
- Switch to Zsh: `zsh` (if installed)

### Aliases Not Working
If aliases don't work after installation:
1. Reload your configuration: `source ~/.bashrc` or `source ~/.zshrc`
2. Restart your terminal
3. Check if aliases were added: `tail -50 ~/.bashrc` or `tail -50 ~/.zshrc`
4. Verify shell detection: `echo $BASH_VERSION` or `echo $ZSH_VERSION`

### Command Not Found Errors
Some aliases depend on packages that might not be installed:
```bash
# Check if command exists
which htop
which docker
which kubectl

# Install missing packages
sudo apt install htop docker.io kubectl
```

### Permission Issues
If you encounter permission errors:
- Ensure the script is executable: `chmod +x alias_setup.sh`
- Check write permissions to your home directory: `ls -la ~/`
- Run with appropriate user permissions (avoid sudo unless necessary)

### Conflicts with Existing Aliases
If aliases conflict with existing ones:
1. Check existing aliases: `alias | grep alias_name`
2. Remove conflicting aliases from your config file
3. Or modify the script to use different names

## Usage Examples

After installation, you can immediately use the enhanced aliases:

### Basic Operations
```bash
# File management
ll              # Detailed file listing
back            # Go up one directory
...             # Go up two directories
mkcd newproject # Create and enter directory
dsize           # Show directory size

# System monitoring
pscpu           # Show top CPU processes
psmem           # Show top memory processes
duf             # Disk usage
myip4           # Show IPv4 address
ports           # Show listening ports
```

### Development Workflow
```bash
# Git operations
gs              # Git status
gaa             # Git add all
gc "Fix bug"    # Git commit with message
gp              # Git push
gl              # Git log oneline

# Node.js development
ni              # npm install
nrs             # npm run start
nrb             # npm run build

# Python development
py script.py    # Run Python script
venv myenv      # Create virtual environment
activate        # Activate environment
pipi requests   # Install package
```

### DevOps Operations
```bash
# Docker management
dps             # Show running containers
dex myapp bash  # Execute bash in container
dlog myapp      # Show container logs
dcup            # Docker compose up

# Kubernetes
kpods           # Show pods
klog mypod      # Show pod logs
kexec mypod bash # Execute in pod

# System services
status nginx    # Check service status
restart apache2 # Restart service
logs            # Follow system logs
```

### System Administration
```bash
# Service management
services        # List all services
start mysql     # Start service
stop nginx      # Stop service
enable docker   # Enable at boot

# Log analysis
authlog         # Follow auth logs
nginxlog        # Follow nginx logs
syslog          # Follow system logs

# Security
firewall        # Check firewall status
perm755 script  # Set permissions
showusers       # List system users
```

### Database Operations
```bash
# PostgreSQL
pgstart         # Start PostgreSQL
pgstatus        # Check status
pglogin         # Login to PostgreSQL

# MySQL
mysqlstart      # Start MySQL
mysqlstatus     # Check status
mysqllogin      # Login to MySQL

# MongoDB
mongostart      # Start MongoDB
mongologin      # Login to MongoDB
```

### Web Development
```bash
# Local servers
serve           # Start HTTP server on port 8000
phpserve        # Start PHP server
nodeserve       # Start Node.js server

# Testing and debugging
header google.com  # Check HTTP headers
jsonpp < file.json # Pretty print JSON
webtest myapi.com  # Test web response
```

### Text Processing
```bash
# File operations
count file.txt     # Count lines
head10 file.txt    # First 10 lines
tail10 file.txt    # Last 10 lines
lower < input.txt  # Convert to lowercase
upper < input.txt  # Convert to uppercase
```

### Archive Operations
```bash
# Compression
tarzip backup.tar.gz *    # Create tar.gz archive
zipdir project.zip dir/   # Create zip archive

# Extraction (smart function)
extract file.tar.gz       # Auto-detect and extract
extract file.zip          # Works with any format
extract file.7z           # Handles multiple formats
```

## Performance Impact

### Keystroke Savings Analysis
- **Basic navigation**: 60-80% reduction (e.g., `cd ../..` → `...`)
- **Git operations**: 70-90% reduction (e.g., `git status` → `gs`)
- **Docker commands**: 75-85% reduction (e.g., `docker ps` → `dps`)
- **System services**: 65-75% reduction (e.g., `systemctl restart nginx` → `restart nginx`)
- **Database operations**: 70-80% reduction (e.g., `sudo systemctl start postgresql` → `pgstart`)
- **Overall productivity**: Estimated 40-60% faster command execution

### Memory Usage
- Aliases add minimal memory overhead (~2-3KB total for 200+ aliases)
- Smart functions use memory only when called
- No performance impact on system resources
- Faster command execution due to reduced typing

## Uninstallation

To remove all aliases:

### Complete Removal
```bash
# Open your shell configuration file
nano ~/.bashrc    # or ~/.zshrc

# Delete the entire section between:
# # === Enhanced Custom Aliases Collection ===
# and
# # === End of Enhanced Custom Aliases ===#

# Reload configuration
source ~/.bashrc  # or source ~/.zshrc
```

### Selective Removal
```bash
# Remove specific categories by deleting relevant sections
# For example, remove only Docker aliases by deleting the Docker section
```

### Backup Before Removal
```bash
# Create backup before removing
cp ~/.bashrc ~/.bashrc.backup.$(date +%Y%m%d)
```

## Notes

- The `update` alias is optimized for Debian-based systems (Ubuntu, Debian). Fedora users should modify to use `dnf update && dnf upgrade`
- The `gcp` alias uses a generic commit message "Update" - customize for your workflow
- Some aliases may conflict with existing system commands or personal preferences
- The script appends aliases, so running it multiple times will create duplicates
- Docker and Kubernetes aliases require respective tools to be installed
- Database aliases require database servers to be installed and configured
- Web development aliases work with standard development tools
- Smart functions like `extract` automatically detect file types
- Network aliases may require additional permissions for some commands

## Version Compatibility

- **Bash**: 3.0+ (Recommended: 4.0+)
- **Zsh**: 4.0+ (Recommended: 5.0+)
- **Linux**: All major distributions (Ubuntu, Debian, CentOS, RHEL, Fedora, Arch)
- **macOS**: Compatible (some commands may need adjustment for BSD variants)
- **Windows WSL**: Full compatibility with WSL 1 and WSL 2

## Contributing

To improve this script:

### How to Contribute
1. **Add new aliases**: Submit useful aliases for specific workflows
2. **Improve documentation**: Enhance examples and troubleshooting
3. **Cross-platform testing**: Test on different Linux distributions
4. **Performance optimization**: Suggest more efficient implementations
5. **User feedback**: Report issues and suggest improvements

### Contribution Guidelines
- Follow existing naming conventions (short, memorable names)
- Include clear descriptions for new aliases
- Test on multiple shell types (bash, zsh)
- Update documentation for new features
- Consider security implications of new aliases
- Organize aliases into appropriate categories

### Extension Ideas
- **Cloud platform aliases** (AWS CLI, Azure CLI, GCP)
- **Container orchestration** (Docker Swarm, Rancher)
- **Monitoring tools** (Prometheus, Grafana, Zabbix)
- **CI/CD platforms** (Jenkins, GitLab CI, GitHub Actions)
- **Database management** (Redis, Elasticsearch, InfluxDB)
- **Security tools** (nmap, OpenVAS, fail2ban)
- **Infrastructure as Code** (Terraform, Ansible, Pulumi)

---

*This enhanced documentation covers the comprehensive alias setup script - a powerful tool for dramatically improving command-line productivity across all user types and workflows. Save thousands of keystrokes daily with this professionally curated collection of 200+ time-saving aliases.*