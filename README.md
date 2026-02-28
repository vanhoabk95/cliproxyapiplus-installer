# CLIProxyAPI Plus Installer

A comprehensive installation script for [CLIProxyAPI Plus](https://github.com/router-for-me/CLIProxyAPIPlus) that automates installation, upgrades, and management of the CLIProxyAPI Plus service on **Linux** and **Windows**.

**✨ Plus Version Features:**
- 🚀 **GitHub Copilot Support** - OAuth-based authentication for GitHub Copilot
- 🔐 **Kiro/AWS CodeWhisperer** - Web-based OAuth authentication with AWS Builder ID or IDC
- 📊 **Enhanced Monitoring** - Built-in metrics and rate limiting
- ⚡ **Advanced Features** - Background token refresh, cooldown management, and more

## Features

- 🚀 **Automatic Installation** - Detects your architecture and downloads the latest version
- 🔄 **Smart Upgrades** - Preserves your configuration during upgrades
- 🔑 **API Key Management** - Automatically generates secure API keys
- 🛡️ **Service Management** - Systemd (Linux) or NSSM Windows service support
- 📊 **Status Monitoring** - Check installation status and configuration
- 🧹 **Cleanup** - Automatically removes old versions (keeps latest 2)
- ⚡ **Zero-Downtime Updates** - Service is properly stopped and restarted during upgrades
- 🖥️ **Cross-Platform** - Supports Linux (amd64/arm64) and Windows (amd64/arm64)

## Quick Start

### Linux - One-Command Install

```bash
# Download and run the installer
curl -fsSL https://raw.githubusercontent.com/vanhoabk95/cliproxyapiplus-installer/refs/heads/master/cliproxyapi-installer | bash
```

### Linux - Manual Install

```bash
# Clone and run manually
git clone https://github.com/vanhoabk95/cliproxyapiplus-installer.git
cd cliproxyapiplus-installer
chmod +x cliproxyapi-installer
./cliproxyapi-installer
```

### Windows - Install

```cmd
:: Clone and run the installer
git clone https://github.com/vanhoabk95/cliproxyapiplus-installer.git
cd cliproxyapiplus-installer
cliproxyapi-installer.bat
```

After installation, to run as a Windows service (requires Administrator):
```cmd
cd %USERPROFILE%\cliproxyapi
install_service.bat
```

### After Installation

1. **Configure API keys** (if not automatically generated):

   Linux:
   ```bash
   cd ~/cliproxyapi && nano config.yaml
   ```
   Windows:
   ```cmd
   cd %USERPROFILE%\cliproxyapi
   notepad config.yaml
   ```

2. **Set up authentication** (choose one or more):
   ```bash
   cli-proxy-api-plus --login           # For Gemini
   cli-proxy-api-plus --codex-login     # For OpenAI
   cli-proxy-api-plus --claude-login    # For Claude
   cli-proxy-api-plus --qwen-login      # For Qwen
   cli-proxy-api-plus --iflow-login     # For iFlow
   cli-proxy-api-plus --copilot-login   # For GitHub Copilot (PLUS)
   
   # For Kiro/AWS CodeWhisperer (PLUS) - use web browser:
   # Visit: http://localhost:8317/v0/oauth/kiro
   ```

3. **Start the service**:

   **Linux:**
   ```bash
   # Direct execution
   ./cli-proxy-api

   # Or as a systemd service (recommended)
   systemctl --user enable cliproxyapi.service
   systemctl --user start cliproxyapi.service
   systemctl --user status cliproxyapi.service
   ```

   **Windows:**
   ```cmd
   :: Direct execution
   cli-proxy-api-plus.exe

   :: Or install as a Windows service (run as Administrator)
   install_service.bat
   ```

4. **Enable autostart on boot** (recommended):

   **Linux:**
   ```bash
   systemctl --user enable cliproxyapi.service
   ```

   **Windows:** The Windows service is set to auto-start by default when installed via `install_service.bat`.

> **💡 Pro Tip**: The installer automatically manages running processes during upgrades. If the service is running when you upgrade, it will be gracefully stopped, updated, and restarted automatically.

## Usage

### Linux

```bash
./cliproxyapi-installer [COMMAND]
```

| Command | Description |
|---------|-------------|
| `install` / `upgrade` | Install or upgrade CLIProxyAPI Plus (default) |
| `status` | Show current installation status |
| `auth` | Display authentication setup information |
| `check-config` | Verify configuration and API keys |
| `generate-key` | Generate a new API key |
| `manage-docs` | Manage documentation and check consistency |
| `uninstall` | Remove CLIProxyAPI Plus completely |
| `-h` / `--help` | Show help message |

### Windows

```cmd
cliproxyapi-installer.bat [COMMAND]
```

| Command | Description |
|---------|-------------|
| `install` / `upgrade` | Install or upgrade CLIProxyAPI Plus (default) |
| `status` | Show current installation status |
| `uninstall` | Remove CLIProxyAPI Plus completely |
| `help` / `-h` / `--help` | Show help message |

After installation, manage the Windows service with:
- `install_service.bat` - Install and configure NSSM Windows service (run as Admin)
- `uninstall_service.bat` - Remove the Windows service (run as Admin)

### Examples

```bash
# Linux: Install or upgrade
./cliproxyapi-installer

# Linux: Check status
./cliproxyapi-installer status
```

```cmd
:: Windows: Install or upgrade
cliproxyapi-installer.bat

:: Windows: Check status
cliproxyapi-installer.bat status
```

## Configuration

### Installation Directory

**Linux:** `~/cliproxyapi/`
```
~/cliproxyapi/
├── cli-proxy-api          # Main executable
├── config.yaml            # Configuration file
├── cliproxyapi.service    # Systemd service file
├── version.txt            # Current version info
├── x.x.x/                 # Version-specific directory
└── config_backup/         # Configuration backups
```

**Windows:** `%USERPROFILE%\cliproxyapi\`
```
%USERPROFILE%\cliproxyapi\
├── cli-proxy-api-plus.exe  # Main executable
├── config.yaml             # Configuration file
├── install_service.bat     # NSSM service installer
├── uninstall_service.bat   # NSSM service uninstaller
├── nssm-2.24\              # NSSM service manager
├── version.txt             # Current version info
├── x.x.x\                  # Version-specific directory
└── config_backup\          # Configuration backups
```

### API Keys

The installer automatically generates secure API keys in OpenAI format (`sk-...`). These keys are used for authenticating requests to your proxy server, **not** for provider authentication.

To view or modify your API keys:
```bash
cd ~/cliproxyapi
nano config.yaml
```

### Authentication Providers

CLIProxyAPI Plus supports multiple AI providers:

#### Standard Providers
- **Gemini (Google)**: `./cli-proxy-api --login`
- **OpenAI (Codex/GPT)**: `./cli-proxy-api --codex-login`
- **Claude (Anthropic)**: `./cli-proxy-api --claude-login`
- **Qwen (Qwen Chat)**: `./cli-proxy-api --qwen-login`
- **iFlow**: `./cli-proxy-api --iflow-login`

#### Plus-Exclusive Providers ✨
- **GitHub Copilot**: `./cli-proxy-api --copilot-login`
  - OAuth-based authentication provided by em4go
- **Kiro/AWS CodeWhisperer**: Web OAuth at `http://localhost:8317/v0/oauth/kiro`
  - Browser-based OAuth login with AWS Builder ID or AWS Identity Center (IDC)
  - Support for token import from Kiro IDE
  - Provided by fuko2935 and Ravens2121

> **💡 Tip**: Add `--no-browser` to any login command to print the URL instead of opening a browser automatically.

## Alternative Installation Methods

### Docker Deployment

For containerized deployment, CLIProxyAPI Plus also supports Docker:

```bash
# One-command Docker deployment
mkdir -p ~/cli-proxy && cd ~/cli-proxy

# Create docker-compose.yml
cat > docker-compose.yml << 'EOF'
services:
  cli-proxy-api:
    image: eceasy/cli-proxy-api-plus:latest
    container_name: cli-proxy-api-plus
    ports:
      - "8317:8317"
    volumes:
      - ./config.yaml:/CLIProxyAPI/config.yaml
      - ./auths:/root/.cli-proxy-api
      - ./logs:/CLIProxyAPI/logs
    restart: unless-stopped
EOF

# Download example config
curl -o config.yaml https://raw.githubusercontent.com/router-for-me/CLIProxyAPIPlus/main/config.example.yaml

# Pull and start
docker compose pull && docker compose up -d
```

See the [official Docker guide](https://github.com/router-for-me/CLIProxyAPIPlus#quick-deployment-with-docker) for more details.

### Choosing Your Installation Method

| Method | Best For | Pros | Cons |
|--------|----------|------|------|
| **Linux Installer** | Native Linux deployment | Direct execution, systemd integration, no container overhead | Linux only |
| **Windows Installer** | Native Windows deployment | NSSM service management, direct execution | Windows only |
| **Docker** | Cross-platform, containerized | Isolated environment, easy updates | Requires Docker, slight overhead |

## System Requirements

### Linux
- **Operating System**: Linux (amd64, arm64)
- **Required Tools**: `curl` or `wget`, `tar`
- **Shell**: Bash

### Windows
- **Operating System**: Windows 10 1803+ or Windows Server 2019+ (amd64, arm64)
- **Required Tools**: `curl` and `tar` (included with Windows 10+), PowerShell
- **For service management**: Administrator privileges for `install_service.bat`

### Installing Dependencies (Linux)

**Ubuntu/Debian:**
```bash
sudo apt-get install curl wget tar
```

**CentOS/RHEL:**
```bash
sudo yum install curl wget tar
```

**Fedora:**
```bash
sudo dnf install curl wget tar
```

## Systemd Service

The installer creates and manages a systemd service file for easy lifecycle management:

### ✨ Smart Service Management

The installer provides intelligent service handling during upgrades:

- **Automatic Detection**: Detects if the service is running before upgrades
- **Graceful Shutdown**: Safely stops the service before applying updates
- **Auto-Restart**: Restarts the service after successful upgrades
- **State Preservation**: Maintains the service's previous running state

### Basic Service Management

```bash
# Enable the service (starts on user login)
systemctl --user enable cliproxyapi.service

# Start the service
systemctl --user start cliproxyapi.service

# Check service status
systemctl --user status cliproxyapi.service

# View service logs
journalctl --user -u cliproxyapi.service -f

# Stop the service
systemctl --user stop cliproxyapi.service

# Restart the service
systemctl --user restart cliproxyapi.service
```

### Service Status During Upgrades

When you run `./cliproxyapi-installer upgrade`, the installer will:

1. **Check** if the service is currently running
2. **Stop** the service gracefully if it's active
3. **Apply** the upgrade (download, extract, update files)
4. **Restart** the service if it was running before
5. **Report** the final service status

You'll see output like:
```
[INFO] Service is currently running and will be restarted after upgrade
[INFO] Stopping CLIProxyAPI Plus service...
[SUCCESS] Service stopped
...
[INFO] Restarting CLIProxyAPI Plus service...
[SUCCESS] Service restarted successfully
```

### Autostart Configuration

**To enable CLIProxyAPI Plus to start automatically on system boot:**

```bash
# Enable the service for automatic startup on user login
systemctl --user enable cliproxyapi.service

# Verify the service is enabled
systemctl --user is-enabled cliproxyapi.service

# Check if the service will start on boot
systemctl --user is-active cliproxyapi.service
```

**To disable autostart:**
```bash
systemctl --user disable cliproxyapi.service
```

**Important Notes:**
- The `--user` flag means the service runs as your user and starts when you log in
- For system-wide startup (requires root), you would need to manually install the service file to `/etc/systemd/system/`
- User services require lingering to be enabled for startup without login: `loginctl enable-linger $USER`

**If the service is not working:**
```bash
# Reload systemd daemon
systemctl --user daemon-reload

# Check service status for errors
systemctl --user status cliproxyapi.service

# View detailed logs
journalctl --user -u cliproxyapi.service -n 50

# Check if service file exists
ls -la ~/.config/systemd/user/cliproxyapi.service
```

## Troubleshooting

### Common Issues

1. **Permission Denied**
    ```bash
    chmod +x cliproxyapi-installer
    ```

2. **Missing Dependencies**
    ```bash
    # Check what's missing
    ./cliproxyapi-installer status
    
    # Install required tools
    sudo apt-get install curl wget tar  # Ubuntu/Debian
    ```

3. **API Keys Not Configured**
    ```bash
    ./cliproxyapi-installer check-config
    # Follow the instructions to configure API keys
    ```

4. **Service Won't Start**
    ```bash
    # Check service logs
    journalctl --user -u cliproxyapi.service -n 50
    
    # Check configuration
    ./cliproxyapi-installer check-config
    ```

5. **Port Already in Use**
    ```bash
    # Check what's using port 8317
    netstat -tlnp | grep 8317
    
    # Stop the existing process
    pkill cli-proxy-api
    
    # Then restart the service
    systemctl --user restart cliproxyapi.service
    ```

6. **Systemd Service Issues**
    ```bash
    # Reload systemd daemon
    systemctl --user daemon-reload
    
    # Check if service file exists
    ls -la ~/.config/systemd/user/cliproxyapi.service
    
    # Reset service (disable and re-enable)
    systemctl --user disable cliproxyapi.service
    systemctl --user enable cliproxyapi.service
    systemctl --user start cliproxyapi.service
    ```

7. **Upgrade Service Issues**
    ```bash
    # If service doesn't restart after upgrade
    systemctl --user status cliproxyapi.service
    
    # Check recent service logs
    journalctl --user -u cliproxyapi.service -n 20
    
    # Manually restart if needed
    systemctl --user restart cliproxyapi.service
    ```

8. **Configuration Protection Issues**
    ```bash
    # If your config was accidentally overwritten (should never happen)
    # Check backup directory
    ls -la ~/cliproxyapi/config_backup/
    
    # Restore from latest backup
    cp ~/cliproxyapi/config_backup/config_YYYYMMDD_HHMMSS.yaml ~/cliproxyapi/config.yaml
    
    # Restart service after restoring
    systemctl --user restart cliproxyapi.service
    ```

9. **Windows: Service Won't Install** (Windows)
    ```cmd
    :: Make sure to run as Administrator
    :: Right-click install_service.bat -> Run as Administrator

    :: Check if NSSM is present
    dir %USERPROFILE%\cliproxyapi\nssm-2.24\win64\nssm.exe
    ```

10. **Windows: Upgrade Fails** (Windows)
    ```cmd
    :: Stop the service first
    net stop CLIProxyAPI

    :: Then run the installer
    cliproxyapi-installer.bat upgrade
    ```

### Getting Help

```bash
# Linux: Show all available commands
./cliproxyapi-installer --help

# Linux: Check installation status
./cliproxyapi-installer status
```

```cmd
:: Windows: Show all available commands
cliproxyapi-installer.bat help

:: Windows: Check installation status
cliproxyapi-installer.bat status
```

## Security Considerations

- API keys are automatically generated using cryptographically secure random strings
- Configuration files are stored in your home directory with standard permissions
- The systemd service runs with appropriate security restrictions
- Backups of configuration are created automatically during upgrades
- **User configurations are never overwritten** - your modifications are protected during upgrades

## Updates and Upgrades

The installer automatically checks for newer versions:

```bash
# Check for updates and upgrade if available
./cliproxyapi-installer upgrade

# Or simply run (upgrade is the default action)
./cliproxyapi-installer
```

### Smart Upgrade Process

During upgrades, the installer provides intelligent service management:

- **🔄 Service Management**: If the service is running, it's automatically stopped before upgrade and restarted afterward
- **🛡️ Configuration Protection**: Your `config.yaml` file is **never overwritten** - user modifications are preserved
- **💾 Automatic Backups**: Configuration backups are created automatically before any changes
- **🧹 Version Cleanup**: Old versions are cleaned up (latest 2 versions kept)
- **📋 Service Updates**: Systemd service file is updated if needed

### Upgrade Behavior

| Scenario | Service Action | Config Action |
|----------|----------------|---------------|
| Service running | Stop → Upgrade → Restart | Preserved with backup |
| Service stopped | Upgrade only | Preserved with backup |
| First install | N/A | Created from example with generated keys |

> **🔒 Your configuration is safe**: The installer uses a priority system that always preserves existing user configurations over example files.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This installer script is released under the same license as CLIProxyAPI Plus (MIT License).

## Support

- **CLIProxyAPI Plus Documentation**: https://github.com/router-for-me/CLIProxyAPIPlus
- **Installer Issues**: https://github.com/vanhoabk95/cliproxyapiplus-installer/issues
- **General Help**: Run `./cliproxyapi-installer --help`
- **Docker Deployment**: See [Quick Deployment with Docker](https://github.com/router-for-me/CLIProxyAPIPlus#quick-deployment-with-docker)

## Changelog

### Recent Improvements

#### ✨ **Windows Installer**
- **Windows Batch Installer**: New `cliproxyapi-installer.bat` for Windows systems
- **Auto-Download**: Downloads latest release from GitHub with architecture detection
- **NSSM Integration**: Copies `install_service.bat`, `uninstall_service.bat`, and NSSM into the install directory
- **Config Preservation**: Same upgrade-safe config handling as the Linux installer

#### ✨ **CLIProxyAPI Plus Support**
- **Plus Version Integration**: Full support for CLIProxyAPI Plus enhanced features
- **GitHub Copilot**: OAuth-based authentication for GitHub Copilot
- **Kiro/AWS CodeWhisperer**: Web-based OAuth authentication with AWS Builder ID or IDC
- **Enhanced Provider Support**: All Plus-exclusive providers properly configured

#### ✅ **Smart Service Management**
- **Automatic Service Detection**: Installer detects if CLIProxyAPI Plus service is running before upgrades
- **Graceful Service Handling**: Service is properly stopped before upgrade and restarted afterward
- **State Preservation**: Service maintains its previous running state after upgrades
- **Enhanced Logging**: Clear feedback about service status throughout the upgrade process

#### ✅ **Enhanced Configuration Protection**
- **Never Overwrite**: User-modified `config.yaml` files are never replaced during upgrades
- **Priority System**: Clear hierarchy for configuration preservation (backup → existing → previous → example)
- **Automatic Backups**: Configuration backups created before any upgrade operations
- **User Notifications**: Clear messaging when user configurations are preserved

#### ✅ **Improved Systemd Integration**
- **Fixed Service File**: Resolved systemd service configuration issues
- **Better Error Handling**: Improved service startup and restart reliability
- **Simplified Security**: Removed problematic restrictions while maintaining security

---

**Note**: This installer supports Linux and Windows systems. For Docker deployment, please refer to the main [CLIProxyAPI Plus repository](https://github.com/router-for-me/CLIProxyAPIPlus).

## About CLIProxyAPI Plus

CLIProxyAPI Plus is the enhanced version of CLIProxyAPI, adding third-party provider support maintained by community contributors:

- **GitHub Copilot support** (OAuth login) - by em4go
- **Kiro/AWS CodeWhisperer support** (OAuth web authentication) - by fuko2935 and Ravens2121
- **Enhanced features**: Rate limiting, metrics & monitoring, background token refresh, and more

All Plus features stay in lockstep with the mainline CLIProxyAPI features while providing additional third-party integrations.
