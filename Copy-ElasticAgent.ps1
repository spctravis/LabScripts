function Copy-ElasticAgent {
    [CmdletBinding()]
    param (
        [string]$DCName,
        [string]$SourcePath,
        [string]$DestinationPath
    )

    # Get all AD computers from the specified Domain Controller
    $computers = Invoke-Command -ComputerName $DCName -ScriptBlock {
        (Get-ADComputer -Filter * -Server $DCName).Name
    }

    # Loop through each computer and copy the Elastic Agent
    foreach ($computer in $computers) {
        try {
            # Use Invoke-Command to copy the Elastic Agent to the remote computer
            Invoke-Command -ComputerName $computer -ScriptBlock {
                param ($SourcePath, $DestinationPath)
                Copy-Item -Path $using:SourcePath -Destination $using:DestinationPath -Force
            } -ArgumentList $SourcePath, $DestinationPath
            Write-Host "Successfully copied Elastic Agent to $computer"
        } catch {
            Write-Host "Failed to copy Elastic Agent to $computer: $_"
        }
    }
}

# Example usage:
# Copy-ElasticAgent -DCName "YourDomainControllerName" -SourcePath "C:\path\to\elastic-agent.exe" -DestinationPath "C:\destination\path\elastic-agent.exe"