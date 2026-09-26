# Codex ChatGPT Web custom integrations

This repository distributes the custom integrations as source patches against the upstream [codex-chatgpt-web](https://github.com/miuuyy/codex-chatgpt-web) project. It is not a standalone application, installer, or auto-updater. Release artifacts do not include generated binaries, browser profiles, credentials, personal Codex configuration, or research documents.

## Release `v6.0.0-custom.1`

- Upstream version: `6.0.0`.
- Exact clean base: upstream tag `v6.0.0`, commit `212ceef2acac9d6ee0f3c9037abfaf4ad8ff9827`.
- Rebased custom source commit: `ff9a3f4f83d652ffcc100a782ddb1a86991300d3`.
- Patch: `codex-chatgpt-web-custom-v6.0.0.patch`.
- Runtime requirement: Bun `1.4.2`.

The patch is intended for a fresh, clean checkout at the exact base above. Do not apply it on top of the older `v5.0.8-custom.1` patch, another custom release, or a modified checkout.

### What this custom delta adds

- More reliable large-context transport, bounded chunk handling, and persisted recovery for interrupted/uncertain sends.
- Better retention and validation of conversation ancestry and response state during continuation and compaction.
- Custom MCP/skill context integration, tool routing, and bridge/turn diagnostics.
- Browser/launcher hardening and focused regression coverage for the retained integrations.

The delta retains existing project behavior where compatible with upstream 6.0.0. It is a source change set, not a claim that a packaged desktop build or live ChatGPT session was validated.

## Apply to a fresh upstream checkout

Keep your current checkout as a rollback copy. Clone or use a separate fresh checkout, then pin it to the exact base:

```powershell
git clone https://github.com/miuuyy/codex-chatgpt-web.git
git -C codex-chatgpt-web checkout --detach 212ceef2acac9d6ee0f3c9037abfaf4ad8ff9827
& C:/path/to/custom-integrations/scripts/verify.ps1 -UpstreamPath ./codex-chatgpt-web
& C:/path/to/custom-integrations/scripts/apply.ps1 -UpstreamPath ./codex-chatgpt-web
```

The apply script checks the patch checksum, exact base, clean worktree, and Git applicability before modifying the checkout. Build the patched source using the upstream instructions and Bun `1.4.2`. The patch does not install, restart, or update an already-running app; adopting it is a separate manual build/deploy step.

## Validation

The rebased tree passed root and launcher typechecks, the full root test suite (829 passed, 1 skipped), and the full launcher suite (340 passed, 4 skipped). The generated patch was applied with `git apply --check` to a clean checkout at the exact upstream tag. No live application, ChatGPT session, or platform installer was launched or validated. See `manifest.json` and `RELEASE_NOTES.md` for the release record.
