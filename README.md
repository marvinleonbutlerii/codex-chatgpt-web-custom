# Codex ChatGPT Web custom integrations

Patch-only distribution of the existing custom integrations for [codex-chatgpt-web](https://github.com/miuuyy/codex-chatgpt-web). This is not a standalone Codex fork or an application installer. Generated binaries, browser profiles, credentials, global Codex configuration, skills, and research documents are not included.

## Release `v5.0.8-custom.1`

- Upstream package version: `5.0.8`.
- Exact upstream base: `eaf4f09ae92d4dc4429fa597b0861663138f08f8` (upstream `main` inspected September 22, 2026).
- Custom source commit: `8880ef46404571bfc32e5537358d1c08952c25e6`.
- Runtime requirement retained from the custom line: Bun `1.4.2`.
- Patch: `codex-chatgpt-web-custom-v5.0.8.patch`.

**The base is no longer the original `v5.0.8` tag.** Use the exact commit below. The refreshed patch contains only the custom delta against that base; upstream changes are not republished as custom changes. Do not apply this package on top of an older custom patch or an edited checkout.

### Changes in this revision

- Retain six-part multipart journal records after restart, preventing automatic replay of uncertain sends. Existing two-part behavior and legacy three-part recovery guards remain supported.
- Partition immutable MCP context once per envelope, reuse it for sequential/repeated chunk reads, and keep the cached array private. Exact payloads, hashes, and Unicode boundaries are preserved.
- Validate persisted continuation ancestry without repeatedly materializing full histories. Missing parents and cycles are rejected while valid shared branches survive.
- Check patch integrity, exact base, clean checkout, and native Git exit codes before application.

The patch retains the existing custom MCP context and skill transport, continuation/compaction handling, bridge diagnostics, and launcher/runtime integration. It does not introduce a new bridge, UI, database, runtime upgrade, or global instruction changes. The upstream MIT notice is in `LICENSE-upstream.txt`.

## Apply to a fresh upstream checkout

Extract the release ZIP separately from the upstream checkout, then run:

```powershell
git clone https://github.com/miuuyy/codex-chatgpt-web.git
git -C codex-chatgpt-web checkout --detach eaf4f09ae92d4dc4429fa597b0861663138f08f8
& C:/path/to/custom-integrations/scripts/apply.ps1 -UpstreamPath ./codex-chatgpt-web
```

Use `scripts/verify.ps1 -UpstreamPath <checkout>` for a non-mutating checksum/base/applicability check. `manifest.json` records the source tree and patch hash; `SHA256SUMS.txt` covers the distribution files. The scripts stop on failed Git commands and refuse dirty or wrong-base checkouts.

After applying, follow the patched upstream build instructions with Bun `1.4.2`. This package does not build, install, restart, or modify the running application. Preserve any existing checkout for rollback; adoption should use a separate checkout rather than overwriting local changes.

## Validation boundary

TypeScript typecheck and 17 focused regression tests passed for the changed source paths, including multipart restart safety, Unicode context reads, adapter handoff, and continuation persistence. Applying the released patch to its exact clean base reconstructs the committed source tree. No live ChatGPT session, target application launch, full release suite, or platform installer validation was performed. This is a source-patch prerelease, not a claim of a fully validated packaged application.

