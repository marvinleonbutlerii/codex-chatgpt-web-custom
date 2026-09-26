# v6.1.1-custom.3

Custom-integrations-only source-patch prerelease for upstream codex-chatgpt-web `v6.1.1`, based on commit `a13cd09950969f43e3b7e25c71fa43efaf5446c5`.

The application/runtime delta is unchanged from `v6.1.1-custom.2`. This release hardens the patched project's GitHub Actions supply chain by replacing every mutable third-party action tag with a full, upstream-verified commit SHA. Distribution publishing is also draft-first so assets can be assembled and verified before publication; repository-level GitHub release immutability remains the required publication setting for locking the final tag/assets and generating GitHub's release attestation.

## Highlights

- Durable journal guards against duplicate browser sends after ambiguous submission or restart; bounded abortable retries and privacy-safe turn telemetry.
- Large Full-mode context moves to an exact SHA-256-identified MCP read channel; Bigger Context fragments oversized records and budgets six-part compaction safely.
- Canonical immutable, namespace-aware tool registry unifies discovery and invocation; Responses Lite preserves namespaced custom/freeform/tool-search tools.
- Stronger retained compaction, response ancestry/replay, and helper/browser lifecycle safety.
- Native V2 subagent flags are deterministically enabled and restored; launcher debugging-port and Windows package-smoke checks are hardened.
- All third-party actions used by the patched upstream CI/release workflows are pinned to full verified commit SHAs.
- Release automation validates exact asset inventories and digests, uses draft-first publication, and refuses to clobber mismatched assets.

## Validation

- Root typecheck: passed.
- Launcher typecheck: passed during the Windows package build.
- Root tests: 849 passed, 27 skipped, 0 failed.
- Launcher tests: 354 passed, 4 skipped, 0 failed.
- `git apply --check --binary` on a clean upstream `v6.1.1` checkout: passed.
- Application/runtime files are unchanged from `v6.1.1-custom.2`; this release's source delta beyond `.2` is confined to GitHub workflow action references.

This is a source patch, not a desktop installer or auto-updater. No live application was installed, relaunched, or changed by the source-patch workflow. To adopt the patch, apply it to a separate clean checkout and follow the upstream build/deploy instructions.

Patched source tree: `c63feecb94bfc958c51b42a1f95b323cb2053b76`.
