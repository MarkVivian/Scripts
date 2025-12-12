# the script will be passed here 
param(
    # [parameter(Mandatory=$true)]
    [string]$pathToScript = "$env:USERPROFILE\Desktop\Scripts\powershell\test_startUp.ps1"
)


# function DialogBox{
#     param(
#         [parameter(Mandatory=$true)]
#         [string]$message
#     )
#     # Add .NET Windows Forms assembly to use graphical components
#     Add-Type -AssemblyName System.Windows.Forms
#     Add-Type -AssemblyName System.IO 

#     # Create a new OpenFileDialog instance
#     $openDialog = New-Object System.Windows.Forms.OpenFileDialog
#     $openDialog.CheckFileExists = $true 
#     $openDialog.CheckPathExists = $true
#     $openDialog.InitialDirectory = $env:USERPROFILE
#     $openDialog.Title = $message
#     $openDialog.ValidateNames = $true
 
#     # Show the dialog and check if the user clicked "OK"
#     if ($openDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
#         # Return the selected file path
#         return $openDialog.FileName
#     } else {
#         # Write an error and exit if no file was selected
#         Write-Host "No file selected. Exiting script." -ForegroundColor Red
#         Read-Host "Press Enter to exit..."
#         exit 1
#     }
# }


# # checking if the path to the script is provided. if not, it will print an error
# if($pathToScript.Length -gt 0) {
#     # check if the script exists.
#     if (-not (Test-Path $pathToScript)){
#         Write-Host "The script does not exist `n $($pathToScript) `n Exiting"
#         Read-Host "Press Enter to exit..."
#         # exits teh entire script.
#         exit -1
#     }else{
#         # if the script exists, i want to extrapolate the path so as to ensure both ~ and ./ are understood.
#         $pathToScript = Resolve-Path $pathToScript
#     }
# }else{
#     $pathToScript = DialogBox "Select the script you want to run at startup"
#     if(-not $pathToScript){
#         Write-Host "No script selected. Exiting." -ForegroundColor Red
#         Read-Host "Press Enter to exit..."
#         exit 1
#     }
#     # Write-Host "please pass the path to the script to be executed `n e.g. `n defender_startup.ps1 /path/to/script " -ForegroundColor Red
#     # Read-Host "Press Enter to exit..."
#     # exit 1
# }


# This function will put your Script to start up.
function TaskSchedular {
    param (
        $Script
    )
    # test path is set to custom so that its easy to locate all the powershell scripts..
    $taskPath = "\Custom_Scripts"

    try{
        # getting all the tasks that had been created previously by this script.
        $current_task_names = Get-ScheduledTask -TaskPath "$taskPath\" -ErrorAction SilentlyContinue

        # check if any script is found.
        if ($current_task_names){
            Write-Host "`n current tasks `n ----------------------- " -ForegroundColor Green 
            
            # print out every script found.
            foreach ($task in $current_task_names) {
                Write-Host $task.TaskName
            }
        }
    }catch { 
        Write-Host "Error getting scheduled tasks: $_" -ForegroundColor Red
        Read-Host "Press Enter to exit..."
        exit 1
    }

    # Prompt user for task name
    $taskName = Read-Host " `n Provide a task name not in the names above: `n "
    
    # Trim any leading/trailing spaces from the task name
    $trimed_taskName = $taskName.Trim()

    # Check if a task name was provided. If not, print an error and exit. also make sure its not spaces provided.
    if ($trimed_taskName.Length -eq 0){
        Write-Host "please provide a usable taskName " -ForegroundColor Red
        exit -1
    }

    # loop through the tasks in current_task_names and check if the taskName provided is present. check in lower case.
    foreach ($task in $current_task_names){
        if ($task.TaskName.ToString().ToLower() -eq $trimed_taskName.ToLower()){
            Write-Host "Task name '$trimed_taskName' already exists. Please choose a different name." -ForegroundColor Red
            Read-Host "Press Enter to exit..."
            exit 1
        }
    }     

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
        Register-ScheduledTask -TaskPath $taskPath -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings
        Write-Host "Scheduled task '$taskName' has been created successfully." -ForegroundColor Green
        Write-Host "If you wish to confirm go to task scheduler and refresh and you should see a folder named $taskPath containing your scripts" -ForegroundColor Green
    } catch {
        Write-Host "Failed to create scheduled task: $_" -ForegroundColor Red
        Read-Host "Press Enter to exit..."
        exit 1
    }
}

function Services{
    param (
        $Script
    )
    Write-Host "Service function called with script: $Script" -ForegroundColor Green
    # Add your code for option 2 here
}

function StartupFolder{
    param (
        $Script
    )
    Write-Host "StartupFolder function called with script: $Script" -ForegroundColor Green
    # Add your code for option 3 here
}

function Registry{
    param (
        $Script
    )
    Write-Host "Registry function called with script: $Script" -ForegroundColor Green
    # Add your code for option 4 here
}

function WMIEventSubscription{
    param (
        $Script
    )
    Write-Host "WMIEventSubscription function called with script: $Script" -ForegroundColor Green
    # Add your code for option 5 here
}

# Write-Host "Choose an option for start-up execution: 
# `n 1) Task Scheduler (recommended) 
# `n 2) Service 
# `n 3) startup folder 
# `n 4) Registry 
# `n 5) WMI event subscription
# `n 6) All options
# " -ForegroundColor Green

# $choice=Read-Host " `n Enter your choice (1-5): "

# switch($choice){
#     "1" {
#         TaskSchedular $pathToScript
#     }
#     "2" {
#         Services $pathToScript
#     }
#     "3" {
#         StartupFolder $pathToScript
#     }
#     "4" {
#         Registry $pathToScript
#     }
#     "5" {
#         WMIEventSubscription $pathToScript
#     }
#     "6" {
#         TaskSchedular $pathToScript
#         Services $pathToScript
#         StartupFolder $pathToScript
#         Registry $pathToScript
#         WMIEventSubscription $pathToScript
#     }
#     default {
#         Write-Host "invalid input provided..." -ForegroundColor Red
#         Read-Host "Press Enter to exit..."
#         exit 1
#     }
# }