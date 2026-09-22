param(
  [Parameter(Mandatory=$true)]
  [string]$UpstreamPath
)

$ErrorActionPreference = 'Stop'
$packageRoot = Split-Path $PSScriptRoot -Parent
$manifest = Get-Content -LiteralPath (Join-Path $packageRoot 'manifest.json') -Raw | ConvertFrom-Json
$patch = Join-Path $packageRoot $manifest.patch
if ((Get-FileHash -LiteralPath $patch -Algorithm SHA256).Hash -ne $manifest.patchSha256) {
  throw 'Patch SHA-256 does not match manifest.json'
}

$checkout = (Resolve-Path -LiteralPath $UpstreamPath).Path
$top = git -C $checkout rev-parse --show-toplevel
if ($LASTEXITCODE -ne 0) { throw 'UpstreamPath is not a Git working tree' }
$resolvedTop = (Resolve-Path -LiteralPath $top).Path
if ($checkout -ne $resolvedTop) { throw 'UpstreamPath must be the repository root' }
$head = git -C $checkout rev-parse HEAD
if ($LASTEXITCODE -ne 0) { throw 'Cannot resolve upstream HEAD' }
if ($head -ne $manifest.baseCommit) {
  throw "Expected upstream commit $($manifest.baseCommit), found $head"
}
$status = git -C $checkout status --porcelain --untracked-files=all
if ($LASTEXITCODE -ne 0) { throw 'Cannot inspect upstream worktree' }
if ($status) { throw 'Upstream checkout must be clean, including untracked files' }

git -C $checkout apply --check --binary $patch
if ($LASTEXITCODE -ne 0) { throw 'Patch applicability check failed; nothing was applied' }
Write-Output "Patch checksum and applicability verified against $head"
