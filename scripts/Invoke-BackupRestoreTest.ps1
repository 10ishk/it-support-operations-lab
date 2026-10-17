#requires -Version 5.1
<#
.SYNOPSIS
Copy lab inputs into unique backup/restore directories and compare three SHA-256 digests.
.DESCRIPTION
Rejects overlapping source/output directories and reparse points. Never removes original files.
Operational errors throw. File integrity failures return FAIL; use -FailOnMismatch for a terminating error.
#>
[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()][string]$SourceDirectory = (Join-Path $PSScriptRoot '..\lab-data'),
    [ValidateNotNullOrEmpty()][string]$OutputDirectory = (Join-Path $PSScriptRoot '..\reports'),
    [switch]$Redact,
    [switch]$FailOnMismatch
)
. "$PSScriptRoot\Private\Common.ps1"
$source = (Get-Item -LiteralPath $SourceDirectory -ErrorAction Stop).FullName.TrimEnd('\','/')
if (-not (Test-Path -LiteralPath $source -PathType Container)) { throw 'Source must be a directory.' }
$output = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputDirectory).TrimEnd('\','/')
if ($source -eq $output -or $output.StartsWith($source + [IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase) -or
    $source.StartsWith($output + [IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)) {
    throw 'Source and output must be separate, non-overlapping directories.'
}
# Check every existing ancestor so links cannot hide an output inside the source.
foreach ($path in @($source,$output)) {
    $cursor = $path
    while ($cursor) {
        if (Test-Path -LiteralPath $cursor) {
            if ((Get-Item -LiteralPath $cursor -Force).Attributes -band [IO.FileAttributes]::ReparsePoint) { throw 'Reparse points are not supported in source/output paths.' }
        }
        $parent = Split-Path -Path $cursor -Parent
        if ($parent -eq $cursor) { break }; $cursor = $parent
    }
}
# Enumerate one level at a time to reject links before descending into them.
$files = @()
$pending = New-Object 'System.Collections.Generic.Queue[string]'
$pending.Enqueue($source)
while ($pending.Count) {
    foreach ($item in Get-ChildItem -LiteralPath $pending.Dequeue() -Force -ErrorAction Stop) {
        if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw 'Source contains a reparse point; remove it from the lab inputs.' }
        if ($item.PSIsContainer) { $pending.Enqueue($item.FullName) } else { $files += $item }
    }
}
if (-not $files.Count) { throw 'Source contains no files; no successful verification is possible.' }
$run = New-LabRunDirectory $output 'backup'
$backup = Join-Path $run 'backup'
$restore = Join-Path $run 'restore'
New-Item -ItemType Directory -Path $backup,$restore -ErrorAction Stop | Out-Null
$rows = @(foreach ($file in $files) {
    $relative = $file.FullName.Substring($source.Length).TrimStart('\','/')
    $originalHash = $null; $backupHash = $null; $restoredHash = $null; $detail = ''
    try {
        $originalHash = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256 -ErrorAction Stop).Hash
        $backupFile = Join-Path $backup $relative
        $restoredFile = Join-Path $restore $relative
        New-Item -ItemType Directory -Path (Split-Path $backupFile -Parent),(Split-Path $restoredFile -Parent) -Force -ErrorAction Stop | Out-Null
        Copy-Item -LiteralPath $file.FullName -Destination $backupFile -ErrorAction Stop
        if (-not (Test-Path -LiteralPath $backupFile -PathType Leaf)) { throw 'Backup file is missing.' }
        $backupHash = (Get-FileHash -LiteralPath $backupFile -Algorithm SHA256 -ErrorAction Stop).Hash
        Copy-Item -LiteralPath $backupFile -Destination $restoredFile -ErrorAction Stop
        $restoredHash = (Get-FileHash -LiteralPath $restoredFile -Algorithm SHA256 -ErrorAction Stop).Hash
    }
    catch { $detail = $_.Exception.Message }
    $status = if (Test-LabHashMatch $originalHash $backupHash $restoredHash) { 'PASS' } else { 'FAIL' }
    [pscustomobject]@{ File=$relative; OriginalHash=$originalHash; BackupHash=$backupHash; RestoredHash=$restoredHash; Status=$status; Detail=$detail }
})
$status = if (@($rows | Where-Object Status -ne 'PASS').Count) { 'FAIL' } else { 'PASS' }
$report = [pscustomobject]@{
    GeneratedAt=(Get-Date -Format o)
    Checks=@(New-LabCheck 'Backup Verification' $status $rows 'Content verification only; not a snapshot, system image, ACL, alternate-stream or application-consistency backup. Keep inputs idle during the run.')
}
if ($Redact) { $report = Protect-LabObject $report }
Write-LabReport $report $run 'backup-verification'
# Paths stay out of the publishable report; callers can locate artifacts through this value.
$report | Add-Member -NotePropertyName ArtifactDirectory -NotePropertyValue $run
if ($FailOnMismatch -and $status -eq 'FAIL') { throw "Backup integrity verification failed. Review $run" }
$report
