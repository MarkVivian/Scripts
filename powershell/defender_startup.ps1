# the script will be passed here 
param(
    [string]$pathToScript
)

# checking if the path to the script is provided. if not, it will print an error
if($pathToScript.Length -gt 0) {
    # check if the script exists.
    if (-not (Test-Path $pathToScript)){
        Write-Host "The script does not exist `n $($pathToScript) `n Exiting"

        # exits teh entire script.
        exit -1
    }
}else{
    Write-Host "please pass the path to the script to be executed `n e.g. `n defender_startup.ps1 /path/to/script " -ForegroundColor Red
    exit -1
}

$choice=Read-Host "1) Bypass defender `n 2) add to start-up `n 3) both 1 and 2 `n "

switch($choice){
    "1" {
        defernderLister $pathToScript
    }
    "2" {
        start_up $pathToScript
    }
    "3" {
        defernderLister $pathToScript
        start_up $pathToScript
    }
    default {
        "invalid input provided..."
        exit 1
    }
}


# This function will put your script past the defender/ 
function defernderLister {
    param (
        [string] $Script
    )
    
}

# This function will put your Script to start up.
function start_up   {
    param (
        $Script
    )
    # Prompt user for task name
    $taskName = Read-Host "Provide a task name"

    # Define the action
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-File `"$Script`""
    
    # Define the trigger
    $trigger = New-ScheduledTaskTrigger -AtStartup
    
    # Define the principal
    $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
    
    # Define the settings
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

    try {
        # Register the scheduled task
        Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings
        Write-Host "Scheduled task '$taskName' has been created successfully." -ForegroundColor Green
    } catch {
        Write-Host "Failed to create scheduled task: $_" -ForegroundColor Red
    }
}
