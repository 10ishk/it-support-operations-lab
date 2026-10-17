# KB003 - Investigating Windows Event Logs

## Overview

Use event context and timing to support an observed symptom.

## Common Symptoms

Application failure, service start error or recurring System/Application critical/error entries.

## Likely Causes

Application defects, missing dependencies, permissions, device problems or resource pressure.

## Diagnostic Commands

```powershell
.\scripts\Invoke-SupportDiagnostics.ps1 -Events -Hours 24 -MaxEvents 100
eventvwr.msc
```

## Troubleshooting Procedure

Record symptom time and timezone. Filter by log, provider, severity and a narrow window. Read the full message, correlate related events and check reproducibility. The toolkit caps records per log; broaden the window/cap deliberately if needed.

## Resolution

Use the application or device owner's documented repair for the confirmed cause. Preserve logs; do not clear them to hide an error. Record rollback before any repair.

## Verification

Repeat the failing operation and inspect a fresh time window. Old entries remain after repair. No matching events and access denied are different findings.

## Escalation Criteria

Repeated crashes, disk/controller errors, suspected security events, inaccessible logs or a repair needing vendor assistance.

