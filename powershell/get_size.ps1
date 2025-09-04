param(
    [String]$path_values,
    [switch]$total
)

# this will check if the path is a folder or a file or if even exists.
function Get-FileOrFolder{
    $item_sizes = @()
    # check if the path value is empty.
    if ($path_values.Trim() -eq ""){
        Write-Host "No path value provided.." -ForegroundColor Red
        exit 1
    }else{
        # get the number of files provided.
        foreach($path in $path_values.Split(" ")){
            # Check if the file or folder exists.
            if (Test-Path $path){
                # if the script exists, i want to extrapolate the path so as to ensure both ~ and ./ are understood.
                $path = Resolve-Path $path

                # check if the file is a folder or a file.
                if ((Get-Item -Path $path).PSIsContainer) {
                    $item_name = "$path is a folder." 
                    
                    # this will get the size of the folder in bytes.
                   $item_size = (Get-ChildItem $path -Recurse -ErrorAction SilentlyContinue -Force | Measure-Object -Property Length -Sum).Sum
                } else {
                    $item_name = "$path is a file." 
                    
                    # this will get the size of the file in bytes.
                    $item_size = (Get-Item $path).Length
                }
            }else{
                Write-Host "File/folder does not exist. " -ForegroundColor Red
                exit 1
            }
            $item_sizes += [PSCustomObject]@{
                Name = $item_name
                Size = $item_size
            }
        }
    }

    return $item_sizes
}

# will convert the file sizes in bytes to human legibal format.
function Get-Size{
    $size_array = Get-FileOrFolder

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
        Write-Host "$size $($sizes[$factor])" -ForegroundColor Green
    }

    if ($total) {
        $total_size = ($size_array | Measure-Object -Property Size -Sum).Sum
        # Convert total size to human-readable format
        $sizes =@("Bytes", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB")
        $factor = [math]::Floor([math]::Log($total_size, 1024))
        $size = $total_size / [math]::Pow(1024, $factor)
        Write-Host "Total Size : " -ForegroundColor Yellow -NoNewline
        Write-Host ("{0:N2} {1}" -f $size, $sizes[$factor]) -ForegroundColor Green
    }
}
Get-Size