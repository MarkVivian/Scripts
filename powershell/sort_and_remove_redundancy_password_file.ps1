param(
    [string] $path_to_file
)

class ServerInfo{
    [string] $profile_name
    [string] $profile_key
}

try {
    $get_data_to_sort = get-content $path_to_file -Raw

    # Get the directory where the script is located
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

    # Define the path for the output file
    $outputFile = Join-Path $scriptDir $($path_to_file | ForEach-Object{
        $_ -replace ".*W", "W"
    })

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

    function testing_something{
        param(
            $sorted_unique_test
        )

    }

    function Remove-Redundancy{
        param (
            $sorted_data
        )

        $previous_item_profile_name = ""
        $previous_item_profile_key = ""
        $sorted_unique = @()

        foreach ($item in $sorted_data) {
            $profile_name = $item.profile_name
            $profile_key = $item.profile_key
            if ($profile_key.Trim() -ne $previous_item_profile_key.Trim() -or $profile_name.Trim() -ne $previous_item_profile_name.Trim()){
                $sorted_unique += $item
                $previous_item_profile_name = $item.profile_name
                $previous_item_profile_key  = $item.profile_key
            }
        }
        return $sorted_unique
    }
    
    $finally_sorted = Get-FormattedProfiles -rawData $get_data_to_sort | Sort-Object profile_name

    $sorted_unique_values = Remove-Redundancy -sorted_data $finally_sorted

    $sorted_unique = @()
    foreach ($value in $sorted_unique_values) {
        $sorted_unique += "$($value.profile_name) `n $($value.profile_key) `n"
    }

    if ($sorted_unique.Count -gt 0) {
        $sorted_unique -join "`n" | Out-File -filepath $outputFile
    }

    Write-Host "you have successfully removed redundancy and sorted the file"
}finally{
    # Reset the execution policy back to the original policy
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Restricted
}