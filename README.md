# Script Collection
A collection of useful scripts in both Bash and PowerShell for system administration and automation tasks.

## Directory Structure
```
|
├── bash/
│   ├── background_switcher.sh
│   ├── battery_alert.sh
│   ├── compressFiles.sh
│   ├── createApp.sh
│   ├── extractingFiles.sh
│   ├── fixing_grub.sh
│   ├── git_pull.sh
│   ├── gitConfig.sh
│   ├── gitFeatures.sh
│   ├── gitInit.sh
│   ├── gitPush.sh
│   ├── gitSshConfig.sh
│   ├── isoImageFix.sh
│   ├── multi_namer.sh
│   ├── script_logger.sh
│   ├── start_up.sh
│   ├── tmux_background_runner.sh
│   ├── tmux_config.sh
│   ├── update_hashcat.sh
│   └── wifi_passwords.sh
└── powershell/
    ├── auto_executable.ps1
    ├── connect_wifi_automatically.ps1
    ├── get_size.ps1
    ├── get_wifi_passwords_xmls.ps1
    ├── installing_office.ps1
    ├── sort_and_remove_redundancy_password_file.ps1
    ├── startup.ps1
    ├── time_sync.ps1
    ├── fixing_office_activation.ps1
    └── executables/
        ├── x64fixing_office_activation.exe
        ├── x64get_wifi_passwords_xmls.exe
        ├── x64installing_office.exe
        └── x64sort_and_remove_redundancy_password_file.exe
```

## Bash Scripts 

### background_switcher.sh
This script automatically changes your desktop background based on your Linux desktop environment (GNOME, XFCE, etc.).

**Requirements:**
- Set the picture folder location
- Configure the logfile directory
- Compatible with various Linux desktop environments

**Configuration:**
```bash
# Example configuration
PICTURE_FOLDER="/path/to/pictures"
LOG_FILE="/var/log/background_switcher.log"
```

<!-- Add your detailed description here -->

### battery_alert.sh
<!-- Add description here -->

### compressFiles.sh
<!-- Add description here -->

<!-- Continue with other bash scripts -->

## PowerShell Scripts

### auto_executable.ps1
<!-- Add description here -->

### connect_wifi_automatically.ps1
<!-- Add description here -->

### Executables

The `executables` directory contains compiled versions of several PowerShell scripts:
- x64fixing_office_activation.exe
- x64get_wifi_passwords_xmls.exe
- x64installing_office.exe
- x64_sort_and_remove_redundancy_password_file.exe

## Installation

```bash
git clone <repository-url>
cd <repository-name>
```

## Usage

### Bash Scripts
```bash
cd bash
chmod +x script_name.sh
./script_name.sh
```

### PowerShell Scripts
```powershell
cd powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\script_name.ps1
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

<!-- Add your license information here -->

## Author

<!-- Add your information here -->

---
**Note:** This repository is for educational and administrative purposes only. Some scripts may require root/administrator privileges.

