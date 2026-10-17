# INC-005 - Windows Service Failure

**Unexecuted guided exercise. Status: not started.** Category: services. Use the [template](../templates/incident-template.md).

## Scenario and observation

An expected function appears unavailable. Investigate service state without stopping services or changing startup types. Stopped automatic services may use triggers or delayed startup and are not automatically broken. Do not stop security, update, storage or network services to manufacture a fault.

## Diagnostic steps and commands

```powershell
.\scripts\Invoke-SupportDiagnostics.ps1 -Services
Get-Service -Name wuauserv | Format-List Name,Status,StartType,ServicesDependedOn,DependentServices
Get-CimInstance Win32_Service -Filter "Name='wuauserv'" | Select-Object Name,State,StartMode,ExitCode
Get-WinEvent -FilterHashtable @{LogName='System'; ProviderName='Service Control Manager'; StartTime=(Get-Date).AddHours(-24)} -MaxEvents 30
```

`wuauserv` is an observation example, not an instruction to keep it running. For an actual affected service, substitute its verified name. Correlate events, dependencies and application symptoms. Inspect credentials locally if relevant; never include them in evidence.

## Actual evidence

- Affected function/service and expected state: <not established>
- Startup configuration, dependency states, exit code and events: <not collected>
- Report/screenshot links: <not collected>
- Possible causes: trigger behavior, dependency failure, invalid configuration or permission issue; <unconfirmed>.

## Resolution and verification

Only start or reconfigure a service after confirming expected behavior and authorization. Record the original state/configuration, apply the documented fix, and test the consuming application. A running service alone does not prove recovery. Escalate repeated start failures with sanitized event details.

Rollback: no changes in this exercise. Any separately authorized repair must document how to restore original configuration before it is attempted. Reference: [KB005](../knowledge-base/KB005-windows-services.md).
