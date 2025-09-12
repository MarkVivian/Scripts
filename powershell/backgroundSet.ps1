Add-Type -AssemblyName System.Windows.Forms

function MonitorAllocation{
    $monitor_virtual = [System.Windows.Forms.SystemInformation]::VirtualScreen

    $Monitor_data = [PSCustomObject]@{
        monitor_virtual = [PSCustomObject]@{
            width = $monitor_virtual.Width
            height = $monitor_virtual.Height
            x_axis = $monitor_virtual.X
            y_axis = $monitor_virtual.Y
        }
        monitor_actual =[PSCustomObject]@{
            count = [System.Windows.Forms.Screen]::AllScreens.Count
            details = @([System.Windows.Forms.Screen]::AllScreens | ForEach-Object {
               [PSCustomObject]@{
                    device_name = $_.DeviceName
                    bounds = [PSCustomObject]@{
                        X_axis = $_.Bounds.X
                        Y_axis = $_.Bounds.Y
                        Width = $_.Bounds.Width
                        Height = $_.Bounds.Height
                    }
                    primary = $_.Primary
                }
            })
        }
    }

    for($i = 0; $i -lt $Monitor_data.monitor_actual.count; $i++) {
        Write-Progress -Activity "Processing Monitors" -Status "Monitor $($i + 1) of $($Monitor_data.monitor_actual.count)" -PercentComplete (($i / $Monitor_data.monitor_actual.count) * 100)
        $screen = $Monitor_data.monitor_actual.details[$i]
        Write-Host "Monitor $($i + 1):" -ForegroundColor Green
        Write-Host "  Device Name: $($screen.device_name)" -ForegroundColor Yellow
        Write-Host "  Bounds: $($screen.bounds)" -ForegroundColor Yellow
        Write-Host "  Primary: $($screen.primary)" -ForegroundColor Yellow
    }

    return $Monitor_data
}

MonitorAllocation