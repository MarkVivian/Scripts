# this will ensure that the background image of the vertical monitor is rotated to fit.

# ensure the MutlMonitorTool package is installed.
function Install-MultMonitorTool {
    $packageName = "MutlMonitorTool"
    $packagePath = "$env:ProgramFiles\$packageName"

    if (-not (Test-Path $packagePath)) {
        Write-Host "Installing MutlMonitorTool package..." -ForegroundColor Green
        # Assuming the package is available in a specific location, adjust the path as necessary.
        $sourcePath = "C:\path\to\MutlMonitorTool.zip"
        Expand-Archive -Path $sourcePath -DestinationPath $env:ProgramFiles -Force
    } else {
        Write-Host "MutlMonitorTool is already installed." -ForegroundColor Yellow
    }
}