# Screenshot automation notes

On 2026-10-17 the native computer-use runtime initialized successfully and returned an evidence-viewer window. Opening the viewer restored unrelated existing tabs, which were not captured or published. An attempt to select the File menu to isolate a new evidence window failed with **coordinate input geometry is unavailable**. No successful edit, screenshot capture, crop or image publication followed. Existing document contents were left untouched.

No publishable screenshots were captured. No console output, Event Viewer screen or diagnostic image was synthesized. Actual command outputs under [evidence](../evidence/README.md) are the authoritative artifacts for this run.

The following views still require manual capture from actual execution or the saved selected evidence:

1. Full diagnostic console status table and actual local HTML report.
2. Controlled invalid DNS error and valid comparison lookup.
3. Destination-specific TCP failure alongside successful comparison checks.
4. Marked event properties/XML: log, provider, actual IDs, timestamps, level and EventData. The chosen IDs have no rendered Message template.
5. Bounded workload process metrics and file size, followed by cleanup.
6. Actual read-only service state; label it an observation, not an induced failure.
7. Loopback TCP success, stopped-listener failure, restart success and final cleanup.
8. Backup per-file original/backup/restore digests and all-file PASS.
9. Deliberate integrity mismatch and the repaired matching digest.

A screenshot of saved sanitized output must be labeled as such; it is not a live console capture. Reproducing a transient condition creates a new run and needs its own date/time. Use [the checklist](../docs/SCREENSHOT-CHECKLIST.md), crop unrelated UI, review every pixel for identifiers and notifications, and force-add only individually reviewed captures under screenshots/incidents/. Do not capture restored user documents or browser accounts.
