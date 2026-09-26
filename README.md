# Codex ChatGPT Web custom integrations

This repository distributes the custom integrations as source patches against the upstream [codex-chatgpt-web](https://github.com/miuuyy/codex-chatgpt-web) project. It is not a standalone application, installer, or auto-updater. Release artifacts do not include generated binaries, browser profiles, credentials, personal Codex configuration, or research documents.

## Release `v6.1.1-custom.1`

- Upstream version: `6.1.1`.
- Exact clean base: upstream tag `v6.1.1`, commit `a13cd09950969f43e3b7e25c71fa43efaf5446c5`.
- Rebased custom source commit: `92f697374a9175297dbf5825ccb0127314be5100`.
- Patch: `codex-chatgpt-web-custom-v6.1.1.patch` (SHA-256 `447c634d6a85c878f16109d52150bdefe56ab4dad7cbd4bfa895bf4ee8c8906d`).
- Delta: 87 files, 6,207 insertions, 842 deletions.
- Runtime requirement: Bun `1.4.2`.

The patch is intended for a fresh, clean checkout at the exact base above. Do not apply it on top of the older `v5.0.8-custom.1`, `v6.0.0-custom.1`, or `v6.1.0-custom.1` patch, another custom release, or a modified checkout.

### What this custom delta adds

- Durable in-flight send recovery that blocks duplicate browser submissions after ambiguous sends or restarts, plus bounded retry and privacy-safe timing telemetry.
- Exact SHA-256-identified, chunked MCP transport for large canonical Full-mode context; improved six-part Bigger Context staging and compaction budgeting.
- One immutable, namespace-aware Codex tool registry shared by discovery and invocation, with stricter tool identity checks and fuller custom/freeform/tool-search preservation.
- Stronger retained-turn, native compaction, response ancestry, replay, and browser-helper lifecycle handling.
- Deterministic Native V2 subagent feature ownership/restoration, plus browser debugging-port and Windows package-smoke hardening.
- Bun 1.4.2 license/dependency updates and a stricter source-patch release workflow that validates exact release assets and checksums without clobbering mismatches.

The delta carries the custom integrations forward onto upstream 6.1.1 while retaining existing project behavior where compatible. It is a source change set, not a claim that a live ChatGPT session was validated.

## Apply to a fresh upstream checkout

Keep your current checkout as a rollback copy. Clone or use a separate fresh checkout, then pin it to the exact base:

```powershell
git clone https://github.com/miuuyy/codex-chatgpt-web.git
git -C codex-chatgpt-web checkout --detach a13cd09950969f43e3b7e25c71fa43efaf5446c5
& C:/path/to/custom-integrations/scripts/verify.ps1 -UpstreamPath ./codex-chatgpt-web
& C:/path/to/custom-integrations/scripts/apply.ps1 -UpstreamPath ./codex-chatgpt-web
```

The apply script checks the patch checksum, exact base, clean worktree, and Git applicability before modifying the checkout. Build the patched source using the upstream instructions and Bun `1.4.2`. The patch does not install, restart, or update an already-running app; adopting it is a separate manual build/deploy step.

## Validation

Validation results for this release are recorded in `RELEASE_NOTES.md` and `manifest.json`. The patch is checked against a clean checkout at the exact upstream tag by the release workflow. No live ChatGPT session is included in source-patch validation.
