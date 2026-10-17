#requires -Version 5.1
<#+
.SYNOPSIS
Collect local Windows health, event and service evidence without changing configuration.
.DESCRIPTION
Each independent check records unavailable data on access or provider errors. CPU usage is cumulative process CPU time.
#>
[CmdletBinding()]
param(
    [ValidateRange(1,8760)][int]$Hours = 24,
    [ValidateRange(1,100)][int]$TopProcesses = 10,
    [ValidateRange(1,5000)][int]$MaxEvents = 100,
    [string]$OutputDirectory,
    [ValidateSet('All','Events','Services')][string]$Scope = 'All',
    [switch]$Redact
)
. "$PSScriptRoot\Private\Common.ps1"
Assert-LabWindows
$checks = @()
if ($Scope -eq 'All') {
    $checks += Invoke-LabCheck 'System Overview' {
        $os = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop
        $computer = Get-CimInstance Win32_ComputerSystem -ErrorAction Stop
        $cpu = @(Get-CimInstance Win32_Processor -ErrorAction Stop)
        New-LabCheck 'System Overview' INFO ([pscustomobject]@{
            ComputerName = $env:COMPUTERNAME; OS = $os.Caption; Version = $os.Version
            Build = $os.BuildNumber; Architecture = $os.OSArchitecture; LastBoot = $os.LastBootUpTime.ToString('o')
            UptimeHours = [math]::Round(((Get-Date) - $os.LastBootUpTime).TotalHours,2)
            CpuNames = @($cpu | Select-Object -ExpandProperty Name)
            LogicalProcessors = $computer.NumberOfLogicalProcessors; PhysicalMemoryBytes = $computer.TotalPhysicalMemory
        })
    }
    $checks += Invoke-LabCheck 'System Health - Memory' {
        $os = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop
        $used = [math]::Round(100 * (1 - $os.FreePhysicalMemory / $os.TotalVisibleMemorySize),2)
        $status = if ($used -ge 90) { 'WARNING' } else { 'PASS' }
        New-LabCheck 'System Health - Memory' $status ([pscustomobject]@{
            TotalVisibleBytes = [long]$os.TotalVisibleMemorySize * 1KB
            FreeBytes = [long]$os.FreePhysicalMemory * 1KB; UtilizationPercent = $used
        }) 'WARNING threshold: memory utilization >= 90%; a snapshot is not a diagnosis.'
    }
    $checks += Invoke-LabCheck 'Storage' {
        $disks = @(Get-CimInstance Win32_Volume -Filter 'DriveType=3' -ErrorAction Stop | Where-Object { $_.Capacity -gt 0 } | ForEach-Object {
            [pscustomobject]@{ Mount = $_.Name; SizeBytes = $_.Capacity; FreeBytes = $_.FreeSpace
                UsedBytes = $_.Capacity - $_.FreeSpace; PercentFree = [math]::Round(100 * $_.FreeSpace / $_.Capacity,2) }
        })
        $status = if ($disks.Count -eq 0) { 'UNAVAILABLE' } elseif (@($disks | Where-Object PercentFree -lt 15).Count) { 'WARNING' } else { 'PASS' }
        New-LabCheck 'Storage' $status $disks 'Mounted local fixed volumes; WARNING below 15% free. No disk latency measurement.'
    }
    $checks += Invoke-LabCheck 'Processes' {
        $processes = @(Get-Process -ErrorAction Stop)
        New-LabCheck 'Processes' INFO ([pscustomobject]@{
            ByCpuSeconds = @($processes | Sort-Object CPU -Descending | Select-Object -First $TopProcesses Id,ProcessName,CPU)
            ByWorkingSet = @($processes | Sort-Object WorkingSet64 -Descending | Select-Object -First $TopProcesses Id,ProcessName,WorkingSet64)
        }) 'CPU is cumulative seconds since process start; protected process fields may be null.'
    }
    $checks += Invoke-LabCheck 'Network Adapter Status' {
        New-LabCheck 'Network Adapter Status' INFO @(Get-NetAdapter -ErrorAction Stop | Select-Object Name,InterfaceDescription,Status,LinkSpeed,MacAddress)
    }
}
if ($Scope -in @('All','Services')) {
    $checks += Invoke-LabCheck 'Services' {
        $services = @(Get-CimInstance Win32_Service -Filter "StartMode='Auto' AND State<>'Running'" -ErrorAction Stop | Select-Object Name,DisplayName,State,StartMode,ExitCode)
        $status = if ($services.Count) { 'WARNING' } else { 'PASS' }
        New-LabCheck 'Services' $status $services 'Stopped automatic services can be trigger-start or deliberately idle; investigate before changing them.'
    }
    $checks += Invoke-LabCheck 'Windows Update Service' {
        $service = Get-Service -Name wuauserv -ErrorAction Stop | Select-Object Name,@{n='Status';e={$_.Status.ToString()}},@{n='StartType';e={$_.StartType.ToString()}}
        New-LabCheck 'Windows Update Service' INFO $service 'Service state alone does not establish update compliance.'
    }
}
if ($Scope -in @('All','Events')) {
    foreach ($log in @('System','Application')) {
        $checks += Invoke-LabCheck "Event Logs - $log" {
            try {
                $events = @(Get-WinEvent -FilterHashtable @{ LogName=$log; Level=1,2; StartTime=(Get-Date).AddHours(-$Hours) } -MaxEvents $MaxEvents -ErrorAction Stop |
                    Select-Object TimeCreated,LogName,Id,LevelDisplayName,ProviderName,Message)
            }
            catch {
                if ($_.FullyQualifiedErrorId -like 'NoMatchingEventsFound*') { $events = @() } else { throw }
            }
            $status = if ($events.Count) { 'WARNING' } else { 'PASS' }
            New-LabCheck "Event Logs - $log" $status $events "Critical/error events in the last $Hours hours; at most $MaxEvents records per log. Absence is not proof of application health."
        }
    }
}
$report = [pscustomobject]@{ GeneratedAt = (Get-Date -Format o); Checks = $checks }
if ($Redact) { $report = Protect-LabObject $report }
if ($OutputDirectory) { Write-LabReport $report $OutputDirectory 'system-health' }
$report
