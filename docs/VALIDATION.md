# Validation record

Development validation is performed on Windows using the included `tests/Invoke-Validation.ps1` runner. This document summarizes checks; raw host reports are ignored and are not published as lab evidence.

## Completed on 2026-10-17

| Check | Actual result |
| --- | --- |
| Windows PowerShell 5.1, Pester 3 | 12 passed, 0 failed |
| PowerShell 7, Pester 3 | 12 passed, 0 failed |
| PowerShell parser, both shells | All scripts parsed without syntax errors |
| Repository-relative Markdown links | All resolved after excluding code examples |
| Real full collection, both shells | Completed system, process, network, event, service and backup checks; warnings preserved |
| Full-run report files | Nine expected top-level files; JSON parsed successfully |
| Current-identity redaction | Current computer, username and home path absent from top-level report content |
| Events/Services selection | Did not collect unrelated system overview |
| Reserved nonexistent DNS name | DNS FAIL with TCP skipped as UNAVAILABLE |
| Backup inputs | All four supplied files matched original, backup and restored SHA-256 |
| Repository content review | No prohibited purpose references, current machine identifiers, personal paths or recognized credential patterns found |
| Ignore rules | Generated report and screenshot paths ignored; guidance retained |

The 5.1 run exposed an inaccessible process CPU-time field during development. Collection now tolerates unavailable per-process metrics instead of discarding the entire process list. HTML tests accept either HTML entity escaping or the 5.1 JSON serializer's Unicode escaping. No actual machine values or event messages are reproduced here.

## Reproduce

```powershell
.\tests\Invoke-Validation.ps1
# Optional real collection; sends DNS, ICMP and TCP probes to documented targets:
.\tests\Invoke-Validation.ps1 -Live
```

The runner parses every PowerShell script, resolves repository-relative Markdown links, and runs Pester tests. `-Live` additionally collects a redacted full run, checks the nine output artifacts and JSON parsing, searches for the current user/computer/home in published report content, verifies Events/Services selection, and queries a reserved nonexistent DNS name to verify failed DNS and skipped TCP behavior.

## Scope

The focused tests exercise valid/mismatched/missing hashes, unavailable provider results, nested redaction, array/null preservation, unique directories, escaped HTML, caller-only path exclusion, nested/wildcard-like file names, unchanged inputs, later restore modification, empty sources, overlapping paths, copy errors and junction rejection. Test inputs are synthetic fixtures, never diagnostic evidence.

Runtime observations do not prove behavior on every Windows build, permissions context, VPN/proxy environment or IPv6-only network. CI is configured to repeat tests with Pester 5 on both Windows shells. Guided fault exercises, VM rollback and screenshots must still be performed in the intended disposable VM. No fabricated evidence is substituted for those activities.
