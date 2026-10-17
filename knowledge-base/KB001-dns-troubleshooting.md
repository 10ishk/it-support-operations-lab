# KB001 - Troubleshooting DNS Resolution

## Overview

Separate a missing name from resolver reachability, caching and application issues.

## Common Symptoms

Names fail while an IP-based probe works; a timeout, negative answer or unexpected address.

## Likely Causes

Incorrect name, unreachable DNS server, stale cache, split DNS or a missing record.

## Diagnostic Commands

```powershell
Get-DnsClientServerAddress -AddressFamily IPv4
Resolve-DnsName -Name github.com -Type A -DnsOnly
Get-DnsClientCache
```

## Troubleshooting Procedure

Confirm the exact hostname. Inspect configured DNS servers and compare a known valid name with the failing name. Distinguish NXDOMAIN from timeout. Correlate with gateway and TCP tests. Preserve cache evidence before considering a cache clear.

## Resolution

Correct a mistyped name or have the responsible owner repair the confirmed record/settings. Do not replace managed DNS settings blindly. If an approved change is made, record the original values and restore them if the change fails.

## Verification

Repeat the same lookup and affected application request. A valid answer alone does not prove the application works.

## Escalation Criteria

Multiple machines fail, authoritative records appear wrong, managed DNS configuration is unclear or the issue persists after a verified local repair.

