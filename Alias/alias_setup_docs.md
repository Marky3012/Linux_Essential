# Alias Setup Script Documentation

## Overview

The `alias_setup.sh` script is a bash utility that automatically adds a collection of useful command-line aliases to your shell configuration file. It supports both Bash and Zsh shells and provides convenient shortcuts for common Linux/Unix operations.

## Features

- **Shell Detection**: Automatically detects whether you're using Bash or Zsh
- **Safe Installation**: Appends aliases to the appropriate configuration file
- **Common Shortcuts**: Includes frequently used command aliases for productivity
- **Git Integration**: Quick git commands for version control workflows
- **System Utilities**: Aliases for system monitoring and file operations

## Prerequisites

- Linux or Unix-based operating system
- Bash or Zsh shell
- Basic command-line permissions

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
3. **Alias Installation**: Appends all aliases to the configuration file using a heredoc
4. **Confirmation**: Provides feedback on successful installation

## Included Aliases

### File and Directory Operations
| Alias | Command | Description |
|-------|---------|-------------|
| `ll` | `ls -alh` | List all files in long format with human-readable sizes |
| `back` | `cd ..` | Navigate to parent directory |
| `findf` | `find . -name` | Find files by name in current directory |
| `open` | `xdg-open .` | Open current directory in file manager |

### File Safety
| Alias | Command | Description |
|-------|---------|-------------|
| `rm` | `rm -i` | Remove files with confirmation prompt |
| `mv` | `mv -i` | Move files with confirmation for overwrites |

### System Information
| Alias | Command | Description |
|-------|---------|-------------|
| `duf` | `df -h` | Display disk usage in human-readable format |
| `free` | `free -m` | Show memory usage in megabytes |
| `psg` | `ps aux \| grep` | Search running processes |
| `myip` | `ip addr show \| grep inet` | Display IP addresses |

### System Maintenance
| Alias | Command | Description |
|-------|---------|-------------|
| `update` | `sudo apt update && sudo apt upgrade -y` | Update system packages (Debian/Ubuntu) |
| `cls` | `clear` | Clear terminal screen |

### Git Shortcuts
| Alias | Command | Description |
|-------|---------|-------------|
| `gs` | `git status` | Show git repository status |
| `gcp` | `git commit -am "Update" && git push` | Quick commit and push with generic message |

## Configuration Files

The script modifies one of the following files based on your shell:

- **Bash**: `~/.bashrc`
- **Zsh**: `~/.zshrc`

## Safety Features

- **Interactive Removal**: The `rm` alias includes the `-i` flag for confirmation prompts
- **Move Protection**: The `mv` alias includes the `-i` flag to prevent accidental overwrites
- **Non-destructive**: Script only appends to configuration files, doesn't modify existing content

## Customization

To add your own aliases after running the script, you can either:

1. **Edit the script** before running it to include your custom aliases
2. **Manually add aliases** to your shell configuration file after installation

Example of manual addition:
```bash
# Add to ~/.bashrc or ~/.zshrc
alias myalias='your_command_here'
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
3. Check if aliases were added: `tail ~/.bashrc` or `tail ~/.zshrc`

### Permission Issues
If you encounter permission errors:
- Ensure the script is executable: `chmod +x alias_setup.sh`
- Check write permissions to your home directory
- Run with appropriate user permissions (avoid sudo unless necessary)

## Usage Examples

After installation, you can use the aliases immediately:

```bash
# List files with details
ll

# Go back one directory
back

# Clear screen
cls

# Check git status
gs

# Find a file
findf "filename.txt"

# Check disk usage
duf

# Quick system update (Ubuntu/Debian)
update
```

## Uninstallation

To remove the aliases:
1. Open your shell configuration file (`~/.bashrc` or `~/.zshrc`)
2. Delete the section marked with `# === Custom Aliases ===`
3. Reload your configuration or restart your terminal

## Notes

- The `update` alias is designed for Debian-based systems (Ubuntu, Debian). Modify it for other distributions
- The `gcp` alias uses a generic commit message "Update" - consider customizing for your workflow
- Some aliases may conflict with existing system commands or personal preferences
- The script appends aliases, so running it multiple times will create duplicates

## Version Compatibility

- **Bash**: 3.0+
- **Zsh**: 4.0+
- **Linux**: Most distributions
- **macOS**: Compatible (may need to adjust some commands)

## Contributing

To improve this script:
1. Add more useful aliases
2. Include support for other shells (fish, tcsh)
3. Add platform-specific optimizations
4. Implement backup functionality before modification

---

*This documentation covers alias_setup.sh - a convenient tool for setting up productive command-line aliases.*