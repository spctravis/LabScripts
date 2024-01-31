# Get the list of computer names excluding specific ones
$computers = Get-ADComputer -Filter * | Where-Object { $_.Name -notlike 'dc*' -and $_.Name -ne 'fileserver' -and $_.Name -ne 'exchange2013' } | Select-Object -ExpandProperty Name

# Define the path to the installer
$installerPath = "C:\path\to\python-installer.exe"

# Define the installation options
$options = "/quiet InstallAllUsers=1 PrependPath=1"

# Define the script block to run
$scriptBlock = {
    # Start the installation
    Start-Process -FilePath $using:installerPath -ArgumentList $using:options -Wait -NoNewWindow
}

# Run the script block on each computer
foreach ($computer in $computers) {
    Invoke-Command -ComputerName $computer -ScriptBlock $scriptBlock
}