# INC-008 - File Integrity Verification

**Unexecuted guided exercise. Status: not started.** Category: integrity. Use the [template](../templates/incident-template.md).

## Scenario and safe simulation

Demonstrate how a content change appears in SHA-256 verification. Run INC-007 first; modify only its restored disposable text file. The existing report describes the earlier verification time and will not automatically change when a file is later edited.

```powershell
$result = .\scripts\Invoke-BackupRestoreTest.ps1 -FailOnMismatch
$original = Join-Path $PWD 'lab-data\notes.txt'
$backup = Join-Path $result.ArtifactDirectory 'backup\notes.txt'
$restored = Join-Path $result.ArtifactDirectory 'restore\notes.txt'
Get-FileHash -LiteralPath $original,$backup,$restored -Algorithm SHA256
Add-Content -LiteralPath $restored -Value 'Controlled lab modification.'
$beforeRepair = Get-FileHash -LiteralPath $original,$backup,$restored -Algorithm SHA256
$beforeRepair | Format-List Path,Hash
```

## Diagnostic logic and actual evidence

The newly calculated restored digest should differ after the edit. Confirm it from actual output. A mismatch proves different content, not malware or the cause of the difference.

- Date, baseline digests and post-edit digests: <not collected>
- Report/screenshot links: <not collected>
- Confirmed cause: <record only after observing the deliberate edit and mismatch>
- Impact: disposable restored copy only; <confirm original remained unchanged>.

## Resolution, verification and rollback

Restore only the modified disposable copy from the backup and calculate fresh hashes:

```powershell
Copy-Item -LiteralPath $backup -Destination $restored -Force
$afterRepair = Get-FileHash -LiteralPath $original,$backup,$restored -Algorithm SHA256
$afterRepair | Format-List Path,Hash
@($afterRepair.Hash | Select-Object -Unique).Count -eq 1
```

Record the actual comparison result and open the restored text. Keep the original run report plus separately timestamped mismatch/repair observations. Rollback is the copy command above; no original input is changed. Reference: [KB006](../knowledge-base/KB006-backup-integrity.md).
