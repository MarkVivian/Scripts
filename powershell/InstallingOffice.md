# InstallingOffice.ps1 - Microsoft Office Automated Installer

A PowerShell script that automates the installation of Microsoft Office using the official Office Deployment Tool (ODT). The script provides a user-friendly graphical interface for selecting installation directories and configuration files, then handles the entire installation process automatically.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Configuration Files](#configuration-files)
- [Usage](#usage)
- [Step-by-Step Process](#step-by-step-process)
- [Directory Structure](#directory-structure)
- [Troubleshooting](#troubleshooting)
- [Best Practices](#best-practices)
- [Advanced Configuration](#advanced-configuration)
- [Contributing](#contributing)

## Overview

This script automates the Microsoft Office installation process by:
1. **Downloading the latest Office Deployment Tool** from Microsoft
2. **Using a configuration XML file** to define installation parameters
3. **Creating a temporary installation directory** for the process
4. **Automating the setup and configuration** steps
5. **Providing graphical file dialogs** for user-friendly operation

The script eliminates the need to manually download tools, extract files, or run complex command-line operations.

## Features

- ✅ **Automated ODT Download** - Downloads the latest Office Deployment Tool
- ✅ **Graphical File Selection** - User-friendly dialogs for directory and file selection
- ✅ **Custom Configuration Support** - Works with any valid Office configuration XML
- ✅ **Automatic Directory Creation** - Creates necessary folders automatically
- ✅ **Error Handling** - Validates file types and paths
- ✅ **Clean Organization** - Keeps installation files organized in dedicated folders
- ✅ **Progress Feedback** - Provides status updates throughout the process

## Requirements

- **Windows 10/11** (Office Deployment Tool requirement)
- **PowerShell 5.1 or later**
- **Administrator privileges** (recommended for Office installation)
- **Internet connection** (for downloading ODT and Office files)
- **Valid Office license** (Office 365, Office 2019, 2021, etc.)

## Installation

### Option 1: Download Script Only
```powershell
# Download just the PowerShell script
Invoke-WebRequest -Uri "https://github.com/MarkVivian/Scripts/blob/main/powershell/backgroundSet.ps1" -OutFile "InstallingOffice.ps1"
```

### Option 2: Clone Entire Repository
```powershell
# Clone repository with sample configuration files
# clone the powershell script
git clone https://github.com/MarkVivian/Scripts/blob/main/powershell/backgroundSet.ps1
```

### Option 3: Download Executable Version
If you prefer not to run PowerShell scripts directly, download the compiled executable version from the releases section.
```powershell
# clone the executable version of the script.
git clone https://github.com/MarkVivian/Scripts/blob/main/powershell/executables/x64installing_office.exe
```

## PowerShell vs Executable Versions

### Executable Version (Recommended for Beginners)

The **executable (.exe) version** is the simplest option for most users:

**Advantages:**
- **Always Updated:** The executable is rebuilt monthly with the latest Office Deployment Tool download link, so you never need to worry about outdated URLs
- **Pre-Verified Configuration:** Includes a tested and verified configuration file that works out-of-the-box
- **No Technical Knowledge Required:** Just download the .exe file and the Configuration.xml from GitHub and run them
- **Works Everywhere:** Runs on any Windows system regardless of PowerShell threading model (works with both MTA and STA threads)
- **Zero Setup:** No need to modify execution policies or understand PowerShell concepts

**For Complete Beginners:**
1. Download `InstallingOffice.exe` from GitHub releases
2. Download `Configuration.xml` from the same location  
3. Double-click the exe file
4. Select folder and configuration file when prompted
5. Wait for Office to install

### PowerShell Script Version (For Advanced Users)

The **PowerShell script (.ps1) version** offers more flexibility but requires some technical setup:

**Requirements:**
- **STA Threading:** PowerShell must run in Single-Threaded Apartment (STA) mode for the graphical file dialogs to work properly
- **Manual URL Updates:** You must manually update the Office Deployment Tool download URL when Microsoft releases new versions
- **Execution Policy:** May require changing PowerShell execution policies

**Technical Note:** Most modern PowerShell sessions run in STA mode by default, but some automation environments or older systems may use MTA (Multi-Threaded Apartment) mode, which can cause the file selection dialogs to fail.

**When to Use Each Version:**

| User Type                 | Recommended Version | Reason                                              |
|---------------------------|---------------------|-----------------------------------------------------|
| **Complete Beginners**    | Executable (.exe)   | No setup required, always works                     |
| **Home Users**            | Executable (.exe)   | Simplest and most reliable                          |
| **IT Professionals**      | PowerShell (.ps1)   | Can customize and integrate into existing workflows |
| **Automated Deployments** | PowerShell (.ps1)   | Can be modified for scripted installations          |


## Configuration Files

### Using Provided Configuration (Easiest)
The repository includes a sample `Configuration.xml` file that installs:
- Microsoft 365 Apps for Enterprise
- English language pack
- Automatic updates enabled
- Standard applications (Word, Excel, PowerPoint, Outlook, etc.)

### Creating Custom Configuration (Advanced)
For custom installations, create your own configuration file:

1. **Visit the Office Customization Tool:**
   ```
   https://config.office.com/deploymentsettings
   ```

2. **Configure your preferences:**
   - Office suite and version
   - Applications to include/exclude
   - Language packs
   - Update channels
   - Installation behavior

3. **Download the generated XML file**
4. **Use it with this script**

### Sample Configuration Options
The customization tool allows you to configure:
- **Office Suites:** Office 365, Office 2019, Office 2021
- **Applications:** Word, Excel, PowerPoint, Outlook, Access, Publisher, etc.
- **Languages:** Multiple language packs
- **Update Channels:** Current, Semi-Annual Enterprise, etc.
- **Installation Options:** Shared computer licensing, display preferences

## Usage

### Basic Usage
```powershell
# Run the script
.\InstallingOffice.ps1
```

### With Administrator Privileges (Recommended)
```powershell
# Run PowerShell as Administrator, then:
.\InstallingOffice.ps1
```

### Using with Executable
```
# Double-click the executable file or run:
InstallingOffice.exe
```

## Step-by-Step Process

### Step 1: Update Download Link (Important)
Before running the script, verify the Office Deployment Tool URL is current:

1. **Visit:** https://www.microsoft.com/en-us/download/details.aspx?id=49117
2. **Right-click** the download button and copy the link
3. **Edit the script** and update this line:
   ```powershell
   $office_deployment_url = "https://download.microsoft.com/download/..."
   ```
4. **Replace with the current download URL**

### Step 2: Script Execution
1. **Run the script** using one of the methods above
2. **Select installation directory** when prompted
3. **Choose configuration XML file** when prompted
4. **Wait for installation** to complete

### Step 3: Interactive Prompts

#### Directory Selection Dialog
- **Purpose:** Choose where temporary installation files will be stored
- **Recommended locations:**
  - `C:\Users\YourName\Downloads\OfficeInstaller`
  - `C:\Users\YourName\Desktop\OfficeInstaller`
  - `C:\Users\YourName\Documents\OfficeInstaller`
- **Why these locations:** Easy to find and clean up after installation

#### Configuration File Selection Dialog
- **Purpose:** Select the XML configuration file
- **File type:** Must have `.xml` extension
- **Location:** Either the provided file or your custom configuration

### Step 4: Automated Process
Once selections are made, the script:
1. **Creates** the installation directory
2. **Downloads** the Office Deployment Tool
3. **Copies** the configuration file
4. **Extracts** the ODT files
5. **Runs** the Office installation
6. **Provides** completion notification

## Directory Structure

After running the script, your installation directory will contain:

```
OfficeInstaller/
├── office_deployment_tool.exe    # Downloaded ODT
├── Configuration.xml              # Your configuration file
├── setup.exe                      # Extracted from ODT
├── setup.exe.config              # ODT configuration
└── [Office installation files]    # Downloaded during installation
```

## Troubleshooting

### Common Issues

#### "Execution Policy" Error
```powershell
# Fix: Set execution policy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

#### Download Fails
**Cause:** Outdated ODT URL or network issues
**Solution:**
1. Update the download URL from Microsoft's official page
2. Check internet connection
3. Verify firewall/antivirus isn't blocking downloads

#### "Not an XML file" Error
**Cause:** Selected file doesn't have .xml extension
**Solution:**
- Ensure configuration file has `.xml` extension
- Verify file isn't corrupted
- Download fresh configuration from Office customization tool

#### Office Installation Fails
**Causes:** Insufficient permissions, conflicting Office versions, network issues
**Solutions:**
1. **Run as Administrator**
2. **Remove existing Office installations** first
3. **Check system requirements**
4. **Verify Office license validity**

#### Access Denied Errors
**Cause:** Insufficient permissions
**Solution:**
```powershell
# Run PowerShell as Administrator
Right-click PowerShell → "Run as Administrator"
```

### Advanced Troubleshooting

#### Check ODT Logs
After installation, check for detailed logs:
```
%temp%\OfficeSetupLogs\
```

#### Verify Configuration
Test your XML configuration:
```powershell
# Validate XML syntax
[xml](Get-Content "Configuration.xml")
```

#### Manual ODT Execution
If script fails, try manual execution:
```powershell
cd $installer_directory
.\setup.exe /configure .\Configuration.xml
```

## Best Practices

### Before Installation
1. **Update the ODT URL** from Microsoft's official page
2. **Close all Office applications** if updating existing installation
3. **Run as Administrator** for best results
4. **Choose accessible directory** for easy cleanup

### Directory Selection
- **Use major directories:** Downloads, Desktop, Documents
- **Avoid system directories:** Program Files, Windows folders
- **Consider cleanup:** Choose location you can easily find and delete

### Configuration Management
- **Test configurations** in non-production environments first
- **Backup custom configurations** for reuse
- **Document your settings** for future reference

### Post-Installation
- **Verify Office activation** after installation
- **Test core applications** (Word, Excel, etc.)
- **Clean up installation directory** if desired
- **Update Office** through normal channels

## Advanced Configuration

### Multiple Language Packs
```xml
<Add OfficeClientEdition="64" Channel="Current">
    <Product ID="O365ProPlusRetail">
        <Language ID="en-us" />
        <Language ID="es-es" />
        <Language ID="fr-fr" />
    </Product>
</Add>
```

### Exclude Specific Applications
```xml
<Add OfficeClientEdition="64" Channel="Current">
    <Product ID="O365ProPlusRetail">
        <Language ID="en-us" />
        <ExcludeApp ID="Access" />
        <ExcludeApp ID="Publisher" />
    </Product>
</Add>
```

### Shared Computer Licensing
```xml
<Add OfficeClientEdition="64" Channel="Current">
    <Product ID="O365ProPlusRetail">
        <Language ID="en-us" />
    </Product>
</Add>
<Property Name="SharedComputerLicensing" Value="1" />
```

## Automation and Scripting

### Silent Installation
For completely automated deployment:
```powershell
# Modify script to skip dialogs
$installer_directory = "C:\Temp\OfficeInstaller"
$config_file = "C:\Path\To\Configuration.xml"
```

### Batch Processing
For multiple computers:
```powershell
# Deploy to multiple machines using PSRemoting
$computers = @("PC1", "PC2", "PC3")
foreach ($computer in $computers) {
    Invoke-Command -ComputerName $computer -ScriptBlock {
        # Run installation script
    }
}
```

## Security Considerations

- **Verify ODT source:** Always download ODT from Microsoft's official site
- **Check XML files:** Validate configuration files from trusted sources
- **Run as Administrator:** Required for proper Office installation
- **Firewall exceptions:** May be needed for Office activation

## Contributing

Contributions are welcome! Please:

1. **Fork the repository**
2. **Create a feature branch**
3. **Test thoroughly** with different configurations
4. **Update documentation** for new features
5. **Submit a pull request**

### Development Guidelines
- Follow PowerShell best practices
- Include error handling for new features
- Test with various Office configurations
- Update README for any new parameters or features

## License

This project is licensed under the MIT License. Microsoft Office and the Office Deployment Tool are proprietary software from Microsoft Corporation.

## Support

- **Issues:** Report bugs via GitHub Issues
- **Discussions:** Join community discussions for tips and configuration help
- **Documentation:** Keep this README updated with your findings and improvements

---

**Version:** 1.0  
**Last Updated:** September 2025  
**Compatibility:** Windows 10/11, PowerShell 5.1+, Office 365/2019/2021

## Important Notes

- **Always verify the ODT download URL** is current before running
- **Office licenses are required** - this script only handles installation
- **Administrator privileges recommended** for successful installation
- **Clean up installation directories** after completion to save disk space