$sysmonService = Get-Service -Name "sysmon"

$sessions = Get-PSSession
foreach ($session in $sessions) {
    if ($sysmonService.Status -eq "Running") {
        Remove-PSSession $session
    }
}