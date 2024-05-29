class ServerInfo {
    [String] $profile_name
    [String] $profile_key
}

try {
    [int] $number_of_new_additions = 0
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

    # Get the directory where the script is located
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

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
        }
        $current_match_state = $false
        
    }

    # Write only the new entries to the output file, appending to existing content
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
