function Enable-GPOPowerShellRemoting {
<#
.SYNOPSIS
A script to enable PowerShell Remoting via GPO and configure the firewall to allow connections from specific IPs.

.PARAMETER allowedIPs
An array of IP addresses from which incoming connections will be allowed.

.PARAMETER domainName
The name of the domain where the GPO will be created.

.PARAMETER topLevelDomain
The top-level domain of your organization. For example, if your domain is "example.com", the top-level domain is "com".
#>
param(
    [Parameter(Mandatory=$false, HelpMessage="An array of IP addresses from which incoming connections will be allowed.")]
    [string[]]$allowedIPs,
    [Parameter(Mandatory=$true, HelpMessage="The name of the domain where the GPO will be created.")]
    [string]$domainName,
    [Parameter(Mandatory=$true, HelpMessage="The top-level domain of your organization. For example, if your domain is 'example.com', the top-level domain is 'com'.")]
    [string]$topLevelDomain
)

# Define the name of the GPO
$gpoName = "Enable PowerShell Remoting"

# Check if the "Remote Management Users" group exists
$group = Get-ADGroup -Filter { Name -eq "Remote Management Users" }

if ($null -eq $group) {
    # Ask the user if they want to create the group
    $createGroup = Read-Host "The 'Remote Management Users' group does not exist. Do you want to create it? (yes/no)"

    if ($createGroup -eq "yes") {
        # Create the group
        New-ADGroup -Name "Remote Management Users" -GroupScope Global -PassThru
    } else {
        Write-Host "Please create the 'Remote Management Users' group and rerun the script."
        return
    }
}

# Create the GPO
New-GPO -Name $gpoName | New-GPLink -Target "ou=Computers,dc=$domainName,dc=$topLevelDomain" -LinkEnabled Yes

# Enable PowerShell Remoting in the GPO
Set-GPRegistryValue -Name $gpoName -Key "HKLM\Software\Policies\Microsoft\Windows\WinRM\Service" -ValueName AllowRemoteShellAccess -Type DWord -Value 1

# Open a GPO session
$gpoSession = Open-NetGPO -PolicyStore "$domainName\\$gpoName"

# Configure the firewall for each allowed IP, if any
if ($null -ne $allowedIPs) {
    foreach ($ip in $allowedIPs) {
        # Add a firewall rule to allow incoming connections from the IP
        New-NetFirewallRule -GPOSession $gpoSession -DisplayName "Allow PowerShell Remoting from $ip" -Direction Inbound -LocalPort 5985 -Protocol TCP -Action Allow -RemoteAddress $ip
    }
}

# Save the changes and close the GPO session
Save-NetGPO -GPOSession $gpoSession

} # End of Enable-GPOPowerShellRemoting