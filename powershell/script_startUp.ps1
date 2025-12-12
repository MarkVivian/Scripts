[CmdletBinding()]
param(
    [parameter(Mandatory=$true)]
    [string]$script,
    [parameter(Mandatory=$true)]
    [string]$arguments
)

function DialogBox{
    param(
        [parameter(Mandatory=$true)]
        [string]$message
    )
    # Add .NET Windows Forms assembly to use graphical components
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.IO 

    # Create a new OpenFileDialog instance
    $openDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openDialog.CheckFileExists = $true 
    $openDialog.CheckPathExists = $true
    $openDialog.InitialDirectory = $env:USERPROFILE
    $openDialog.Title = $message
    $openDialog.ValidateNames = $true
 
    # Show the dialog and check if the user clicked "OK"
    if ($openDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        # Return the selected file path
        return $openDialog.FileName
    } else {
        # Write an error and exit if no file was selected
        Write-Host "No file selected. Exiting script." -ForegroundColor Red
        Read-Host "Press Enter to exit..."
        exit 1
    }
}

try{
    # if scirpt and arguments are not provided , call DialogBox and a Read-Host
    if(-not $script){
        $script = DialogBox "Select the script you want to run at startup"
        if(-not $script){
            Write-Host "No script selected. Exiting." -ForegroundColor Red
            Read-Host "Press Enter to exit..."
            exit 1
        }
    }
    if(-not $arguments){
        $arguments = Read-Host "Enter the arguments to be passed to the script (if any). If none, just press Enter"
    }

}catch{
    Write-Host $_.Exception.Message -ForegroundColor Red
    Read-Host "Press Enter to exit..."
    exit 1
}