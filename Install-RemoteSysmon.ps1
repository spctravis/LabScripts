foreach ($Computer in $ComputerName) {
    try {
        # Test WSMan availability on the remote machine
        Test-WSMan -ComputerName $Computer -ErrorAction Stop
    } catch {
        "WSMan not available on $Computer: $_" | Out-File -Append -FilePath "$env:USERPROFILE\Desktop\sysmon_install_error.txt"
        continue
    }

    $destFolder = "\\$Computer\c$\Program Files\sysmon"
    $destSysmonExe = "$destFolder\sysmon.exe"
    $destConfig = "$destFolder\sysmonconfig.xml"

    # Create the destination folder on the remote machine
    New-Item -ItemType Directory -Path $destFolder -Force

    # Copy the Sysmon executable and configuration file to the remote machine
    try {
        # Copy the Sysmon executable to the remote machine
        Copy-Item -Path $SourceSysmonExe -Destination $destSysmonExe -ErrorAction Stop
    } catch {
        $_ | Out-File -Append -FilePath "$env:USERPROFILE\Desktop\sysmon_install_error.txt"
    }

    try {
        # Copy the Sysmon configuration file to the remote machine
        Copy-Item -Path $SourceConfig -Destination $destConfig -ErrorAction Stop
    } catch {
        $_ | Out-File -Append -FilePath "$env:USERPROFILE\Desktop\sysmon_install_error.txt"
    }

    Invoke-Command -ComputerName $Computer -ScriptBlock {
        try {
            Start-Process -FilePath "C:\Program Files\sysmon\sysmon.exe" -ArgumentList "-accepteula -i 'C:\Program Files\sysmon\sysmonconfig.xml'" -Wait -NoNewWindow -ErrorAction Stop
        } catch {
            $_ | Out-File -Append -FilePath "$env:USERPROFILE\Desktop\sysmon_install_error.txt"
        }
    }
}