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

$packageRoot = Split-Path $PSScriptRoot -Parent
$manifestPath = Join-Path $packageRoot 'manifest.json'
$manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json

if ($manifest.upstream -ne 'https://github.com/miuuyy/codex-chatgpt-web') {
  throw 'Unexpected upstream URL in manifest.json'
}
if ($manifest.upstreamVersion -notmatch '^\d+\.\d+\.\d+$') {
  throw 'upstreamVersion must be a semantic version'
}
if ($manifest.baseRef -ne "v$($manifest.upstreamVersion)") {
  throw 'baseRef must match upstreamVersion'
}
if ($manifest.baseCommit -notmatch '^[0-9a-f]{40}$') {
  throw 'baseCommit must be a full Git commit id'
}
$releasePattern = '^v' + [regex]::Escape([string]$manifest.upstreamVersion) + '-custom\.[0-9]+$'
if ($manifest.release -notmatch $releasePattern) {
  throw 'release must match upstreamVersion and use the custom prerelease form'
}
$expectedPatchName = "codex-chatgpt-web-custom-v$($manifest.upstreamVersion).patch"
if ($manifest.patch -ne $expectedPatchName) {
  throw "patch must be named $expectedPatchName"
}
if ($manifest.patchSha256 -notmatch '^[0-9a-f]{64}$') {
  throw 'patchSha256 must be a full SHA-256 digest'
}
if ($manifest.sourceTree -notmatch '^[0-9a-f]{40}$') {
  throw 'sourceTree must be a full Git tree id'
}

$patch = Join-Path $packageRoot $manifest.patch
if (-not (Test-Path -LiteralPath $patch -PathType Leaf)) {
  throw "Patch file not found: $($manifest.patch)"
}
$actualPatchSha = (Get-FileHash -LiteralPath $patch -Algorithm SHA256).Hash.ToLowerInvariant()
if ($actualPatchSha -ne $manifest.patchSha256) {
  throw 'Patch SHA-256 does not match manifest.json'
}

$checkout = (Resolve-Path -LiteralPath $UpstreamPath).Path
$top = Invoke-GitCapture -Repository $checkout -GitArgs @('rev-parse', '--show-toplevel') | Select-Object -First 1
$resolvedTop = (Resolve-Path -LiteralPath $top).Path
if ($checkout -ne $resolvedTop) { throw 'UpstreamPath must be the repository root' }
$head = Invoke-GitCapture -Repository $checkout -GitArgs @('rev-parse', 'HEAD') | Select-Object -First 1
if ($head -ne $manifest.baseCommit) {
  throw "Expected upstream commit $($manifest.baseCommit), found $head"
}
$status = @(Invoke-GitCapture -Repository $checkout -GitArgs @('status', '--porcelain', '--untracked-files=all'))
if ($status.Count -gt 0) { throw 'Upstream checkout must be clean, including untracked files' }

$numstat = @(Invoke-GitCapture -Repository $checkout -GitArgs @('apply', '--numstat', '--binary', $patch))
$filesChanged = 0L
$insertions = 0L
$deletions = 0L
foreach ($line in $numstat) {
  $parts = $line -split "`t", 3
  if ($parts.Count -lt 3) { throw "Unexpected git apply --numstat output: $line" }
  $filesChanged++
  if ($parts[0] -match '^\d+$') { $insertions += [int64]$parts[0] }
  elseif ($parts[0] -ne '-') { throw "Unexpected insertion count: $($parts[0])" }
  if ($parts[1] -match '^\d+$') { $deletions += [int64]$parts[1] }
  elseif ($parts[1] -ne '-') { throw "Unexpected deletion count: $($parts[1])" }
}
if ($filesChanged -ne [int64]$manifest.patchSummary.filesChanged -or
    $insertions -ne [int64]$manifest.patchSummary.insertions -or
    $deletions -ne [int64]$manifest.patchSummary.deletions) {
  throw "Patch summary mismatch: found $filesChanged files, $insertions insertions, $deletions deletions"
}

Invoke-GitCapture -Repository $checkout -GitArgs @('apply', '--check', '--binary', $patch) | Out-Null

$tempIndex = Join-Path ([IO.Path]::GetTempPath()) ("codex-source-patch-$([guid]::NewGuid().ToString('N')).index")
$oldIndex = [Environment]::GetEnvironmentVariable('GIT_INDEX_FILE', 'Process')
try {
  $env:GIT_INDEX_FILE = $tempIndex
  Invoke-GitCapture -Repository $checkout -GitArgs @('read-tree', $manifest.baseCommit) | Out-Null
  Invoke-GitCapture -Repository $checkout -GitArgs @('apply', '--cached', '--binary', $patch) | Out-Null
  $actualSourceTree = Invoke-GitCapture -Repository $checkout -GitArgs @('write-tree') | Select-Object -First 1
  if ($actualSourceTree -ne $manifest.sourceTree) {
    throw "Patched source tree mismatch: expected $($manifest.sourceTree), found $actualSourceTree"
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

Write-Output "Patch checksum, summary, applicability, and source tree verified against $head"
