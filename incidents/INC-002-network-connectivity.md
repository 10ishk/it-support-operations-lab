# INC-002 - network connectivity

- Incident ID: INC-002
- Date: 2026-10-17
- Category: Networking
- Priority: Low — controlled local scope
- Status: Completed destination/port failure; healthy comparison verified
- Environment: Windows 11; PowerShell 7; restricted execution. **RESTRICTED TO NON-DESTRUCTIVE SIMULATION**.

## Reported / Simulated Symptom

A bounded TCP connection to a documentation-only destination on port 65000 timed out.

## Impact

Confined to the described lab probes, marked events and disposable resources. No organizational or production outage is claimed.

## Initial Observations

Local IP configuration and routes were collected locally; published evidence omits addresses and interface identifiers.

## Diagnostic Steps

Route selection succeeded: true. ICMP response count: 1. Controlled TCP Connected=false, Error="Connection timed out" with a 750 ms deadline. All five valid-target comparison checks passed.

## Commands Used

[Executed commands](../evidence/INC-002/commands.txt) and [reproducible runner](../scripts/Invoke-ControlledLab.ps1). Variables preserve the actual command sequence while withholding machine addresses and paths.

## Evidence

- [Selected actual observations](../evidence/INC-002/observations.json)
- [Sanitized output](../evidence/INC-002/sanitized-output.txt)
- [Evidence summary](../evidence/INC-002/evidence-summary.md)

Raw records remain ignored locally. These are selected measurements, not complete terminal transcripts.

## Root Cause

The selected TCP endpoint did not respond before the deadline. The remote routing/filtering/listener cause is unconfirmed. ICMP did respond, so a blanket assertion that the destination was unreachable would be wrong.

## Resolution

Stopped using the deliberately selected failing destination; compared the intended valid application target. No adapter or route repair was needed.

## Verification

Configuration, gateway, public ICMP, DNS and comparison TCP 443 all passed. A destination/port failure can coexist with working local connectivity.

## Rollback / Cleanup

Read-only probes only. Final network snapshots matched.

[Final cleanup verification](../evidence/cleanup-verification.json). [Screenshot capture limitations](../screenshots/AUTOMATION-NOTES.md).

## Knowledge Base Reference

[KB002](../knowledge-base/KB002-network-connectivity.md)
