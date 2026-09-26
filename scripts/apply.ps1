param(
  [Parameter(Mandatory=$true)]
  [string]$UpstreamPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Invoke-GitCapture {
  param(
    [Parameter(Mandatory=$true)]
    [string]$Repository,
    [Parameter(Mandatory=$true)]
    [string[]]$GitArgs
  )

  $output = @(& git -C $Repository @GitArgs)
  $exitCode = $LASTEXITCODE
  if ($exitCode -ne 0) {
    throw "git $($GitArgs -join ' ') failed with exit code $exitCode"
  }
  return $output
}

& (Join-Path $PSScriptRoot 'verify.ps1') -UpstreamPath $UpstreamPath

$checkout = (Resolve-Path -LiteralPath $UpstreamPath).Path
$packageRoot = Split-Path $PSScriptRoot -Parent
$manifest = Get-Content -LiteralPath (Join-Path $packageRoot 'manifest.json') -Raw | ConvertFrom-Json
$patch = Join-Path $packageRoot $manifest.patch

Invoke-GitCapture -Repository $checkout -GitArgs @('apply', '--binary', $patch) | Out-Null

$tempIndex = Join-Path ([IO.Path]::GetTempPath()) ("codex-applied-tree-$([guid]::NewGuid().ToString('N')).index")
$oldIndex = [Environment]::GetEnvironmentVariable('GIT_INDEX_FILE', 'Process')
try {
  $env:GIT_INDEX_FILE = $tempIndex
  Invoke-GitCapture -Repository $checkout -GitArgs @('read-tree', 'HEAD') | Out-Null
  Invoke-GitCapture -Repository $checkout -GitArgs @('add', '-A') | Out-Null
  $actualSourceTree = Invoke-GitCapture -Repository $checkout -GitArgs @('write-tree') | Select-Object -First 1
  if ($actualSourceTree -ne $manifest.sourceTree) {
    throw "Applied source tree mismatch: expected $($manifest.sourceTree), found $actualSourceTree"
  }
}
finally {
  if ($null -eq $oldIndex) {
    Remove-Item Env:GIT_INDEX_FILE -ErrorAction SilentlyContinue
  }
  else {
    $env:GIT_INDEX_FILE = $oldIndex
  }
  Remove-Item -LiteralPath $tempIndex -Force -ErrorAction SilentlyContinue
}

Write-Output "Applied $($manifest.patch) and verified source tree $($manifest.sourceTree)"
