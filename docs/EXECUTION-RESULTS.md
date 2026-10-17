# Controlled execution results

Executed on **2026-10-17**. The included records are observations from commands actually executed during this run. A preceding event-source preflight is separately documented.

## Environment and safety decision

Windows 11; execution was restricted to non-destructive checks and isolated temporary resources.

Classification: **RESTRICTED TO NON-DESTRUCTIVE SIMULATION**. Isolation applied to temporary loopback resources, a bounded workload and copied files. No DNS, route, firewall, security, registry, startup or service configuration was changed. Windows PowerShell validation used a process-only RemoteSigned invocation; no persistent policy was changed. [Policy verification](../evidence/execution-policy-verification.json) records before/after defaults and the exited subprocess. The measured [baseline](../evidence/baseline/baseline-summary.md) retained storage, service and event warnings; it was not falsely declared entirely healthy.

The full environment check, native adapter/address/route data, command records, XML and backup copies remain ignored under local reports folders. [Sanitized environment fields](../evidence/baseline/environment-check.txt) retain the operating-system family, shell compatibility and restricted execution scope without host specifications.

## Actual outcomes

| Incident | Result and limitation |
| --- | --- |
| [INC-001](../incidents/INC-001-dns-resolution.md) | Real nonexistent-name error; valid DNS and TCP 443 worked; settings unchanged |
| [INC-002](../incidents/INC-002-network-connectivity.md) | Selected TCP endpoint timed out; route selection and ICMP worked; healthy comparison passed; underlying remote cause unconfirmed |
| [INC-003](../incidents/INC-003-application-event-error.md) | Real marked Error/Information event pair collected from existing provider; EventData used because rendered Message was empty |
| [INC-004](../incidents/INC-004-storage-performance.md) | Three-second owned workload and two MiB file measured; child exited and generated workload removed |
| [INC-005](../incidents/INC-005-service-failure.md) | Authorized read-only service fallback; stopped Manual wuauserv observed unchanged; no service failure induced or established |
| [INC-006](../incidents/INC-006-tcp-port-connectivity.md) | Native loopback TCP success → stopped-listener failure → restart success; final listener release verified |
| [INC-007](../incidents/INC-007-backup-restore.md) | All four files matched original, backup and restored SHA-256 |
| [INC-008](../incidents/INC-008-file-integrity.md) | One disposable restore deliberately changed; mismatch detected; verified backup restored matching content |

See [selected evidence](../evidence/README.md). No company outage, application crash, failed update function, storage corruption or whole-machine performance failure is implied by these exercises.

## Cleanup

[Actual final verification](../evidence/cleanup-verification.json) confirmed unchanged network configuration, unchanged canonical sample-file hashes, unchanged observed service state, removed workload, closed listener and repaired disposable content. Cleanup used exact generated file paths, not recursive removal of a computed directory.

Backup/restore copies are intentionally retained only in ignored local report directories. Three clearly marked event records remain as audit traces: one preflight Error, one main Error and one completion Information. No source was created and no log or individual event was deleted. This is disclosed retention, not unreported rollback of an audit trail.

## Validation and privacy review

The included validation runner passed in Windows PowerShell 5.1 and PowerShell 7 using local Pester 3: **16 passed, 0 failed in each shell**. All PowerShell scripts parsed and repository-relative Markdown links resolved. [Selected validation results](../evidence/validation-summary.json) record actual summaries; raw console logs remain ignored. Four new checks validate evidence completeness, matching backup/repair digests, the TCP lifecycle, cleanup fields, and honest service/event interpretation.

Candidate text files were scanned for the current username, hostname, home path, configured email, detected Wi-Fi SSID, email/credential/private-key patterns, MAC addresses, literal network addresses, user-profile paths and prohibited purpose references. No sensitive values were found in selected evidence. Known static probe constants, software version strings and explicitly labeled synthetic redaction fixtures in existing source/tests were reviewed separately from observed data. No screenshot file or backup content is included. These checks supplement the manual review of selected fields and diffs.

## Screenshots and remaining human work

No publishable screenshots were captured. Native viewer automation initialized but an input attempt failed with unavailable coordinate geometry; existing restored document content was not captured or modified. [Automation notes](../screenshots/AUTOMATION-NOTES.md) list the manual captures still needed. Saved selected output can be viewed manually, but screenshots of saved evidence must not be labeled as live diagnostic consoles.

An induced service-failure exercise would require a separately confirmed disposable/elevated environment. It was intentionally replaced here by the permitted observation fallback. No user action is needed to restore the network, service, files or listener after this run.

## Reproduction and interpretation limits

Review and run `scripts/Invoke-ControlledLab.ps1` from the repository root. It appends explicitly marked audit events and replaces selected evidence on rerun; preserve dated incident records first. Raw captures receive unique run directories. Public probes require internet access. Counts, ports, timing, warning states and digests can differ. The runner records observations; any failed verification must be investigated rather than relabeled as success.

Selected files are allowlisted projections of actual records. Addresses, usernames, computer/domain names, MAC addresses, SSIDs, unrelated messages and personal paths are excluded. Selection and redaction prevent publication of complete raw transcripts. Published JSON/TXT consistency checks cannot independently authenticate provenance; the acquisition code and ignored raw records provide the local audit trail.
