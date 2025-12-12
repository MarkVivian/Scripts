function Display_Apps_Per(){
    param(
        [parameter(Mandatory=$true)]
        [string]$filter_choice
    )

    switch ($filter_choice) {
        "All" { 
            Write-Host "Displaying all apps..." -ForegroundColor Green
         }
         "System" {
            Write-Host "Displaying system apps..." -ForegroundColor Yellow
         }
         "User" {
            Write-Host "Displaying user-installed apps..." -ForegroundColor Cyan
         }
        Default {
            Write-Host "Invalid filter choice. Please select 'All', 'System', or 'User'." -ForegroundColor Red
        }
    }

    function Displaying_apps(){
        # 
    }

}

function Remove_Apps_Per(){
    param(
        [parameter(Mandatory=$true)]
        [switch]$virus_app_trigger,
        [string]$app_index
    )

    switch ($virus_app_trigger) {
        $true { 
            Write-Host "Removing virus apps..." -ForegroundColor Red
         }
         $false {
            Write-Host "Removing specified app with index $app_index..." -ForegroundColor Magenta
         }
        Default {
            Write-Host "Invalid choice for virus_app_trigger." -ForegroundColor Red
        }
    }

    function Removing_apps(){
        # 
    }

}


function Detect_Phone_And_Access{
    # Detect a connected phone.

    # Confirm access to the phone.
}