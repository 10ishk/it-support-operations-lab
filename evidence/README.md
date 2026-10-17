# Actual lab execution evidence

These files were produced by commands executed on 2026-10-17. Public evidence retains dates only; precise times and timezone are withheld. No screenshots, results, digests or event records were invented.

Execution was classified **RESTRICTED TO NON-DESTRUCTIVE SIMULATION**. Isolation refers to temporary resources and copied files; no broader system-isolation claim is made.

[Baseline](baseline/baseline-summary.md) · [Cleanup](cleanup-verification.json) · [Execution results](../docs/EXECUTION-RESULTS.md)

| Case | Actual outcome |
| --- | --- |
| [INC-001](INC-001/evidence-summary.md) | Completed controlled query failure; valid comparison verified |
| [INC-002](INC-002/evidence-summary.md) | Completed destination/port failure; healthy comparison verified |
| [INC-003](INC-003/evidence-summary.md) | Completed real test-event collection; completion event verified |
| [INC-004](INC-004/evidence-summary.md) | Completed bounded workload; cleanup verified |
| [INC-005](INC-005/evidence-summary.md) | Completed read-only fallback; no service failure induced or confirmed |
| [INC-006](INC-006/evidence-summary.md) | Completed controlled listener failure; recovery and cleanup verified |
| [INC-007](INC-007/evidence-summary.md) | Completed content recovery; every file verified |
| [INC-008](INC-008/evidence-summary.md) | Completed mismatch detection; matching content restored |

Each incident folder includes commands.txt, observations.json, sanitized-output.txt and evidence-summary.md. Commands record the actual sequence with variable names where values are withheld; observations are allowlisted values, not a verbatim transcript. Human-readable conclusions distinguish confirmed facts from limits. The service case uses the authorized read-only fallback; no service failure was induced.

Raw evidence is retained locally under ignored reports/lab-execution and timestamped reports folders. The required environment-check.txt there is raw and ignored; its minimal sanitized counterpart is in baseline/. Backup copies themselves are never published. Event IDs 9001 and 9002 were deliberately chosen for clearly marked real test writes through an existing provider; the collected EventData, not unavailable formatted message text, is published. One preflight event is documented separately.

Reproduce from the repository root with:

```powershell
.\scripts\Invoke-ControlledLab.ps1
```

The runner does not change DNS, routes, services, firewall or security settings. It appends marked audit events, probes the network, creates bounded local resources and retains disposable copied data locally. Review the script first. Raw runs receive unique directories; selected evidence is replaced on rerun, so preserve the dated incident reports and regenerate/review their conclusions when running again. Results may differ; a missing or failed verification must not be reported as success.

[Manual screenshot requirements](../screenshots/AUTOMATION-NOTES.md). No images were created because the attempted native viewer automation lacked reliable input geometry.
