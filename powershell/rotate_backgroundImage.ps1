<#
.SYNOPSIS
    Creates a composite wallpaper for multiple monitors with either
    the same image across all monitors (-Same) or different images per monitor (-Diff).

.DESCRIPTION
    - In -Same mode: one random image is chosen for all monitors,
      portrait monitors get it rotated automatically.
    - In -Diff mode: each monitor gets its own orientation-appropriate image.
      If no portrait image exists, falls back to rotated same image.

.NOTES
    Requires: PowerShell 5+ or 7+, System.Drawing
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("Same","Diff")]
    [string]$Mode,   # Choose mode: Same or Diff
    [Parameter(Mandatory=$true)]
    [string]$ImageFolder,   # folder with images
    [string]$OutputFile  = "$env:TEMP\composite_wallpaper.bmp"  # wallpaper Windows will use
)

# -------------------------------
# Step 1: Get monitor resolutions
# -------------------------------
Add-Type -AssemblyName System.Windows.Forms
$monitors = [System.Windows.Forms.Screen]::AllScreens

$monitorInfo = @()
foreach ($m in $monitors) {
    $width  = $m.Bounds.Width
    $height = $m.Bounds.Height
    $orientation = if ($height -gt $width) { "Portrait" } else { "Landscape" }

    $monitorInfo += [PSCustomObject]@{
        DeviceName  = $m.DeviceName
        Width       = $width
        Height      = $height
        Orientation = $orientation
    }
}

Write-Host "`nDetected Monitors:" -ForegroundColor Cyan
$monitorInfo | Format-Table

# -------------------------------
# Step 2: Load images
# -------------------------------
Add-Type -AssemblyName System.Drawing
$files = Get-ChildItem -Path $ImageFolder -Include *.jpg,*.jpeg,*.png -File
if (-not $files) { throw "No images found in $ImageFolder" }

# Helper: get a random image
function Get-RandomImage {
    param([string]$orientation)
    $filtered = foreach ($f in $files) {
        try {
            $img = [System.Drawing.Image]::FromFile($f.FullName)
            if ($orientation -eq "Portrait" -and $img.Height -gt $img.Width) { $f }
            elseif ($orientation -eq "Landscape" -and $img.Width -ge $img.Height) { $f }
            $img.Dispose()
        } catch {}
    }
    if ($filtered) {
        return Get-Random -InputObject $filtered
    }
    else {
        return $null  # fallback case handled later
    }
}

# -------------------------------
# Step 3: Assign images to monitors
# -------------------------------
$assignments = @()

if ($Mode -eq "Same") {
    # Pick one random image for all monitors
    $chosen = Get-Random -InputObject $files
    foreach ($m in $monitorInfo) {
        $assignments += [PSCustomObject]@{
            DeviceName  = $m.DeviceName
            Orientation = $m.Orientation
            Width       = $m.Width
            Height      = $m.Height
            Image       = $chosen.FullName
            Rotate      = $m.Orientation -eq "Portrait"
        }
    }
}
elseif ($Mode -eq "Diff") {
    foreach ($m in $monitorInfo) {
        $imgFile = Get-RandomImage -orientation $m.Orientation
        $rotate = $false
        if (-not $imgFile) {
            # No orientation-specific image, fallback
            $imgFile = Get-Random -InputObject $files
            $rotate = ($m.Orientation -eq "Portrait")
        }

        $assignments += [PSCustomObject]@{
            DeviceName  = $m.DeviceName
            Orientation = $m.Orientation
            Width       = $m.Width
            Height      = $m.Height
            Image       = $imgFile.FullName
            Rotate      = $rotate
        }
    }
}

Write-Host "`nImage Assignments:" -ForegroundColor Cyan
$assignments | Format-Table DeviceName Orientation Image Rotate

# -------------------------------
# Step 4: Build composite wallpaper
# -------------------------------
$totalWidth  = ($monitorInfo | Measure-Object -Property Width -Sum).Sum
$totalHeight = ($monitorInfo | Measure-Object -Property Height -Maximum).Maximum

$bitmap = New-Object System.Drawing.Bitmap $totalWidth, $totalHeight
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.Clear([System.Drawing.Color]::Black)

$xOffset = 0
foreach ($a in $assignments) {
    $img = [System.Drawing.Image]::FromFile($a.Image)

    # Rotate if needed
    if ($a.Rotate) { $img.RotateFlip([System.Drawing.RotateFlipType]::Rotate90FlipNone) }

    # Resize to fit monitor
    $resized = New-Object System.Drawing.Bitmap $a.Width, $a.Height
    $g2 = [System.Drawing.Graphics]::FromImage($resized)
    $g2.DrawImage($img, 0, 0, $a.Width, $a.Height)
    $g2.Dispose()

    # Paste into composite
    $graphics.DrawImage($resized, $xOffset, 0, $a.Width, $a.Height)

    $xOffset += $a.Width
    $img.Dispose()
    $resized.Dispose()
}

$graphics.Dispose()
$bitmap.Save($OutputFile, [System.Drawing.Imaging.ImageFormat]::Bmp)
$bitmap.Dispose()

Write-Host "`nComposite wallpaper saved to $OutputFile" -ForegroundColor Green

# -------------------------------
# Step 5: Apply wallpaper
# -------------------------------
Add-Type @"
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@

$SPI_SETDESKWALLPAPER = 20
$SPIF_UPDATEINIFILE = 1
$SPIF_SENDCHANGE = 2
[Wallpaper]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $OutputFile, $SPIF_UPDATEINIFILE -bor $SPIF_SENDCHANGE)

Write-Host "`nWallpaper applied!" -ForegroundColor Green
