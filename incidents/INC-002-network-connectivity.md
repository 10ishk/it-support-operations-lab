# INC-002 - Network Connectivity Problem

**Unexecuted guided exercise. Status: not started.** Category: networking. Use the [template](../templates/incident-template.md) to record actual impact and environment.

## Scenario and safe simulation

A VM loses external connectivity. Use the VM's local console, take a snapshot if available, and record its current virtual NIC attachment. Disconnect only the disposable VM's virtual network cable using the hypervisor. Never disable the host's physical adapter or perform this through a remote session.

## Diagnostic steps and commands

Run once before disconnection and once after it:

```powershell
Get-NetAdapter
Get-NetIPConfiguration
Get-NetRoute -AddressFamily IPv4 -DestinationPrefix '0.0.0.0/0'
.\scripts\Invoke-NetworkDiagnostics.ps1 -OutputDirectory .\reports\connectivity-exercise
```

Expected logic: an absent usable link or configuration supports a local connectivity fault. If a link remains up, inspect routing and the virtual network mode. Failed ICMP alone does not establish an outage. Record which tests are unavailable and why; DNS cache may affect observations.

## Actual evidence

- Date, VM network mode, original attachment: <not recorded>
- Adapter, gateway, DNS and TCP findings before/after: <not collected>
- Report/screenshot links: <not collected>
- Possible cause: disconnected virtual cable; confirm from observations rather than assuming.

## Rollback, resolution and verification

Reconnect the same virtual NIC to its original virtual network in the hypervisor. Confirm the link and address return, then rerun the diagnostics and an intended application request. If renewal is needed, use the VM console and document the affected interface before requesting DHCP renewal. Restore the snapshot only if ordinary reconnection fails and losing later VM changes is acceptable.

Record restoration of the original attachment as part of closure. Reference: [KB002](../knowledge-base/KB002-network-connectivity.md).
