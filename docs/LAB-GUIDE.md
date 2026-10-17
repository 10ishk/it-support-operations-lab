# Lab guide

## Prepare a Windows VM

Use an appropriately licensed Windows 11 installation in a disposable VM with enough CPU, memory and disk for ordinary desktop use. Hyper-V, VMware or VirtualBox are optional examples; no particular hypervisor is required. Use a local account and a NAT-style virtual network if suitable. Record VM resources and network mode. Take a baseline snapshot where supported. Do not use production data or require domain/enterprise services.

Copy/clone the repository into the VM. Open Windows PowerShell 5.1 or PowerShell 7 at the repository root and record `$PSVersionTable`. Native Windows networking/CIM modules must be available. Start as a normal user; only retry denied collection with elevated access if appropriate for your VM. Elevated access is optional and must be initiated by the operator.

## Execution requirements

Read scripts before running them. If downloaded script files carry a download block, use `Unblock-File -LiteralPath <reviewed-script>` for the reviewed files, including helpers. Inspect `Get-ExecutionPolicy -List`. In an unmanaged disposable VM, if needed and permitted, set a session-only policy with `Set-ExecutionPolicy -Scope Process RemoteSigned`; closing that PowerShell session removes the process-scope setting. Organizational policy may take precedence; do not override it.

## Collect a baseline

```powershell
.\scripts\Invoke-SupportDiagnostics.ps1 -System -Redact
.\scripts\Invoke-SupportDiagnostics.ps1 -Network -Target github.com -Ports 443 -Redact
$backup = .\scripts\Invoke-BackupRestoreTest.ps1 -FailOnMismatch -Redact
$backup.Checks[0].Data | Format-List
$run = .\scripts\Invoke-SupportDiagnostics.ps1 -Full -Redact
Invoke-Item (Join-Path $run.ReportDirectory 'diagnostic-summary.html')
```

The entry point prints statuses and a run path. JSON includes data and per-check details; inspect it when a check is unavailable. TXT is readable evidence, CSV supports event/service review, and HTML needs only a browser. Standalone backup returns `ArtifactDirectory` for local navigation. Redaction does not alter copied file content.

## Execute incidents

The [recorded execution](EXECUTION-RESULTS.md) used restricted, non-destructive scenarios. Use `.\scripts\Invoke-ControlledLab.ps1` to repeat those scenarios. It appends marked audit events and replaces selected evidence, so preserve the dated reports first. Never disconnect the host or change service configuration to reproduce these records.

Copy the [template](../templates/incident-template.md) to a new local record for each run. Fill dates, scope, environment, impact and actual observations. Keep the guided instructions and recorded results clearly distinguished.

| Exercise | Action | Restore/cleanup |
| --- | --- | --- |
| [INC-001](../incidents/INC-001-dns-resolution.md) | Compare nonexistent and valid DNS names | No settings changed |
| [INC-002](../incidents/INC-002-network-connectivity.md) | Compare a bounded selected-destination TCP probe with healthy checks | No adapter or route change |
| [INC-003](../incidents/INC-003-application-event-error.md) | Write clearly marked events through the existing provider and inspect actual EventData | No provider registration; preserve audit records |
| [INC-004](../incidents/INC-004-storage-performance.md) | Measure the bounded three-second owned child and two MiB temporary file | Child exits; exact generated workload files removed in finally |
| [INC-005](../incidents/INC-005-service-failure.md) | Observe service state/dependencies and events | No prescribed service change |
| [INC-006](../incidents/INC-006-tcp-port-connectivity.md) | Start a loopback-only temporary listener and compare stopped state | Stop listener or close its process |
| [INC-007](../incidents/INC-007-backup-restore.md) | Copy and restore disposable lab files | Originals untouched; retain or manually remove identified run folder |
| [INC-008](../incidents/INC-008-file-integrity.md) | Modify only restored disposable text | Copy backed-up text over the changed restore; rehash |

Record rollback completion before starting another case. Do not disconnect a remote VM session to simulate failure. Cases using existing symptoms may legitimately find no fault; record that instead of inventing a resolution. Any additional configuration repair needs recorded original settings and a specific rollback before execution.

## Save and publish evidence

Use the [screenshot checklist](SCREENSHOT-CHECKLIST.md). Save real captures in the corresponding ignored screenshot folders. Do not include raw user data or other applications. Compare before/after evidence from the same tests, record timezone and keep unresolved causes explicitly unconfirmed.

Use `-Redact` when generating reports, then manually inspect every intended artifact. Remove remaining identifiers and sensitive messages. Copy only selected sanitized reports into your incident evidence location; exclude backup/restore content. Review staged changes with `git diff --cached`, then explicitly add reviewed ignored evidence using `git add -f <specific-reviewed-file>`. Commit actual sanitized observations with a factual message. Never force-add an entire run directory.
