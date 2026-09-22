# v5.0.8-custom.1

Custom-integrations-only source patch for codex-chatgpt-web 5.0.8, based on upstream commit `eaf4f09ae92d4dc4429fa597b0861663138f08f8`.

## Changes

- Fix six-part journal recovery so uncertain sends remain protected against automatic replay; retain legacy three-part records.
- Reuse immutable MCP context partitions without changing payload fidelity or exposing cached arrays.
- Remove repeated full-history materialization from continuation snapshot ancestry validation.
- Refresh the existing custom delta against the current upstream base and make patch application fail on checksum, base, cleanliness, or Git errors.

## Use

Download and extract `codex-chatgpt-web-custom-v5.0.8-custom.1.zip`; follow its README and apply script against a fresh checkout at the exact base commit. The original upstream `v5.0.8` tag and previously patched checkouts are not valid application targets. Bun remains pinned to `1.4.2` in the custom source.

The ZIP contains the patch, pinned manifest, SHA-256 checksums, apply/verify scripts, documentation, and upstream license. The standalone patch, manifest, and checksum files are also attached. No full upstream source mirror, credentials, profiles, global configuration, or installer is included.

## Validation

- TypeScript typecheck passed.
- 17 focused regression tests passed.
- Clean-base patch reconstruction matches the committed custom source tree.

Source commit: `8880ef46404571bfc32e5537358d1c08952c25e6`.

This prerelease distributes source integration changes only. No live ChatGPT/application launch, installation, full release suite, or cross-platform packaged-app validation was performed. Existing installations were left unchanged.
