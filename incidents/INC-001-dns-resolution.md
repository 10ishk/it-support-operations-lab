# INC-001 - dns resolution

- Incident ID: INC-001
- Date: 2026-10-17
- Category: DNS
- Priority: Low — controlled local scope
- Status: Completed controlled query failure; valid comparison verified
- Environment: Windows 11; PowerShell 7; restricted execution. **RESTRICTED TO NON-DESTRUCTIVE SIMULATION**.

## Reported / Simulated Symptom

The deliberately nonexistent support-lab.invalid query failed while the valid comparison worked.

## Impact

Confined to the described lab probes, marked events and disposable resources. No organizational or production outage is claimed.

## Initial Observations

The baseline network checks passed. Adapter DNS was inspected and retained.

## Diagnostic Steps

Native lookup error: DNS_ERROR_RCODE_NAME_ERROR,Microsoft.DnsClient.Commands.ResolveDnsName. Public ICMP responses: 1. github.com A records: 1. Native TCP 443: true. Project results for the invalid target were DNS FAIL and TCP UNAVAILABLE.

## Commands Used

[Executed commands](../evidence/INC-001/commands.txt) and [reproducible runner](../scripts/Invoke-ControlledLab.ps1). Variables preserve the actual command sequence while withholding machine addresses and paths.

## Evidence

- [Selected actual observations](../evidence/INC-001/observations.json)
- [Sanitized output](../evidence/INC-001/sanitized-output.txt)
- [Evidence summary](../evidence/INC-001/evidence-summary.md)

Raw records remain ignored locally. These are selected measurements, not complete terminal transcripts.

## Root Cause

The supplied name is deliberately in the reserved .invalid namespace. The valid comparison does not support a resolver outage.

## Resolution

Changed only the query target to github.com. No DNS settings were changed.

## Verification

All corrected-target project checks returned PASS. This establishes the comparison target, not every application.

## Rollback / Cleanup

No configuration change. End-of-run adapter/address/DNS/route snapshots matched.

[Final cleanup verification](../evidence/cleanup-verification.json). [Screenshot capture limitations](../screenshots/AUTOMATION-NOTES.md).

## Knowledge Base Reference

[KB001](../knowledge-base/KB001-dns-troubleshooting.md)
