# Get the list of remote computers
$computers = (Get-ADComputer -Filter * | Where-Object name -NotLike ws*).name

# Loop through each computer
foreach ($computer in $computers) {
    # Create a PSSession to the remote computer
    $session = New-PSSession -ComputerName $computer

    # Check if the Sysmon service is installed
    if (Get-Service -Name "Sysmon" -ComputerName $computer -ErrorAction SilentlyContinue) {
        # Stop and remove the Sysmon service
        Invoke-Command -Session $session -ScriptBlock {
            Start-Process 'C:\Program Files\Sysmon\sysmon.exe' -ArgumentList '-u force' -Wait
        }
        Write-Host "Sysmon service uninstalled on $computer"
    }

    # Check if the Sysmon64 service is installed
    if (Get-Service -Name "Sysmon64" -ComputerName $computer -ErrorAction SilentlyContinue) {
        # Stop and remove the Sysmon64 service
        Invoke-Command -Session $session -ScriptBlock {
            Stop-Service -Name "Sysmon64" -Force
            Start-Process 'C:\Program Files\Sysmon\sysmon64.exe' -ArgumentList '-u force' -Wait
            start-sleep -s 25
            & sc delete Sysmon64
        }
        Write-Host "Sysmon64 service uninstalled on $computer"
    }

    # Close the PSSession
    Remove-PSSession -Session $session
}