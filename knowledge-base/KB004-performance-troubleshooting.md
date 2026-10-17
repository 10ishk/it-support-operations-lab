# KB004 - Diagnosing CPU, Memory, and Disk Problems

## Overview

Collect snapshots and compare them with resource activity during the affected task.

## Common Symptoms

Slow response, high memory usage, low disk space or sustained CPU/disk activity.

## Likely Causes

Workload demand, background activity, low free space, memory pressure or VM host contention.

## Diagnostic Commands

```powershell
.\scripts\Invoke-SystemHealth.ps1 -TopProcesses 10
Get-Volume | Select-Object DriveLetter,Size,SizeRemaining
resmon.exe
```

## Troubleshooting Procedure

Record the affected operation and duration. Compare idle and active observations. Use Resource Monitor for current CPU and disk response time. Toolkit CPU is cumulative seconds; memory is a snapshot, and free capacity is not I/O latency.

## Resolution

Close only known disposable work after saving it. Review cleanup candidates manually. Coordinate resource or application changes and preserve original configuration. Do not use indiscriminate process termination or disk-fill tests.

## Verification

Repeat the same task under similar conditions, compare duration and resource pressure, and confirm no new errors.

## Escalation Criteria

Persistent memory pressure, storage errors, unexplained high latency, unknown processes or host-level resource contention.

