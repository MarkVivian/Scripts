[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string] $PicturesPath,
    
    [Parameter(Mandatory = $true)]
    [string] $OutputImagePath,
        
    [switch] $DebugMode,

    [Parameter()]
    [int] $sleepDuration = 10
)

# Load required assemblies for image manipulation
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms

# Enable debug output if requested
if ($DebugMode) {
    $DebugPreference = "Continue"
}

function MonitorAllocation{
    $monitor_virtual = [System.Windows.Forms.SystemInformation]::VirtualScreen

    $Monitor_data = [PSCustomObject]@{
        monitor_virtual = [PSCustomObject]@{
            width = $monitor_virtual.Width
            height = $monitor_virtual.Height
            x_axis = $monitor_virtual.X
            y_axis = $monitor_virtual.Y
        }
        monitor_actual =[PSCustomObject]@{
            count = [System.Windows.Forms.Screen]::AllScreens.Count
            details = @([System.Windows.Forms.Screen]::AllScreens | ForEach-Object {
               [PSCustomObject]@{
                    device_name = $_.DeviceName
                    bounds = [PSCustomObject]@{
                        X_axis = $_.Bounds.X
                        Y_axis = $_.Bounds.Y
                        Width = $_.Bounds.Width
                        Height = $_.Bounds.Height
                    }
                    primary = $_.Primary
                    type = if ($_.bounds.Width -gt $_.bounds.Height) {"Horizontal"} else {"Vertical"}
                    AspectRatio = [math]::Round($_.bounds.Width / $_.bounds.Height, 2)
                }
            })
        }
    }
    Write-Host "Virtual Monitor: $($Monitor_data.monitor_virtual)" -ForegroundColor Cyan
    for($i = 0; $i -lt $Monitor_data.monitor_actual.count; $i++) {
        Write-Progress -Activity "Processing Monitors" -Status "Monitor $($i + 1) of $($Monitor_data.monitor_actual.count)" -PercentComplete (($i / $Monitor_data.monitor_actual.count) * 100)
        $screen = $Monitor_data.monitor_actual.details[$i]
        Write-Debug "Monitor $($i + 1):" 
        Write-Debug "   Device Name: $($screen.device_name)" 
        Write-Debug "   Bounds: $($screen.bounds)" 
        Write-Debug "   Primary: $($screen.primary)" 
        Write-Debug "   Type: $($screen.type)" 
        Write-Debug "   Aspect Ratio: $($screen.AspectRatio)" 
    }

    return $Monitor_data
}

function Get-ImageDimensions {
    param(
        [string] $ImagePath
    )
    
    try {
        $image = [System.Drawing.Image]::FromFile($ImagePath)
        $dimensions = [PSCustomObject]@{
            Width = $image.Width
            Height = $image.Height
            AspectRatio = $image.Width / $image.Height
            Path = $ImagePath
        }
        Write-Debug "----------------------------------devider ----------------------------------"
        Write-Debug "Loaded image: $ImagePath - ${($dimensions.Width)}x${($dimensions.Height)} (Ratio: $($dimensions.AspectRatio.ToString('F2')))"
        $image.Dispose()
        return $dimensions
    }
    catch {
        Write-Debug "Failed to get dimensions for: $ImagePath - $($_.Exception.Message)"
        return $null
    }
}

function Find-SuitableImages {
    param(
        [string] $Directory,
        [double] $ThresholdRatio
    )
    
    Write-Host "Scanning for images in: $Directory" -ForegroundColor Yellow
    
    $imageExtensions = @("*.jpg", "*.jpeg", "*.png")
    $allImages = @()
    
    foreach ($ext in $imageExtensions) {
        $allImages += Get-ChildItem -File -Path $Directory -Filter $ext -Recurse -ErrorAction SilentlyContinue
    }
    
    Write-Host "Found $($allImages.Count) image files" -ForegroundColor Green
    
    $verticalImages = @()
    $horizontalImages = @()
    $not_fit = @()
    $processedCount = 0
    
    foreach ($imageFile in $allImages) {
        $processedCount++
        Write-Progress -Activity "Analyzing Images" -Status "Processing $($imageFile.Name)" -PercentComplete (($processedCount / $allImages.Count) * 100)
        
        $dimensions = Get-ImageDimensions -ImagePath $imageFile.FullName
        if ($dimensions) {
            Write-Debug "Image: $($imageFile.Name) - Dimensions: $($dimensions.Width)x$($dimensions.Height) - Ratio: $($dimensions.AspectRatio.ToString('F2'))"
            
            # If aspect ratio is less than threshold, it's more vertical (height > width * threshold)
            if ($dimensions.AspectRatio -lt 0.6) {
                $verticalImages += $dimensions
                Write-Debug "  -> Classified as VERTICAL"
            } elseif ($dimensions.AspectRatio -gt 1.7) {
                $horizontalImages += $dimensions
                Write-Debug "  -> Classified as HORIZONTAL"
            }else{
                $not_fit += $dimensions
                Write-Debug "  -> Classified as NOT FITTING CRITERIA"
            }
        }
    }
    
    Write-Progress -Completed -Activity "Analyzing Images"
    
    Write-Host "Classification Results:" -ForegroundColor Cyan
    Write-Host "  Vertical-oriented images: $($verticalImages.Count)" -ForegroundColor Green
    Write-Host "  Horizontal-oriented images: $($horizontalImages.Count)" -ForegroundColor Green
    
    return @{
        Vertical = $verticalImages
        Horizontal = $horizontalImages
        not_fit = $not_fit
        count = $allImages.Count
    }
}

function Resize-ImageToFit {
    param(
        [System.Drawing.Image] $SourceImage,
        [int] $TargetWidth,
        [int] $TargetHeight,
        [bool] $RotateIfNeeded = $false
    )

    # This function returns a System.Drawing.Bitmap (resized, possibly rotated).
    # If rotation is requested it *also* writes a temp PNG of the rotated image and prints its path.
    try {
        Write-Host "Resize-ImageToFit: Starting (RotateIfNeeded = $RotateIfNeeded)" -ForegroundColor DarkCyan
        Write-Host "  Target: ${TargetWidth}x${TargetHeight}" -ForegroundColor Gray
        Write-Host ("  Source: {0}x{1}" -f $SourceImage.Width, $SourceImage.Height) -ForegroundColor Gray

        # Save original source image for debugging
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss_fff"
        $tempDir = [System.IO.Path]::GetTempPath()
        $originalTempPath = Join-Path $tempDir "step1_original_${timestamp}.png"
        $SourceImage.Save($originalTempPath, [System.Drawing.Imaging.ImageFormat]::Png)
        Write-Host "  DEBUG: Saved original source to: $originalTempPath" -ForegroundColor Magenta

        $workingImage = $SourceImage

        # If rotation is required, rotate a copy and persist it so the rotated pixels can be inspected.
        if ($RotateIfNeeded) {
            Write-Host "  -> Rotating source by 90 degrees (in-memory copy)..." -ForegroundColor Yellow

            # Copy into an in-memory bitmap first (safe to modify)
            $rotCopy = New-Object System.Drawing.Bitmap $SourceImage
            $rotCopy.RotateFlip([System.Drawing.RotateFlipType]::Rotate90FlipNone)

            # Save rotated image to a unique temp file so you can open it and verify
            $rotTempPath = Join-Path $tempDir "step2_rotated_${timestamp}.png"
            $rotCopy.Save($rotTempPath, [System.Drawing.Imaging.ImageFormat]::Png)
            Write-Host "  DEBUG: Saved rotated image to: $rotTempPath" -ForegroundColor Magenta

            # Create a copy that is not file-backed (so no locks) and use that as the new source for resizing
            $workingImage = New-Object System.Drawing.Bitmap $rotCopy
            $rotCopy.Dispose()

            Write-Host ("  New source dimensions after rotate: {0}x{1}" -f $workingImage.Width, $workingImage.Height) -ForegroundColor Gray
        }

        # Now compute scaling to fit inside TargetWidth x TargetHeight while preserving aspect ratio
        $sourceWidth = $workingImage.Width
        $sourceHeight = $workingImage.Height

        if ($sourceWidth -le 0 -or $sourceHeight -le 0) {
            throw "Source image has invalid dimensions: ${sourceWidth}x${sourceHeight}"
        }

        $scaleX = $TargetWidth / $sourceWidth
        $scaleY = $TargetHeight / $sourceHeight
        $scale = [Math]::Min($scaleX, $scaleY)

        $newWidth = [int]([Math]::Max(1, [Math]::Round($sourceWidth * $scale)))
        $newHeight = [int]([Math]::Max(1, [Math]::Round($sourceHeight * $scale)))

        Write-Host ("  Computed resize: {0}x{1} (scale: {2:F2})" -f $newWidth, $newHeight, $scale) -ForegroundColor Cyan

        # Create destination bitmap and draw scaled image with high-quality settings
        $resizedBitmap = New-Object System.Drawing.Bitmap($newWidth, $newHeight)
        $gfx = [System.Drawing.Graphics]::FromImage($resizedBitmap)
        $gfx.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceOver
        $gfx.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
        $gfx.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $gfx.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
        $gfx.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

        $gfx.DrawImage($workingImage, 0, 0, $newWidth, $newHeight)
        $gfx.Dispose()

        # Save final resized image for debugging
        $resizedTempPath = Join-Path $tempDir "step3_resized_${timestamp}.png"
        $resizedBitmap.Save($resizedTempPath, [System.Drawing.Imaging.ImageFormat]::Png)
        Write-Host "  DEBUG: Saved final resized image to: $resizedTempPath" -ForegroundColor Magenta

        # Clean up working image if it's different from source
        if ($RotateIfNeeded -and $workingImage -ne $SourceImage) {
            $workingImage.Dispose()
        }

        Write-Host "  Resize complete; returning resized bitmap." -ForegroundColor Green

        return $resizedBitmap
    }
    catch {
        Write-Host "Resize-ImageToFit ERROR: $($_.Exception.Message)" -ForegroundColor Red
        throw
    }
}


function CreateCompositeWallpaper {
    param(
        [hashtable] $Images,
        [int] $HorzWidth,
        [int] $HorzHeight,
        [int] $VertWidth,
        [int] $VertHeight,
        [string] $Output,
        [PSCustomObject] $virtual_data,
        [int] $vertX,
        [int] $vertY,
        [int] $horzX,
        [int] $horzY,
        [int] $totalImgCount
    )

    Write-Host "`nCreateCompositeWallpaper: Starting..." -ForegroundColor Yellow
    Write-Host "Virtual screen: $($virtual_data.width)x$($virtual_data.height) at ($($virtual_data.x_axis), $($virtual_data.y_axis))" -ForegroundColor Gray
    Write-Host "Original Horizontal position: ($horzX, $horzY) - Size: ${HorzWidth}x${HorzHeight}" -ForegroundColor Gray
    Write-Host "Original Vertical position: ($vertX, $vertY) - Size: ${VertWidth}x${VertHeight}" -ForegroundColor Gray

    # Normalize coordinates - make them all positive relative to the virtual screen origin
    $normalizedHorzX = [Math]::Abs($horzX - $virtual_data.x_axis)
    $normalizedHorzY = [Math]::Abs($horzY - $virtual_data.y_axis)  
    $normalizedVertX = [Math]::Abs($vertX - $virtual_data.x_axis)
    $normalizedVertY = [Math]::Abs($vertY - $virtual_data.y_axis)

    # Additional debug info
    Write-Host "Virtual screen origin: ($($virtual_data.x_axis), $($virtual_data.y_axis))" -ForegroundColor DarkGray
    Write-Host "Monitor offsets - Horz: ($($horzX - $virtual_data.x_axis), $($horzY - $virtual_data.y_axis)) Vert: ($($vertX - $virtual_data.x_axis), $($vertY - $virtual_data.y_axis))" -ForegroundColor DarkGray

    Write-Host "Normalized Horizontal position: ($normalizedHorzX, $normalizedHorzY)" -ForegroundColor Cyan
    Write-Host "Normalized Vertical position: ($normalizedVertX, $normalizedVertY)" -ForegroundColor Cyan

    # Create canvas with virtual screen dimensions
    $canvasWidth = $virtual_data.width
    $canvasHeight = $virtual_data.height
    
    Write-Host "Creating canvas: ${canvasWidth}x${canvasHeight}" -ForegroundColor Green

    # Create the composite canvas
    $canvas = New-Object System.Drawing.Bitmap($canvasWidth, $canvasHeight)
    $canvasGraphics = [System.Drawing.Graphics]::FromImage($canvas)
    $canvasGraphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    
    # Fill with dark gray background for debugging
    $canvasGraphics.Clear([System.Drawing.Color]::DarkGray)

    try {
        # Draw outline rectangles first to show placement
        $outlinePen = New-Object System.Drawing.Pen([System.Drawing.Color]::Red, 5)
        
        # Draw horizontal monitor outline
        $canvasGraphics.DrawRectangle($outlinePen, $normalizedHorzX, $normalizedHorzY, $HorzWidth, $HorzHeight)
        Write-Host "Drew horizontal monitor outline at: ($normalizedHorzX, $normalizedHorzY) size: ${HorzWidth}x${HorzHeight}" -ForegroundColor Red

        # Draw vertical monitor outline  
        $canvasGraphics.DrawRectangle($outlinePen, $normalizedVertX, $normalizedVertY, $VertWidth, $VertHeight)
        Write-Host "Drew vertical monitor outline at: ($normalizedVertX, $normalizedVertY) size: ${VertWidth}x${VertHeight}" -ForegroundColor Red

        $outlinePen.Dispose()

        # Save outline version for debugging
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss_fff"
        $tempDir = [System.IO.Path]::GetTempPath()
        $outlinePath = Join-Path $tempDir "composite_outline_${timestamp}.png"
        $canvas.Save($outlinePath, [System.Drawing.Imaging.ImageFormat]::Png)
        Write-Host "DEBUG: Saved outline composite to: $outlinePath" -ForegroundColor Magenta

        # Select and process horizontal image
        $horizontalImagePath = $null
        $count_math = [math]::Floor($totalImgCount / 2)
        if ($Images.Horizontal.Count -gt $count_math) {
            $horizontalImagePath = ($Images.Horizontal | Get-Random).Path
            Write-Host "Selected horizontal image: $(Split-Path $horizontalImagePath -Leaf)" -ForegroundColor Cyan
        } else {
            Write-Host "No suitable horizontal images found, will use vertical image rotated" -ForegroundColor Yellow
            if ($Images.Vertical.Count -gt 0) {
                $horizontalImagePath = ($Images.Vertical | Get-Random).Path
            }
        }

        # Select and process vertical image  
        $verticalImagePath = $null
        if ($Images.Vertical.Count -gt $count_math) {
            $verticalImagePath = ($Images.Vertical | Get-Random).Path
            Write-Host "Selected vertical image: $(Split-Path $verticalImagePath -Leaf)" -ForegroundColor Cyan
        } else {
            Write-Host "No suitable vertical images found, will use horizontal image rotated" -ForegroundColor Yellow
            if ($Images.Horizontal.Count -gt 0) {
                $verticalImagePath = ($Images.Horizontal | Get-Random).Path
            }
        }

        # Process horizontal monitor image
        if ($horizontalImagePath) {
            Write-Host "Processing horizontal image..." -ForegroundColor Yellow
            $horzSourceImage = [System.Drawing.Image]::FromFile($horizontalImagePath)
            $needsRotation = ($Images.Horizontal.Count -lt $count_math) # Rotate if we're using a vertical image
            $horzProcessedImage = Resize-ImageToFit -SourceImage $horzSourceImage -TargetWidth $HorzWidth -TargetHeight $HorzHeight -RotateIfNeeded $needsRotation
            
            # Center the image within the horizontal monitor area
            $horzCenterX = $normalizedHorzX + [int](($HorzWidth - $horzProcessedImage.Width) / 2)
            $horzCenterY = $normalizedHorzY + [int](($HorzHeight - $horzProcessedImage.Height) / 2)
            
            Write-Host "Placing horizontal image at: ($horzCenterX, $horzCenterY) (resized $($horzProcessedImage.Width)x$($horzProcessedImage.Height))" -ForegroundColor Green
            $canvasGraphics.DrawImage($horzProcessedImage, $horzCenterX, $horzCenterY)
            
            $horzSourceImage.Dispose()
            $horzProcessedImage.Dispose()
        }

        # Process vertical monitor image
        if ($verticalImagePath) {
            Write-Host "Processing vertical image..." -ForegroundColor Yellow
            $vertSourceImage = [System.Drawing.Image]::FromFile($verticalImagePath)
            $needsRotation = ($Images.Vertical.Count -lt $count_math) # Rotate if we're using a horizontal image
            $vertProcessedImage = Resize-ImageToFit -SourceImage $vertSourceImage -TargetWidth $VertWidth -TargetHeight $VertHeight -RotateIfNeeded $needsRotation
            
            # Center the image within the vertical monitor area - fix the positioning
            $vertCenterX = $normalizedVertX + [int](($VertWidth - $vertProcessedImage.Width) / 2)
            $vertCenterY = $normalizedVertY + [int](($VertHeight - $vertProcessedImage.Height) / 2)

            # Debug positioning
            Write-Host "Vertical monitor area: ($normalizedVertX, $normalizedVertY) ${VertWidth}x${VertHeight}" -ForegroundColor DarkYellow
            Write-Host "Vertical image size: $($vertProcessedImage.Width)x$($vertProcessedImage.Height)" -ForegroundColor DarkYellow
            Write-Host "Calculated center position: ($vertCenterX, $vertCenterY)" -ForegroundColor DarkYellow
            
            Write-Host "Placing vertical image at: ($vertCenterX, $vertCenterY) (resized $($vertProcessedImage.Width)x$($vertProcessedImage.Height))" -ForegroundColor Green
            $canvasGraphics.DrawImage($vertProcessedImage, $vertCenterX, $vertCenterY)
            
            $vertSourceImage.Dispose()
            $vertProcessedImage.Dispose()
        }

    }
    finally {
        $canvasGraphics.Dispose()
    }

    # Save the final composite wallpaper
    Write-Host "Saving composite wallpaper to: $Output" -ForegroundColor Green
    
    try {
        # Ensure output is a file path, not just directory
        if ((Test-Path $Output -PathType Container) -or $Output.EndsWith('\') -or $Output.EndsWith('/')) {
            $Output = Join-Path $Output "composite_wallpaper_${timestamp}.png"
            Write-Host "Using filename: $Output" -ForegroundColor Yellow
        }
        
        # Ensure directory exists
        $outputDir = Split-Path $Output -Parent
        if (-not (Test-Path $outputDir)) {
            New-Item -Path $outputDir -ItemType Directory -Force | Out-Null
        }
        
        # Save final composite
        $canvas.Save($Output, [System.Drawing.Imaging.ImageFormat]::Png)
        Write-Host "Composite wallpaper saved successfully!" -ForegroundColor Green
        Write-Host "File size: $((Get-Item $Output).Length / 1MB) MB" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to save composite: $($_.Exception.Message)" -ForegroundColor Red
        throw
    }
    finally {
        $canvas.Dispose()
    }
}

function Set-WindowsWallpaper {
    param(
        [string] $ImagePath
    )
    
    Add-Type -TypeDefinition @"
    using System;
    using System.Runtime.InteropServices;
    
    public class Wallpaper {
        [DllImport("user32.dll", CharSet = CharSet.Auto)]
        public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
    }
"@
    
    Write-Host "Setting Windows wallpaper to: $ImagePath" -ForegroundColor Green
    
    # First, set the wallpaper style to "Span" in registry
    try {
        $regPath = "HKCU:\Control Panel\Desktop"
        Set-ItemProperty -Path $regPath -Name "WallpaperStyle" -Value "22" -Force
        Set-ItemProperty -Path $regPath -Name "TileWallpaper" -Value "0" -Force
        Write-Host "Set wallpaper mode to 'Span'" -ForegroundColor Yellow
    }
    catch {
        Write-Warning "Could not set registry values for wallpaper mode: $($_.Exception.Message)"
    }
    
    # Now set the wallpaper
    $SPI_SETDESKWALLPAPER = 0x0014
    $SPIF_UPDATEINIFILE = 0x01
    $SPIF_SENDCHANGE = 0x02
    
    $result = [Wallpaper]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $ImagePath, $SPIF_UPDATEINIFILE -bor $SPIF_SENDCHANGE)
    
    if ($result -eq 0) {
        Write-Warning "SystemParametersInfo returned 0 - wallpaper may not have been set correctly"
    } else {
        Write-Host "Wallpaper set successfully!" -ForegroundColor Green
    }
    
    # Force desktop refresh
    Add-Type -TypeDefinition @"
    using System;
    using System.Runtime.InteropServices;
    
    public class Desktop {
        [DllImport("user32.dll")]
        public static extern bool InvalidateRect(IntPtr hWnd, IntPtr lpRect, bool bErase);
        
        [DllImport("user32.dll")]
        public static extern IntPtr GetDesktopWindow();
    }
"@
    
    [Desktop]::InvalidateRect([Desktop]::GetDesktopWindow(), [IntPtr]::Zero, $true)
    Write-Host "Forced desktop refresh" -ForegroundColor Yellow
}


# Main execution
try {
    $monitorInfo = MonitorAllocation
    Write-Host "=== Dual Monitor Composite Wallpaper Generator ===" -ForegroundColor Magenta
    foreach ($screen in $monitorInfo.monitor_actual.details) {
        if ($screen.type -eq "Horizontal") {
            $HorizontalWidth = $screen.bounds.Width
            $HorizontalHeight = $screen.bounds.Height
            $horzX = $screen.bounds.X_axis
            $horzY = $screen.bounds.Y_axis
        } else {
            $VerticalWidth = $screen.bounds.Width
            $VerticalHeight = $screen.bounds.Height
            $vertX = $screen.bounds.X_axis
            $vertY = $screen.bounds.Y_axis
            if ($screen.bounds.X -lt 0) {
                $VerticalPosition = "Left"
            } elseif ($screen.bounds.X -gt 0) {
                $VerticalPosition = "Right"
            }
        }
    }
    Write-Host "Horizontal dimensions: $HorizontalHeight x $HorizontalWidth" -ForegroundColor Blue
    Write-Host "Vertical dimensions: $verticalHeight x $VerticalWidth" -ForegroundColor Blue
    Write-Host "Horizontal axis: $horzX x $horzY" -ForegroundColor Blue
    Write-Host "Vertical axis: $vertX x $vertY" -ForegroundColor Blue
    Write-Host "Vertical Position: $($VerticalPosition -join ', ')" -ForegroundColor Blue
    Write-Host "Pictures Directory: $PicturesPath" -ForegroundColor White
    Write-Host "Output Location: $OutputImagePath" -ForegroundColor White
    
    # Validate inputs
    if (-not (Test-Path $PicturesPath)) {
        throw "Pictures directory does not exist: $PicturesPath"
    }
    $OutputImagePath = (Resolve-Path $OutputImagePath).Path
    if (-not (Test-Path $OutputImagePath)) {
        Write-Host "Creating output directory: $OutputImagePath" -ForegroundColor Yellow
        New-Item -Path $OutputImagePath -ItemType Directory -Force | Out-Null
    }
    
    # Find suitable images
    $images = Find-SuitableImages -Directory $PicturesPath -ThresholdRatio $AspectRatioThreshold
    
    if ($images.Vertical.Count -eq 0 -and $images.Horizontal.Count -eq 0) {
        throw "No suitable images  found in the specified directory"
    }
    Write-Debug "inadequate images: $($images.not_fit.Count)"

    while($true){    
        # Create composite wallpaper
        CreateCompositeWallpaper -Images $images -HorzWidth $HorizontalWidth -HorzHeight $HorizontalHeight -VertWidth $VerticalWidth -VertHeight $VerticalHeight -Output $OutputImagePath -virtual_data $monitorInfo.monitor_virtual -vertX $vertX -vertY $vertY -horzX $horzX -horzY $horzY -totalImgCount $images.count
            
        Set-WindowsWallpaper -ImagePath $OutputImagePath

        Remove-Item -Path "$($env:TEMP)\*.png" -ErrorAction SilentlyContinue -Force 
        Start-Sleep $sleepDuration
    }    
    Write-Host "`n=== Process Complete ===" -ForegroundColor Magenta
    Write-Host "Your composite wallpaper has been saved to: $OutputImagePath" -ForegroundColor Green
    Write-Host "You can now preview it and if satisfied, uncomment the wallpaper setting code." -ForegroundColor Yellow
}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}