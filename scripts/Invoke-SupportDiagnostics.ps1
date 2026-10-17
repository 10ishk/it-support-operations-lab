#requires -Version 5.1
<#+
.SYNOPSIS
Run selected Windows support checks and produce local TXT, JSON, CSV and HTML reports.
.DESCRIPTION
No switch defaults to -System. -Full includes backup using disposable lab inputs.
Check findings are recorded in reports; -FailOnFinding throws after writing reports on FAIL or UNAVAILABLE.
#>
[CmdletBinding()]
param(
    [switch]$System, [switch]$Network, [switch]$Events, [switch]$Services, [switch]$Backup, [switch]$Full,
    [ValidateRange(1,8760)][int]$Hours = 24,
    [ValidateRange(1,100)][int]$TopProcesses = 10,
    [ValidateRange(1,5000)][int]$MaxEvents = 100,
    [ValidateNotNullOrEmpty()][string]$Target = 'github.com',
    [ValidateRange(1,65535)][int[]]$Ports = @(80,443),
    [ValidateNotNullOrEmpty()][string]$PublicTestAddress = '1.1.1.1',
    [ValidateRange(100,30000)][int]$Timeout = 3000,
    [string]$SourceDirectory = (Join-Path $PSScriptRoot '..\lab-data'),
    [string]$OutputDirectory = (Join-Path $PSScriptRoot '..\reports'),
    [switch]$Redact, [switch]$FailOnFinding
)
. "$PSScriptRoot\Private\Common.ps1"
Assert-LabWindows
if ($Full) { $System = $true; $Network = $true; $Backup = $true }
if (-not ($System -or $Network -or $Events -or $Services -or $Backup)) { $System = $true }
$label = if ($Redact) { 'REDACTED' } else { $env:COMPUTERNAME }
$directory = New-LabRunDirectory $OutputDirectory $label
$reports = @()
if ($System -or $Events -or $Services) {
    $scope = if ($System -or ($Events -and $Services)) { 'All' } elseif ($Events) { 'Events' } else { 'Services' }
    $health = & "$PSScriptRoot\Invoke-SystemHealth.ps1" -Hours $Hours -TopProcesses $TopProcesses -MaxEvents $MaxEvents -Scope $scope -Redact:$Redact -OutputDirectory $directory
    $reports += $health
    $eventChecks = @($health.Checks | Where-Object Name -like 'Event Logs*')
    if ($eventChecks.Count) {
        $rows = @($eventChecks | ForEach-Object { $_.Data } | Where-Object { $null -ne $_ })
        if ($rows.Count) { $rows | Export-Csv -LiteralPath (Join-Path $directory 'event-errors.csv') -NoTypeInformation -Encoding UTF8 }
        else { '"TimeCreated","LogName","Id","LevelDisplayName","ProviderName","Message"' | Set-Content -LiteralPath (Join-Path $directory 'event-errors.csv') -Encoding UTF8 }
    }
    $serviceChecks = @($health.Checks | Where-Object Name -eq 'Services')
    if ($serviceChecks.Count) {
        $rows = @($serviceChecks | ForEach-Object { $_.Data } | Where-Object { $null -ne $_ })
        if ($rows.Count) { $rows | Export-Csv -LiteralPath (Join-Path $directory 'services.csv') -NoTypeInformation -Encoding UTF8 }
        else { '"Name","DisplayName","State","StartMode","ExitCode"' | Set-Content -LiteralPath (Join-Path $directory 'services.csv') -Encoding UTF8 }
    }
}
if ($Network) {
    $reports += & "$PSScriptRoot\Invoke-NetworkDiagnostics.ps1" -Target $Target -Ports $Ports -PublicTestAddress $PublicTestAddress -Timeout $Timeout -Redact:$Redact -OutputDirectory $directory
}
if ($Backup) {
    try {
        $backupReport = & "$PSScriptRoot\Invoke-BackupRestoreTest.ps1" -SourceDirectory $SourceDirectory -OutputDirectory $directory -Redact:$Redact
        $reports += $backupReport
        Write-LabReport $backupReport $directory 'backup-verification'
    }
    catch {
        $backupReport = [pscustomobject]@{ GeneratedAt=(Get-Date -Format o); Checks=@(New-LabCheck 'Backup Verification' FAIL $null $_.Exception.Message) }
        if ($Redact) { $backupReport = Protect-LabObject $backupReport }
        $reports += $backupReport
        Write-LabReport $backupReport $directory 'backup-verification'
    }
}
Write-LabHtml $reports (Join-Path $directory 'diagnostic-summary.html')
$findings = @($reports | ForEach-Object { $_.Checks })
$findings | Select-Object Name,Status | Format-Table -AutoSize | Out-Host
Write-Host "Reports: $directory"
if ($FailOnFinding -and @($findings | Where-Object { $_.Status -in @('FAIL','UNAVAILABLE') }).Count) { throw 'Diagnostics completed with FAIL or UNAVAILABLE findings. Review the reports.' }
[pscustomobject]@{ ReportDirectory=$directory; Checks=$findings }
