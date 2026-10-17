#requires -Version 5.1
<#+
.SYNOPSIS
Check local network configuration, ICMP reachability, DNS and TCP connections.
.DESCRIPTION
Timeout is in milliseconds for each ICMP/TCP probe. DNS uses the Windows resolver timeout.
#>
[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()][string]$Target = 'github.com',
    [ValidateRange(1,65535)][int[]]$Ports = @(80,443),
    [ValidateNotNullOrEmpty()][string]$PublicTestAddress = '1.1.1.1',
    [ValidateRange(100,30000)][int]$Timeout = 3000,
    [string]$OutputDirectory,
    [switch]$Redact
)
. "$PSScriptRoot\Private\Common.ps1"
Assert-LabWindows
function Test-LabPing {
    param([string]$Address)
    $ping = New-Object System.Net.NetworkInformation.Ping
    try {
        $reply = $ping.Send($Address,$Timeout)
        [pscustomobject]@{ Address=$Address; Reachable=($reply.Status -eq 'Success'); Result=$reply.Status.ToString(); RoundtripMs=$reply.RoundtripTime }
    }
    finally { $ping.Dispose() }
}
$checks = @()
$usable = @()
$checks += Invoke-LabCheck 'Adapter Configuration' {
    $adapters = @(Get-NetAdapter -ErrorAction Stop | Where-Object Status -eq 'Up')
    $config = @(foreach ($adapter in $adapters) {
        $ip = Get-NetIPConfiguration -InterfaceIndex $adapter.ifIndex -ErrorAction Stop
        $dns = Get-DnsClientServerAddress -InterfaceIndex $adapter.ifIndex -AddressFamily IPv4 -ErrorAction Stop
        $interface = Get-NetIPInterface -InterfaceIndex $adapter.ifIndex -AddressFamily IPv4 -ErrorAction Stop
        [pscustomobject]@{
            InterfaceAlias=$adapter.Name; InterfaceIndex=$adapter.ifIndex; LinkStatus=$adapter.Status.ToString()
            IPv4=@($ip.IPv4Address | Select-Object IPAddress,PrefixLength)
            DefaultGateway=@($ip.IPv4DefaultGateway | Select-Object -ExpandProperty NextHop)
            DnsServers=@($dns.ServerAddresses); DHCP=@($interface | ForEach-Object { $_.Dhcp.ToString() })
            MacAddress=$adapter.MacAddress
        }
    })
    $status = if (@($config | Where-Object { @($_.IPv4 | Where-Object { $_.IPAddress -notmatch '^(169\.254\.|127\.|0\.)' }).Count }).Count) { 'PASS' } else { 'FAIL' }
    New-LabCheck 'Adapter Configuration' $status $config 'IPv4-focused checks. APIPA or loopback alone is not usable. A link being up does not prove routed connectivity.'
}
if ($checks[0].Status -ne 'UNAVAILABLE') {
    $usable = @($checks[0].Data | Where-Object { @($_.IPv4 | Where-Object { $_.IPAddress -notmatch '^(169\.254\.|127\.|0\.)' }).Count })
}
$checks += Invoke-LabCheck 'Default Gateway' {
    $gateways = @($usable | ForEach-Object { $_.DefaultGateway } | Sort-Object -Unique)
    if (-not $gateways.Count) { New-LabCheck 'Default Gateway' WARNING @() 'No IPv4 default gateway on a usable interface; isolated networks may intentionally have none.' }
    else {
        $results = @(foreach ($gateway in $gateways) { Test-LabPing $gateway })
        $status = if (@($results | Where-Object Reachable).Count) { 'PASS' } else { 'WARNING' }
        New-LabCheck 'Default Gateway' $status $results 'ICMP may be filtered. Test application connectivity before concluding routing has failed.'
    }
}
$checks += Invoke-LabCheck 'Internet Connectivity' {
    $result = Test-LabPing $PublicTestAddress
    $status = if ($result.Reachable) { 'PASS' } else { 'WARNING' }
    New-LabCheck 'Internet Connectivity' $status $result 'Tests ICMP to the selected public target only. Failure is inconclusive when ICMP is blocked.'
}
$checks += Invoke-LabCheck 'DNS Resolution' {
    try {
        $answer = @(Resolve-DnsName -Name $Target -Type A -DnsOnly -ErrorAction Stop |
            Where-Object Type -eq 'A' | Select-Object Name,Type,IPAddress)
        $status = if ($answer.Count) { 'PASS' } else { 'FAIL' }
        New-LabCheck 'DNS Resolution' $status $answer "IPv4 lookup for $Target using the configured resolver."
    }
    catch {
        if ($_.CategoryInfo.Category -eq 'ObjectNotFound' -and $_.Exception -is [System.Management.Automation.CommandNotFoundException]) { throw }
        New-LabCheck 'DNS Resolution' FAIL $null $_.Exception.Message
    }
}
$dnsCheck = $checks | Where-Object Name -eq 'DNS Resolution'
foreach ($port in ($Ports | Sort-Object -Unique)) {
    $checks += Invoke-LabCheck "TCP $port" {
        if ($dnsCheck.Status -ne 'PASS') {
            New-LabCheck "TCP $port" UNAVAILABLE $null 'Skipped: no resolved IPv4 address; a TCP failure cannot yet be isolated.'
        }
        else {
            $results = @(foreach ($address in $dnsCheck.Data.IPAddress) {
                $client = New-Object System.Net.Sockets.TcpClient
                try {
                    $task = $client.ConnectAsync([string]$address,[int]$port)
                    $connected = $task.Wait($Timeout) -and $client.Connected
                    [pscustomobject]@{ Address=$address; Port=$port; Connected=$connected; Detail=$(if ($connected) { 'Connected' } else { 'Timed out' }) }
                }
                catch { [pscustomobject]@{ Address=$address; Port=$port; Connected=$false; Detail=$_.Exception.GetBaseException().Message } }
                finally { $client.Close(); $client.Dispose() }
            })
            $status = if (@($results | Where-Object Connected).Count) { 'PASS' } else { 'FAIL' }
            New-LabCheck "TCP $port" $status $results "DNS worked; connection tested to each returned IPv4 address on $Target. TCP success does not test TLS or application health."
        }
    }
}
$report = [pscustomobject]@{ GeneratedAt=(Get-Date -Format o); Checks=$checks }
if ($Redact) { $report = Protect-LabObject $report }
if ($OutputDirectory) { Write-LabReport $report $OutputDirectory 'network-diagnostics' }
$report
