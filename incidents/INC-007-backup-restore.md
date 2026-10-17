# INC-007 - Backup and Restore Case

**Unexecuted guided exercise. Status: not started.** Category: backup. Use the [template](../templates/incident-template.md).

## Scenario and safe exercise

Prove that disposable lab files can be copied and recovered into a different directory. Do not delete source files or simulate a disaster on the host.

```powershell
$result = .\scripts\Invoke-BackupRestoreTest.ps1 -FailOnMismatch
$result.Checks | Select-Object Name,Status
$result.Checks[0].Data | Format-Table File,OriginalHash,BackupHash,RestoredHash,Status
Invoke-Item $result.ArtifactDirectory
```

## Diagnostic logic

The script calculates original hashes, creates a unique run directory, copies and hashes backup content, restores from that backup, and hashes restored content. Inspect the TXT/JSON report and open a restored text file. PASS requires every file to match across all three hashes. An empty source is rejected. Access/copy/hash errors cannot yield PASS.

## Actual evidence

- File count and source description: <not collected>
- Run date, backup/restore relative paths: <not recorded>
- Hash table, status, readable restored content: <not collected>
- Report/screenshot links: <not collected>
- Root cause if a failure occurs: <unconfirmed; investigate errors before retrying>.

## Resolution, verification and rollback

If verification fails, keep the failed report, examine path/space/access issues, and rerun into a fresh directory after repair. Do not overwrite a failed run. Compare file count and every relative name, not just one matching hash.

Rollback: originals are unchanged. After evidence review, manually remove only the identified generated run directory if no longer needed. This is a content-copy exercise, not a system recovery or metadata backup. Reference: [KB006](../knowledge-base/KB006-backup-integrity.md).
