try {
    # for getting the xml folders.
    function Get-FolderFromDialog {
        # Add .NET Windows Forms assembly to use graphical components
        Add-Type -AssemblyName System.Windows.Forms
    
        # Create a new FolderBrowserDialog instance
        $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    
        # Set the dialog's description, shown at the top of the window
        $folderBrowser.Description = "Select the folder where the xml files are located"
    
        # Set the root folder from where the browsing starts (e.g., My Computer)
        $folderBrowser.RootFolder = [System.Environment+SpecialFolder]::MyComputer
    
        # Show the dialog and check if the user clicked "OK"
        if ($folderBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            # Return the selected folder path
            return $folderBrowser.SelectedPath
        } else {
            # Write an error and exit if no folder was selected
            Write-Error "No folder selected. Exiting script."
            exit 1
        }
    }

    # check if the wifi xmls exists and are present.
    function check_wifi_xmls{
        param(
            [string]$wifi_name
        )
        # folder containing xml files.
        $xml_folder=Get-FolderFromDialog
    
        # check if the wifi xmls exists and are present
        if(Get-ChildItem $xml_folder -Filter "*.xml"){
            $xml_files = Get-ChildItem $xml_folder -Filter "*.xml"
            foreach($xml in $xml_files){
                # remove all spaces and names like WiFi- and .xml
                $xml_name = (($xml.Name -replace "WiFi-","") -replace ".xml", "") -replace " ", ""
                $wifi_name_formatted = ($wifi_name -replace " ", "") 
                if($wifi_name_formatted -eq $xml_name){
                    # add the profile to the network.
                    netsh wlan add profile filename=$(Join-Path -path $xml_folder -ChildPath $xml)
                     
                    # connect to the network.
                    netsh wlan connect name=$wifi_name
                }
            }
        }else{
            # stop the script 
            Write-Error "No wifi xml files found in the selected folder. Exiting script."
            exit 1
        }
        
    }

    # todo : it will use signal strength of the network to connect .. in terms of order.
    function connector{
        
    }

    # check if there is internet connection.
    $internetConnectionStatus = Test-Connection -ComputerName localhost -Count 1 -Quiet
    while($internetConnectionStatus) {
        # as long as there is wifi connection.
        Start-Sleep -Seconds 3600
    }
    # if internet connection is lost.
    connector
}
catch {
    <#Do this if a terminating exception happens#>
}