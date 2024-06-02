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

    # Get the directory where the script is located
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

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
`

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
