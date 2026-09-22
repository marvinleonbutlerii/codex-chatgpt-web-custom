param(
  [Parameter(Mandatory=$true)]
  [string]$UpstreamPath
)

$ErrorActionPreference = 'Stop'
& (Join-Path $PSScriptRoot 'verify.ps1') -UpstreamPath $UpstreamPath
$packageRoot = Split-Path $PSScriptRoot -Parent
$manifest = Get-Content -LiteralPath (Join-Path $packageRoot 'manifest.json') -Raw | ConvertFrom-Json
$patch = Join-Path $packageRoot $manifest.patch
git -C $UpstreamPath apply --binary $patch
if ($LASTEXITCODE -ne 0) { throw 'Patch application failed' }
Write-Output "Applied $($manifest.patch) to $UpstreamPath"
