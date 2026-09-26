# v6.0.0-custom.1

Custom-integrations-only source-patch prerelease for upstream codex-chatgpt-web `v6.0.0`, based on commit `212ceef2acac9d6ee0f3c9037abfaf4ad8ff9827`.

## Highlights

- Hardened large-context/MCP transport and restart recovery, including guardrails against replaying uncertain sends.
- Improved continuation/compaction ancestry checks and response-state handling.
- Retained custom tool routing, bridge integration, browser/launcher reliability work, and regression tests on the upstream 6.0.0 base.
- Simplified the source-patch release contract: exact upstream tag and commit, SHA-256 verification, clean-tree requirement, applicability check, and a tag-triggered prerelease workflow.

## Validation

- Root typecheck: passed.
- Launcher typecheck: passed.
- Root tests: 829 passed, 1 skipped, 0 failed.
- Launcher tests: 340 passed, 4 skipped, 0 failed.
- `git apply --check --binary` on a clean upstream `v6.0.0` checkout: passed.

This is a source patch, not a desktop installer or auto-updater. No live application was installed, relaunched, or changed. To adopt the patch, apply it to a separate clean checkout and follow the upstream build/deploy instructions.

Source commit: `ff9a3f4f83d652ffcc100a782ddb1a86991300d3`.
