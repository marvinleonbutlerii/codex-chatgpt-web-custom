# codex-chatgpt-web custom v5.0.8 delta

This directory contains only the changes reconstructed from the local custom line. It is a Git patch against the official upstream `v5.0.8` release; it is not a standalone source checkout and it intentionally excludes generated Electron packages and build output.

Base repository: https://github.com/miuuyy/codex-chatgpt-web
Base release: `v5.0.8`
Base peeled commit: `00aab23eb78a0d35ab575ff14044e29c0f80e711`
Patch file: `codex-chatgpt-web-custom-v5.0.8.patch`

## Apply to a clean upstream checkout

```powershell
git clone https://github.com/miuuyy/codex-chatgpt-web.git
Set-Location codex-chatgpt-web
git fetch --tags origin
git checkout --detach v5.0.8
git apply --check --binary C:/path/to/codex-chatgpt-web-custom-v5.0.8.patch
git apply --binary C:/path/to/codex-chatgpt-web-custom-v5.0.8.patch
```

The same operation is available as `scripts/apply.ps1 -UpstreamPath <checkout>`. The script refuses a checkout whose `HEAD` is not the recorded release commit and runs `git apply --check` before applying. Use `scripts/verify.ps1 -UpstreamPath <checkout>` for the non-mutating check.

The delta contains the local browser/launcher reliability work, MCP context and skill-file transport, native-network and telemetry diagnostics, launcher/runtime wiring, regression coverage, and the Windows packaged-smoke timeout needed for first-run Defender/runtime-copy overhead. The upstream MIT notice is preserved in `LICENSE-upstream.txt`.

The patch was applied successfully to a clean detached `v5.0.8` worktree and its normalized file contents matched the source worktree. Generated `launcher/artifacts*`, `dist`, and other packaging output are excluded.

