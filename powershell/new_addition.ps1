# Function to check if the script is run with administrative privileges
try {
    # Get the directory where the script is located
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

    # Define the path for the output file
    $outputFile = Join-Path $scriptDir "WifiProfilesAndKeys.txt"

    # Read existing content from the output file if it exists
    $existingContent = if (Test-Path $outputFile) { Get-Content $outputFile -Raw } else { "" }

    # Retrieve all WLAN profiles
    $profiles = netsh wlan show profiles | Select-String "All User Profile" | ForEach-Object { $_.Line -replace ".*: ", "" }

    # Initialize a string builder for the new content
    $newContent = [System.Text.StringBuilder]::new()

    # Function to get profile key content
    function Get-ProfileKey($profile) {
        $profileInfo = netsh wlan show profile name="$profile" key=clear | Select-String "Key Content"
        if ($profileInfo) {
            return $profileInfo.Line -replace ".*: ", ""
        } else {
            return "No key found"
        }
    }

    # Start jobs to get profile keys in parallel
    $jobs = @()
    foreach ($profile in $profiles) {
        $jobs += Start-Job -ScriptBlock {
            param ($profile)
            return Get-ProfileKey $profile
        } -ArgumentList $profile
    }

    # Collect job results
    $profileKeys = @{}
    foreach ($job in $jobs) {
        $result = Receive-Job -Job $job -Wait
        Remove-Job -Job $job
        $profile = $job.ChildJobs[0].Arguments[0]
        $profileKeys[$profile] = $result
    }

    # Process the results and build the output content
    foreach ($profile in $profiles) {
        $profileKey = $profileKeys[$profile]
        $entry = "Profile: $profile`nKey: $profileKey`n"
        
        # Check if the profile with the same key already exists in the existing content
        if ($existingContent -notmatch [regex]::Escape($entry)) {
            $newContent.AppendLine($entry) | Out-Null
        }
    }

    # Write only the new entries to the output file, appending to existing content
    if ($newContent.Length -gt 0) {
        $newContent.ToString() | Out-File -FilePath $outputFile -Append -Encoding utf8
    }

    Write-Host "WLAN profile information has been updated in $outputFile"
} finally {
    # Reset the execution policy back to the original policy
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Restricted
}
