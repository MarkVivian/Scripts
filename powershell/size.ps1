[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string[]] $path,
    [string[]] $exclude,
    [switch] $rawData
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
    $finale_items = @()
    foreach($included in $path_content){
        $checker = $null
        foreach($item in $exclude_pattern.Split(" ")){
            Write-Debug "Comparing $($included.Name) with $item"
            # Normalize both values to compare only the name
            $includedName = $included.Name
            $excludePattern = $item.TrimStart('.', '\')
            # If pattern contains wildcard characters '*' or '?', use wildcard matching.
            if ($excludePattern -match '[\*\?]') {
                if ($includedName -like $excludePattern -or $included.FullName -like "*$excludePattern") {
                    Write-Debug "----------------- Found wildcard match: $($included.FullName) matches exclude pattern $excludePattern -----------------"
                    $checker = $true
                    break
                }
            } else {
                # No wildcard: perform exact match on the leaf name to avoid accidental partial matches.
                if ($includedName -ieq $excludePattern) {
                    Write-Debug "----------------- Found exact match: $($included.FullName) matches exclude pattern $excludePattern -----------------"
                    $checker = $true
                    break
                }
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
    if ([String]::IsNullOrWhiteSpace($path_value)) {
        Write-Warning "No path value provided.." 
        continue 
    }else{
        foreach($prop in $path_value){
            # check if there is a * wildcard.
            if (Test-Path $prop){
                $item = Resolve-Path $prop
                $item_enumerated = Get-ChildItem $item -Recurse -ErrorAction SilentlyContinue -Force
                Write-Debug "Resolved path: $item"
                $exclude_result = ExcludeLogic -path_content $item_enumerated -exclude_pattern $exclude
                $containment += [PSCustomObject]@{
                    Name = $item
                    Size = $(if ($exclude_result.state) { 
                        Write-Debug "Including all items. $exclude_result"
                        ($item_enumerated | Measure-Object -Property Length -Sum).Sum
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
            Write-Warning "File size could not be determined." 
            continue 
        }
        if ($size_in_bytes -eq 0) {
            Write-Warning "0 Bytes"
            continue
        }

        if ($rawData) {
            Write-Host "Raw Data: $($size_array.Size) Bytes" -ForegroundColor Green
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
    if ($rawData){
        Write-Host "`nTotal Size (Raw Data): $total_size Bytes" -ForegroundColor Green
    }
    # Convert total size to human-readable format
    $sizes =@("Bytes", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB")
    $factor = [math]::Floor([math]::Log($total_size, 1024))
    $size = $total_size / [math]::Pow(1024, $factor)
    Write-Host "Total Size : " -ForegroundColor Yellow -NoNewline
    Write-Host ("{0:N2} {1}" -f $size, $sizes[$factor]) -ForegroundColor Green
}

GetSize