# INC-003 - application event error

- Incident ID: INC-003
- Date: 2026-10-17
- Category: Event logs
- Priority: Low — controlled local scope
- Status: Completed real test-event collection; completion event verified
- Environment: Windows 11; PowerShell 7; restricted execution. **RESTRICTED TO NON-DESTRUCTIVE SIMULATION**.

## Reported / Simulated Symptom

A clearly labeled controlled Error record was appended through an existing event source.

## Impact

Confined to the described lab probes, marked events and disposable resources. No organizational or production outage is claimed.

## Initial Observations

The PowerShell source already existed. The first preflight write succeeded but the rendered Message was empty; actual event properties/XML retained the marker.

## Diagnostic Steps

Collected the main case's Error 9001 and Information 9002 from Windows PowerShell, provider PowerShell, by matching the actual EventData marker. IDs were deliberately selected for writes and are the IDs actually read back. Their chosen provider IDs lack rendered message templates; no rendered message is invented. The preflight record is separately preserved in [preflight-event.json](../evidence/INC-003/preflight-event.json).

## Commands Used

[Executed commands](../evidence/INC-003/commands.txt) and [reproducible runner](../scripts/Invoke-ControlledLab.ps1). Variables preserve the actual command sequence while withholding machine addresses and paths.

## Evidence

- [Selected actual observations](../evidence/INC-003/observations.json)
- [Sanitized output](../evidence/INC-003/sanitized-output.txt)
- [Evidence summary](../evidence/INC-003/evidence-summary.md)

Raw records remain ignored locally. These are selected measurements, not complete terminal transcripts.

## Root Cause

The error entry is deliberate test injection, not an application defect. Empty Message is a provider-template limitation; EventData contains the written text.

## Resolution

Stopped generating test errors and appended a marked completion Information record. No failing application is claimed to have been repaired.

## Verification

ErrorCollected=true; CompletionCollected=true. Actual log, provider, IDs, levels, timestamps and EventData are published.

## Rollback / Cleanup

No source registration, logging-policy change or log clearing. Three marked records remain intentionally as audit evidence: a preflight Error and the main Error/Information pair. Individual records were not deleted.

[Final cleanup verification](../evidence/cleanup-verification.json). [Screenshot capture limitations](../screenshots/AUTOMATION-NOTES.md).

## Knowledge Base Reference

[KB003](../knowledge-base/KB003-windows-event-logs.md)
