<#
.SYNOPSIS
    Installs Sysmon on remote computers.

.DESCRIPTION
    The Install-RemoteSysmon function installs Sysmon on remote computers. It copies the Sysmon executable and configuration file from local paths to the remote computers, and then installs Sysmon on the remote computers. If Sysmon is already installed, it will not reinstall unless the -Force switch is used. The -UpdateConfig switch can be used to update the configuration file without reinstalling Sysmon.

.PARAMETER ComputerName
    The names of the computers where Sysmon should be installed.

.PARAMETER SourceSysmonExe
    The local path of the Sysmon executable.

.PARAMETER SourceConfig
    The local path of the Sysmon configuration file.

.PARAMETER Force
    Forces the installation of Sysmon even if it's already installed.

.PARAMETER UpdateConfig
    Updates the configuration file without reinstalling Sysmon.

.EXAMPLE
    $(Get-Adcomputer -filter *).name | Install-RemoteSysmon -SourceSysmonExe "C:\path\to\sysmon.exe" -SourceConfig "C:\path\to\sysmonconfig.xml"
#>
function Install-RemoteSysmon {
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage="The names of the remote computers where Sysmon should be installed.")]
        [string[]]$ComputerName,

        [Parameter(Mandatory=$true, HelpMessage="The local path of the Sysmon executable.")]
        [string]$SourceSysmonExe,

        [Parameter(Mandatory=$true, HelpMessage="The local path of the Sysmon configuration file.")]
        [string]$SourceConfig,

        [Parameter(HelpMessage="Forces the installation of Sysmon even if it's already installed.")]
        [switch]$Force,

        [Parameter(HelpMessage="Updates the configuration file without reinstalling Sysmon.")]
        [switch]$UpdateConfig
    )

    $destFolder = "C:\Program Files\sysmon"
    $destSysmonExe = "$destFolder\sysmon.exe"
    $destConfig = "$destFolder\sysmonconfig.xml"

    # Establish all PSSessions
    foreach ($computer in $ComputerName) {
        try {
             New-PSSession -ComputerName $computer -ErrorAction Stop
        } catch {
            "Unable to establish PSSession with on $_" | Out-File -Append -FilePath "$env:USERPROFILE\Desktop\sysmon_install_error.txt"
            return
        }
    }

    # Get the PSSessions that were successfully established
    $sessions = Get-PSSession

    # Check if Sysmon is installed on the remote machines
    Invoke-Command -Session $sessions -ScriptBlock {
        if (Get-Service -Name "Sysmon" -and !$using:Force -and !$using:UpdateConfig) {
            "Sysmon is already installed on $env:COMPUTERNAME"
            return
        }

        # Create the destination folder
        New-Item -ItemType Directory -Path $using:destFolder -Force
    } -AsJob

    # Copy the Sysmon executable and configuration file to the remote machines
    if (!$UpdateConfig) {
        $sessions | ForEach-Object {
            Copy-Item -Path $SourceSysmonExe -Destination $destSysmonExe -ToSession $_ -ErrorAction Stop
        }
    }
    $sessions | ForEach-Object {
        Copy-Item -Path $SourceConfig -Destination $destConfig -ToSession $_ -ErrorAction Stop
    }

    # Check if Sysmon is installed on the remote machines
    Invoke-Command -Session $sessions -ScriptBlock {
        if (!$using:UpdateConfig) {

            # Install Sysmon on the remote machine
            Start-Process -FilePath $using:destSysmonExe -ArgumentList "-accepteula -i $using:destConfig" -Wait -NoNewWindow -ErrorAction Stop
        }
        if ($using:UpdateConfig) {
            # Update the Sysmon configuration file on the remote machine
            Start-Process -FilePath $using:destSysmonExe -ArgumentList "-c $using:destConfig" -Wait -NoNewWindow -ErrorAction Stop
        }
    } -AsJob
 
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
                "Failed to start Sysmon service on $env:COMPUTERNAME: $_" | Out-File -Append -FilePath "$env:USERPROFILE\Desktop\sysmon_install_error.txt"
            }
        }
    }

    # Remove the PSSessions
    $sessions | Remove-PSSession
}