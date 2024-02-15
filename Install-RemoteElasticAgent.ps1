function Install-RemoteElasticAgent {
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage="The names of the remote computers.")]
        [string[]]$ComputerName,

        [Parameter(Mandatory=$true, HelpMessage="The path to the Elastic Agent executable on the local machine.")]
        [string]$SourceElasticAgentExe
    )

    # Establish all PSSessions
    $sessions = $ComputerName | ForEach-Object {
        try {
            New-PSSession -ComputerName $_ -ErrorAction Stop
        } catch {
            "Unable to establish PSSession with $_: $_" | Out-File -Append -FilePath "$env:USERPROFILE\Desktop\elastic_agent_install_error.txt"
            $null
        }
    }

    $destFolder = "C:\Program Files\Elastic"
    $destElasticAgentExe = "$destFolder\so-elatic-agent_windows_amd64.exe"

    # Create the destination folder on the remote machines
    Invoke-Command -Session $sessions -ScriptBlock {
        New-Item -ItemType Directory -Path $using:destFolder -Force
    } -AsJob

    # Copy the Elastic Agent executable to the remote machines
    $sessions | ForEach-Object {
        try {
            Copy-Item -Path $SourceElasticAgentExe -Destination $destElasticAgentExe -ToSession $_ -ErrorAction Stop
        } catch {
            $_ | Out-File -Append -FilePath "$env:USERPROFILE\Desktop\elastic_agent_install_error.txt"
        }
    }

    # Install Elastic Agent on the remote machines
    Invoke-Command -Session $sessions -ScriptBlock {
        try {
            Start-Process -FilePath $using:destElasticAgentExe -Wait -NoNewWindow -ErrorAction Stop
        } catch {
            $_ | Out-File -Append -FilePath "$env:USERPROFILE\Desktop\elastic_agent_install_error.txt"
        }
    } -AsJob

    # Remove the PSSessions
    $sessions | Remove-PSSession
}