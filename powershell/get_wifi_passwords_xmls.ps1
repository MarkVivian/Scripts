# Define a class to hold server information
class ServerInfo {
    [String] $profile_name
    [String] $profile_key
}

try {
    # Initialize a variable to count the number of new additions
    [int] $number_of_new_additions = 0

    # Define a function to format raw data into a list of ServerInfo objects
    function Get-FormattedProfiles {
        # Define a parameter for the raw data
        param($rawData)

        # Initialize an empty list to store the formatted data
        $content_list = @()

        # Initialize variables to hold the current profile name and key
        $profile_name = ""
        $key_name = ""

        # Loop through each line in the raw data
        foreach ($line in $($rawData -Split "`n")) {
            # Check if the line is not empty
            if($line){
                # Check if the line contains the word "Profile"
                if ($line -match "Profile"){
                    # Set the profile name to the current line
                    $profile_name=$line
                }
    
                # Check if the line contains the word "key"
                if ($line -match "key"){
                    # Set the key name to the current line
                    $key_name=$line
                }
    
                # Check if both profile name and key name are set
                if ($profile_name -and $key_name){
                    # Create a new ServerInfo object
                    $ServerInfo = New-Object ServerInfo
                    # Set the profile name and key of the ServerInfo object
                    $ServerInfo.profile_name = $profile_name
                    $ServerInfo.profile_key = $key_name
                    # Reset the profile name and key variables
                    $profile_name = $null
                    $key_name= $null
                    # Add the ServerInfo object to the content list
                    $content_list += $ServerInfo
                }
            }
        }  
        # Return the list of formatted ServerInfo objects
        return $content_list
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
        $script_location = Join-Path $home_directory "x64get_wifi_passwords_xmls.exe"

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

    # check if a folder exists for storage of wifi xmls.
    $xml_folder = $(Join-Path -Path $scriptDir -ChildPath "wifi_xmls")
    if (!(Test-Path $xml_folder)) {
        New-Item -ItemType Directory -Path $xml_folder
    }

    # Define the path for the output file
    $outputFile = Join-Path $scriptDir "WifiProfilesAndKeys.txt"

    # Read existing content from the output file if it exists
    if (Test-Path $outputFile) {
        # Read the entire content of the file into a single string
        $existingContent = Get-Content $outputFile -Raw
        $existing_content_list = Get-FormattedProfiles -rawData $existingContent
    } else {
        # Initialize as empty string if the file does not exist
        $existingContent = ""
    }

    # Retrieve all WLAN profiles
    $profiles = netsh wlan show profiles | Select-String "All User Profile" | ForEach-Object {
        # Extract profile names by removing the leading text
        $_ -replace ".*: ", ""
    }

    # Initialize an array to store the content that will be written to the file
    $outputContent = @()

    # Iterate through each profile and show the key
    foreach ($profile in $profiles) {
        # Get the profile information including the key
        $profileInfo = netsh wlan show profile name="$profile" key=clear | Select-String "Key Content"

        # If the profile info contains the key, extract it
        if ($profileInfo) {
            $profileKey = $profileInfo -replace ".*: ", ""           
        } else {
            $profileKey = "No key found"
        }

        $profile_name_1 = $profile
        $profile_key_1 = $profileKey
        foreach($inform in $existing_content_list){
            $profile_name_2 = $inform.profile_name | ForEach-Object{
                $_ -replace ".*: ", ""
            }
            $profile_key_2 = $inform.profile_key | ForEach-Object{
                $_ -replace ".*: ", ""
            }
            if($profile_name_1.Trim() -eq $profile_name_2.Trim() -and $profile_key_1.Trim() -eq $profile_key_2.Trim()){
                $current_match_state = $true
                break
            }
        }  
        if (-not $current_match_state){
            # Add the new entry to the output content array
            $outputContent += "Profile: $profile_name_1 `n Key: $profile_key_1 `n"
            Write-Host "new addition $profile_name_1"
            $number_of_new_additions = $number_of_new_additions + 1 

            # get the wifi xml profiles.
            # this will allow only profiles which are not known.
            netsh wlan export profile name=$profile_name_1 key=clear folder=$xml_folder
        }
        $current_match_state = $false
        
    }

    # Write only the new entries to the output file, appending to existing content
    if ($outputContent.Count -gt 0) {
        $outputContent -join "`n" | Out-File -FilePath $outputFile -Append
    }

    if($number_of_new_additions -gt 0){
        Write-Host "WLAN profile information has been updated in $outputFile `n $number_of_new_additions added"
    } else{
        Write-Host "no update required"
    }
}
finally {
    # Reset the execution policy back to the original policy
    # Set-ExecutionPolicy -Scope Process -ExecutionPolicy Restricted
}
 