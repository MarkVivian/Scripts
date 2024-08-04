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
    }else{
        # if the script exists, i want to extrapolate the path so as to ensure both ~ and ./ are understood.
        $pathToScript = Resolve-Path $pathToScript
    }
}else{
    Write-Host "please pass the path to the script to be executed `n e.g. `n defender_startup.ps1 /path/to/script " -ForegroundColor Red
    exit -1
}

# This function will put your script past the defender/ 
function defernderLister {
    param (
        [string] $Script
    )
    Write-Host "called "
}

# This function will put your Script to start up.
function startUp {
    param (
        $Script
    )
    Write-Host "using script in location $Script" -ForegroundColor Green
    # Prompt user for task name
    $taskName = Read-Host "Provide a task name: `n "

    # Trim any leading/trailing spaces from the task name
    $trimed_taskName = $taskName.Trim()

    # Check if a task name was provided. If not, print an error and exit. also make sure its not spaces provided.
    if ($trimed_taskName.Length -eq 0){
        Write-Host "please provide a usable taskName " -ForegroundColor Red
        exit -1
    }

    # Define the action
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-File `"$Script`""
    
    # Define the trigger
    $trigger = New-ScheduledTaskTrigger -AtStartup
    
    # Define the principal
    $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
    
    # Define the settings
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

    # test path is set to custom so that its easy to locate all the powershell scripts..
    $taskPath = "\Custom_Scripts"
    
    try {
        # Register the scheduled task
        Register-ScheduledTask -TaskPath $taskPath -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings
        Write-Host "Scheduled task '$taskName' has been created successfully." -ForegroundColor Green
        Write-Host "If you wish to confirm go to task scheduler and refresh and you should see a folder named $taskPath containing your scripts" -ForegroundColor Green
    } catch {
        Write-Host "Failed to create scheduled task: $_" -ForegroundColor Red
    }
}

$choice=Read-Host "1) Bypass defender `n 2) add to start-up `n 3) both 1 and 2 `n "

switch($choice){
    "1" {
        defernderLister $pathToScript
    }
    "2" {
        startUp $pathToScript
    }
    "3" {
        defernderLister $pathToScript
        startUp $pathToScript
    }
    default {
        Write-Host "invalid input provided..." -ForegroundColor Red
        exit 1
    }
}

