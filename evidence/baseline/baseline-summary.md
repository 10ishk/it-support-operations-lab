# Baseline summary

Captured: 2026-10-17, using the existing entry point with -Full -Redact.

This is an actual measured baseline, **not a declaration that the workstation is entirely healthy**. Existing warnings are retained and were not repaired speculatively.

- OS: Windows 11.
- Memory: utilization within the configured threshold (PASS).
- Storage: one volume triggered the configured low-space warning. No disk-fill test or cleanup was performed.
- Windows Update: Stopped, startup Manual. State alone does not establish update health.
- Automatic services requiring investigation were detected; these are leads, not confirmed failures.
- Events: System and Application critical/error observations triggered WARNING. Full messages are withheld; no causal claim is made.
- Backup: 4 files, all original/backup/restored hashes matched.

| Check | Actual status |
| --- | --- |
| System Overview | INFO |
| System Health - Memory | PASS |
| Storage | WARNING |
| Processes | INFO |
| Network Adapter Status | INFO |
| Services | WARNING |
| Windows Update Service | INFO |
| Event Logs - System | WARNING |
| Event Logs - Application | WARNING |
| Adapter Configuration | PASS |
| Default Gateway | PASS |
| Internet Connectivity | PASS |
| DNS Resolution | PASS |
| TCP 80 | PASS |
| TCP 443 | PASS |
| Backup Verification | PASS |

[Environment classification](environment-check.txt) · [Selected observations](observations.json) · [Commands](commands.txt) · [Selected output](sanitized-output.txt)

Machine names, addresses, volume identifiers, user paths, MAC addresses, account details and unrelated event text were excluded. Raw TXT/JSON/CSV/HTML and copied lab data remain in ignored report directories. The publishable baseline contains only selected useful fields.
