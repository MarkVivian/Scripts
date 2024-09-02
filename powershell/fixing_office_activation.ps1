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
            $filePathWithName = $searchResults.FullName
            $filePathWithoutName = $filePathWithName.Replace($fileName, "")
            break
        }
    }

    # Method 1 .
    # Check if the file was found
    if ($filePathWithName) {
       Write-Host "File found at: $filePathWithName"

        # Run the file 3 times as admin
       for ($i = 1; $i -le 3; $i++) {
           Write-Host "Running $fileName - Attempt $i"
           Start-Process -FilePath $filePathWithName -Verb RunAs -Wait
       }
    } else {
       Write-Host "File not found in the specified directories" -ForegroundColor Red
       exit 1
    }


    # Method 2.
    # check for internet connection
    $internetConnectionStatus = Test-Connection -ComputerName localhost -Count 1 -Quiet
    if ($internetConnectionStatus) {
        Write-Host "Internet connection is available"
        
        # check if the file exists in the location provided.
        $vbs_script = Join-Path -Path $filePathWithoutName -childPath "ospp.vbs"

        if($vbs_script){
            Write-Host "File exists. $vbs_script"

            # Run the commands.
            $cscript_command="cscript.exe `'$vbs_script`' /sethst:kms.03k.org"
            
            $cscript_activation="cscript.exe `'$vbs_script`' /act"
            
            Invoke-Expression -Command "$cscript_command; $cscript_activation"

        }else{  
            Write-Host "Invalid file location." -ForegroundColor Red
            exit 1
        }

    }else {
        Write-Host "Internet connection is not available. Please connect to the Internet" -ForegroundColor Red
        exit 1
    }

}
finally {
    # Reset the execution policy back to the original policy
    # Set-ExecutionPolicy -Scope Process -ExecutionPolicy Restricted
}