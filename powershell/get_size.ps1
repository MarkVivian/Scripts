param(
    [String]$path
)

# this will check if the path is a folder or a file or if even exists.
function Get-FileOrFolder{
    # check if the path value is empty.
    if ($path.Trim() -eq ""){
        Write-Host "No path value provided.." -ForegroundColor Red
        exit 1
    }else{
        # Check if the file or folder exists.
        if (Test-Path $path){
            # if the script exists, i want to extrapolate the path so as to ensure both ~ and ./ are understood.
            $path = Resolve-Path $path

            # check if the file is a folder or a file.
            if ((Get-Item -Path $path).PSIsContainer) {
                Write-Host "$path is a folder." -ForegroundColor Green
                
                # this will get the size of the folder in bytes.
                return (Get-ChildItem $path -Recurse -ErrorAction SilentlyContinue -Force | Measure-Object -Property Length -Sum).Sum
            } else {
                Write-Host "$path is a file." -ForegroundColor Green
                
                # this will get the size of the file in bytes.
                return (Get-Item $path).Length
            }
        }else{
            Write-Host "File/folder does not exist. " -ForegroundColor Red
            exit 1
        }
    }
}

# will convert the file sizes in bytes to human legibal format.
function Get-Size{
    $size_in_bytes = Get-FileOrFolder

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
    "{0:N2} {1}" -f $size, $sizes[$factor]

}

Size