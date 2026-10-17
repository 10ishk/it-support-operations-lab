# Executed controlled incidents

These reports document actual execution on 2026-10-17 using isolated resources in a Windows environment. Execution was **RESTRICTED TO NON-DESTRUCTIVE SIMULATION**. The service case is a completed observation fallback; it does not claim a service failure was induced. Each report links selected actual evidence and states what the observations do and do not establish.

Use the [runner](../scripts/Invoke-ControlledLab.ps1) to reproduce the safe scenarios and the [incident template](../templates/incident-template.md) for a new dated record. Do not present an earlier run's observations as a fresh measurement. [Execution results](../docs/EXECUTION-RESULTS.md) and [evidence index](../evidence/README.md) explain scope and privacy.

| Exercise | Focus |
| --- | --- |
| [INC-001](INC-001-dns-resolution.md) | DNS resolution |
| [INC-002](INC-002-network-connectivity.md) | Network configuration and routing |
| [INC-003](INC-003-application-event-error.md) | Application event investigation |
| [INC-004](INC-004-storage-performance.md) | Storage and performance |
| [INC-005](INC-005-service-failure.md) | Windows service state |
| [INC-006](INC-006-tcp-port-connectivity.md) | TCP connection failure |
| [INC-007](INC-007-backup-restore.md) | Backup and restore |
| [INC-008](INC-008-file-integrity.md) | Controlled content mismatch |

Record Problem → Diagnostics → Evidence → Root Cause → Resolution → Verification → Documentation. Do not mark an incident resolved until the original symptom has been retested. If a fault is absent, record that finding instead of inventing one.
