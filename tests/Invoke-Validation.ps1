#requires -Version 5.1
[CmdletBinding()]
param([switch]$Live)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
Push-Location $root
try {
    Get-ChildItem scripts,tests -Filter *.ps1 -Recurse | ForEach-Object {
        $parseErrors = $null
        [System.Management.Automation.Language.Parser]::ParseFile($_.FullName,[ref]$null,[ref]$parseErrors) | Out-Null
        if ($parseErrors) { throw ($parseErrors | Out-String) }
    }
    $files = @(git ls-files --cached --others --exclude-standard)
    foreach ($file in $files) {
        if ($file -like '*.md') {
            $text = Get-Content -LiteralPath $file -Raw
            $text = [regex]::Replace($text,'(?s)```.*?```','')
            $text = [regex]::Replace($text,'`[^`]*`','')
            foreach ($match in [regex]::Matches($text,'\[[^\]]*\]\(([^)]+)\)')) {
                $target = $match.Groups[1].Value
                if ($target -match '^(https?://|#)') { continue }
                $target = ($target -split '#')[0]
                if (-not (Test-Path -LiteralPath (Join-Path (Split-Path (Join-Path $root $file) -Parent) $target))) { throw "Broken link in $file" }
            }
        }
    }
    $result = Invoke-Pester -Path (Join-Path $root 'tests') -PassThru
    if ($result.FailedCount -gt 0 -or $result.PassedCount -lt 16) { throw 'Tests failed or not discovered.' }
    Write-Host "Syntax, relative Markdown links, and $($result.PassedCount) tests passed on PowerShell $($PSVersionTable.PSVersion)."
    if ($Live) {
        $run = & .\scripts\Invoke-SupportDiagnostics.ps1 -Full -Redact -MaxEvents 5
        foreach ($file in Get-ChildItem -LiteralPath $run.ReportDirectory -File) {
            $text = Get-Content -LiteralPath $file.FullName -Raw
            if ($file.Extension -eq '.json') { $text | ConvertFrom-Json | Out-Null }
            foreach ($identity in @($env:USERNAME,$env:COMPUTERNAME,$env:USERPROFILE)) {
                if ($identity -and $text -match [regex]::Escape($identity)) { throw "Current identity in $($file.Name)" }
            }
        }
        if (@(Get-ChildItem -LiteralPath $run.ReportDirectory -File).Count -ne 9) { throw 'Unexpected full-run artifact count' }
        $selected = & .\scripts\Invoke-SupportDiagnostics.ps1 -Events -Services -MaxEvents 1 -Redact
        if (@($selected.Checks | Where-Object Name -eq 'System Overview').Count) { throw 'Selection collected unrelated system overview' }
        $dnsFailure = & .\scripts\Invoke-NetworkDiagnostics.ps1 -Target support-lab.invalid -Ports 443 -Redact
        if (($dnsFailure.Checks | Where-Object Name -eq 'DNS Resolution').Status -ne 'FAIL') { throw 'Reserved invalid DNS target unexpectedly resolved' }
        if (($dnsFailure.Checks | Where-Object Name -eq 'TCP 443').Status -ne 'UNAVAILABLE') { throw 'TCP was not skipped on DNS failure' }
        Write-Host 'Live collection, nine output artifacts, current-identity redaction, switch selection, and reserved invalid DNS behavior verified. Reports remain ignored.'
    }
}
finally { Pop-Location }
