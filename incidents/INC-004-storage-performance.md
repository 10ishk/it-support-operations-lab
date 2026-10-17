# INC-004 - storage performance

- Incident ID: INC-004
- Date: 2026-10-17
- Category: Performance
- Priority: Low — controlled local scope
- Status: Completed bounded workload; cleanup verified
- Environment: Windows 11; PowerShell 7; restricted execution. **RESTRICTED TO NON-DESTRUCTIVE SIMULATION**.

## Reported / Simulated Symptom

A bounded PowerShell child consumed CPU while a two MiB disposable file existed.

## Impact

Confined to the described lab probes, marked events and disposable resources. No organizational or production outage is claimed.

## Initial Observations

Memory, volume and filesystem-drive observations were collected; precise host measurements are withheld. No whole-machine slowdown or disk exhaustion was asserted.

## Diagnostic Steps

CPU activity was observed in the owned child while the two MiB disposable file existed. The child completed its approximately three-second bounded workload.

## Commands Used

[Executed commands](../evidence/INC-004/commands.txt) and [reproducible runner](../scripts/Invoke-ControlledLab.ps1). Variables preserve the actual command sequence while withholding machine addresses and paths.

## Evidence

- [Selected actual observations](../evidence/INC-004/observations.json)
- [Sanitized output](../evidence/INC-004/sanitized-output.txt)
- [Evidence summary](../evidence/INC-004/evidence-summary.md)

Raw records remain ignored locally. These are selected measurements, not complete terminal transcripts.

## Root Cause

The explicitly launched workload explains its own resource use. A baseline warning on a small low-free-space volume does not establish a performance root cause.

## Resolution

Allowed the child to finish; finally removed only the generated leaf files and empty workload directory.

## Verification

ChildExited=true; TemporaryFileExists=false; CleanupVerified=true. Precise host memory measurements are withheld; background activity precludes diagnosing a memory leak from this comparison.

## Rollback / Cleanup

Owned child exited; workload directory absent. No recursive deletion, canonical input edit or resource-configuration change.

[Final cleanup verification](../evidence/cleanup-verification.json). [Screenshot capture limitations](../screenshots/AUTOMATION-NOTES.md).

## Knowledge Base Reference

[KB004](../knowledge-base/KB004-performance-troubleshooting.md)
