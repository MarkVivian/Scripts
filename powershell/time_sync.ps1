# this will loop until a good internet connection is available.
while ($true){
    
    # check if there is an internet connection. will return either true or false because of the quiet.
    $connection = Test-Connection 8.8.8.8 -Count 1 -Quiet
    
    try{
        if ($connection) {      
            # lets start the time syncer in windows.
            Start-Service W32Time
            
            # Wait for the service to start (waiting for 10 seconds)
            Start-Sleep -Seconds 10
            
            # Now let's sync the time using w32tm.exe
            w32tm.exe /resync
        
            Write-Output "the time has been synced succesfully" | Out-File "C:\Users\Mark\Desktop\time_sync.txt"
            break

        }else{
            Write-Output "error connecting to the internet .. trying again after 10 seconds" | Out-File "C:\Users\Mark\Desktop\time_sync.txt" -Append
            
            # wait 10 seconds before trying again
            Start-Sleep -Seconds 10
        }   
    }catch{
        Write-Output "error occured while syncing time" | Out-File "C:\Users\Mark\Desktop\time_sync.txt"
        exit -1
    }
}