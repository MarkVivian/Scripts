# Define a parameter to accept the path to the input file.
param(
    [string] $path_to_file
)

# Define a class to hold profile information(ServerInfo).
class ServerInfo{
    [string] $profile_name
    [string] $profile_key
}

try {
    # Read the content of the input file as a single string.
    $get_data_to_sort = get-content $path_to_file -Raw

    # Get the directory where the script is located
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

    # Define the path for the output file by replacing part of the input file path.
    $outputFile = Join-Path $scriptDir $($path_to_file | ForEach-Object{
        $_ -replace ".*W", "W"
    })

    # Define a function to parse and format the raw profile data.
    function Get-FormattedProfiles {
        param($rawData)
        $content_list = @() # Initialie an empty arra to hold profile data.
        $profile_name = ""
        $key_name = ""

        # iterate over each line in the raw data.
        foreach ($line in $($rawData -Split "`n")) {
            if($line){
                # capture profile and key name.
                if ($line -match "Profile"){
                    $profile_name=$line 
                }
    
                if ($line -match "key"){
                    $key_name=$line
                }

                # If both profile name and key are captured, create a new ServerInfo object
                if ($profile_name -and $key_name){
                    $ServerInfo = New-Object ServerInfo
                    $ServerInfo.profile_name = $profile_name
                    $ServerInfo.profile_key = $key_name
                    $profile_name = $null
                    $key_name= $null
                    $content_list += $ServerInfo #  Add the ServerInfo object to the list
                }
            }
        }  
        return $content_list # Return the list of ServerInfo objects
    }

    # Define a function to remove redundant entries from the sorted data.
    function Remove-Redundancy{
        param (
            $sorted_data
        )

        $previous_item_profile_name = ""
        $previous_item_profile_key = ""
        $sorted_unique = @() # Initialize an empty array to hold unique profiles.

        # Iterate over each item in the sorted data.
        foreach ($item in $sorted_data) {
            $profile_name = $item.profile_name
            $profile_key = $item.profile_key

            # Add the item to the unique list if it's different from the previous one
            if ($profile_key.Trim() -ne $previous_item_profile_key.Trim() -or $profile_name.Trim() -ne $previous_item_profile_name.Trim()){
                $sorted_unique += $item
                $previous_item_profile_name = $item.profile_name
                $previous_item_profile_key  = $item.profile_key
            }
        }
        return $sorted_unique # return the list of unique profiles.
    }
    
    # Parse the raw data and sort the profiles by name
    $finally_sorted = Get-FormattedProfiles -rawData $get_data_to_sort | Sort-Object profile_name

    # Remove redundant profiles.
    $sorted_unique_values = Remove-Redundancy -sorted_data $finally_sorted

    $sorted_unique = @()

    # Format the sorted unique profiles into strings.
    foreach ($value in $sorted_unique_values) {
        $sorted_unique += "$($value.profile_name) `n $($value.profile_key) `n"
    }

    # Write the sorted unique profiles to the output file if there are any.
    if ($sorted_unique.Count -gt 0) {
        $sorted_unique -join "`n" | Out-File -filepath $outputFile
    }

    Write-Host "you have successfully removed redundancy and sorted the file"
}finally{
    # Reset the execution policy back to the original policy
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Restricted
}