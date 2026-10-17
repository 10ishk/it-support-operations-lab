# INC-007 - backup restore

- Incident ID: INC-007
- Date: 2026-10-17
- Category: Backup
- Priority: Low — controlled local scope
- Status: Completed content recovery; every file verified
- Environment: Windows 11; PowerShell 7; restricted execution. **RESTRICTED TO NON-DESTRUCTIVE SIMULATION**.

## Reported / Simulated Symptom

Recover the supplied harmless lab files into separate directories without deleting originals.

## Impact

Confined to the described lab probes, marked events and disposable resources. No organizational or production outage is claimed.

## Initial Observations

Source inventory contained 4 files, including the nested configuration.

## Diagnostic Steps

Existing backup script hashed originals, copied and hashed backup files, restored from those backups into a distinct directory, and hashed restored content. Complete per-file digests are published in observations.json.

## Commands Used

[Executed commands](../evidence/INC-007/commands.txt) and [reproducible runner](../scripts/Invoke-ControlledLab.ps1). Variables preserve the actual command sequence while withholding machine addresses and paths.

## Evidence

- [Selected actual observations](../evidence/INC-007/observations.json)
- [Sanitized output](../evidence/INC-007/sanitized-output.txt)
- [Evidence summary](../evidence/INC-007/evidence-summary.md)

Raw records remain ignored locally. These are selected measurements, not complete terminal transcripts.

## Root Cause

No unexpected fault occurred. This is recovery verification, not recovery from lost user data.

## Resolution

Created verified backup and restored copies using -FailOnMismatch and -Redact.

## Verification

Status=PASS; 4/4 files matched all three SHA-256 digests.

## Rollback / Cleanup

Copies remain only in ignored local run folders for inspection; none are published. Original inputs independently matched final hashes. No ACL, alternate-stream or application-consistency claim.

[Final cleanup verification](../evidence/cleanup-verification.json). [Screenshot capture limitations](../screenshots/AUTOMATION-NOTES.md).

## Knowledge Base Reference

[KB006](../knowledge-base/KB006-backup-integrity.md)
