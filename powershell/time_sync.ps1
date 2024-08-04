try{
    # lets start the time syncer in windows.
    Start-Service W32Time
    
    # Wait for the service to start
    Start-Sleep -Seconds 10
    
    # Now let's sync the time using w32tm.exe
    w32tm.exe /resync

    Write-Output "the time has been synced succesfully" | Out-File "C:\Users\Mark\Desktop\time_sync.txt"
}catch{
    Write-Output "error occured while syncing time" | Out-File "C:\Users\Mark\Desktop\time_sync.txt"
}