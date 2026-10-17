# KB005 - Troubleshooting Windows Services

## Overview

Relate service configuration and dependencies to a specific affected function.

## Common Symptoms

Function unavailable, service stopped unexpectedly or repeated start failures.

## Likely Causes

Trigger-start behavior, dependencies, invalid configuration, account permissions or application failure.

## Diagnostic Commands

```powershell
.\scripts\Invoke-SupportDiagnostics.ps1 -Services
Get-Service -Name wuauserv | Format-List *
Get-CimInstance Win32_Service -Filter "Name='wuauserv'" | Select-Object Name,State,StartMode,ExitCode
```

## Troubleshooting Procedure

Confirm which service the affected function actually needs. Review expected startup behavior, dependencies and Service Control Manager events. A stopped automatic service is a lead, not proof of failure.

## Resolution

Apply only a confirmed, authorized repair. Record original state/startup configuration and rollback before starting or changing a service. Do not expose service credentials or disable security services.

## Verification

Check service state and repeat the consuming application's operation. Look for fresh errors; a running state alone is insufficient.

## Escalation Criteria

Repeated start failure, credential rotation, managed configuration, critical dependencies or changes affecting other users.

