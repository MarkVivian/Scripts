# the script will be passed here 
param(
    [string]$pathToScript
)



# check if the script exists.
if (-not (Test-Path $pathToScript)){
    Write-Host "The script does not exist `n $($pathToScript) `n Exiting"

    # exits teh entire script.
    exit -1
}


"the path to the script is $($pathToScript)" | Out-File -FilePath "file.txt"