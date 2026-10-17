# KB002 - Troubleshooting Windows Network Connectivity

## Overview

Work from link and addressing through routing, name resolution and the application port.

## Common Symptoms

No usable link/address, missing gateway, DNS failure or a TCP timeout.

## Likely Causes

Disconnected virtual cable, DHCP failure, APIPA, routing problems, filtering, proxy requirements or a stopped listener.

## Diagnostic Commands

```powershell
Get-NetAdapter
Get-NetIPConfiguration
Get-NetRoute -AddressFamily IPv4 -DestinationPrefix '0.0.0.0/0'
.\scripts\Invoke-NetworkDiagnostics.ps1 -Target github.com -Ports 443
```

## Troubleshooting Procedure

Confirm scope and VM network mode. Verify IPv4 address/prefix, DHCP, gateway and DNS. Probe the discovered gateway and selected public target, then resolve the application name and test its port. ICMP filtering can make ping inconclusive.

## Resolution

Reconnect the intended link or repair the specific confirmed configuration with its owner. Save original settings and rollback steps before changes. Avoid firewall disablement or broad network resets.

## Verification

Repeat network tests and the original application operation. A TCP connection proves a listener is reachable, not that TLS, HTTP or authentication succeeds.

## Escalation Criteria

Several devices fail, routing/firewall changes are needed, managed proxy/VPN behavior is involved or packet capture is required.

