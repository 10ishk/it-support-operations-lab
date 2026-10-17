# INC-004 - Storage or Performance Investigation

**Unexecuted guided exercise. Status: not started.** Category: performance. Use the [template](../templates/incident-template.md).

## Scenario and observation

Investigate a slow operation or establish a baseline in an idle VM. Do not fill the system disk, allocate excessive memory or run a stress loop. If there is no slowdown, record a baseline, not a resolved performance fault.

## Diagnostic steps and commands

```powershell
.\scripts\Invoke-SupportDiagnostics.ps1 -System -TopProcesses 10
Get-Volume | Select-Object DriveLetter,FileSystemLabel,Size,SizeRemaining
Get-Process | Sort-Object WorkingSet64 -Descending | Select-Object -First 10 Id,ProcessName,WorkingSet64,CPU
resmon.exe
```

Reproduce the normal affected task and compare measurements with idle values. Use Resource Monitor for current CPU, memory pressure, disk activity and response time. Script CPU values are cumulative seconds, so an old process can rank highly without consuming much CPU now. Low free disk space is a clue; it does not measure storage latency.

## Actual evidence

- Affected task, timing, VM CPU/memory allocation: <not recorded>
- Baseline and during-task observations: <not collected>
- Report/screenshot links: <not collected>
- Possible causes: resource pressure, low space, background activity or host contention; <unconfirmed>.

## Resolution and verification

Identify the owner of resource-heavy processes before closing anything. Review disposable files before manual cleanup and retain recoverable copies. Adjust VM resources only after recording original allocations. Repeat the same task and compare response time under similar conditions.

Rollback: read-only observation needs none; if changing VM allocation, restore the recorded values through the hypervisor. This exercise prescribes no deletion or service changes. Reference: [KB004](../knowledge-base/KB004-performance-troubleshooting.md).
