[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string] $PicturesPath,
    
    [Parameter(Mandatory = $true)]
    [string] $OutputPath,
    
    [int] $HorizontalWidth = 2560,
    
    [int] $HorizontalHeight = 1440,
    
    [int] $VerticalWidth = 1080,
    
    [int] $VerticalHeight = 1920,
    
    [Parameter()]
    [ValidateSet("Left", "Right", "Top", "Bottom")]
    [string] $VerticalPosition = "Left",
    
    [Parameter()]
    [double] $AspectRatioThreshold = 1.3,
    
    [switch] $DebugMode
)

# Enable debug output if requested
if ($DebugMode) {
    $DebugPreference = "Continue"
}

# Load required assemblies for image manipulation
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms


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
        $allImages += Get-ChildItem -Path $Directory -Filter $ext -Recurse -ErrorAction SilentlyContinue
    }
    
    Write-Host "Found $($allImages.Count) image files" -ForegroundColor Green
    
    $verticalImages = @()
    $horizontalImages = @()
    $processedCount = 0
    
    foreach ($imageFile in $allImages) {
        $processedCount++
        Write-Progress -Activity "Analyzing Images" -Status "Processing $($imageFile.Name)" -PercentComplete (($processedCount / $allImages.Count) * 100)
        
        $dimensions = Get-ImageDimensions -ImagePath $imageFile.FullName
        if ($dimensions) {
            Write-Debug "Image: $($imageFile.Name) - Dimensions: $($dimensions.Width)x$($dimensions.Height) - Ratio: $($dimensions.AspectRatio.ToString('F2'))"
            
            # If aspect ratio is less than threshold, it's more vertical (height > width * threshold)
            if ($dimensions.AspectRatio -lt (1 / $ThresholdRatio)) {
                $verticalImages += $dimensions
                Write-Debug "  -> Classified as VERTICAL"
            } else {
                $horizontalImages += $dimensions
                Write-Debug "  -> Classified as HORIZONTAL"
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
    }
}

function Resize-ImageToFit {
    param(
        [System.Drawing.Image] $SourceImage,
        [int] $TargetWidth,
        [int] $TargetHeight,
        [bool] $RotateIfNeeded = $false
    )
    
    $sourceWidth = $SourceImage.Width
    $sourceHeight = $SourceImage.Height
    $sourceRatio = $sourceWidth / $sourceHeight
    $targetRatio = $TargetWidth / $TargetHeight
    
    # Check if we should rotate the image for better fit
    if ($RotateIfNeeded) {
        $rotatedRatio = $sourceHeight / $sourceWidth
        if ([Math]::Abs($rotatedRatio - $targetRatio) -lt [Math]::Abs($sourceRatio - $targetRatio)) {
            Write-Debug "Rotating image for better fit"
            $SourceImage.RotateFlip([System.Drawing.RotateFlipType]::Rotate90FlipNone)
            $sourceWidth = $SourceImage.Width
            $sourceHeight = $SourceImage.Height
            $sourceRatio = $sourceWidth / $sourceHeight
        }
    }
    
    # Calculate scaling to fit within target dimensions while maintaining aspect ratio
    $scaleWidth = $TargetWidth / $sourceWidth
    $scaleHeight = $TargetHeight / $sourceHeight
    $scale = [Math]::Min($scaleWidth, $scaleHeight)
    
    $newWidth = [int]($sourceWidth * $scale)
    $newHeight = [int]($sourceHeight * $scale)
    
    Write-Debug "Resizing from ${sourceWidth}x${sourceHeight} to ${newWidth}x${newHeight} (scale: $($scale.ToString('F2')))"
    
    # Create new bitmap with calculated dimensions
    $resizedImage = New-Object System.Drawing.Bitmap($newWidth, $newHeight)
    $graphics = [System.Drawing.Graphics]::FromImage($resizedImage)
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    
    # Draw the resized image
    $graphics.DrawImage($SourceImage, 0, 0, $newWidth, $newHeight)
    $graphics.Dispose()
    
    return $resizedImage
}

function CreateCompositeWallpaper {
    param(
        [hashtable] $Images,
        [int] $HorzWidth,
        [int] $HorzHeight, 
        [int] $VertWidth,
        [int] $VertHeight,
        [string] $VertPos,
        [string] $Output
    )
    
    Write-Host "`nCreating composite wallpaper..." -ForegroundColor Yellow
    
    # Calculate total canvas size based on monitor arrangement
    switch ($VertPos) {
        "Left" { 
            $canvasWidth = $VertWidth + $HorzWidth
            $canvasHeight = [Math]::Max($VertHeight, $HorzHeight)
            $vertX = 0; $vertY = 0
            $horzX = $VertWidth; $horzY = 0
        }
        "Right" { 
            $canvasWidth = $HorzWidth + $VertWidth
            $canvasHeight = [Math]::Max($HorzHeight, $VertHeight)
            $horzX = 0; $horzY = 0
            $vertX = $HorzWidth; $vertY = 0
        }
        "Top" { 
            $canvasWidth = [Math]::Max($HorzWidth, $VertWidth)
            $canvasHeight = $VertHeight + $HorzHeight
            $vertX = 0; $vertY = 0
            $horzX = 0; $horzY = $VertHeight
        }
        "Bottom" { 
            $canvasWidth = [Math]::Max($HorzWidth, $VertWidth)
            $canvasHeight = $HorzHeight + $VertHeight
            $horzX = 0; $horzY = 0
            $vertX = 0; $vertY = $HorzHeight
        }
    }
    
    Write-Host "Canvas size: ${canvasWidth}x${canvasHeight}" -ForegroundColor Green
    Write-Host "Horizontal monitor position: (${horzX}, ${horzY}) - Size: ${HorzWidth}x${HorzHeight}" -ForegroundColor Green
    Write-Host "Vertical monitor position: (${vertX}, ${vertY}) - Size: ${VertWidth}x${VertHeight}" -ForegroundColor Green
    
    # Create the composite canvas
    $canvas = New-Object System.Drawing.Bitmap($canvasWidth, $canvasHeight)
    $canvasGraphics = [System.Drawing.Graphics]::FromImage($canvas)
    $canvasGraphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    
    # Fill with black background
    $canvasGraphics.Clear([System.Drawing.Color]::Black)
    
    try {
        # Select and process horizontal image
        $horizontalImagePath = $null
        if ($Images.Horizontal.Count -gt 0) {
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
        if ($Images.Vertical.Count -gt 0) {
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
            $horzSourceImage = [System.Drawing.Image]::FromFile($horizontalImagePath)
            $needsRotation = ($Images.Horizontal.Count -eq 0) # Rotate if we're using a vertical image
            $horzProcessedImage = Resize-ImageToFit -SourceImage $horzSourceImage -TargetWidth $HorzWidth -TargetHeight $HorzHeight -RotateIfNeeded $needsRotation
            
            # Center the image within the horizontal monitor area
            $horzCenterX = $horzX + [int](($HorzWidth - $horzProcessedImage.Width) / 2)
            $horzCenterY = $horzY + [int](($HorzHeight - $horzProcessedImage.Height) / 2)
            
            $canvasGraphics.DrawImage($horzProcessedImage, $horzCenterX, $horzCenterY)
            
            $horzSourceImage.Dispose()
            $horzProcessedImage.Dispose()
        }
        
        # Process vertical monitor image
        if ($verticalImagePath) {
            $vertSourceImage = [System.Drawing.Image]::FromFile($verticalImagePath)
            $needsRotation = ($Images.Vertical.Count -eq 0) # Rotate if we're using a horizontal image
            $vertProcessedImage = Resize-ImageToFit -SourceImage $vertSourceImage -TargetWidth $VertWidth -TargetHeight $VertHeight -RotateIfNeeded $needsRotation
            
            # Center the image within the vertical monitor area
            $vertCenterX = $vertX + [int](($VertWidth - $vertProcessedImage.Width) / 2)
            $vertCenterY = $vertY + [int](($VertHeight - $vertProcessedImage.Height) / 2)
            
            $canvasGraphics.DrawImage($vertProcessedImage, $vertCenterX, $vertCenterY)
            
            $vertSourceImage.Dispose()
            $vertProcessedImage.Dispose()
        }
        
    }
    finally {
        $canvasGraphics.Dispose()
    }
    
    # Save the composite wallpaper
    Write-Host "Saving composite wallpaper to: $Output" -ForegroundColor Green
    $imageFormat = [System.Drawing.Imaging.ImageFormat]::Png
    $canvas.Save($Output, $imageFormat)
    $canvas.Dispose()
    
    Write-Host "Composite wallpaper created successfully!" -ForegroundColor Green
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
    $SPI_SETDESKWALLPAPER = 0x0014
    $SPIF_UPDATEINIFILE = 0x01
    $SPIF_SENDCHANGE = 0x02
    
    [Wallpaper]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $ImagePath, $SPIF_UPDATEINIFILE -bor $SPIF_SENDCHANGE)
}

# Main execution
try {
    Write-Host "=== Dual Monitor Composite Wallpaper Generator ===" -ForegroundColor Magenta
    Write-Host "Pictures Directory: $PicturesPath" -ForegroundColor White
    Write-Host "Output Location: $OutputPath" -ForegroundColor White
    Write-Host "Horizontal Monitor: ${HorizontalWidth}x${HorizontalHeight}" -ForegroundColor White
    Write-Host "Vertical Monitor: ${VerticalWidth}x${VerticalHeight}" -ForegroundColor White
    Write-Host "Vertical Position: $VerticalPosition" -ForegroundColor White
    Write-Host "Aspect Ratio Threshold: $AspectRatioThreshold" -ForegroundColor White
    
    # Validate inputs
    if (-not (Test-Path $PicturesPath)) {
        throw "Pictures directory does not exist: $PicturesPath"
    }
    $OutputPath = (Resolve-Path $OutputPath).Path
    if (-not (Test-Path $OutputPath)) {
        Write-Host "Creating output directory: $outputPath" -ForegroundColor Yellow
        New-Item -Path $outputPath -ItemType Directory -Force | Out-Null
    }
    
    # Find suitable images
    $images = Find-SuitableImages -Directory $PicturesPath -ThresholdRatio $AspectRatioThreshold
    
    if ($images.Vertical.Count -eq 0 -and $images.Horizontal.Count -eq 0) {
        throw "No suitable images  found in the specified directory"
    }
    
    # Create composite wallpaper
    CreateCompositeWallpaper -Images $images -HorzWidth $HorizontalWidth -HorzHeight $HorizontalHeight -VertWidth $VerticalWidth -VertHeight $VerticalHeight -VertPos $VerticalPosition -Output $OutputPath
    
    Set-WindowsWallpaper -ImagePath $OutputPath
    
    Write-Host "`n=== Process Complete ===" -ForegroundColor Magenta
    Write-Host "Your composite wallpaper has been saved to: $OutputPath" -ForegroundColor Green
    Write-Host "You can now preview it and if satisfied, uncomment the wallpaper setting code." -ForegroundColor Yellow
}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}