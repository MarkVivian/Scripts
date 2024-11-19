# Function to check if the script is run with administrative privileges
# run the file in remotesigned execution policy.

class ServerInfo {
    [String] $profile_name
    [String] $profile_key
}

try {
    
    [int] $threshold=50
    [int] $number_of_jobs=1
    [int] $number_of_new_additions = 0

    # Initialize an array to store the content that will be written to the file
    $outputContent = @()

    # initialize an array to store the content gotten from the windows machine
    $entry_list=@()

    function calculator{
        param(
            $existing_content_count_value
        )
        $squareRoot = [math]::Sqrt($existing_content_count_value)
        $cubeRoot= [math]::Pow($existing_content_count_value, 1/3)
    
        if ($squareRoot -le $threshold){
            $number_of_jobs=2
        }elseif ($cubeRoot -le $threshold) {
            $number_of_jobs=3
        }else{
            Write-Host "please update the jobs.. the content value is too big."
            if ($squareRoot -le $cubeRoot){
                $number_of_jobs=4
            }else{
                $number_of_jobs=5
            }
        }
    }

    function Get-FormattedProfiles {
        param($rawData)
        $content_list = @()
        $profile_name = ""
        $key_name = ""
        foreach ($line in $($rawData -Split "`n")) {
            if($line){
                if ($line -match "Profile"){
                    $profile_name=$line
                }
    
                if ($line -match "key"){
                    $key_name=$line
                }

    
                if ($profile_name -and $key_name){
                    $ServerInfo = New-Object ServerInfo
                    $ServerInfo.profile_name = $profile_name
                    $ServerInfo.profile_key = $key_name
                    $profile_name = $null
                    $key_name= $null
                    $content_list += $ServerInfo
                }
            }
        }  
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
    
        # Set the initially selected folder to the user's home directory
        $folderBrowser.SelectedPath = $HOME
    
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
        $script_location = Join-Path $home_directory "get_wifi_passwords.exe"

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

    # Define the path for the output file
    $outputFile = Join-Path $scriptDir "WifiProfilesAndKeys.txt"

    # Read existing content from the output file if it exists using the test-path command.
    if (Test-Path $outputFile) {
        $existence = $true
        # Read the entire content of the file into a single string
        $existingContent = Get-Content $outputFile -Raw
        $existing_content_list = Get-FormattedProfiles -rawData $existingContent

        # get the number of profiles in the existing content.
        [int] $existing_content_count=($existingContent -Split("Profile")).Count - 1

        calculator -existing_content_count_value $existing_content_count

    } else {
        $existence = $false
        # Initialize as empty string if the file does not exist
        Write-Host "the file is empty"
        $existingContent = ""
    }


    # Retrieve all WLAN profiles
    $profiles = netsh wlan show profiles | Select-String "All User Profile" | ForEach-Object {
        # Extract profile names by removing the leading text
        $_ -replace ".*: ", ""
    }

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
        
        # Create a formatted entry for the new profile
        $entry = "Profile: $profile `n Key: $profileKey `n"

        $entry_list+=$entry
    }

    # get the number of profiles gotten from the host machine
    [int] $entry_list_count = ($entry_list).Count



    # this function should perform pararrel processing when checking if it exists.
    # this is the heavy weight of the entire script.
    function check_if_exists{
        param(
            $entry_data
        )
        $profile_per_job=[math]::Ceiling($entry_list_count / $number_of_jobs)

        $jobs=@()
        $current_match_state=$false
        for ($i = 0; $i -lt $number_of_jobs; $i++) {
            # this will get the profiles that each job will handle.
            $start = $i * $profile_per_job
            $end = [math]::Min($start + $profile_per_job, $entry_data.Count)
            
            # this divides the entries per job
            $sub_entries = $entry_data[$start..($end - 1)]

            $jobs += Start-Job -ScriptBlock {
                param (
                    $entries,
                    $existing_content_list
                )
                $outputContentValue = @()
                foreach ($entry in $entries) {
                    $test_subject_1 = ($entry -Split "`n" | ForEach-Object {
                        $_ -replace ".*: ", ""
                    })
                    $profile_name_1 = $test_subject_1[0]
                    $profile_key_1 = $test_subject_1[1]
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
                           $outputContentValue += "Profile: $profile_name_1 `n Key: $profile_key_1 `n"
                           Write-Host "new addition $profile_name_1"
                           $number_of_new_additions = $number_of_new_additions + 1
                   }
                   $current_match_state = $false
                }
                return $outputContentValue
            } -ArgumentList $sub_entries, $existing_content_list
        }
        
        foreach ($job in $jobs){
            $jobs_results = Receive-Job -Job $job -Wait
            # Write-Host $jobs_results
            $outputContent += $jobs_results
            Remove-Job -Job $job
        }
        return $outputContent
    }

    if ($existence){
        $outputContent = check_if_exists -entry_data $entry_list
    }else{
        $outputContent = $entry_list
    }
    
    if ($outputContent.Count -gt 0) {
        $outputContent -join "`n" | Out-File -FilePath $outputFile -Append -Encoding utf8
    }

    if($number_of_new_additions -gt 0){
        Write-Host "WLAN profile information has been updated in $outputFile `n $number_of_new_additions added"
    } else{
        Write-Host "no update required"
    }
}
finally {
    # Reset the execution policy back to the original policy
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Restricted
}
