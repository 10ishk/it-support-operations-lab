# INC-006 - tcp port connectivity

- Incident ID: INC-006
- Date: 2026-10-17
- Category: TCP/application connectivity
- Priority: Low — controlled local scope
- Status: Completed controlled listener failure; recovery and cleanup verified
- Environment: Windows 11; PowerShell 7; restricted execution. **RESTRICTED TO NON-DESTRUCTIVE SIMULATION**.

## Reported / Simulated Symptom

The local TCP test failed after the loopback listener on dynamically selected port 59845 was stopped.

## Impact

Confined to the described lab probes, marked events and disposable resources. No organizational or production outage is claimed.

## Initial Observations

A temporary IPv4 loopback-only listener was started; no external listener or firewall change.

## Diagnostic Steps

Native Test-NetConnection returned success=true while listening, success=false after stopping, and success=true after rebinding the same port. localhost resolved to 2 addresses. Explicit IPv4 loopback prevented IPv6 selection from obscuring the comparison.

## Commands Used

[Executed commands](../evidence/INC-006/commands.txt) and [reproducible runner](../scripts/Invoke-ControlledLab.ps1). Variables preserve the actual command sequence while withholding machine addresses and paths.

## Evidence

- [Selected actual observations](../evidence/INC-006/observations.json)
- [Sanitized output](../evidence/INC-006/sanitized-output.txt)
- [Evidence summary](../evidence/INC-006/evidence-summary.md)

Raw records remain ignored locally. These are selected measurements, not complete terminal transcripts.

## Root Cause

The controlled listener was absent during the failed probe. Name resolution and TCP availability are separate conditions.

## Resolution

Restarted the lab-only listener on the same loopback port.

## Verification

Native TCP succeeded again. A bounded probe after final cleanup failed, confirming the listener was released.

## Rollback / Cleanup

Listener stopped in finally; CleanupVerified=true. This port is the observed ephemeral value, not a fixed production port.

[Final cleanup verification](../evidence/cleanup-verification.json). [Screenshot capture limitations](../screenshots/AUTOMATION-NOTES.md).

## Knowledge Base Reference

[KB002](../knowledge-base/KB002-network-connectivity.md)
