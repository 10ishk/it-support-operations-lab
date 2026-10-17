Set-StrictMode -Version Latest

function Get-LabTimestamp { [DateTimeOffset]::Now.ToOffset([TimeSpan]::FromHours(4)).ToString('o') }

function Save-LabRaw {
    param([string]$Name, $Value)
    $Value | ConvertTo-Json -Depth 30 | Set-Content -LiteralPath (Join-Path $rawRoot "$Name.json") -Encoding UTF8
}

function Save-LabEvidence {
    param([string]$Id, $Value, [string[]]$Commands)
    Save-LabRaw $Id $Value
    $folder = Join-Path $evidenceRoot $Id
    New-Item -ItemType Directory -Path $folder -Force | Out-Null
    $Value | ConvertTo-Json -Depth 25 | Set-Content -LiteralPath (Join-Path $folder 'observations.json') -Encoding UTF8
    $Value | ConvertTo-Json -Depth 25 | Set-Content -LiteralPath (Join-Path $folder 'sanitized-output.txt') -Encoding UTF8
    @('Commands executed by scripts/Invoke-ControlledLab.ps1.',
        'Variable names below stand for values selected/computed during the run; identifying values are withheld.', '') + $Commands |
        Set-Content -LiteralPath (Join-Path $folder 'commands.txt') -Encoding UTF8
}

function Test-ExecutionTcp {
    param([string]$Address, [int]$Port, [int]$Timeout = 750)
    $client = New-Object Net.Sockets.TcpClient
    try {
        $task = $client.ConnectAsync($Address,$Port)
        $connected = $task.Wait($Timeout) -and $client.Connected
        [pscustomobject]@{ At=Get-LabTimestamp; Connected=$connected; Error=$(if ($connected) { $null } else { 'Connection timed out' }) }
    }
    catch { [pscustomobject]@{ At=Get-LabTimestamp; Connected=$false; Error=$_.Exception.GetBaseException().GetType().Name } }
    finally { $client.Dispose() }
}

function Get-ExecutionNetworkState {
    [pscustomobject]@{
        Adapters=@(Get-NetAdapter | Sort-Object ifIndex | Select-Object ifIndex,Name,Status)
        Addresses=@(Get-NetIPAddress -AddressFamily IPv4 | Sort-Object InterfaceIndex,IPAddress | Select-Object InterfaceIndex,IPAddress,PrefixLength)
        Dns=@(Get-DnsClientServerAddress -AddressFamily IPv4 | Sort-Object InterfaceIndex | Select-Object InterfaceIndex,ServerAddresses)
        Routes=@(Get-NetRoute -AddressFamily IPv4 | Sort-Object InterfaceIndex,DestinationPrefix,NextHop | Select-Object InterfaceIndex,DestinationPrefix,NextHop,RouteMetric)
    }
}
