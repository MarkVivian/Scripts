# Size.ps1 - Directory and File Size Calculator

A PowerShell script that calculates and displays the total size of directories and files with advanced filtering capabilities. Perfect for disk space analysis, cleanup operations, and storage management.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Parameters](#parameters)
- [Examples](#examples)
- [Output Format](#output-format)
- [Exclusion Patterns](#exclusion-patterns)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

## Overview

`Size.ps1` recursively scans specified directories and files, calculates their total size, and presents the results in human-readable format (Bytes, KB, MB, GB, etc.). The script supports sophisticated exclusion patterns to filter out unwanted files or directories from the calculation.

## Features

- ✅ **Recursive Directory Scanning** - Traverses all subdirectories automatically
- ✅ **Multiple Path Support** - Analyze multiple directories/files in one command
- ✅ **Advanced Exclusion Filtering** - Support for wildcards and exact matches
- ✅ **Human-Readable Output** - Automatic conversion to appropriate units (KB, MB, GB, etc.)
- ✅ **Raw Data Mode** - Display exact byte counts when needed
- ✅ **Error Handling** - Graceful handling of inaccessible files and permissions
- ✅ **Debug Support** - Detailed logging for troubleshooting
- ✅ **Total Summary** - Combined size calculation across all specified paths

## Requirements

- **PowerShell 5.1 or later** (Windows PowerShell or PowerShell Core)
- **Read permissions** on target directories and files
- **Windows, macOS, or Linux** (PowerShell Core)

## Installation

1. **Download the script:**
   ```powershell
   # Option 1: Direct download (replace with actual URL)
   Invoke-WebRequest -Uri "https://your-repo/size.ps1" -OutFile "size.ps1"
   
   # Option 2: Clone repository
   git clone https://github.com/yourusername/size-calculator.git
   ```

2. **Set execution policy (if needed):**
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

3. **Make it globally available (optional):**
   ```powershell
   # Add to PowerShell profile or move to a directory in $env:PATH
   ```

## Usage

### Basic Syntax
```powershell
.\size.ps1 -path <string[]> [-exclude <string[]>] [-rawData]
```

### Quick Start
```powershell
# Calculate size of current directory
.\size.ps1 -path "."

# Calculate size of specific folder
.\size.ps1 -path "C:\Users\YourName\Documents"

# Multiple paths with exclusions
.\size.ps1 -path "C:\Projects", "D:\Backup" -exclude "*.log", "temp*"
```

## Parameters

### `-path` (Mandatory)
- **Type:** `string[]` (Array of strings)
- **Description:** One or more file or directory paths to analyze
- **Examples:** 
  - `"C:\Users"`
  - `".", "C:\Temp", "D:\Projects"`
  - `"file.txt"`

### `-exclude` (Optional)
- **Type:** `string[]` (Array of strings)  
- **Description:** Patterns to exclude from size calculation
- **Supports:** Wildcards (`*`, `?`) and exact matches
- **Examples:**
  - `"*.log"` - Exclude all .log files
  - `"temp*"` - Exclude items starting with "temp"
  - `"node_modules"` - Exclude exact folder name
  - `"*.tmp", "cache*", ".git"` - Multiple patterns

### `-rawData` (Optional)
- **Type:** `switch` (Flag)
- **Description:** Display raw byte counts alongside human-readable format
- **Usage:** Add `-rawData` to show exact byte values

## Examples

### Basic Directory Analysis
```powershell
# Analyze Documents folder
.\size.ps1 -path "C:\Users\John\Documents"
```
**Output:**
```
C:\Users\John\Documents
15.67 GB

Total Size : 15.67 GB
```

### Multiple Directories
```powershell
# Analyze multiple locations
.\size.ps1 -path "C:\Projects", "D:\Backup", "E:\Media"
```

### Excluding Log Files
```powershell
# Exclude all .log files from calculation
.\size.ps1 -path "C:\Applications" -exclude "*.log"
```

### Advanced Exclusions
```powershell
# Exclude multiple patterns
.\size.ps1 -path "C:\Development" -exclude "*.log", "node_modules", "bin", "obj", ".git"
```

### Raw Data Mode
```powershell
# Show exact byte counts
.\size.ps1 -path "C:\SmallFolder" -rawData
```
**Output:**
```
C:\SmallFolder
Raw Data: 1073741824 Bytes
1.00 GB

Total Size (Raw Data): 1073741824 Bytes
Total Size : 1.00 GB
```

### Complex Real-World Example
```powershell
# Analyze development projects, excluding build artifacts and logs
.\size.ps1 -path "C:\Dev\Project1", "C:\Dev\Project2" -exclude "node_modules", "*.log", "bin", "obj", ".git", "*.tmp", "cache*" -rawData
```

## Output Format

The script provides clear, organized output:

```
[Path Name] (in yellow)
[Size in human-readable format] (in green)

[Next Path Name]
[Size in human-readable format]

Total Size : [Combined size] (yellow label, green value)
```

### Size Units
The script automatically selects the most appropriate unit:
- **Bytes** (< 1 KB)
- **KB** (Kilobytes)
- **MB** (Megabytes)  
- **GB** (Gigabytes)
- **TB** (Terabytes)
- **PB, EB, ZB, YB** (for extremely large sizes)

## Exclusion Patterns

### Wildcard Patterns
- `*.ext` - All files with specific extension
- `prefix*` - All items starting with prefix
- `*suffix` - All items ending with suffix
- `*pattern*` - All items containing pattern
- `file?.txt` - Single character wildcard

### Exact Matches
- `filename.txt` - Exact filename
- `foldername` - Exact folder name
- `.git` - Hidden folders/files

### Pattern Examples
| Pattern | Matches | Use Case |
|---------|---------|----------|
| `*.log` | `error.log`, `debug.log` | Exclude log files |
| `temp*` | `temp`, `temporary`, `temp_backup` | Exclude temp items |
| `node_modules` | `node_modules` (exact) | Exclude npm dependencies |
| `bin`, `obj` | Build output folders | .NET projects |
| `.git`, `.svn` | Version control folders | Source repositories |
| `*.tmp`, `*.bak` | Temporary/backup files | Cleanup operations |

## Troubleshooting

### Common Issues

#### "Execution Policy" Error
```powershell
# Fix: Set execution policy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

#### Path Not Found
- Verify paths exist and are accessible
- Use quotes around paths with spaces
- Check permissions on target directories

#### Zero Bytes Displayed
- **Cause:** Empty directories or inaccessible files
- **Solution:** Check file permissions and path validity

#### Slow Performance
- **Cause:** Large directory trees or network drives
- **Solution:** Use more specific exclusions, avoid network paths

### Debug Mode
Enable detailed logging for troubleshooting:
```powershell
# Edit the script and uncomment:
$DebugPreference = "Continue"
```

### Permissions Issues
```powershell
# Run as Administrator if needed (Windows)
# Or ensure read permissions on target paths
```

## Performance Tips

1. **Use Specific Exclusions:** Exclude large, unnecessary folders early
   ```powershell
   -exclude "node_modules", ".git", "bin", "obj"
   ```

2. **Avoid Network Drives:** Local drives are significantly faster

3. **Filter by Extension:** Use `*.ext` patterns to exclude large file types
   ```powershell
   -exclude "*.iso", "*.vmdk", "*.vdi"
   ```

## Common Use Cases

### Development Environment Cleanup
```powershell
.\size.ps1 -path "C:\Dev" -exclude "node_modules", "bin", "obj", ".git", "*.log"
```

### System Disk Analysis
```powershell
.\size.ps1 -path "C:\Users", "C:\Program Files", "C:\Windows\Temp" -exclude "*.log", "*.tmp"
```

### Backup Verification
```powershell
.\size.ps1 -path "D:\Backups\2024" -rawData
```

### Media Folder Analysis
```powershell
.\size.ps1 -path "E:\Photos", "E:\Videos", "E:\Music"
```

## Contributing

We welcome contributions! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

### Development Guidelines
- Follow PowerShell best practices
- Include parameter validation
- Add appropriate error handling
- Update documentation for new features

## License

This project is licensed under the MIT License. See LICENSE file for details.

## Support

- **Issues:** Report bugs and request features via GitHub Issues
- **Discussions:** Join community discussions for questions and tips
- **Documentation:** Keep this README updated with your use cases

---

**Version:** 1.0  
**Last Updated:** September 2025  
**Compatibility:** PowerShell 5.1+, Windows/macOS/Linux