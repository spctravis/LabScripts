# Get all computers from Active Directory
$computers = (Get-ADComputer -Filter * | where name -NotLike ws*).name

# create sessions
$sessions = New-PSSession -ComputerName $computers