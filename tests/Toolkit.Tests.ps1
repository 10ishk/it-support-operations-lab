#requires -Version 5.1
# These fixtures are synthetic test inputs, never workstation evidence.
Describe 'Report and integrity helpers' {
    BeforeEach {
        . (Join-Path $PSScriptRoot '..\scripts\Private\Common.ps1')
    }
    It 'Requires three equal well-formed SHA-256 digests' {
        $digest = 'A' * 64
        if (-not (Test-LabHashMatch $digest $digest $digest)) { throw 'Equal digests rejected' }
        if (Test-LabHashMatch $digest $digest ('B' * 64)) { throw 'Mismatch accepted' }
        if (Test-LabHashMatch '' '' '') { throw 'Missing digests accepted' }
        if (Test-LabHashMatch 'same' 'same' 'same') { throw 'Malformed digests accepted' }
    }
    It 'Preserves status and data when a provider fails' {
        $check = Invoke-LabCheck 'Denied fixture' { throw 'Synthetic provider denial' }
        if ($check.Status -ne 'UNAVAILABLE' -or $check.Data -ne $null -or $check.Detail -notmatch 'denial') { throw 'Unavailable contract failed' }
    }
    It 'Redacts nested identifiers while keeping private subnet data useful' {
        $inputObject = [pscustomobject]@{ Checks=@([pscustomobject]@{
            ComputerName='synthetic-computer'; SSID='synthetic-network'; Detail='C:\Users\SyntheticPerson\file.txt AA-BB-CC-DD-EE-FF 8.8.4.4 192.168.2.3'
        }) }
        $safe = Protect-LabObject $inputObject
        $json = $safe | ConvertTo-Json -Depth 10
        if ($json -match 'SyntheticPerson|synthetic-computer|synthetic-network|AA-BB|8\.8\.4\.4') { throw 'Identifier leaked' }
        if ($json -notmatch '192\.168\.2\.3' -or $safe.Checks.Count -ne 1) { throw 'Interpretation/shape damaged' }
    }
    It 'Retains nulls and array shape through JSON redaction' {
        $value = Protect-LabObject ([pscustomobject]@{ NullValue=$null; Items=@('one'); Empty=@() })
        $json = $value | ConvertTo-Json -Depth 10 | ConvertFrom-Json
        if ($null -ne $json.NullValue -or $json.Items.Count -ne 1 -or $json.Empty.Count -ne 0) { throw 'Object shape changed' }
    }
    It 'Creates distinct output directories for repeated runs' {
        $first = New-LabRunDirectory $TestDrive 'fixture'
        $second = New-LabRunDirectory $TestDrive 'fixture'
        if ($first -eq $second -or -not (Test-Path -LiteralPath $second -PathType Container)) { throw 'Run collision' }
    }
    It 'Escapes untrusted data in standalone HTML and omits caller artifact paths from JSON' {
        $report = [pscustomobject]@{ GeneratedAt='synthetic-time'; ArtifactDirectory='SYNTHETIC-LOCAL-PATH'; Checks=@(New-LabCheck '<fixture>' INFO '<script>alert(1)</script>' 'synthetic detail') }
        $path = Join-Path $TestDrive 'summary.html'
        Write-LabHtml @($report) $path
        Write-LabReport $report $TestDrive 'fixture'
        $html = Get-Content -LiteralPath $path -Raw
        # Windows PowerShell's JSON serializer may escape angle brackets before HTML encoding.
        if ($html -match '<script>' -or $html -notmatch '(&lt;script&gt;|\\u003cscript\\u003e)' -or $html -notmatch '&lt;fixture&gt;') { throw 'HTML not escaped' }
        $saved = Get-Content -LiteralPath (Join-Path $TestDrive 'fixture.json') -Raw
        if ($saved -match 'SYNTHETIC-LOCAL-PATH') { throw 'Caller-only artifact path published' }
        if (($saved | ConvertFrom-Json).Checks[0].Status -ne 'INFO') { throw 'JSON status lost' }
    }
}

Describe 'Controlled backup safety and real content verification' {
    BeforeEach {
        $scriptPath = Join-Path $PSScriptRoot '..\scripts\Invoke-BackupRestoreTest.ps1'
        $fixtureRoot = Join-Path $TestDrive ([guid]::NewGuid().ToString('N'))
        $sourcePath = Join-Path $fixtureRoot 'source'
        $outputPath = Join-Path $fixtureRoot 'output'
        New-Item -ItemType Directory -Path (Join-Path $sourcePath 'nested') -Force | Out-Null
        'Synthetic content' | Set-Content -LiteralPath (Join-Path $sourcePath 'nested\name [fixture].txt') -Encoding UTF8
        'Other synthetic content' | Set-Content -LiteralPath (Join-Path $sourcePath 'second.txt') -Encoding UTF8
    }
    It 'Restores nested and wildcard-like names with equal hashes and unchanged originals' {
        $before = (Get-FileHash -LiteralPath (Join-Path $sourcePath 'second.txt') -Algorithm SHA256).Hash
        $result = & $scriptPath -SourceDirectory $sourcePath -OutputDirectory $outputPath -FailOnMismatch
        if ($result.Checks[0].Status -ne 'PASS' -or $result.Checks[0].Data.Count -ne 2) { throw 'Verification failed' }
        foreach ($row in $result.Checks[0].Data) {
            if ($row.OriginalHash -ne $row.BackupHash -or $row.OriginalHash -ne $row.RestoredHash) { throw 'Digest differs' }
            if (-not (Test-Path -LiteralPath (Join-Path $result.ArtifactDirectory ('restore\' + $row.File)))) { throw 'Restore missing' }
        }
        if ($before -ne (Get-FileHash -LiteralPath (Join-Path $sourcePath 'second.txt') -Algorithm SHA256).Hash) { throw 'Original changed' }
    }
    It 'Detects a later content modification in a restored file' {
        . (Join-Path $PSScriptRoot '..\scripts\Private\Common.ps1')
        $result = & $scriptPath -SourceDirectory $sourcePath -OutputDirectory $outputPath
        $row = $result.Checks[0].Data | Where-Object File -eq 'second.txt'
        $restored = Join-Path $result.ArtifactDirectory 'restore\second.txt'
        Add-Content -LiteralPath $restored -Value 'Controlled synthetic modification'
        $changed = (Get-FileHash -LiteralPath $restored -Algorithm SHA256).Hash
        if (Test-LabHashMatch $row.OriginalHash $row.BackupHash $changed) { throw 'Changed content accepted' }
    }
    It 'Rejects an empty source instead of reporting PASS' {
        $empty = Join-Path $fixtureRoot 'empty'
        New-Item -ItemType Directory -Path $empty | Out-Null
        $caught = $false
        try { & $scriptPath -SourceDirectory $empty -OutputDirectory $outputPath | Out-Null }
        catch { $caught = $_.Exception.Message -match 'no files' }
        if (-not $caught) { throw 'Empty source was not rejected' }
    }
    It 'Rejects identical nested and ancestor output paths before creating artifacts' {
        foreach ($destination in @($sourcePath,(Join-Path $sourcePath 'output'),$fixtureRoot)) {
            $caught = $false
            try { & $scriptPath -SourceDirectory $sourcePath -OutputDirectory $destination | Out-Null }
            catch { $caught = $_.Exception.Message -match 'non-overlapping' }
            if (-not $caught) { throw "Overlapping path accepted: $destination" }
        }
    }
    It 'Records FAIL when a copy operation fails' {
        Mock Copy-Item { throw 'Synthetic copy denial' }
        $result = & $scriptPath -SourceDirectory $sourcePath -OutputDirectory $outputPath
        if ($result.Checks[0].Status -ne 'FAIL' -or @($result.Checks[0].Data | Where-Object Status -eq 'PASS').Count) { throw 'Copy failure became PASS' }
    }
    It 'Rejects junction traversal before descending on Windows' {
        if ([Environment]::OSVersion.Platform -ne 'Win32NT') { return }
        $link = Join-Path $sourcePath 'junction'
        New-Item -ItemType Directory -Path $outputPath -ErrorAction Stop | Out-Null
        New-Item -ItemType Junction -Path $link -Target $outputPath -ErrorAction Stop | Out-Null
        $caught = $false
        try { & $scriptPath -SourceDirectory $sourcePath -OutputDirectory (Join-Path $fixtureRoot 'other-output') | Out-Null }
        catch { $caught = $_.Exception.Message -match 'reparse point' }
        if (-not $caught) { throw 'Junction not rejected' }
    }
}
