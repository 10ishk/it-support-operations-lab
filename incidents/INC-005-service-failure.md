# INC-005 - service failure

- Incident ID: INC-005
- Date: 2026-10-17
- Category: Services
- Priority: Low — controlled local scope
- Status: Completed read-only fallback; no service failure induced or confirmed
- Environment: Windows 11; PowerShell 7; restricted execution. **RESTRICTED TO NON-DESTRUCTIVE SIMULATION**.

## Reported / Simulated Symptom

An existing stopped service was observed; no service failure was induced or confirmed.

## Impact

Confined to the described lab probes, marked events and disposable resources. No organizational or production outage is claimed.

## Initial Observations

wuauserv: State=Stopped, StartMode=Manual, ExitCode=0. The restricted execution scope excluded temporary service creation.

## Diagnostic Steps

Get-Service agreed with CIM. The project collector reported other stopped automatic services as WARNING and Windows Update as INFO. This manual service was not included in the stopped-automatic-service list.

## Commands Used

[Executed commands](../evidence/INC-005/commands.txt) and [reproducible runner](../scripts/Invoke-ControlledLab.ps1). Variables preserve the actual command sequence while withholding machine addresses and paths.

## Evidence

- [Selected actual observations](../evidence/INC-005/observations.json)
- [Sanitized output](../evidence/INC-005/sanitized-output.txt)
- [Evidence summary](../evidence/INC-005/evidence-summary.md)

Raw records remain ignored locally. These are selected measurements, not complete terminal transcripts.

## Root Cause

No service failure was established. Manual/trigger behavior is a possible explanation, not a confirmed cause. No affected update operation was tested, so update health remains unproven.

## Resolution

No service repair was justified; preserved state/configuration. This completes the authorized read-only fallback, not a manufactured service failure.

## Verification

Before/after ConfigurationUnchanged=true; IncludedInStoppedAutomaticList=false. No service was created, started or stopped.

## Rollback / Cleanup

Service state/configuration matched both immediately after the case and at final verification. An induced service-failure case remains outside this restricted run.

[Final cleanup verification](../evidence/cleanup-verification.json). [Screenshot capture limitations](../screenshots/AUTOMATION-NOTES.md).

## Knowledge Base Reference

[KB005](../knowledge-base/KB005-windows-services.md)
