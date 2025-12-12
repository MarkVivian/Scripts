# ensure to update link to the latest one.
# update the download link from : https://www.microsoft.com/en-us/download/details.aspx?id=49117
$office_deployment_url = "https://download.microsoft.com/download/6c1eeb25-cf8b-41d9-8d0d-cc1dbc032140/officedeploymenttool_19231-20072.exe"

function DialogBox{
    param(
        [parameter(Mandatory=$true)]
        [string]$message,
        [switch]$folder = $false
    )
    # Add .NET Windows Forms assembly to use graphical components
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.IO 

    # Create a new OpenFileDialog instance
    $openDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openDialog.CheckFileExists = $false 
    $openDialog.CheckPathExists = $true
    $openDialog.InitialDirectory = $env:USERPROFILE
    $openDialog.Title = $message
    $openDialog.ValidateNames = $false
    $openDialog.Filter =  "Text files (*.txt)|*.txt"
    if($folder){
        $openDialog.FileName = "SelectFolder"      # trick
    }

    # Show the dialog and check if the user clicked "OK"
    if ($openDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        # Return the selected file path
        if($folder){
            return [System.IO.Path]::GetDirectoryName($openDialog.FileName)
        } else {
            return $openDialog.FileName
        }
    } else {
        # Write an error and exit if no file was selected
        Write-Error "No file selected. Exiting script."
        Read-Host "Press Enter to exit..."
        exit 1
    }
}

$installer_directory = DialogBox -message "Select a directory where the installer should be located: " -folder 
$installer = Join-Path -Path $installer_directory -ChildPath "officeInstaller"

if(-not (Test-Path $installer)){
    New-Item -ItemType Directory -Path $installer
}

# get the configuration xml file.
$config_file = DialogBox -message "Select the configuration xml file: "
if($config_file -match "\.xml$"){
    Write-Host "Configuration file selected: $config_file"
} else {
    Write-Host "The selected file is not an XML file. Exiting script." -ForegroundColor Red
    Read-Host "Press Enter to exit..."
    exit 1
}

# This line of code uses the Invoke-WebRequest cmdlet to download the Office Deployment Tool from the specified URL.
# The -Uri parameter specifies the download URL, and the -OutFile parameter specifies the destination file path.
# The downloaded file is saved in the directory specified by the $directory_name variable.
$deployment_directory = Join-Path -Path $installer -ChildPath "office_deployment_tool.exe"
Invoke-WebRequest -Uri $office_deployment_url -OutFile $deployment_directory

# get the office customization tools.
# Get the directory where the script is located
copy-item $config_file -destination $installer -Force

# run the office deployment tools
start-process $deployment_directory -Wait

# run the setup.
set-location $installer
.\setup.exe /configure .\Configuration.xml
Write-Host "installation has begun succesfully `n once the office installer is done your office will be ready."