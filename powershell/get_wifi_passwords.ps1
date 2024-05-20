# Function to check if the script is run with administrative privileges
function Test-Admin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Admin)) {
    Write-Host "This script must be run with administrative privileges."
    Write-Host "Please run this script in an elevated PowerShell window."
    exit
}

# Check the current execution policy
$currentPolicy = Get-ExecutionPolicy

# If the policy is restricted or all signed, prompt the user to change it
if ($currentPolicy -eq "Restricted" -or $currentPolicy -eq "AllSigned") {
    Write-Host "The current execution policy is $currentPolicy. Please change it to RemoteSigned to run this script."
    Write-Host "You can do this by running the following command in an elevated PowerShell window:"
    Write-Host "Set-ExecutionPolicy RemoteSigned"
    exit
}



try {
    # Get the directory where the script is located
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

    # Define the path for the output file
    $outputFile = Join-Path $scriptDir "WifiProfilesAndKeys.txt"

    # Read existing content from the output file if it exists
    if (Test-Path $outputFile) {
        # Read the entire content of the file into a single string
        $existingContent = Get-Content $outputFile -Raw
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

        # Create a formatted entry for the new profile
        $entry = "Profile: $profile`nKey: $profileKey`n"

        # Check if the profile with the same key already exists in the existing content (case-sensitive)
        if ($existingContent -match "Profile: $profile`nKey: $profileKey`n") {
            continue  # Skip if the profile with the same key already exists
        }

        # Add the new entry to the output content array
        $outputContent += $entry
    }

    # Write only the new entries to the output file, appending to existing content
    if ($outputContent.Count -gt 0) {
        $outputContent -join "`n" | Out-File -FilePath $outputFile -Append -Encoding utf8
    }

    Write-Host "WLAN profile information has been updated in $outputFile"
}
finally {
    # Reset the execution policy back to the original policy
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Restricted
}
