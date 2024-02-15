<#
.SYNOPSIS
    Installs Elastic Agent on remote computers.

.DESCRIPTION
    The Install-RemoteElasticAgent function installs Elastic Agent on remote computers. It copies the Elastic Agent executable from a local path to the remote computers, and then installs Elastic Agent on the remote computers. If Elastic Agent is already installed, it will not reinstall unless the -Force switch is used.

.PARAMETER ComputerName
    The names of the computers where Elastic Agent should be installed.

.PARAMETER SourceElasticAgentExe
    The local path of the Elastic Agent executable.

.PARAMETER Force
    Forces the installation of Elastic Agent even if it's already installed.

.EXAMPLE
    $(Get-Adcomputer -filter *).name | Install-RemoteElasticAgent -SourceElasticAgentExe "C:\path\to\elastic-agent.exe"
#>
function Install-RemoteElasticAgent {
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage="The names of the remote computers where Elastic Agent should be installed.")]
        [string[]]$ComputerName,

        [Parameter(Mandatory=$true, HelpMessage="The local path of the Elastic Agent executable.")]
        [string]$SourceElasticAgentExe,

        [Parameter(HelpMessage="Forces the installation of Elastic Agent even if it's already installed.")]
        [switch]$Force
    )

    $destFolder = "C:\Program Files\Elastic"
    $destElasticAgent = "$destFolder\so-elatic-agent_windows_amd64.exe"
    
    # Establish all PSSessions
    foreach ($computer in $ComputerName) {
        try {
            New-PSSession -ComputerName $computer -ErrorAction Stop
        } catch {
            "Unable to establish PSSession with $computer" | Out-File -Append -FilePath "$env:USERPROFILE\Desktop\elastic_agent_install_error.txt"
            return
        }
    }

    # Get the PSSessions that were successfully established
    $sessions = Get-PSSession

    # Check if Elastic Agent is installed on the remote machines
    Invoke-Command -Session $sessions -ScriptBlock {
        if (Get-Service -Name "elastic-agent" -and !$using:Force) {
            "Elastic Agent is already installed on $env:COMPUTERNAME"
            return
        }

       # Create the destination folder
       New-Item -ItemType Directory -Path $using:destFolder -Force

    } -AsJob

    # Copy the Elastic Agent executable to the remote machine
    $sessions | ForEach-Object {
        Copy-Item -Path $SourceElasticAgent -Destination $destElasticAgent -ToSession $_ -ErrorAction Stop
    } -AsJob
    Get-Job | Wait-Job

    # Check if Elastic Agent is installed on the remote machines
    Invoke-Command -Session $sessions -ScriptBlock {
       # Install Elastic Agent on the remote machine
       Start-Process -FilePath $using:destElasticAgent -Wait -NoNewWindow -ErrorAction Stop
    } -AsJob    

    # Wait for the jobs to complete
    Get-Job | Wait-Job

    # Check if the service elsatic-agent is running
    Invoke-Command -Session $sessions -ScriptBlock {
        try {
            if(Get-Service -Name elastic-agent) {
                "Elastic Agent installed and running on $_" }
        } catch {
            $_ | Out-File -Append -FilePath "$env:USERPROFILE\Desktop\elastic_agent_install_error.txt"
        }
    }
    # Remove the PSSessions
    $sessions | Remove-PSSession
}