$office_deployment = Read-Host "enter the download link from  `n https://www.microsoft.com/en-us/download/details.aspx?id=49117"

if ($office_deployment.Trim() -eq "") {
    Write-Host "no url provided .... using default url"
    $office_deployment = "https://download.microsoft.com/download/2/7/A/27AF1BE6-DD20-4CB4-B154-EBAB8A7D4A7E/officedeploymenttool_17830-20162.exe"
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
        Write-Host "Invalid selection. Defaulting to Desktop." -ForegroundColor Red
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

# for the exe files.
function Get-FolderFromDialog {
    # Add .NET Windows Forms assembly to use graphical components
    Add-Type -AssemblyName System.Windows.Forms

    # Create a new FolderBrowserDialog instance
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog

    # Set the dialog's description, shown at the top of the window
    $folderBrowser.Description = "Select the folder where the script is located"

    # Set the root folder from where the browsing starts (e.g., My Computer)
    $folderBrowser.RootFolder = [System.Environment+SpecialFolder]::MyComputer

    # Show the dialog and check if the user clicked "OK"
    if ($folderBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        # Return the selected folder path
        return $folderBrowser.SelectedPath
    } else {
        # Write an error and exit if no folder was selected
        Write-Error "No folder selected. Exiting script."
        exit 1
    }
}

# Get the directory where the script is located 
# UPDATED FOR EXE FILES.
try{
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
}catch{
    # i tried if statements but nothing was working.
    # if it can't get the directory the script is located ask the user.
    $home_directory = Get-FolderFromDialog

    # Check if the provided home directory exists and check if the script is located in that directory
    $script_location = Join-Path $home_directory "installing_office.exe"

    if (Test-Path $home_directory){
        if(Test-Path -Path $script_location) {
            $scriptDir = $home_directory
        } else {
            Write-Error "The script could not be located in the provided home directory. $home_directory"
            exit 1
        }
    } else {
        Write-Error "The provided home directory does not exist. $home_directory"
        exit 1
    }
}

# configuration file location.
# todo : make sure you are updating the file each time to ensure consistency in downloads.
$office_customization=Join-Path -Path $ScriptDir -ChildPath "Configuration.xml" 

# Check if Configuration.xml exists
if (-not (Test-Path $office_customization)) {
    Write-Host "Configuration.xml file not found in script directory." -ForegroundColor Red
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