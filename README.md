# Scripts Collection 🚀

A comprehensive collection of powerful automation scripts for system administration, productivity enhancement, and daily workflow optimization. Built for both Linux (Bash) and Windows (PowerShell) environments with a focus on practical solutions for real-world problems.

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Linux-lightgrey.svg)](#requirements)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-blue.svg)](#powershell-requirements)
[![Bash](https://img.shields.io/badge/Bash-4.0+-green.svg)](#bash-requirements)

## 🎯 What This Repository Offers

Transform your daily computing experience with battle-tested scripts that handle:
- **System Administration** - Automated maintenance and configuration tasks
- **Office Management** - Microsoft Office installation and activation solutions  
- **Network Utilities** - WiFi password extraction and management tools
- **Productivity Tools** - File organization, background management, and startup automation
- **Development Workflow** - Git automation and project setup utilities

---

## 📂 Repository Structure

```
Scripts/
├── bash/                           # Linux/macOS Automation Scripts
│   ├── background_switcher.sh      # Automatic desktop background rotation
│   ├── battery_alert.sh            # Battery monitoring and alerts
│   ├── compressFiles.sh            # Batch file compression utility
│   ├── createApp.sh                # Application creation helper
│   ├── extractingFiles.sh          # Archive extraction automation
│   ├── fixing_grub.sh              # GRUB bootloader repair utility
│   ├── git_pull.sh                 # Automated git pull operations
│   ├── gitConfig.sh                # Git configuration setup
│   ├── gitFeatures.sh              # Advanced git workflow tools
│   ├── gitInit.sh                  # Repository initialization helper
│   ├── gitPush.sh                  # Streamlined git push automation
│   ├── gitSshConfig.sh             # SSH key configuration for git
│   ├── isoImageFix.sh              # ISO image repair and validation
│   ├── multi_namer.sh              # Bulk file renaming utility
│   ├── script_logger.sh            # Advanced logging framework
│   ├── start_up.sh                 # System startup automation
│   ├── tmux_background_runner.sh   # Background process management
│   ├── tmux_config.sh              # Tmux session configuration
│   ├── update_hashcat.sh           # Hashcat update automation
│   └── wifi_passwords.sh           # WiFi credential extraction
│
└── powershell/                     # Windows Automation Scripts
    ├── backgroundSet.ps1            # Dual(vertical + horizontal) monitor wallpaper management
    ├── fixing_office_activation.ps1 # Office activation troubleshooting
    ├── get_wifi_passwords_parallel_processing.ps1  # Advanced WiFi password extraction
    ├── sort_and_remove_redundancy_password_file.ps1  # Password file optimization
    ├── installingOffice.ps1         # Automated Office deployment
    ├── size.ps1                     # Directory size analysis tool
    ├── startup.ps1                  # Windows startup management
    └── executables/                 # Ready-to-run compiled versions
        ├── installingOffice.exe
        ├── get_wifi_passwords_parallel_processing.exe
        ├── sort_and_remove_redundancy_password_file.exe
        |── fixingOfficeActivation.exe
        └── startup.exe
```

---

## 🌟 Featured Scripts

### 💻 PowerShell Collection

#### 🎨 [backgroundSet.ps1](./powershell/backgroundSet.md)
**Dual Monitor Wallpaper Management**
- Intelligent image selection for horizontal/vertical monitors
- Automatic composite wallpaper creation
- Continuous wallpaper cycling with cleanup
- Smart aspect ratio detection and rotation

#### 📊 [size.ps1](./powershell/size.md) 
**Advanced Directory Analysis**
- Recursive file size calculation with exclusion patterns
- Human-readable size formatting (KB, MB, GB, TB)
- Wildcard filtering and pattern matching
- Performance optimized for large directory trees

#### 🏢 [installingOffice.ps1](./powershell/installingOffice.md)
**Microsoft Office Automated Installer**
- Downloads latest Office Deployment Tool automatically
- Graphical interface for configuration selection
- Custom XML configuration support
- Error handling and progress feedback

#### 📡 [get_wifi_passwords_parallel_processing.ps1](./powershell/get_wifi_passwords_pararrel_processing.md)
**High-Performance WiFi Password Extraction**
- Parallel processing for optimal performance
- Incremental updates prevent duplicates
- Smart job allocation based on profile count
- Secure password extraction with proper formatting

#### 🔧 [fixing_office_activation.ps1](./powershell/fixing_office_activation.md)
**Office Activation Troubleshooter**
- Resolves common Office activation failures
- Automated license repair and reset procedures
- Multiple activation method attempts
- Comprehensive error diagnosis and reporting

#### 🧹 sort_and_remove_redundancy_password_file.ps1
**Password File Optimizer**
- Removes duplicate entries from password files
- Alphabetical sorting for easy navigation
- Preserves file integrity while optimizing structure
- Works seamlessly with WiFi password extraction tools

#### 🚀 startup.ps1
**Windows Startup Manager**
- Easy script and application startup configuration
- GUI-free startup item management
- Supports both user and system-level startup
- Eliminates need for manual registry/folder editing

### 🐧 Bash Collection

#### 🖼️ background_switcher.sh
**Universal Linux Background Manager**
- Multi-desktop environment support (GNOME, XFCE, KDE)
- Configurable rotation intervals and logging
- Automatic picture folder scanning
- Desktop environment detection

#### 🔋 battery_alert.sh
**Intelligent Battery Monitoring**
- Customizable alert thresholds
- Multiple notification methods
- Power saving recommendations
- Battery health tracking

#### 📦 compressFiles.sh & extractingFiles.sh
**Archive Management Suite**
- Support for multiple compression formats
- Batch processing capabilities
- Integrity verification
- Space optimization algorithms

#### 🔨 Git Automation Suite
**Complete Git Workflow Tools**
- `gitConfig.sh` - Streamlined git configuration
- `gitInit.sh` - Repository initialization with templates
- `gitPush.sh` & `git_pull.sh` - Automated push/pull operations
- `gitSshConfig.sh` - SSH key management
- `gitFeatures.sh` - Advanced workflow automation

#### 🛠️ System Utilities
- **fixing_grub.sh** - GRUB bootloader repair and recovery
- **isoImageFix.sh** - ISO validation and repair tools
- **tmux_config.sh** - Advanced terminal multiplexer setup
- **update_hashcat.sh** - Security tool maintenance

---

## 🚀 Quick Start

### Prerequisites

#### PowerShell Requirements
- **Windows 10/11** or **PowerShell Core 6.0+**
- **PowerShell 5.1+** minimum version
- **Administrator privileges** (recommended for system-level operations)

#### Bash Requirements  
- **Linux/macOS** with Bash 4.0+
- **Standard utilities**: curl, wget, git (for specific scripts)
- **Desktop environment** (for GUI-related scripts)

### Installation

```bash
# Clone the repository
git clone https://github.com/MarkVivian/Scripts.git
cd Scripts
```

### PowerShell Setup
```powershell
# Set execution policy (run as Administrator)
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# Navigate to PowerShell scripts
cd powershell

# Run any script
.\scriptname.ps1 -Parameter Value
```

### Bash Setup
```bash
# Make scripts executable
cd bash
chmod +x *.sh

# Run any script
./scriptname.sh
```

### Using Executables (Windows)
For users who prefer not to run PowerShell scripts directly:
```
# Simply double-click any .exe file in the executables folder
# Or run from command line:
installingOffice.exe
```

---

## 📋 Usage Examples

### Office Management
```powershell
# Install Microsoft Office with custom configuration
.\installingOffice.ps1

# Fix Office activation issues
.\fixing_office_activation.ps1
```

### Network Administration
```powershell
# Extract WiFi passwords with parallel processing
.\get_wifi_passwords_parallel_processing.ps1 -DebugMode

# Clean and sort password files
.\sort_and_remove_redundancy_password_file.ps1
```

### System Analysis
```powershell
# Analyze directory sizes with exclusions
.\size.ps1 -path "C:\Users" -exclude "*.log", "temp*" -rawData
```

### Desktop Customization
```powershell
# Set up dual monitor wallpapers
.\backgroundSet.ps1 -PicturesPath "C:\Wallpapers" -OutputImagePath "C:\Current.png" -sleepDuration 60
```

### Git Workflow
```bash
# Configure git with interactive setup
./gitConfig.sh

# Initialize new repository with templates
./gitInit.sh MyNewProject
```

---

## 🔧 Configuration

Most scripts include configurable parameters and settings:

- **PowerShell scripts** use parameter-based configuration
- **Bash scripts** often include configuration sections at the top
- **Executable versions** provide GUI prompts for configuration
- **Detailed configuration guides** available in individual script documentation

---

## 📖 Documentation

Each major script includes comprehensive documentation:

- **[backgroundSet.ps1 Documentation](./powershell/backgroundSet.md)** - Complete dual monitor setup guide
- **[size.ps1 Documentation](./powershell/size.md)** - Directory analysis and filtering guide
- **[installingOffice.ps1 Documentation](./powershell/installingOffice.md)** - Office deployment guide
- **[get_wifi_passwords_pararrel_processing.ps1 Documentation](./powershell/get_wifi_passwords_pararrel_processing.md)** - wifi + password extraction tool.

Additional documentation available in script comments and help sections.

---

## 🤝 Contributing

Contributions are welcome! Here's how to help:

1. **Fork** the repository
2. **Create** a feature branch: `git checkout -b feature/amazing-feature`
3. **Commit** your changes: `git commit -m 'Add amazing feature'`
4. **Push** to the branch: `git push origin feature/amazing-feature`
5. **Submit** a Pull Request

### Contribution Guidelines
- Follow existing code style and formatting
- Include comprehensive error handling
- Add parameter validation and help documentation
- Test scripts on multiple system configurations
- Update relevant documentation

---

## 🛡️ Security & Best Practices

### Security Considerations
- Scripts that extract passwords or modify system settings require appropriate permissions
- Always review script content before execution, especially when running as Administrator
- Use provided executables for non-technical users to avoid execution policy issues
- Store extracted credentials securely and delete when no longer needed

### Best Practices
- Run scripts in test environments before production use
- Backup important data before running system modification scripts
- Use version control for any script customizations
- Monitor script execution logs for troubleshooting

---

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👤 Author

**Mark Vivian**
- GitHub: [@MarkVivian](https://github.com/MarkVivian)
- Repository: [Scripts Collection](https://github.com/MarkVivian/Scripts.git)

---

## 🙏 Acknowledgments

- Microsoft for PowerShell and Office Deployment Tools
- The open-source community for inspiration and best practices
- Contributors and users who provide feedback and improvements

---

**⚠️ Disclaimer:** These scripts are provided for educational and administrative purposes. Some scripts require elevated privileges and can modify system settings. Always test in non-production environments first and use at your own discretion.