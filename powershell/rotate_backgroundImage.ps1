# this will ensure that the background image of the vertical monitor is rotated to fit.

# ensure the MutlMonitorTool package is installed.
function Install-MultMonitorTool {
    $packageName = "MutlMonitorTool"
    $packagePath = "$env:ProgramFiles\"

    # ensure that the search doesn't require case sensitivity.
    $searchResults = Get-ChildItem -Path $packagePath -ErrorAction SilentlyContinue -Filter "$packageName"

    if ($searchResults.Name) {
        Write-Host "$packageName is already installed."
    } else {
        Write-Host "Installing $packageName..." -ForegroundColor Yellow
        Invoke-WebRequest -Uri "https://www.nirsoft.net/utils/multimonitortool-x64.zip" -OutFile "$packagePath\$packageName.zip"
        Write-Host "Extracting $packageName..." -ForegroundColor Yellow
        Expand-Archive -Path "$packagePath\$packageName.zip" -DestinationPath $packagePath
        Remove-Item -Path "$packagePath\$packageName.zip" -Recurse 
        Write-Host "$packageName installed successfully." -ForegroundColor Green
    }
}


function Walpaper_Machine {
    $wallpaperPath = "C:\Users\Mark\Pictures\cars\" 

    
}