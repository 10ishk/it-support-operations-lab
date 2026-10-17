# INC-003 - Application / Windows Event-Log Error

**Unexecuted guided exercise. Status: not started.** Category: application. Use the [template](../templates/incident-template.md).

## Scenario and observation

Investigate an existing application error reported in the VM. Do not crash software or write artificial events to make evidence. If the selected window has no errors, record that no matching events were found and broaden the window only with a reason.

## Diagnostic steps and commands

```powershell
.\scripts\Invoke-SupportDiagnostics.ps1 -Events -Hours 24 -MaxEvents 100
Get-WinEvent -FilterHashtable @{LogName='Application'; Level=1,2; StartTime=(Get-Date).AddHours(-24)} -MaxEvents 20
eventvwr.msc
```

Record the application symptom and its timestamp first. In Event Viewer, correlate provider, event ID, timestamp and message with that symptom. Review nearby System events. An event ID without its provider/context is insufficient to identify the cause. Message text can contain private paths or input data.

## Actual evidence

- Symptom, time window, provider and event ID: <not collected>
- Sanitized message/report/screenshot links: <not collected>
- Correlation and competing explanations: <not investigated>
- Possible causes: application defect, missing dependency, access failure or resource pressure; none confirmed.

## Resolution and verification

Choose the least disruptive application-specific repair only after evidence supports it. Record the installed version and original settings first; use documented application rollback or the VM snapshot if repair changes configuration. Repeat the original application operation and query a fresh post-repair window. Old events remain in the log and do not by themselves show a repair failed.

Rollback: observation requires none; no generic repair is prescribed. Do not clear logs. Reference: [KB003](../knowledge-base/KB003-windows-event-logs.md).
