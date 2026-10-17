# INC-004 execution evidence

Captured: 2026-10-17.

Outcome: **Completed bounded workload; cleanup verified**.

A bounded PowerShell child consumed CPU while a two MiB disposable file existed.

ChildExited=true; TemporaryFileExists=false; CleanupVerified=true. Precise host memory measurements are withheld; background activity precludes diagnosing a memory leak from this comparison.

Cleanup: Owned child exited; workload directory absent. No recursive deletion, canonical input edit or resource-configuration change.

[Commands](commands.txt) · [Structured observations](observations.json) · [Sanitized output](sanitized-output.txt) · [Incident report](../../incidents/INC-004-storage-performance.md)

These are selected actual records, not a raw transcript. Identifiers, network addresses, unrelated messages and personal paths are omitted. Reproduction may yield different counts, timings, ports or digests. Backup content is not published.
