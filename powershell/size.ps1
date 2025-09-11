[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string[]] $path,
    [string[]] $exclude
)

# $DebugPreference = "Continue"

function ExcludeLogic{
    param(
        [Parameter(Mandatory=$true)]
        $path_content,
        $exclude_pattern 
    )

    Write-Debug "Running exclude logic on path: $path_content"
    if ($exclude.Count -eq 0 -or $null -eq $exclude_pattern ){
        Write-Debug "No exclude patterns provided. Including all items."
        return [PSCustomObject]@{
            state = $true
            info = $path_content
        }
    }
    $incase_folder = Get-ChildItem $path_content -Recurse -ErrorAction SilentlyContinue -Force
    $finale_items = @()
    foreach($included in $incase_folder){
        $checker = $null
        foreach($item in $exclude_pattern){
            Write-Debug "Comparing $($included.Name) with $item"
            # Normalize both values to compare only the name
            $includedName = $included.Name
            $excludePattern = $item.TrimStart('.', '\')
            if ($includedName -like $excludePattern -or $included.FullName -like "*$excludePattern") {
                Write-Debug "----------------- Found match: $($included.FullName) matches exclude pattern $excludePattern -----------------"
                $checker = $true
                break
            }
        }
        if (-not $checker) {
            Write-Debug "adding item due to lack of match: $($included.FullName)"
            $finale_items += $included
        }
    }
    return [PSCustomObject]@{
        state = $false
        info = $finale_items
    }
}

function DiffFolderFile{
    param(
        $path_value
    )
    
    $containment = @()
    if ($path_value.Trim() -eq ""){
        Write-Host "No path value provided.." -ForegroundColor Red
        exit 1
    }else{
        foreach($prop in $path_value){
            # check if there is a * wildcard.
            if (Test-Path $prop){
                $item = Resolve-Path $prop
                Write-Debug "Resolved path: $item"
                $exclude_result = ExcludeLogic -path_content $item -exclude_pattern $exclude
                $containment += [PSCustomObject]@{
                    Name = $item
                    Size = $(if ($exclude_result.state) { 
                        Write-Debug "Including all items. $exclude_result"
                        (Get-ChildItem $exclude_result.info -Recurse -ErrorAction SilentlyContinue -Force | Measure-Object -Property Length -Sum).Sum
                    } else { 
                        Write-Debug "no item excluded. Included items: $($exclude_result.info)"
                        ($exclude_result.info | Measure-Object -Property Length -Sum).Sum
                    } )
                }
            }else{
                Write-Host "$prop does not exist" -ForegroundColor Red
            }
        }
    }
    return $containment
}

function GetSize{
    $size_array = DiffFolderFile -path_value $path
    Write-Debug "Size array: $size_array"
    foreach($object_in_bytes in $size_array){
        $size_in_bytes = $object_in_bytes.Size
        Write-Host $object_in_bytes.Name -ForegroundColor Yellow  
        # check if the size in bytes is NaN or empty and write 0 bytes .
        if ([System.Double]::IsNaN($size_in_bytes)) {
            Write-Host "File size could not be determined." -ForegroundColor Red
            exit 1
        }
        if ($size_in_bytes -eq 0) {
            Write-Host "0 Bytes" -ForegroundColor Green
            exit 1
        }

        # Define an array to hold the units of measurement
        $sizes =@("Bytes", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB")

        # Calculate the logarithmic factor by finding the floor of the logarithm of size_in_bytes to the base 1024
        $factor = [math]::Floor([math]::Log($size_in_bytes, 1024))

        # Calculate the size in the base unit by dividing size_in_bytes by 1024 raised to the power of the factor
        $size = $size_in_bytes / [math]::Pow(1024, $factor)

        # Format the size with two decimal places and concatenate it with the corresponding unit from the sizes array
        # "{0:N2} {1}" -f $size, $sizes[$factor]
        Write-Host ("{0:N2} {1}" -f $size, $sizes[$factor]) -ForegroundColor Green
    }

    $total_size = ($size_array | Measure-Object -Property Size -Sum).Sum
    # Convert total size to human-readable format
    $sizes =@("Bytes", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB")
    $factor = [math]::Floor([math]::Log($total_size, 1024))
    $size = $total_size / [math]::Pow(1024, $factor)
    Write-Host "Total Size : " -ForegroundColor Yellow -NoNewline
    Write-Host ("{0:N2} {1}" -f $size, $sizes[$factor]) -ForegroundColor Green
}

GetSize