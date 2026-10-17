# INC-006 - TCP Port / Application Connectivity Problem

**Unexecuted guided exercise. Status: not started.** Category: TCP. Use the [template](../templates/incident-template.md).

## Scenario and controlled simulation

Compare a local listener with the same port after it is stopped. This uses an automatically selected loopback port; it exposes nothing on external interfaces and needs no firewall changes. Use a separate console for the test. Keep the listener console open until cleanup completes.

```powershell
# Listener console: record the displayed port for the test console.
$listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Loopback,0)
$listener.Start()
$listener.LocalEndpoint.Port
```

```powershell
# Test console: enter the actual displayed port.
$labPort = [int](Read-Host 'Loopback port displayed by the listener')
Test-NetConnection -ComputerName localhost -Port $labPort
```

## Rollback and diagnostic logic

In the listener console run `$listener.Stop()` immediately after the first test. Repeat the test against the same port. Record actual results; another process could acquire that port, and localhost can resolve to IPv6 first. If needed, use `[System.Net.IPAddress]::Loopback.ToString()` as the computer name to select IPv4. Always stop the listener, even if a test errors; closing its PowerShell process also releases it.

For a real external issue run `.\scripts\Invoke-NetworkDiagnostics.ps1 -Target github.com -Ports 443`. DNS success plus TCP failure narrows the problem to reachability, filtering, listener state or routing; it does not identify which one. No TLS or HTTP exchange is tested.

## Actual evidence and resolution

- Chosen port, timestamps, before/after results: <not collected>
- Report/screenshot links: <not collected>
- Root cause in controlled case: <confirm absence/presence of listener from actual observations>
- Resolution: for the exercise, explain the expected closed port after cleanup. For a real service, verify listener/configuration with its owner, then retest TCP and application behavior.

Reference: [KB002](../knowledge-base/KB002-network-connectivity.md).
