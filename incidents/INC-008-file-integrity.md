# INC-008 - file integrity

- Incident ID: INC-008
- Date: 2026-10-17
- Category: File integrity
- Priority: Low — controlled local scope
- Status: Completed mismatch detection; matching content restored
- Environment: Windows 11; PowerShell 7; restricted execution. **RESTRICTED TO NON-DESTRUCTIVE SIMULATION**.

## Reported / Simulated Symptom

Appended one deliberate lab line to a restored disposable notes.txt copy.

## Impact

Confined to the described lab probes, marked events and disposable resources. No organizational or production outage is claimed.

## Initial Observations

Copied canonical text into an ignored disposable source; existing backup script confirmed the initial restored digest matched.

## Diagnostic Steps

Original SHA-256: `5B8FD4D33015D4806F79FE2E2236EFD3CA906CE0333CB96E31CF38FC37D7672B`.

Changed SHA-256: `CC43AB44578F3295D38C11249854C1554CC44157863DF0B0F6D0A2AD9AAB99C5`.

Restored SHA-256: `5B8FD4D33015D4806F79FE2E2236EFD3CA906CE0333CB96E31CF38FC37D7672B`.

Mismatch measured at 2026-10-17; repair measured at 2026-10-17.

## Commands Used

[Executed commands](../evidence/INC-008/commands.txt) and [reproducible runner](../scripts/Invoke-ControlledLab.ps1). Variables preserve the actual command sequence while withholding machine addresses and paths.

## Evidence

- [Selected actual observations](../evidence/INC-008/observations.json)
- [Sanitized output](../evidence/INC-008/sanitized-output.txt)
- [Evidence summary](../evidence/INC-008/evidence-summary.md)

Raw records remain ignored locally. These are selected measurements, not complete terminal transcripts.

## Root Cause

The explicit appended line changed the disposable restored content. The mismatch does not establish malware or storage failure.

## Resolution

Copied the verified backup over the changed restore in finally, then calculated a fresh hash.

## Verification

MismatchDetected=true; FinalVerification=true. Original, backup and repaired restore digests matched.

## Rollback / Cleanup

The deliberate edit was reversed. Only ignored disposable copies remain locally. Canonical lab-data was never edited and independently matched final hashes.

[Final cleanup verification](../evidence/cleanup-verification.json). [Screenshot capture limitations](../screenshots/AUTOMATION-NOTES.md).

## Knowledge Base Reference

[KB006](../knowledge-base/KB006-backup-integrity.md)
