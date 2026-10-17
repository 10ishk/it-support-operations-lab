# Output contract (illustrative, no diagnostic results)

A run can contain `system-health.json`, `system-health.txt`, `network-diagnostics.json`, `network-diagnostics.txt`, `event-errors.csv`, `services.csv`, `backup-verification.json`, `backup-verification.txt`, and `diagnostic-summary.html`.

Each check records `Name`, `Status`, `Data`, and `Detail`. Status values are PASS, WARNING, FAIL, INFO, or UNAVAILABLE. Unavailable data must never be treated as a successful check. The JSON root includes a generation timestamp and check records. Backup file rows contain relative names and three SHA-256 digests. PASS requires all three digests to match and at least one file.

There are intentionally no sample machine identifiers, network addresses, hashes, event records, or fabricated screenshots here. Generate real evidence with the [lab guide](../../docs/LAB-GUIDE.md).
