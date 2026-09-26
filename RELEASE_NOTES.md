# v6.1.0-custom.1

Custom-integrations-only source-patch prerelease for upstream codex-chatgpt-web `v6.1.0`, based on commit `293341084ac7a1ddd2de12fede3706023f5b6474`.

## Highlights

- Durable journal guards against duplicate browser sends after ambiguous submission or restart; bounded abortable retries and privacy-safe turn telemetry.
- Large Full-mode context moves to an exact SHA-256-identified MCP read channel; Bigger Context fragments oversized records and budgets six-part compaction safely.
- Canonical immutable, namespace-aware tool registry unifies discovery and invocation; Responses Lite preserves namespaced custom/freeform/tool-search tools.
- Stronger retained compaction, response ancestry/replay, and helper/browser lifecycle safety.
- Native V2 subagent flags are deterministically enabled and restored; launcher debugging-port and Windows package-smoke checks are hardened.
- Release automation validates exact asset inventories and digests and refuses to clobber mismatched assets.

## Validation

- Root typecheck: passed.
- Launcher typecheck: passed.
- Root tests: 837 passed, 3 skipped, 0 failed.
- Launcher tests: 351 passed, 4 skipped, 0 failed.
- `git apply --check --binary` on a clean upstream `v6.1.0` checkout: passed.

This is a source patch, not a desktop installer or auto-updater. No live application was installed, relaunched, or changed. To adopt the patch, apply it to a separate clean checkout and follow the upstream build/deploy instructions.

Source commit: `36d2cd21e6c2f0f8619cdfbea7c54da2ebc9e3a7`.
