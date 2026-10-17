#requires -Version 5.1
# These checks validate the consistency of selected records, not independent provenance.
Describe 'Published execution evidence consistency' {
    BeforeEach {
        $evidenceRoot = Join-Path $PSScriptRoot '..\evidence'
        . (Join-Path $PSScriptRoot '..\scripts\Private\Common.ps1')
    }
    It 'Contains complete command observation and summary artifacts for eight cases' {
        foreach ($number in 1..8) {
            $folder = Join-Path $evidenceRoot ('INC-{0:000}' -f $number)
            foreach ($name in @('commands.txt','observations.json','sanitized-output.txt','evidence-summary.md')) {
                if (-not (Test-Path -LiteralPath (Join-Path $folder $name) -PathType Leaf)) { throw 'Missing case artifact' }
            }
            $record = Get-Content -LiteralPath (Join-Path $folder 'observations.json') -Raw | ConvertFrom-Json
            if ([DateTimeOffset]$record.FinishedAt -lt [DateTimeOffset]$record.StartedAt) { throw 'Reversed incident timestamps' }
            if (($record | ConvertTo-Json -Depth 25 -Compress) -ne ((Get-Content -LiteralPath (Join-Path $folder 'sanitized-output.txt') -Raw | ConvertFrom-Json) | ConvertTo-Json -Depth 25 -Compress)) { throw 'Selected TXT and JSON disagree' }
        }
    }
    It 'Has a verified digest for every recorded backup file and a repaired real mismatch' {
        $backup = Get-Content -LiteralPath (Join-Path $evidenceRoot 'INC-007\observations.json') -Raw | ConvertFrom-Json
        if ($backup.Files.Count -ne $backup.SourceFileCount -or $backup.VerifiedFileCount -ne $backup.SourceFileCount -or $backup.Status -ne 'PASS') { throw 'Backup inventory/status disagrees' }
        foreach ($row in $backup.Files) {
            if (-not (Test-LabHashMatch $row.OriginalHash $row.BackupHash $row.RestoredHash)) { throw 'Published digest does not match' }
        }
        $integrity = Get-Content -LiteralPath (Join-Path $evidenceRoot 'INC-008\observations.json') -Raw | ConvertFrom-Json
        if ($integrity.ChangedHash -eq $integrity.OriginalHash -or -not $integrity.MismatchDetected) { throw 'No actual content difference recorded' }
        if (-not (Test-LabHashMatch $integrity.OriginalHash $integrity.BackupHash $integrity.RestoredHash) -or -not $integrity.FinalVerification) { throw 'Repair not verified' }
    }
    It 'Records the TCP transition and releases all changed temporary resources' {
        $tcp = Get-Content -LiteralPath (Join-Path $evidenceRoot 'INC-006\observations.json') -Raw | ConvertFrom-Json
        if (-not $tcp.Listening.TcpTestSucceeded -or $tcp.Stopped.TcpTestSucceeded -or -not $tcp.Restarted.TcpTestSucceeded -or $tcp.Cleanup.Connected) { throw 'TCP lifecycle evidence disagrees' }
        $cleanup = Get-Content -LiteralPath (Join-Path $evidenceRoot 'cleanup-verification.json') -Raw | ConvertFrom-Json
        foreach ($key in @('NetworkConfigurationUnchanged','CanonicalInputsUnchanged','ObservedServiceUnchanged','WorkloadRemoved','ListenerClosed','IntegrityRepairVerified')) {
            if ($cleanup.$key -ne $true) { throw "Cleanup not verified: $key" }
        }
        if ($cleanup.SystemConfigurationChangesMade -or $cleanup.SourcesRegistered) { throw 'Restricted scope violated in recorded evidence' }
    }
    It 'Does not misrepresent the service observation or empty event rendering' {
        $service = Get-Content -LiteralPath (Join-Path $evidenceRoot 'INC-005\observations.json') -Raw | ConvertFrom-Json
        if ($service.ConfirmedServiceFailure -or $service.ServiceCreated -or $service.ServiceStartedOrStopped -or -not $service.ConfigurationUnchanged) { throw 'Service fallback misrepresented' }
        $event = Get-Content -LiteralPath (Join-Path $evidenceRoot 'INC-003\observations.json') -Raw | ConvertFrom-Json
        if (-not $event.ErrorCollected -or -not $event.CompletionCollected) { throw 'Event pair not collected' }
        foreach ($record in $event.Events) {
            if ($record.Provider -ne 'PowerShell' -or $record.Log -ne 'Windows PowerShell' -or $record.EventDataMessage -notlike 'ITSupportLab*') { throw 'Unrelated event published' }
        }
    }
}
