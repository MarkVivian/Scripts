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
        Write-Error "No file selected. Exiting script."
        Read-Host "Press Enter to exit..."
        exit 1
    }
}

$path_to_file = DialogBox -message "Open a txt file with usernames and passwords"
Write-Host $path_to_file -ForegroundColor Green
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
    }catch{
        Write-Host "and error occured $_" -ForegroundColor Red
        Read-Host "Press any key to continue"
        exit 1
    }
}else{
    Read-Host "File does not exist. `n press any key to continue"
    exit 1
}