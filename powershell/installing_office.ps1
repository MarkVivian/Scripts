$office_deployment = Read-Host "enter the download link from  `n https://www.microsoft.com/en-us/download/details.aspx?id=49117"

if ($office_deployment.Trim() -eq "") {
    Write-Host "no url provided .... using default url"
    $office_deployment = "https://download.microsoft.com/download/2/7/A/27AF1BE6-DD20-4CB4-B154-EBAB8A7D4A7E/officedeploymenttool_17531-20046.exe"
}

# ask the user where the installation directory is to be stored.
$directory = Read-Host "In which directory would you want the installer to be located: `n 1) Desktop `n 2) Downloads `n 3) Documents"

# choose which directory the office installer is located.
switch ($directory) {
    1 {
        $directory = "Desktop"
      }
    2 {
        $directory  = "Downloads"
    }
    3 {
        $directory = "Documents"
    }
    Default {
        Write-Host "Invalid selection. Defaulting to Desktop."
        $directory = "Desktop"
    }
}

Write-Host "Storing the directory in $($directory)"

# get the office deployment tools 
$user=$env:USERPROFILE

$directory_name= Join-Path -Path ( Join-Path -Path $user -ChildPath $directory) -ChildPath "office2021Installer"
# "$($user)\$($directory)\office2021Installer"

# create the office directory if it doesn't exist.
if (-not (Test-Path $directory_name)) {
    new-item -type directory -path $directory_name   
}

# get the current location where the script is running.
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# configuration file location.
# todo : make sure you are updating the file each time to ensure consistency in downloads.
$office_customization=Join-Path -Path $ScriptDir -ChildPath "Configuration.xml" 

# Check if Configuration.xml exists
if (-not (Test-Path $office_customization)) {
    Write-Host "Configuration.xml file not found in script directory."
    exit
}
 
# This line of code uses the Invoke-WebRequest cmdlet to download the Office Deployment Tool from the specified URL.
# The -Uri parameter specifies the download URL, and the -OutFile parameter specifies the destination file path.
# The downloaded file is saved in the directory specified by the $directory_name variable.
Invoke-WebRequest -Uri $office_deployment -OutFile "$($directory_name)\officedeploymenttool_17531-20046.exe"


# get the office customization tools.
# Get the directory where the script is located
copy-item $office_customization -destination $directory_name -Force

# run the office deployment tools
Write-Host "please save the contents to $($directory_name)"
start-process "$($directory_name)\officedeploymenttool_17531-20046.exe" -Wait



# run the setup.
set-location $directory_name
.\setup.exe /configure .\Configuration.xml
Write-Host "installation has begun succesfully `n once the office installer is done your office will be ready."