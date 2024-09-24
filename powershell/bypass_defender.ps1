# it will handle putting scripts into defender or whatever antivirus they have whitelist and disabling them.
param(
    [string]$script_path 
)

function Resolve_path(){
    if ($script_path.Trim() -eq ""){
        Write-Host "No path value provided .. Please provide a path value" -ForegroundColor Red
        exit 1
    }else{
        if (Test-Path $script_path){   
            $resolved_path = Resolve-Path -Path $script_path
            return $resolved_path
        }else{
            Write-Host "File does not exist. " -ForegroundColor Red
            exit 1
        }
    }
}

$script_path = Resolve_path

# function to handle all firewall related tasks.
function firewall_handler(){
    
}

# function to handle all antivirus related tasks.
function antivirus_handler(){

}


# todo : can i handle rav endpoint protection.
# function to handle rav endpoint protection.
function rav_endpoint_handler(){

}

