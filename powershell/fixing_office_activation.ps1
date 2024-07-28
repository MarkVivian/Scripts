try {
    # Define the file name to search for
    $fileName = "OSPPREARM.EXE"

    # Define the directories to search in
    $directories = @("C:\Program Files", "C:\Program Files (x86)")

    # Initialize a variable to store the file path if found
    $filePath = $null

    # Search the specified directories for the file
    foreach ($dir in $directories) {
        # $searchResults = Get-ChildItem -Path $dir -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq $fileName }
        $searchResults = Get-ChildItem -Path $dir -Recurse -ErrorAction SilentlyContinue -Filter $fileName
        if ($searchResults) {
            $filePath = $searchResults.FullName
            break
        }
    }

    # Check if the file was found
    if ($filePath) {
        Write-Host "File found at: $filePath"

        # Run the file 3 times as admin
        for ($i = 1; $i -le 3; $i++) {
            Write-Host "Running $fileName - Attempt $i"
            Start-Process -FilePath $filePath -Verb RunAs -Wait
        }
    } else {
        Write-Host "File not found in the specified directories" -ForegroundColor Red
    }

}
finally {
    # Reset the execution policy back to the original policy
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Restricted
}