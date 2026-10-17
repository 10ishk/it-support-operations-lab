Set-StrictMode -Version Latest

function New-LabCheck {
    param([string]$Name, [ValidateSet('PASS','WARNING','FAIL','INFO','UNAVAILABLE')][string]$Status,
        $Data = $null, [string]$Detail = '')
    [pscustomobject][ordered]@{ Name = $Name; Status = $Status; Data = $Data; Detail = $Detail }
}

function Invoke-LabCheck {
    param([string]$Name, [scriptblock]$Action)
    try { & $Action }
    catch { New-LabCheck $Name UNAVAILABLE $null $_.Exception.Message }
}

function Assert-LabWindows {
    if ([Environment]::OSVersion.Platform -ne 'Win32NT') { throw 'This diagnostic requires Windows.' }
}

function New-LabRunDirectory {
    param([string]$Root, [string]$Label = 'run')
    $safeLabel = $Label -replace '[^a-zA-Z0-9_-]', '_'
    $name = '{0}-{1}-{2}' -f (Get-Date -Format 'yyyy-MM-dd_HHmmssfff'), $safeLabel, ([guid]::NewGuid().ToString('N').Substring(0,8))
    $path = Join-Path $Root $name
    New-Item -ItemType Directory -Path $path -ErrorAction Stop | Out-Null
    (Get-Item -LiteralPath $path).FullName
}

function Protect-LabText {
    param([AllowEmptyString()][string]$Text)
    $result = $Text
    foreach ($entry in @(@($env:USERPROFILE, '[HOME]'), @($env:COMPUTERNAME, '[COMPUTER]'), @($env:USERNAME, '[USER]'))) {
        if (-not [string]::IsNullOrWhiteSpace($entry[0])) {
            $result = [regex]::Replace($result, [regex]::Escape($entry[0]), $entry[1], 'IgnoreCase')
        }
    }
    $result = $result -replace '(?i)[a-z]:[\\/]Users[\\/][^\\/\s"<>]+', '[HOME]'
    $result = $result -replace '(?i)\b(?:[0-9a-f]{2}[:-]){5}[0-9a-f]{2}\b', '[MAC]'
    # Keep private IPv4 addressing useful for subnet diagnosis; mask other literal IPv4 addresses.
    $result = [regex]::Replace($result, '\b(?:\d{1,3}\.){3}\d{1,3}\b', {
        param($match)
        $ip = $null
        if (-not [System.Net.IPAddress]::TryParse($match.Value, [ref]$ip)) { return $match.Value }
        $bytes = $ip.GetAddressBytes()
        if ($bytes[0] -eq 10 -or $bytes[0] -eq 127 -or
            ($bytes[0] -eq 192 -and $bytes[1] -eq 168) -or
            ($bytes[0] -eq 172 -and $bytes[1] -ge 16 -and $bytes[1] -le 31) -or
            ($bytes[0] -eq 169 -and $bytes[1] -eq 254) -or $match.Value -eq '0.0.0.0') { return $match.Value }
        '[PUBLIC-IP]'
    })
    $result
}

function Protect-LabObject {
    param([AllowNull()]$Value)
    if ($null -eq $Value) { return $null }
    if ($Value -is [string]) { return Protect-LabText $Value }
    if ($Value -is [datetime]) { return $Value.ToString('o') }
    if ($Value -is [System.Collections.IDictionary]) {
        $copy = [ordered]@{}
        foreach ($key in $Value.Keys) {
            if ($key -match '^(ComputerName|UserName|SSID|MacAddress|PSComputerName)$') { $copy[$key] = '[REDACTED]' }
            else { $copy[$key] = Protect-LabObject $Value[$key] }
        }
        return $copy
    }
    if ($Value -is [System.Collections.IEnumerable]) {
        $items = @(); foreach ($item in $Value) { $items += ,(Protect-LabObject $item) }; return ,$items
    }
    if ($Value -is [pscustomobject]) {
        $copy = [ordered]@{}
        foreach ($property in $Value.PSObject.Properties) {
            if ($property.Name -match '^(ComputerName|UserName|SSID|MacAddress|PSComputerName)$') { $copy[$property.Name] = '[REDACTED]' }
            else { $copy[$property.Name] = Protect-LabObject $property.Value }
        }
        return [pscustomobject]$copy
    }
    $Value
}

function Write-LabReport {
    param($Report, [string]$Directory, [string]$Name)
    New-Item -ItemType Directory -Path $Directory -Force -ErrorAction Stop | Out-Null
    $Report | ConvertTo-Json -Depth 30 | Set-Content -LiteralPath (Join-Path $Directory "$Name.json") -Encoding UTF8
    $lines = @("Generated: $($Report.GeneratedAt)", '')
    foreach ($check in $Report.Checks) {
        $lines += '{0,-28} {1}' -f $check.Name, $check.Status
        if ($check.Detail) { $lines += $check.Detail }
        $lines += ($check.Data | ConvertTo-Json -Depth 25)
        $lines += ''
    }
    $lines | Set-Content -LiteralPath (Join-Path $Directory "$Name.txt") -Encoding UTF8
}

function Write-LabHtml {
    param([object[]]$Reports, [string]$Path)
    $sections = foreach ($report in $Reports) {
        foreach ($check in $report.Checks) {
            $name = [System.Net.WebUtility]::HtmlEncode($check.Name)
            $detail = [System.Net.WebUtility]::HtmlEncode($check.Detail)
            $data = [System.Net.WebUtility]::HtmlEncode(($check.Data | ConvertTo-Json -Depth 25))
            '<section><h2>{0} <span class="{1}">{1}</span></h2><p>{2}</p><pre>{3}</pre></section>' -f $name,$check.Status,$detail,$data
        }
    }
    @"
<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Support diagnostic summary</title><style>
body{font:16px system-ui,sans-serif;max-width:1100px;margin:2rem auto;padding:0 1rem;background:#f6f8fa;color:#202a35}
section{background:white;padding:1rem;margin:1rem 0;border:1px solid #d0d7de;border-radius:6px}
h2{font-size:1.15rem}span{font-size:.8rem;padding:.2rem .5rem;border:1px solid;border-radius:4px}
.PASS{color:#166534}.FAIL{color:#b91c1c}.WARNING,.UNAVAILABLE{color:#854d0e}.INFO{color:#1e40af}
pre{white-space:pre-wrap;overflow-wrap:anywhere;font-size:.85rem}footer{color:#475569}
</style></head><body><h1>IT Support Operations Lab</h1><p>Diagnostic summary | Generated $(Get-Date -Format o)</p>
<p>PASS = check met; WARNING = investigate; FAIL = test failed; INFO = observation; UNAVAILABLE = not collected.</p>
$($sections -join [Environment]::NewLine)
<footer>CPU values are cumulative seconds. ICMP failure alone does not establish loss of internet access. Review sensitive data before sharing.</footer>
</body></html>
"@ | Set-Content -LiteralPath $Path -Encoding UTF8
}

function Test-LabHashMatch {
    param([string]$Original, [string]$Backup, [string]$Restored)
    ($Original -match '^[a-fA-F0-9]{64}$' -and $Backup -eq $Original -and $Restored -eq $Original)
}
