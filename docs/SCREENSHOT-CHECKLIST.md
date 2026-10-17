# Real Windows screenshot checklist

No screenshots are provided. Capture these from your actual disposable Windows VM after running the commands. Use readable text and include the relevant command/result or provider/event context. A failed test is valid evidence only if it actually occurred.

| # | Capture | How / when | Destination |
| --- | --- | --- | --- |
| 1 | Main diagnostic summary | Run `Invoke-SupportDiagnostics.ps1 -Full -Redact` and capture status table | `screenshots/system-health/` |
| 2 | Local HTML overview | Open the generated `diagnostic-summary.html`; capture selected sections | `screenshots/system-health/` |
| 3 | IP configuration | `Get-NetIPConfiguration`, crop unrelated interfaces | `screenshots/networking/` |
| 4 | DNS failure | INC-001 actual `.invalid` query error; label controlled query | `screenshots/networking/` |
| 5 | DNS success comparison | INC-001 valid target lookup; explain corrected query | `screenshots/networking/` |
| 6 | Gateway probe | Actual discovered gateway test from network report | `screenshots/networking/` |
| 7 | TCP 443 probe | Network diagnostics for selected target; capture actual status | `screenshots/networking/` |
| 8 | Application error context | Event Viewer provider, ID, time and sanitized message, if one exists | `screenshots/event-viewer/` |
| 9 | Service investigation | `Get-Service` and related event/state from INC-005 | `screenshots/incidents/` |
| 10 | Resource investigation | Resource Monitor during normal affected task | `screenshots/system-health/` |
| 11 | Backup run | Actual backup script status and file count | `screenshots/backup/` |
| 12 | Original digests | Actual original SHA-256 fields using `Format-List` | `screenshots/backup/` |
| 13 | Restored digests | Corresponding restored fields, relative names visible | `screenshots/backup/` |
| 14 | Integrity verification | Actual all-file status and INC-008 mismatch/repair comparison | `screenshots/backup/` |

Use names such as `INC-001-dns-failure-<actual-date>.png`. Record capture date/timezone and evidence links in the incident. If no event exists, record that observation and omit the error screenshot. Do not fabricate or edit a result to look successful. Additional before/after network/loopback captures may be useful.

Crop or blur account names, prompt paths, computer/domain names, IP addresses if sensitive, MAC addresses, notifications and unrelated windows. Review full event messages for user paths/data. Keep enough context to interpret the check. `-Redact` affects script data, not terminal prompts or screenshots. Screenshots are ignored; explicitly add only individually reviewed files.
