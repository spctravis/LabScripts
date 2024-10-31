function Install-ElasticAgentFromPath {
    [CmdletBinding()]
    param (
        [string]$DCName,
        [string]$ElasticAgentPath
    )
    # Dot-source the script to load the function into the current session
    # . .\Install-ElasticAgentFromPath.ps1
    # Call the function with the required parameters
    # Install-ElasticAgentFromPath -DCName "YourDomainControllerName" -ElasticAgentPath "C:\path\to\elastic-agent.exe"

    # Get all AD computers from the specified Domain Controller
    $computers = Invoke-Command -ComputerName $DCName -ScriptBlock {(Get-ADComputer -Filter * -Server $DCName).Name}

    # Loop through each computer and start the elastic-agent.exe
    foreach ($computer in $computers) {
        try {
            # Use Invoke-Command to run the elastic-agent.exe on the remote computer
            Invoke-Command -ComputerName $computer -ScriptBlock {
                param ($ElasticAgentPath)
                Start-Process -FilePath $using:ElasticAgentPath -NoNewWindow -Wait
            }  
        } catch {
            Write-Host "Failed to start elastic-agent on $computer: $_"
        }
    }
}