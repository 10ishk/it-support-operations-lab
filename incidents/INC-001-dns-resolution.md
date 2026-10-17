# INC-001 - DNS Resolution Failure

**Unexecuted guided exercise. Status: not started.** Category: DNS. Set date, priority, environment and impact in a copy of the [template](../templates/incident-template.md).

## Scenario and symptom

A name fails to resolve while IP connectivity may work. Safely reproduce a failed query using the reserved `.invalid` namespace. This is a deliberate nonexistent-name query, not evidence of a broken DNS service. No adapter configuration change is needed.

## Diagnostic steps and commands

```powershell
Get-DnsClientServerAddress -AddressFamily IPv4
Resolve-DnsName -Name support-lab.invalid -Type A -DnsOnly
Resolve-DnsName -Name github.com -Type A -DnsOnly
.\scripts\Invoke-NetworkDiagnostics.ps1 -Target support-lab.invalid -OutputDirectory .\reports\dns-exercise
```

Expected logic: failure for `.invalid` is intentional; success for the comparison target establishes that the resolver can answer that query. If both fail, inspect configured servers and gateway reachability before changing anything. A negative answer and a timeout have different meanings.

## Actual evidence

- Environment/time/impact: <record after execution>
- Exact error and comparison result: <not collected>
- Report and screenshot links: <not collected>
- Root cause: <unconfirmed; distinguish nonexistent name from resolver failure>

## Resolution and verification

For the controlled case, correct the query to the intended valid hostname and rerun the lookup and application connection. For a real resolver fault, confirm the intended DNS settings with the network owner before making a change. Avoid changing DNS on the host for this exercise. Record before/after observations; do not imply that correcting a test name repaired a network.

Rollback: none; all commands are read-only. Reference: [KB001](../knowledge-base/KB001-dns-troubleshooting.md).
