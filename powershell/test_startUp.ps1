Write-Host "provide the arguments for the script if any are required: `n (if none then type 'exit'): "

while ($true){
    $input_value = Read-Host "> "
    if ($input_value -eq "exit") {
        break
    }

    if (-not [string]::IsNullOrWhiteSpace($input_value)) {
        if ($line -match "^(?<key>[^=]+)=(?<value>.+)$" ) {
            $disjointed_input = $input_value -split "="
            $props[$disjointed_input[0].Trim()] = $disjointed_input[1].Trim()            
        } else {
            Write-Host "Invalid format. Use key=value"
        }
    }
}

$argument_values = [PSCustomObject]$props
Write-Host $argument_values