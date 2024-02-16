<#
.SYNOPSIS
    Installs Elastic Agent on remote computers.

.DESCRIPTION
    The Install-RemoteElasticAgent function installs Elastic Agent on remote computers. It copies the Elastic Agent executable from a local path to the remote computers, and then installs Elastic Agent on the remote computers. If Elastic Agent is already installed, it will not reinstall unless the -Force switch is used.

.PARAMETER SourceElasticAgentExe
    The local path of the Elastic Agent executable.

.PARAMETER Force
    Forces the installation of Elastic Agent even if it's already installed.

.PARAMETER SMB
    Use this switch to set the parameter for SMB. The path should be to a shared folder.

.EXAMPLE
    Install-RemoteElasticAgent -SourceElasticAgentExe "C:\path\to\elastic-agent.exe"
#>
function Install-RemoteElasticAgent {
    param(

        [Parameter(Mandatory=$true, HelpMessage="The local path of the Elastic Agent executable.")]
        [string]$SourceElasticAgentExe,

        [Parameter(HelpMessage="Forces the installation of Elastic Agent even if it's already installed.")]
        [switch]$Force,

        [Parameter(HelpMessage="The path to a shared folder.")]
        [switch]$smbPath
    )

    $SourceElasticAgent = Split-Path -Path $SourceElasticAgentExe -Leaf
    $destFolder = "C:\Program Files\Elastic"
    $destElasticAgent = "$destFolder\$SourceElasticAgent"
    $smbElasticAgent = "$smbPath\$sourceElasticAgentExe"


    # Check if there are established PSSessions if not break and tell the user to establish PSSessions
    $sessions = Get-PSSession
    if ($sessions.Count -eq 0) {
        Write-Host "No PSSessions found. Please establish PSSessions before running this function."
        break
    }

    # Check if Elastic Agent is installed on the remote machines
    Invoke-Command -Session $sessions -ScriptBlock {
        if (Get-Service -Name "elastic-agent" -and !$using:Force) {
            "Elastic Agent is already installed on $env:COMPUTERNAME"
            return
        }
        # if using force switch create the destination folder
        if ($using:Force) {
            New-Item -ItemType Directory -Path $using:destFolder -Force
        }
        # Create the destination folder if the folder does not exist
        if (!(Test-Path $using:destFolder)) {
            New-Item -ItemType Directory -Path $using:destFolder -Force
        }

    } -AsJob

    Get-Job | Wait-Job

    # Copy the Elastic Agent executable to the remote machine
    foreach($session in $sessions) {
        # Test if the path is aleady created or the force switch is used
        if (!Get-Service -Name "elastic-agent" -and !$using:Force){
            if($using:smbPath){
                Copy-Item -Path $smbElasticAgent -Destination $destFolder -ToSession $session 
            } else {
                Copy-Item -Path $SourceElasticAgent -Destination $destFolder -ToSession $session 
                }
            }
        
        if ($using:Force){
            if($using:smbPath){
                Copy-Item -Path $smbElasticAgent -Destination $destFolder -ToSession $session -Force
            } else {
                Copy-Item -Path $SourceElasticAgent -Destination $destFolder -ToSession $session -Force
                }
            }    
        } 

    Get-Job | Wait-Job

    # Check if Elastic Agent is installed on the remote machines
    Invoke-Command -Session $sessions -ScriptBlock {
       # Install Elastic Agent on the remote machine if it's not already installed or if force parameter is used

        if (!Get-Service -Name "elastic-agent") {
            Start-Process -FilePath $using:destElasticAgent -Wait -NoNewWindow 
        }
        if ($using:Force) {
            Start-Process -FilePath $using:destElasticAgent -Wait -NoNewWindow 
        }
    } -AsJob    

    # Wait for the jobs to complete
    Get-Job | Wait-Job
    
    # Check if the service elsatic-agent is running
    Invoke-Command -Session $sessions -OutVariable errorMessage -ScriptBlock {
        if (Get-Service -Name "elastic-agent" ){
            "Elastic Agent is installed and running on $env:COMPUTERNAME"
        }
        else {
            "Elastic Agent is not installed on $env:COMPUTERNAME"
        }
    } -AsJob
    # Wait job to complete then if there is an error message write it to a log file
    Get-Job | Wait-Job
    # Write the error message from the job to a log file
    Get-Job | Receive-Job -Keep | Out-File -Append -FilePath "$env:USERPROFILE\Desktop\ElasticAgent_errorlog.txt"
    # Remove the job
    Get-Job | Remove-Job
}