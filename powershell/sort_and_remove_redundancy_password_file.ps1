function path_dialog{
    # Add .NET Windows Forms assembly to use graphical components
    Add-Type -AssemblyName System.Windows.Forms

    # Create a new OpenFileDialog instance
    $fileBrowser = New-Object System.Windows.Forms.OpenFileDialog

    # Set the dialog's initial directory to the provided path
    $fileBrowser.InitialDirectory = $env:USERPROFILE

    # Set the dialog's filter to only allow txt files
    $fileBrowser.Filter = "Text files (*.txt)|*.txt"

    # Set the dialog's title
    $fileBrowser.Title = "Open a txt file with usernames and passwords."

    # Set the dialog's multi-select option to false (only allow one file to be selected)
    $fileBrowser.Multiselect = $false

    # Show the dialog and check if the user clicked "OK"
    if ($fileBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        # Return the selected folder path
        return $fileBrowser.FileName
    } else {
        # Write an error and exit if no folder was selected
        Write-Error "No file selected. Exiting script."
        exit 1
    }
}

$path_to_file = path_dialog

# Define a class to hold profile information(ServerInfo).
class ServerInfo{
    [string] $profile_name
    [string] $profile_key
}

if (Test-Path $path_to_file){
    try {
        # Read the content of the input file as a single string.
        $get_data_to_sort = get-content $path_to_file -Raw

        
        # Define the path
        $outputFile = $path_to_file

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
}else{
    Write-Host "File does not exist. " -ForegroundColor Red
    exit 1
}