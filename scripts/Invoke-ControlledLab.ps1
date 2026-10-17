#requires -Version 5.1
<#
.SYNOPSIS
Execute restricted, non-destructive support scenarios and save selected evidence.
.DESCRIPTION
Uses only loopback sockets, bounded probes, temporary workload files and copied lab data.
Observes an existing service without changing it. Appends explicitly marked events through an
existing provider; no event source or log is created or removed. Published evidence must be reviewed.
This script deliberately selects fields instead of publishing complete diagnostic reports.
#>
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
. "$PSScriptRoot\Private\Common.ps1"
. "$PSScriptRoot\Private\ExecutionEvidence.ps1"
Assert-LabWindows
$root = Split-Path $PSScriptRoot -Parent
$rawRoot = Join-Path $root 'reports\lab-execution'
$evidenceRoot = Join-Path $root 'evidence'
New-Item -ItemType Directory -Path $rawRoot,$evidenceRoot -Force | Out-Null
$runRaw = New-LabRunDirectory $rawRoot 'controlled'
$rawRoot = $runRaw
$started = Get-LabTimestamp
$canonicalBefore = @(Get-ChildItem (Join-Path $root 'lab-data') -File -Recurse | Get-FileHash -Algorithm SHA256 | Select-Object Path,Hash)
$networkBefore = Get-ExecutionNetworkState
$serviceBefore = Get-CimInstance Win32_Service -Filter "Name='wuauserv'" | Select-Object Name,State,StartMode,ExitCode
$os = Get-CimInstance Win32_OperatingSystem
$computer = Get-CimInstance Win32_ComputerSystem
$principal = [Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent())
$nativeVersion = & powershell.exe -NoProfile -NonInteractive -Command '$PSVersionTable.PSVersion.ToString()'
$environment = [pscustomobject]@{
    At=$started; OS=$os.Caption; Version=$os.Version; Build=$os.BuildNumber; ComputerName=$env:COMPUTERNAME
    Manufacturer=$computer.Manufacturer; Model=$computer.Model; HypervisorPresent=$computer.HypervisorPresent
    PartOfDomain=$computer.PartOfDomain; Domain=$computer.Domain
    EnrollmentKeyCount=@(Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Enrollments' -ErrorAction SilentlyContinue).Count
    Elevated=$principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    CurrentPowerShell=$PSVersionTable.PSVersion.ToString(); WindowsPowerShell=[string]$nativeVersion
    Git=([string](git --version)); GitHubCli=([string]((gh --version)[0])); Network=$networkBefore
    Classification='RESTRICTED TO NON-DESTRUCTIVE SIMULATION'
    Reason='Disposable VM status is not established automatically. Hypervisor presence and hardware labels alone cannot establish disposability. Enrollment keys alone do not prove active management. Restricted execution is always selected.'
}
Save-LabRaw 'environment-check' $environment
$environment | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath (Join-Path (Split-Path $rawRoot -Parent) 'environment-check.txt') -Encoding UTF8
$safeEnvironment = [pscustomobject]@{
    At=$started; OS=$os.Caption; Version=$os.Version; Build=$os.BuildNumber
    Hostname='WITHHELD'
    HardwareAssessment=$(if (($computer.Manufacturer + ' ' + $computer.Model) -match '(?i)virtual|vmware|virtualbox|kvm|qemu|xen|hvm|amazon ec2') {
        'Virtualization hardware markers present; disposable ownership not confirmed'
    } else { 'Physical workstation indicators; disposable VM not confirmed' })
    HypervisorPresent=$computer.HypervisorPresent; PartOfDomain=$computer.PartOfDomain
    ManagementAssessment='Enrollment keys present; active management not established; restricted execution chosen'
    Elevated=$environment.Elevated; CurrentPowerShell=$environment.CurrentPowerShell; WindowsPowerShell=$environment.WindowsPowerShell
    Git=$environment.Git; GitHubCli=$environment.GitHubCli
    AdapterCounts=@(Get-NetAdapter | Group-Object Status | Select-Object Name,Count)
    Classification=$environment.Classification
}
New-Item -ItemType Directory -Path (Join-Path $evidenceRoot 'baseline') -Force | Out-Null
$safeEnvironment | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath (Join-Path $evidenceRoot 'baseline\environment-check.txt') -Encoding UTF8

Write-Host 'Collecting real baseline; warnings will be preserved.'
$baseline = & "$PSScriptRoot\Invoke-SupportDiagnostics.ps1" -Full -Redact
$health = Get-Content -LiteralPath (Join-Path $baseline.ReportDirectory 'system-health.json') -Raw | ConvertFrom-Json
$memory = ($health.Checks | Where-Object Name -eq 'System Health - Memory').Data
$storage = ($health.Checks | Where-Object Name -eq 'Storage').Data
$baselineSafe = [pscustomobject]@{
    At=Get-LabTimestamp; OS=$os.Caption; Version=$os.Version; Build=$os.BuildNumber
    Checks=@($baseline.Checks | Select-Object Name,Status)
    Memory=$memory
    Storage=@($storage | Select-Object SizeBytes,FreeBytes,UsedBytes,PercentFree)
    Services=@(($health.Checks | Where-Object Name -eq 'Services').Data | Select-Object Name,State,StartMode,ExitCode)
    UpdateService=($health.Checks | Where-Object Name -eq 'Windows Update Service').Data
    EventCounts=@($health.Checks | Where-Object Name -like 'Event Logs*' | ForEach-Object { [pscustomobject]@{ Check=$_.Name; Status=$_.Status; Count=@($_.Data).Count } })
    BackupFiles=@(($baseline.Checks | Where-Object Name -eq 'Backup Verification').Data | Select-Object File,OriginalHash,BackupHash,RestoredHash,Status)
}
Save-LabEvidence 'baseline' $baselineSafe @('.\scripts\Invoke-SupportDiagnostics.ps1 -Full -Redact')

Write-Host 'INC-001: controlled nonexistent DNS name versus valid target.'
$at = Get-LabTimestamp
$dnsServers = Get-DnsClientServerAddress -AddressFamily IPv4
Save-LabRaw 'INC-001-dns-servers' $dnsServers
$failedLookup = $null
try { $unexpected = Resolve-DnsName support-lab.invalid -Type A -DnsOnly -ErrorAction Stop; Save-LabRaw 'INC-001-unexpected-answer' $unexpected }
catch { $failedLookup = $_; Save-LabRaw 'INC-001-dns-error' ([pscustomobject]@{ Error=$_.ToString(); Id=$_.FullyQualifiedErrorId }) }
$ping = @(Test-Connection -ComputerName '1.1.1.1' -Count 1 -ErrorAction SilentlyContinue)
Save-LabRaw 'INC-001-ping' $ping
$validDns = @(Resolve-DnsName github.com -Type A -DnsOnly)
Save-LabRaw 'INC-001-dns-success' $validDns
$nativeTcp = Test-NetConnection github.com -Port 443 -WarningAction SilentlyContinue
Save-LabRaw 'INC-001-native-tcp' $nativeTcp
$dnsProjectFail = & "$PSScriptRoot\Invoke-NetworkDiagnostics.ps1" -Target support-lab.invalid -Ports 443 -OutputDirectory (Join-Path $rawRoot 'dns-failure')
$dnsProjectAfter = & "$PSScriptRoot\Invoke-NetworkDiagnostics.ps1" -Target github.com -Ports 443 -OutputDirectory (Join-Path $rawRoot 'dns-corrected-target')
$dnsEvidence = [pscustomobject]@{
    StartedAt=$at; FinishedAt=Get-LabTimestamp; Mode='Controlled nonexistent-name query; adapter DNS unchanged'
    FailureTarget='support-lab.invalid'; FailureObserved=($null -ne $failedLookup)
    FailureId=$(if ($failedLookup) { $failedLookup.FullyQualifiedErrorId } else { $null })
    ComparisonTarget='github.com'; ValidARecordCount=@($validDns | Where-Object Type -eq A).Count
    PublicProbeReplyCount=$ping.Count; NativeTcp443Succeeded=$nativeTcp.TcpTestSucceeded
    FailingTargetChecks=@($dnsProjectFail.Checks | Select-Object Name,Status)
    CorrectedTargetChecks=@($dnsProjectAfter.Checks | Select-Object Name,Status)
    ConfigurationModified=$false
}
Save-LabEvidence 'INC-001' $dnsEvidence @('Get-DnsClientServerAddress -AddressFamily IPv4','Resolve-DnsName support-lab.invalid -Type A -DnsOnly','Test-Connection -ComputerName $PublicProbe -Count 1','Resolve-DnsName github.com -Type A -DnsOnly','Test-NetConnection github.com -Port 443','.\scripts\Invoke-NetworkDiagnostics.ps1 -Target support-lab.invalid -Ports 443','.\scripts\Invoke-NetworkDiagnostics.ps1 -Target github.com -Ports 443')

Write-Host 'INC-002: bounded reachability probes to documentation-only destination.'
$at = Get-LabTimestamp
Save-LabRaw 'INC-002-ip-configuration' @(Get-NetIPConfiguration)
Save-LabRaw 'INC-002-routes' @(Get-NetRoute)
$destination = '203.0.113.1'
$controlPing = @(Test-Connection -ComputerName $destination -Count 1 -ErrorAction SilentlyContinue)
$routing = Test-NetConnection -ComputerName $destination -DiagnoseRouting -InformationLevel Detailed -WarningAction SilentlyContinue
Save-LabRaw 'INC-002-route-diagnosis' $routing
$controlTcp = Test-ExecutionTcp $destination 65000
$networkVerified = & "$PSScriptRoot\Invoke-NetworkDiagnostics.ps1" -Target github.com -Ports 443 -OutputDirectory (Join-Path $rawRoot 'network-comparison')
$networkEvidence = [pscustomobject]@{
    StartedAt=$at; FinishedAt=Get-LabTimestamp; Mode='Destination-scoped failure; no adapter or route modifications'
    ControlledDestination='TEST-NET-3 documentation destination, literal withheld from published observations'
    ControlledPort=65000; ControlledIcmpReplies=$controlPing.Count; ControlledTcp=$controlTcp
    RouteSelectionSucceeded=$routing.RouteDiagnosticsSucceeded
    ComparisonChecks=@($networkVerified.Checks | Select-Object Name,Status)
    FailureScope='Selected destination/port only; timeout does not identify a remote firewall or route cause'
}
Save-LabEvidence 'INC-002' $networkEvidence @('Get-NetIPConfiguration','Get-NetRoute','Test-Connection -ComputerName $DocumentationDestination -Count 1','Test-NetConnection -ComputerName $DocumentationDestination -DiagnoseRouting -InformationLevel Detailed','Test-ExecutionTcp $DocumentationDestination 65000','.\scripts\Invoke-NetworkDiagnostics.ps1 -Target github.com -Ports 443')

Write-Host 'INC-003: explicitly labeled events through existing PowerShell provider.'
$at = Get-LabTimestamp
$eventStart = Get-Date
$marker = 'ITSupportLab controlled application error ' + [guid]::NewGuid().ToString('N')
$eventFailure = $null
try {
    if (-not [Diagnostics.EventLog]::SourceExists('PowerShell')) { throw 'Existing PowerShell source unavailable; source creation is prohibited in restricted mode.' }
    [Diagnostics.EventLog]::WriteEntry('PowerShell',$marker,[Diagnostics.EventLogEntryType]::Error,9001)
    [Diagnostics.EventLog]::WriteEntry('PowerShell',($marker + ' | Corrective action: controlled test completed; no application fault asserted.'),[Diagnostics.EventLogEntryType]::Information,9002)
    Start-Sleep -Milliseconds 800
    $eventRecords = @(Get-WinEvent -FilterHashtable @{LogName='Windows PowerShell'; Id=9001,9002; StartTime=$eventStart.AddSeconds(-2)} -MaxEvents 20 |
        Where-Object { @($_.Properties | Where-Object { [string]$_.Value -like ('*' + $marker + '*') }).Count })
    $eventRecords | ForEach-Object ToXml | Set-Content -LiteralPath (Join-Path $rawRoot 'INC-003-event-records.xml') -Encoding UTF8
    $eventsSafe = @($eventRecords | ForEach-Object {
        [pscustomobject]@{ At=([DateTimeOffset]$_.TimeCreated).ToOffset([TimeSpan]::FromHours(4)).ToString('o'); Log=$_.LogName; Provider=$_.ProviderName; EventId=$_.Id
            Level=$_.LevelDisplayName; MessageRenderingAvailable=(-not [string]::IsNullOrWhiteSpace($_.Message))
            EventDataMessage=([string]$_.Properties[0].Value -replace [regex]::Escape($marker),'ITSupportLab controlled application error [correlation marker withheld]') }
    })
}
catch { $eventFailure = $_.Exception.GetType().Name; Save-LabRaw 'INC-003-error' $_.ToString(); $eventsSafe=@() }
$eventEvidence = [pscustomobject]@{
    StartedAt=$at; FinishedAt=Get-LabTimestamp; Mode='Real marked test events, existing provider; no crash or source registration'
    Events=$eventsSafe; Error=$eventFailure
    ErrorCollected=(@($eventsSafe | Where-Object EventId -eq 9001).Count -eq 1)
    CompletionCollected=(@($eventsSafe | Where-Object EventId -eq 9002).Count -eq 1)
    SourceCreated=$false; LogsCleared=$false; AuditRecordsRetained=$true
    RenderingNote='Chosen lab IDs may lack provider message templates; EventData is captured from actual event properties/XML, never invented as a rendered message.'
}
Save-LabEvidence 'INC-003' $eventEvidence @('[Diagnostics.EventLog]::SourceExists(''PowerShell'')','[Diagnostics.EventLog]::WriteEntry(''PowerShell'',$marker,[Diagnostics.EventLogEntryType]::Error,9001)','[Diagnostics.EventLog]::WriteEntry(''PowerShell'',$completionMessage,[Diagnostics.EventLogEntryType]::Information,9002)','Get-WinEvent -FilterHashtable @{LogName=''Windows PowerShell''; Id=9001,9002; StartTime=$eventStart.AddSeconds(-2)}')

Write-Host 'INC-004: two MiB file and three-second single-process workload.'
$at = Get-LabTimestamp
$workDir = Join-Path $rawRoot 'workload'
New-Item -ItemType Directory -Path $workDir | Out-Null
$file = Join-Path $workDir 'bounded-workload.bin'
$workResult = Join-Path $workDir 'result.json'
$ownedProcess = $null
$beforeOs = Get-CimInstance Win32_OperatingSystem
$beforeVolumes = @(Get-Volume | Select-Object DriveLetter,Size,SizeRemaining)
$beforeDrives = @(Get-PSDrive -PSProvider FileSystem | Select-Object Name,Used,Free)
Save-LabRaw 'INC-004-volumes-before' $beforeVolumes
Save-LabRaw 'INC-004-drives-before' $beforeDrives
$during = $null; $childResult = $null; $allocation = 0L
try {
    if ([long]$beforeOs.FreePhysicalMemory * 1KB -lt 512MB) { throw 'Insufficient free memory for bounded workload.' }
    $drive = Get-PSDrive -Name ([IO.Path]::GetPathRoot($workDir).TrimEnd('\').TrimEnd(':'))
    if ($drive.Free -lt 256MB) { throw 'Insufficient free disk headroom for bounded workload.' }
    [IO.File]::WriteAllBytes($file,(New-Object byte[] (2MB)))
    $allocation = (Get-Item -LiteralPath $file).Length
    $arguments = '-NoProfile -NonInteractive -File "{0}" -OutputPath "{1}"' -f (Join-Path $PSScriptRoot 'Private\Invoke-LabWorkload.ps1'),$workResult
    $ownedProcess = Start-Process -FilePath (Get-Process -Id $PID).Path -ArgumentList $arguments -WindowStyle Hidden -PassThru
    Start-Sleep -Milliseconds 1000
    $snapshot = Get-Process -Id $ownedProcess.Id
    $during = [pscustomobject]@{ At=Get-LabTimestamp; CPUSeconds=$snapshot.TotalProcessorTime.TotalSeconds; WorkingSetBytes=$snapshot.WorkingSet64; TemporaryFileBytes=$allocation }
    if (-not $ownedProcess.WaitForExit(15000)) { throw 'Bounded child exceeded deadline.' }
    if ($ownedProcess.ExitCode -ne 0) { throw 'Workload child failed.' }
    $childResult = Get-Content -LiteralPath $workResult -Raw | ConvertFrom-Json
}
finally {
    if ($null -ne $ownedProcess -and -not $ownedProcess.HasExited) { $ownedProcess.Kill(); $ownedProcess.WaitForExit() }
    # Delete only exact generated leaves inside the verified run workspace; never recurse.
    foreach ($generated in @($file,$workResult)) {
        if (-not [IO.Path]::GetFullPath($generated).StartsWith([IO.Path]::GetFullPath($workDir) + '\',[StringComparison]::OrdinalIgnoreCase)) { throw 'Cleanup path escaped workload workspace.' }
        if (Test-Path -LiteralPath $generated) { Remove-Item -LiteralPath $generated -Force }
    }
    Remove-Item -LiteralPath $workDir
}
$afterOs = Get-CimInstance Win32_OperatingSystem
$performanceEvidence = [pscustomobject]@{
    StartedAt=$at; FinishedAt=Get-LabTimestamp; Mode='Bounded investigation, no whole-machine performance fault asserted'
    Before=[pscustomobject]@{ At=$at; FreeMemoryBytes=[long]$beforeOs.FreePhysicalMemory * 1KB; TemporaryFileExists=$false }
    During=$during; Workload=$childResult
    After=[pscustomobject]@{ At=Get-LabTimestamp; FreeMemoryBytes=[long]$afterOs.FreePhysicalMemory * 1KB; TemporaryFileExists=(Test-Path -LiteralPath $file); ChildExited=$ownedProcess.HasExited }
    CleanupVerified=(-not (Test-Path -LiteralPath $workDir) -and $ownedProcess.HasExited)
}
Save-LabEvidence 'INC-004' $performanceEvidence @('Get-CimInstance Win32_OperatingSystem','Get-Volume','Get-PSDrive -PSProvider FileSystem','[IO.File]::WriteAllBytes($temporaryFile,(New-Object byte[] (2MB)))','Start-Process -FilePath $PowerShellExecutable -ArgumentList $boundedWorkloadArguments -WindowStyle Hidden -PassThru','Get-Process -Id $ownedProcess.Id','Get-CimInstance Win32_OperatingSystem','Remove-Item -LiteralPath $exactGeneratedFile')

Write-Host 'INC-005: existing service observation; no service is changed.'
$at = Get-LabTimestamp
$serviceReport = & "$PSScriptRoot\Invoke-SystemHealth.ps1" -Scope Services -OutputDirectory (Join-Path $rawRoot 'services')
$serviceNative = Get-Service -Name wuauserv
$serviceAfter = Get-CimInstance Win32_Service -Filter "Name='wuauserv'" | Select-Object Name,State,StartMode,ExitCode
$serviceEvidence = [pscustomobject]@{
    StartedAt=$at; FinishedAt=Get-LabTimestamp; Mode='Read-only existing service observation; failure not induced or confirmed'
    Before=$serviceBefore; Native=[pscustomobject]@{ Name=$serviceNative.Name; State=$serviceNative.Status.ToString(); StartType=$serviceNative.StartType.ToString() }
    After=$serviceAfter; ProjectChecks=@($serviceReport.Checks | Select-Object Name,Status)
    IncludedInStoppedAutomaticList=(@(($serviceReport.Checks | Where-Object Name -eq Services).Data | Where-Object Name -eq wuauserv).Count -gt 0)
    ConfigurationUnchanged=(($serviceBefore | ConvertTo-Json -Compress) -eq ($serviceAfter | ConvertTo-Json -Compress))
    ServiceCreated=$false; ServiceStartedOrStopped=$false; ConfirmedServiceFailure=$false
}
Save-LabEvidence 'INC-005' $serviceEvidence @('Get-Service -Name wuauserv','Get-CimInstance Win32_Service -Filter "Name=''wuauserv''"','.\scripts\Invoke-SystemHealth.ps1 -Scope Services','Get-CimInstance Win32_Service -Filter "Name=''wuauserv''"')

Write-Host 'INC-006: loopback listener open, stopped, restarted, and cleaned up.'
$at = Get-LabTimestamp
$listener = [Net.Sockets.TcpListener]::new([Net.IPAddress]::Loopback,0)
$port = $null; $open = $null; $closed = $null; $recovered = $null
try {
    $listener.Start(); $port = $listener.LocalEndpoint.Port
    $open = Test-NetConnection -ComputerName ([Net.IPAddress]::Loopback.ToString()) -Port $port -WarningAction SilentlyContinue
    Save-LabRaw 'INC-006-open' $open
    $localhost = [Net.Dns]::GetHostAddresses('localhost')
    $listener.Stop()
    $closed = Test-NetConnection -ComputerName ([Net.IPAddress]::Loopback.ToString()) -Port $port -WarningAction SilentlyContinue
    Save-LabRaw 'INC-006-closed' $closed
    $listener = [Net.Sockets.TcpListener]::new([Net.IPAddress]::Loopback,$port)
    $listener.Start()
    $recovered = Test-NetConnection -ComputerName ([Net.IPAddress]::Loopback.ToString()) -Port $port -WarningAction SilentlyContinue
    Save-LabRaw 'INC-006-recovered' $recovered
}
finally { $listener.Stop() }
$cleanupProbe = Test-ExecutionTcp ([Net.IPAddress]::Loopback.ToString()) $port
$tcpEvidence = [pscustomobject]@{
    StartedAt=$at; FinishedAt=Get-LabTimestamp; Mode='Loopback-only temporary listener, no firewall changes'
    Port=$port; LocalhostResolvedAddressCount=@($localhost).Count
    Listening=[pscustomobject]@{ At=([DateTimeOffset]$at).ToString('o'); TcpTestSucceeded=$open.TcpTestSucceeded }
    Stopped=[pscustomobject]@{ TcpTestSucceeded=$closed.TcpTestSucceeded }
    Restarted=[pscustomobject]@{ TcpTestSucceeded=$recovered.TcpTestSucceeded }
    Cleanup=$cleanupProbe; CleanupVerified=(-not $cleanupProbe.Connected)
}
Save-LabEvidence 'INC-006' $tcpEvidence @('$listener = [Net.Sockets.TcpListener]::new([Net.IPAddress]::Loopback,0)','$listener.Start(); $port = $listener.LocalEndpoint.Port','Test-NetConnection -ComputerName ([Net.IPAddress]::Loopback.ToString()) -Port $port','[Net.Dns]::GetHostAddresses(''localhost'')','$listener.Stop()','Test-NetConnection -ComputerName ([Net.IPAddress]::Loopback.ToString()) -Port $port','$listener = [Net.Sockets.TcpListener]::new([Net.IPAddress]::Loopback,$port); $listener.Start()','Test-NetConnection -ComputerName ([Net.IPAddress]::Loopback.ToString()) -Port $port','$listener.Stop()')

Write-Host 'INC-007: verify every supplied lab file through backup and restore.'
$at = Get-LabTimestamp
$backup = & "$PSScriptRoot\Invoke-BackupRestoreTest.ps1" -OutputDirectory (Join-Path $rawRoot 'backup-case') -FailOnMismatch -Redact
$backupEvidence = [pscustomobject]@{
    StartedAt=$at; FinishedAt=Get-LabTimestamp; Status=$backup.Checks[0].Status
    SourceFileCount=@($backup.Checks[0].Data).Count
    BackupDestination='Ignored unique run directory / backup'; RestoreDestination='Same ignored run directory / restore'
    Files=$backup.Checks[0].Data
    VerifiedFileCount=@($backup.Checks[0].Data | Where-Object Status -eq PASS).Count
}
Save-LabEvidence 'INC-007' $backupEvidence @('.\scripts\Invoke-BackupRestoreTest.ps1 -OutputDirectory $ignoredBackupRoot -FailOnMismatch -Redact','$backup.Checks[0].Data | Format-List')

Write-Host 'INC-008: modify only a restored disposable copy, detect mismatch, restore and rehash.'
$at = Get-LabTimestamp
$disposable = Join-Path $rawRoot 'integrity-source'
New-Item -ItemType Directory -Path $disposable | Out-Null
Copy-Item -LiteralPath (Join-Path $root 'lab-data\notes.txt') -Destination (Join-Path $disposable 'notes.txt')
$integrity = & "$PSScriptRoot\Invoke-BackupRestoreTest.ps1" -SourceDirectory $disposable -OutputDirectory (Join-Path $rawRoot 'integrity-backup') -FailOnMismatch -Redact
$backupFile = Join-Path $integrity.ArtifactDirectory 'backup\notes.txt'
$restoredFile = Join-Path $integrity.ArtifactDirectory 'restore\notes.txt'
$originalHash = (Get-FileHash -LiteralPath (Join-Path $disposable 'notes.txt') -Algorithm SHA256).Hash
$beforeHash = (Get-FileHash -LiteralPath $restoredFile -Algorithm SHA256).Hash
$changedHash=$null; $restoredHash=$null; $mismatchAt=$null; $repairAt=$null
try {
    Add-Content -LiteralPath $restoredFile -Value 'ITSupportLab deliberate disposable content change.'
    $changedHash = (Get-FileHash -LiteralPath $restoredFile -Algorithm SHA256).Hash
    $mismatchAt = Get-LabTimestamp
}
finally {
    Copy-Item -LiteralPath $backupFile -Destination $restoredFile -Force
    $restoredHash = (Get-FileHash -LiteralPath $restoredFile -Algorithm SHA256).Hash
    $repairAt = Get-LabTimestamp
}
$backupHash = (Get-FileHash -LiteralPath $backupFile -Algorithm SHA256).Hash
$integrityEvidence = [pscustomobject]@{
    StartedAt=$at; FinishedAt=Get-LabTimestamp; File='notes.txt'; InitialRestoreHash=$beforeHash; OriginalHash=$originalHash
    BackupHash=$backupHash; ChangedHash=$changedHash; RestoredHash=$restoredHash
    MismatchAt=$mismatchAt; MismatchDetected=(-not (Test-LabHashMatch $originalHash $backupHash $changedHash))
    RepairedAt=$repairAt; FinalVerification=(Test-LabHashMatch $originalHash $backupHash $restoredHash)
    ChangedScope='One restored disposable copy; canonical lab-data not edited'
}
Save-LabEvidence 'INC-008' $integrityEvidence @('Copy-Item -LiteralPath .\lab-data\notes.txt -Destination $disposableSource','.\scripts\Invoke-BackupRestoreTest.ps1 -SourceDirectory $disposableDirectory -OutputDirectory $ignoredBackupRoot -FailOnMismatch -Redact','Get-FileHash -LiteralPath $original,$backup,$restored -Algorithm SHA256','Add-Content -LiteralPath $restored -Value ''ITSupportLab deliberate disposable content change.''','Get-FileHash -LiteralPath $restored -Algorithm SHA256','Test-LabHashMatch $originalHash $backupHash $changedHash','Copy-Item -LiteralPath $backup -Destination $restored -Force','Get-FileHash -LiteralPath $restored -Algorithm SHA256','Test-LabHashMatch $originalHash $backupHash $restoredHash')

$networkAfter = Get-ExecutionNetworkState
$canonicalAfter = @(Get-ChildItem (Join-Path $root 'lab-data') -File -Recurse | Get-FileHash -Algorithm SHA256 | Select-Object Path,Hash)
$finalService = Get-CimInstance Win32_Service -Filter "Name='wuauserv'" | Select-Object Name,State,StartMode,ExitCode
Save-LabRaw 'network-before' $networkBefore
Save-LabRaw 'network-after' $networkAfter
$cleanup = [pscustomobject]@{
    At=Get-LabTimestamp
    NetworkConfigurationUnchanged=(($networkBefore | ConvertTo-Json -Depth 15 -Compress) -eq ($networkAfter | ConvertTo-Json -Depth 15 -Compress))
    CanonicalInputsUnchanged=(($canonicalBefore | ConvertTo-Json -Compress) -eq ($canonicalAfter | ConvertTo-Json -Compress))
    ObservedServiceUnchanged=(($serviceBefore | ConvertTo-Json -Compress) -eq ($finalService | ConvertTo-Json -Compress))
    WorkloadRemoved=$performanceEvidence.CleanupVerified; ListenerClosed=$tcpEvidence.CleanupVerified
    IntegrityRepairVerified=$integrityEvidence.FinalVerification
    SystemConfigurationChangesMade=$false; SourcesRegistered=$false; AuditEventsRetained=$true
    RawArtifacts='Ignored reports/lab-execution directories; backup copies intentionally retained locally, never published'
}
$cleanup | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath (Join-Path $evidenceRoot 'cleanup-verification.json') -Encoding UTF8
Save-LabRaw 'cleanup' $cleanup
Write-Host 'Controlled execution finished. Review selected evidence before publishing.'
$cleanup | Format-List | Out-Host
