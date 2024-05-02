<#
.SYNOPSIS
    Installs Sysmon on remote computers.

.DESCRIPTION
    The Install-RemoteSysmon function installs Sysmon on remote computers. It copies the Sysmon executable and configuration file from local paths to the remote computers, and then installs Sysmon on the remote computers. If Sysmon is already installed, it will not reinstall unless the -Force switch is used. The -UpdateConfig switch can be used to update the configuration file without reinstalling Sysmon.


.PARAMETER SourceSysmonExe
    The local path of the Sysmon executable.

.PARAMETER SourceConfig
    The local path of the Sysmon configuration file.

.PARAMETER Force
    Forces the installation of Sysmon even if it's already installed.

.PARAMETER UpdateConfig
    Updates the configuration file without reinstalling Sysmon.

.PARAMETER SMB
    Use this switch to set the parameter for SMB. The path should be to a shared folder.

.EXAMPLE
    Install-RemoteSysmon -SourceSysmonExe "C:\path\to\sysmon.exe" -SourceConfig "C:\path\to\sysmonconfig.xml"
#>
function Install-RemoteSysmon {
    param (

        [Parameter(Mandatory=$true, HelpMessage="The local path of the Sysmon executable.")]
        [string]$SourceSysmonExe,

        [Parameter(Mandatory=$true, HelpMessage="The local path of the Sysmon configuration file.")]
        [string]$SourceConfig,

        [Parameter(HelpMessage="Forces the installation of Sysmon even if it's already installed.")]
        [switch]$Force,

        [Parameter(HelpMessage="Updates the configuration file without reinstalling Sysmon.")]
        [switch]$UpdateConfig,

        [Parameter(HelpMessage="The path to a shared folder.")]
        [switch]$smbPath
    )

    $SourceConfigPath = $SourceConfig
    $SourceConfig = Split-Path -Path $sourceConfig -Leaf
    $destFolder = "C:\Program Files\sysmon"
    $destConfig = "$destFolder\$SourceConfig"
    $destSysmonExe = "$destFolder\sysmon.exe"
    $smbSysmonExe = "$smbPath\sysmon.exe"
    $smbConfig = "$smbPath\$SourceConfig"

    # Check if there are established PSSessions if not break and tell the user to establish PSSessions
    $sessions = Get-PSSession
    if ($sessions.Count -eq 0) {
        Write-Host "No PSSessions found. Please establish PSSessions before running this function."
        break
    }

    # Check if Sysmon is installed on the remote machines
    Invoke-Command -Session $sessions -ScriptBlock {
        # if using force switch create the destination folder
        if ($using:Force) {
            New-Item -ItemType Directory -Path $using:destFolder -Force
        }
        # Create the destination folder if the folder does not exist
        if (!(Test-Path $using:destFolder)) {
            New-Item -ItemType Directory -Path $using:destFolder -Force
        }
        
    } -AsJob

    # Wait for the jobs to complete
    Get-Job | Wait-Job

    # Copy the Sysmon executable and configuration file to the remote machines
    if (!$UpdateConfig) {
        foreach($session in $sessions) {
            # If smbPath switch is used copy the files from the smbPath
            if ($smbPath) {
                Copy-Item -Path $smbSysmonExe -Destination $destFolder -ToSession $session 
                Copy-Item -Path $smbConfig -Destination $destFolder -ToSession $session 
            }
            else {
                Copy-Item -Path $SourceSysmonExe -Destination $destFolder -ToSession $session 
                Copy-Item -Path $SourceConfigPath -Destination $destFolder -ToSession $session 
            }
        }
    }

    # If the -UpdateConfig switch is used, copy the configuration file to the remote machines
    if ($UpdateConfig) {
        foreach($session in $sessions) {
            # If smbPath switch is used copy the files from the smbPath
            if ($smbPath) {
                Copy-Item -Path $smbConfig -Destination $destFolder -ToSession $session -Force
            }
            else {
                Copy-Item -Path $SourceConfigPath -Destination $destFolder -ToSession $session -Force
            }
        }
    }

    # If UpdateConfig switch is used, update the configuration file on the remote machines
    if (!$UpdateConfig) {
        # Install Sysmon on the remote machines
        Invoke-Command -Session $sessions -ScriptBlock {
            Start-Process $using:destSysmonExe -ArgumentList "-accepteula", "-i $using:destConfig" 
        } -AsJob -ErrorAction SilentlyContinue
    }

    # If UpdateConfig switch is used, update the configuration file on the remote machines
    if ($UpdateConfig) {
        # Update the Sysmon configuration file on the remote machines
        Invoke-Command -Session $sessions -ScriptBlock {
            Start-Process $using:destSysmonExe -ArgumentList "-c $using:destConfig" 
        } -AsJob -ErrorAction SilentlyContinue
    }
 
    # Wait for the jobs to complete
    Get-Job | Wait-Job

    # Check if the Sysmon service is running on the remote machines
    Invoke-Command -Session $sessions -ScriptBlock {
        $service = Get-Service -Name "Sysmon" -ErrorAction SilentlyContinue
        if ($service -and $service.Status -eq "Running") {
            "Sysmon is running on $env:COMPUTERNAME"
        } else {
            try {
                # If the service is not running, start it
                Start-Service -Name "Sysmon" -ErrorAction Stop
                "Sysmon service started on $env:COMPUTERNAME"
            } catch {
                "Failed to perform action on $($_.TargetObject): $($_.Exception.Message)"
            }
        }
    } -AsJob

    Get-Job | Wait-Job
    # Write the error message from the job to a log file
    Get-Job | Receive-Job -Keep | Out-File -Append -FilePath "$env:USERPROFILE\Desktop\Sysmon_errorlog.txt"
    # Remove the job
    Get-Job | Remove-Job

} # End of Install-RemoteSysmon function