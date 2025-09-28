# backgroundSet.ps1 - Dual Monitor Composite Wallpaper Generator

A PowerShell script that automatically creates and sets composite wallpapers for dual monitor setups with orientations. Designed specifically for mixed horizontal/vertical monitor configurations with automatic image rotation and continuous wallpaper cycling.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Parameters](#parameters)
- [Examples](#examples)
- [Monitor Detection](#monitor-detection)
- [Image Classification](#image-classification)
- [Composite Creation Process](#composite-creation-process)
- [Continuous Mode](#continuous-mode)
- [Debug Features](#debug-features)
- [Troubleshooting](#troubleshooting)
- [Performance Considerations](#performance-considerations)
- [Contributing](#contributing)

## Overview

`backgroundSet.ps1` solves the common problem of having different monitor orientations (one horizontal, one vertical) where Windows applies the same wallpaper to both, resulting in poor image quality on the vertical monitor. The script automatically:

1. **Detects your monitor configuration** and positions
2. **Analyzes your image library** to classify images by orientation suitability
3. **Creates composite wallpapers** that span both monitors with appropriate images
4. **Automatically rotates images** when needed for better fit
5. **Sets the wallpaper** using Windows API with proper spanning mode
6. **Continuously cycles wallpapers** at specified intervals (optional)

## Features

- ✅ **Automatic Monitor Detection** - Discovers monitor layout, positions, and orientations
- ✅ **Smart Image Classification** - Separates vertical and horizontal oriented images
- ✅ **Intelligent Image Selection** - Chooses appropriate images for each monitor
- ✅ **Automatic Image Rotation** - Rotates images when no suitable orientation is available
- ✅ **Composite Wallpaper Creation** - Builds single wallpaper spanning multiple monitors
- ✅ **Position Normalization** - Handles negative monitor coordinates correctly
- ✅ **Windows Integration** - Sets wallpaper using native Windows API
- ✅ **Continuous Cycling** - Automatically changes wallpapers at intervals
- ✅ **Debug Visualization** - Shows monitor outlines and saves intermediate images
- ✅ **Temporary File Cleanup** - Removes debug files after each cycle
- ✅ **High-Quality Scaling** - Uses bicubic interpolation for best image quality

## Requirements

- **PowerShell 5.1 or later** (Windows PowerShell or PowerShell Core)
- **Windows OS** (uses Windows-specific display APIs)
- **Multiple monitors** (designed for dual monitor setups)
- **Image library** with sufficient horizontal/vertical images
- **Administrator privileges** (recommended for registry access)

## Installation

1. **Download the script:**
   ```powershell
   # Option 1: Direct download
   Invoke-WebRequest -Uri "https://github.com/MarkVivian/Scripts/blob/main/powershell/backgroundSet.ps1" -OutFile "backgroundSet.ps1"
   
   # Option 2: Clone repository
   git clone https://github.com/MarkVivian/Scripts.git 
   ```

2. **Set execution policy:**
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

3. **Verify monitor setup:**
   ```powershell
   # Test monitor detection
   .\backgroundSet.ps1 -PicturesPath "C:\TestFolder" -OutputImagePath "C:\Temp\test.png" -DebugMode
   ```

## Usage

### Basic Syntax
```powershell
.\backgroundSet.ps1 -PicturesPath <string> -OutputImagePath <string> [-sleepDuration <int>] [-DebugMode]
```

### One-Time Wallpaper Creation
```powershell
.\backgroundSet.ps1 -PicturesPath "C:\Users\YourName\Pictures" -OutputImagePath "C:\Wallpapers\composite.png"
```

### Continuous Cycling Mode
```powershell
# Change wallpaper every 30 seconds
.\backgroundSet.ps1 -PicturesPath "C:\Users\YourName\Pictures" -OutputImagePath "C:\Wallpapers\current.png" -sleepDuration 30
```

## Parameters

### `-PicturesPath` (Mandatory)
- **Type:** `string`
- **Description:** Path to directory containing source wallpaper images
- **Supports:** Recursive scanning of subdirectories
- **Accepted formats:** JPG, JPEG, PNG
- **Example:** `"C:\Users\YourName\Pictures\Wallpapers"`

### `-OutputImagePath` (Mandatory)
- **Type:** `string`
- **Description:** Path where composite wallpaper will be saved and updated
- **Behavior:** Can be file path or directory (auto-generates filename)
- **Format:** Saves as PNG for best quality
- **Examples:**
  - `"C:\Wallpapers\my_wallpaper.png"` - Specific file
  - `"C:\Wallpapers\"` - Auto-generates filename

### `-sleepDuration` (Optional)
- **Type:** `int`
- **Default:** `10` (seconds)
- **Description:** Time interval between wallpaper changes in continuous mode
- **Minimum:** 1 second (not recommended)
- **Recommended:** 30-300 seconds
- **Examples:**
  - `30` - Change every 30 seconds
  - `300` - Change every 5 minutes
  - `3600` - Change every hour

### `-DebugMode` (Optional)
- **Type:** `switch` (Flag)
- **Description:** Enables detailed logging and saves intermediate images
- **Output:** Creates timestamped debug files in temp directory
- **Usage:** Add `-DebugMode` for troubleshooting

## Examples

### Basic Usage
```powershell
# Simple one-time wallpaper creation
.\backgroundSet.ps1 -PicturesPath "C:\Pictures" -OutputImagePath "C:\Wallpapers\desktop.png"
```

### Continuous Mode with Custom Interval
```powershell
# Change wallpaper every 2 minutes
.\backgroundSet.ps1 -PicturesPath "C:\Users\John\Pictures\Landscapes" -OutputImagePath "C:\Wallpapers\current.png" -sleepDuration 120
```

### Debug Mode for Troubleshooting
```powershell
# Enable debug output and intermediate file saving
.\backgroundSet.ps1 -PicturesPath "C:\Pictures" -OutputImagePath "C:\Wallpapers\test.png" -DebugMode
```

### Network Drive Source
```powershell
# Use images from network location
.\backgroundSet.ps1 -PicturesPath "\\Server\Shared\Wallpapers" -OutputImagePath "C:\Wallpapers\network.png" -sleepDuration 60
```

### Quick Test with Temporary Output
```powershell
# Test with output to temp directory
.\backgroundSet.ps1 -PicturesPath "C:\Pictures" -OutputImagePath "$env:TEMP\wallpaper_test.png" -DebugMode
```

## Monitor Detection

The script automatically detects and analyzes your monitor configuration:

### Detection Process
1. **Scans all connected displays** using Windows Forms API
2. **Determines virtual screen dimensions** (total desktop area)
3. **Identifies monitor positions** including negative coordinates
4. **Classifies monitor orientations** (horizontal vs vertical)
5. **Calculates aspect ratios** for each display

### Supported Configurations
- **Horizontal + Vertical:** Most common 
- **Multiple Horizontal:** Uses first two detected
- **Mixed Resolutions:** Handles different DPI and scaling

### Position Handling
```
Example Layout:
┌─────────────┐
│             │
│             │┌──────────────────────┐
│   Monitor 1 ││   Monitor 2          │
│ (-1080, 0)  ││  (0, 0)              │
│ 1080x1920   ││  1920x1080           │
│ Vertical    ││  Horizontal          │
│             │└──────────────────────┘
│             │
│             │
└─────────────┘
```

## Image Classification

### Classification Criteria
Images are automatically classified based on aspect ratio:

| Aspect Ratio | Classification | Examples |
|--------------|----------------|----------|
| < 0.6 | **Vertical** | 1080x1920, 768x1366, 9:16 |
| > 1.7 | **Horizontal** | 1920x1080, 2560x1440, 16:9 |
| 0.6 - 1.7 | **Not Suitable** | 1024x1024, 4:3, square |

### Smart Selection Logic
1. **Perfect Match:** Uses vertical images for vertical monitors, horizontal for horizontal
2. **Rotation Fallback:** Rotates horizontal images for vertical monitors if needed
3. **Random Selection:** Chooses randomly from suitable images each cycle
4. **Fallback Handling:** Uses any available image with rotation if no perfect matches

## Composite Creation Process

### Step-by-Step Process
1. **Canvas Creation:** Creates canvas matching virtual screen size
2. **Coordinate Normalization:** Converts negative positions to positive canvas coordinates
3. **Debug Outline:** Draws colored rectangles showing monitor boundaries
4. **Image Processing:** Loads, rotates (if needed), and resizes images
5. **Positioning:** Centers images within their respective monitor areas
6. **Composition:** Draws all elements onto single canvas
7. **Saving:** Exports as high-quality PNG

### Quality Settings
- **Interpolation:** HighQualityBicubic for smooth scaling
- **Compositing:** HighQuality mode for best blending
- **Smoothing:** HighQuality anti-aliasing
- **Format:** PNG for lossless compression

## Continuous Mode

When `sleepDuration` is provided, the script runs indefinitely:

```powershell
while($true) {
    # 1. Create new composite wallpaper
    CreateCompositeWallpaper [parameters...]
    
    # 2. Set as Windows wallpaper
    Set-WindowsWallpaper -ImagePath $OutputImagePath
    
    # 3. Clean up temporary debug files
    Remove-Item -Path "$($env:TEMP)\*.png" -Force
    
    # 4. Wait for next cycle
    Start-Sleep $sleepDuration
}
```

### Continuous Mode Features
- **Automatic Cleanup:** Removes debug files after each cycle
- **Random Selection:** Different images chosen each cycle
- **Memory Management:** Properly disposes of image objects
- **Error Recovery:** Continues running even if individual cycles fail

## Debug Features

### Debug Mode Outputs
When `-DebugMode` is enabled, the script creates several debug files:

#### Timestamped Debug Files
- **`step1_original_TIMESTAMP.png`** - Original source image before processing
- **`step2_rotated_TIMESTAMP.png`** - Image after 90-degree rotation (if rotated)
- **`step3_resized_TIMESTAMP.png`** - Final resized image ready for composite
- **`composite_outline_TIMESTAMP.png`** - Composite showing monitor boundaries

#### Debug Information
```
DEBUG: Loaded image: photo.jpg - 1920x1080 (Ratio: 1.78)
DEBUG: -> Classified as HORIZONTAL
DEBUG: Monitor 1: Device Name: \\.\DISPLAY1
DEBUG: Horizontal Monitor Found: 1920x1080
DEBUG: Normalized Horizontal position: (1080, 0)
DEBUG: Placing horizontal image at: (1080, 0) (resized 1920x1080)
```

### Outline Visualization
The script draws colored outlines showing exactly where each monitor area is positioned:
- **Red rectangles** indicate monitor boundaries
- **Different colors** for horizontal vs vertical monitors
- **Coordinate labels** show exact positioning

## Troubleshooting

### Common Issues

#### No Images Found
```
Error: No suitable images found in the specified directory
```
**Solutions:**
- Verify path exists and contains JPG/PNG files
- Check if images meet aspect ratio requirements (< 0.6 or > 1.7)
- Use `-DebugMode` to see classification results

#### Wallpaper Not Spanning Correctly
```
Wallpaper appears zoomed/cropped on one monitor
```
**Solutions:**
- Script automatically sets registry to "Span" mode
- Manually check: Settings > Personalization > Background > Choose a fit > Span
- Restart Windows Explorer: `taskkill /f /im explorer.exe && explorer.exe`

#### Permission Errors
```
Error: Cannot create output directory
```
**Solutions:**
- Run PowerShell as Administrator
- Choose output path in user directory
- Verify write permissions on target folder

#### Monitor Detection Issues
```
Wrong monitor orientation detected
```
**Solutions:**
- Check Windows display settings for correct orientation
- Use `-DebugMode` to verify detected monitor properties
- Ensure monitors are properly configured in Windows

### Performance Issues

#### Slow Image Processing
**Causes:** Large image files, network drives, many images
**Solutions:**
- Use local SSD storage for image library
- Reduce image file sizes (script handles scaling)
- Increase `sleepDuration` for less frequent changes

#### High Memory Usage
**Causes:** Large images, debug mode, continuous operation
**Solutions:**
- Script automatically disposes images after processing
- Debug files are cleaned up each cycle
- Restart script periodically for long-running instances

### Debug Checklist
1. **Run with `-DebugMode`** to see detailed processing
2. **Check temp directory** for debug images: `$env:TEMP`
3. **Verify monitor detection** in debug output
4. **Examine outline composite** to confirm positioning
5. **Check Windows wallpaper settings** for "Span" mode

## Performance Considerations

### Optimization Tips
1. **Image Library Size:** 50-200 images recommended for good variety
2. **File Sizes:** 1-5MB images are optimal (script handles scaling)
3. **Sleep Duration:** 30+ seconds recommended to avoid excessive processing
4. **Storage Location:** Local SSD preferred over network drives

### Resource Usage
- **CPU:** Brief spikes during image processing, idle between cycles
- **Memory:** ~50-100MB during processing, cleaned up after
- **Disk:** Temporary files in `%TEMP%`, cleaned automatically
- **Network:** Only if images stored on network drives

### Recommended Settings
```powershell
# Balanced performance and variety
.\backgroundSet.ps1 -PicturesPath "C:\Wallpapers" -OutputImagePath "C:\Wallpapers\current.png" -sleepDuration 60
```

## Advanced Usage

### Scheduled Task Integration
Create a Windows scheduled task to run at startup:
```powershell
# Create scheduled task (run as Administrator)
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-File C:\Scripts\backgroundSet.ps1 -PicturesPath 'C:\Pictures' -OutputImagePath 'C:\Wallpapers\current.png' -sleepDuration 300"
$trigger = New-ScheduledTaskTrigger -AtStartup
Register-ScheduledTask -TaskName "DualMonitorWallpaper" -Action $action -Trigger $trigger -RunLevel Highest
```

### Integration with Other Scripts
```powershell
# Call from other scripts
& ".\backgroundSet.ps1" -PicturesPath $MyPicturesPath -OutputImagePath $OutputPath -sleepDuration 120
```

## Contributing

We welcome contributions to improve the dual monitor wallpaper experience!

### Development Guidelines
- Follow PowerShell best practices and naming conventions
- Include parameter validation and error handling
- Add debug output for new features
- Update documentation for any parameter changes
- Test with different monitor configurations

### Contribution Areas
- Support for triple monitor setups
- Additional image formats (WEBP, TIFF)
- Custom aspect ratio thresholds
- GPU acceleration for image processing
- Integration with popular wallpaper services

## License

This project is licensed under the MIT License. See LICENSE file for details.

## Support

- **Issues:** Report bugs and request features via GitHub Issues  
- **Discussions:** Join community discussions for configuration help
- **Documentation:** Keep this README updated with your use cases and findings

---

**Version:** 2.0  
**Last Updated:** September 2025  
**Compatibility:** Windows 10/11, PowerShell 5.1+  
**Monitor Support:** Dual monitor horizontal/vertical configurations