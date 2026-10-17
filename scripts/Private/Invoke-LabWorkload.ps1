#requires -Version 5.1
[CmdletBinding()]
param([Parameter(Mandatory)][string]$OutputPath)
$ErrorActionPreference = 'Stop'
# Bounded to one process, three seconds and a two MiB disposable file.
$watch = [Diagnostics.Stopwatch]::StartNew()
$iterations = 0L
while ($watch.Elapsed.TotalSeconds -lt 3) {
    [math]::Sqrt(1234567) | Out-Null
    $iterations++
}
[pscustomobject]@{ Iterations=$iterations; ElapsedMs=$watch.ElapsedMilliseconds } |
    ConvertTo-Json | Set-Content -LiteralPath $OutputPath -Encoding UTF8
