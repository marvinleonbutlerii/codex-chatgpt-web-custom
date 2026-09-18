param(
  [Parameter(Mandatory=$true)]
  [string]$UpstreamPath
)

$ErrorActionPreference = 'Stop'
$base = '00aab23eb78a0d35ab575ff14044e29c0f80e711'
$patch = Join-Path $PSScriptRoot '..\codex-chatgpt-web-custom-v5.0.8.patch'
$head = (git -C $UpstreamPath rev-parse HEAD).Trim()
if ($head -ne $base) {
  throw "Expected upstream v5.0.8 commit $base, found $head"
}
git -C $UpstreamPath apply --check --binary $patch
Write-Output "Patch applies cleanly to $head"
