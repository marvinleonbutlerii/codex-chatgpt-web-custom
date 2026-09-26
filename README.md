# Codex ChatGPT Web custom integrations

This repository distributes the custom integrations as source patches against the upstream [codex-chatgpt-web](https://github.com/miuuyy/codex-chatgpt-web) project. It is not a standalone application, installer, or auto-updater. Release artifacts do not include generated binaries, browser profiles, credentials, personal Codex configuration, or research documents.

## Release `v6.1.0-custom.1`

- Upstream version: `6.1.0`.
- Exact clean base: upstream tag `v6.1.0`, commit `293341084ac7a1ddd2de12fede3706023f5b6474`.
- Rebased custom source commit: `36d2cd21e6c2f0f8619cdfbea7c54da2ebc9e3a7`.
- Patch: `codex-chatgpt-web-custom-v6.1.0.patch` (SHA-256 `61218729f1567e7975487554427355ae52b730d9e9f418385de374bada61f23a`).
- Delta: 87 files, 6,204 insertions, 912 deletions.
- Runtime requirement: Bun `1.4.2`.

The patch is intended for a fresh, clean checkout at the exact base above. Do not apply it on top of the older `v5.0.8-custom.1` or `v6.0.0-custom.1` patch, another custom release, or a modified checkout.

### What this custom delta adds

- Durable in-flight send recovery that blocks duplicate browser submissions after ambiguous sends or restarts, plus bounded retry and privacy-safe timing telemetry.
- Exact SHA-256-identified, chunked MCP transport for large canonical Full-mode context; improved six-part Bigger Context staging and compaction budgeting.
- One immutable, namespace-aware Codex tool registry shared by discovery and invocation, with stricter tool identity checks and fuller custom/freeform/tool-search preservation.
- Stronger retained-turn, native compaction, response ancestry, replay, and browser-helper lifecycle handling.
- Deterministic Native V2 subagent feature ownership/restoration, plus browser debugging-port and Windows package-smoke hardening.
- Bun 1.4.2 license/dependency updates and a stricter source-patch release workflow that validates exact release assets and checksums without clobbering mismatches.

The delta retains existing project behavior where compatible with upstream 6.1.0. It is a source change set, not a claim that a packaged desktop build or live ChatGPT session was validated.

## Apply to a fresh upstream checkout

Keep your current checkout as a rollback copy. Clone or use a separate fresh checkout, then pin it to the exact base:

```powershell
git clone https://github.com/miuuyy/codex-chatgpt-web.git
git -C codex-chatgpt-web checkout --detach 293341084ac7a1ddd2de12fede3706023f5b6474
& C:/path/to/custom-integrations/scripts/verify.ps1 -UpstreamPath ./codex-chatgpt-web
& C:/path/to/custom-integrations/scripts/apply.ps1 -UpstreamPath ./codex-chatgpt-web
```

The apply script checks the patch checksum, exact base, clean worktree, and Git applicability before modifying the checkout. Build the patched source using the upstream instructions and Bun `1.4.2`. The patch does not install, restart, or update an already-running app; adopting it is a separate manual build/deploy step.

## Validation

The rebased tree passed root and launcher typechecks, the full root test suite (837 passed, 3 skipped), and the full launcher suite (351 passed, 4 skipped). The generated patch was applied with `git apply --check` to a clean checkout at the exact upstream tag. No live application, ChatGPT session, or platform installer was launched or validated. See `manifest.json` and `RELEASE_NOTES.md` for the release record.
