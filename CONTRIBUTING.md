# Contributing

Report a bug with the script name, PowerShell version, Windows version, exact sanitized command, expected behavior and actual error. Remove identifiers and private content before attaching anything. Do not attach a complete unreviewed diagnostics run.

Keep scripts compatible with Windows PowerShell 5.1 and PowerShell 7 on Windows where practical. Prefer native cmdlets and independent checks that record provider/access failures. Do not silently treat missing data as success. Document parameter changes and run the Pester suite in both shells.

New checks should be read-only, scoped, useful for troubleshooting and explicit about interpretation limits. Add focused tests for new pure logic or safety boundaries. Avoid dependencies unless the functionality warrants them.

New incident cases must distinguish guided scenarios from actual observations, preserve evidence, use disposable inputs, and include rollback for every simulated configuration change. Use the incident template and link the relevant knowledge-base article. Never invent machine output or screenshots.

Use small logical commits. Review staged diffs and filenames for sensitive data, personal paths and copied backup content before opening a contribution.
