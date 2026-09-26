#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

command -v jq >/dev/null || { echo "jq is required" >&2; exit 1; }
command -v sha256sum >/dev/null || { echo "sha256sum is required" >&2; exit 1; }

upstream_url="$(jq -er '.upstream' manifest.json)"
base_ref="$(jq -er '.baseRef' manifest.json)"
base_commit="$(jq -er '.baseCommit' manifest.json)"
release_name="$(jq -er '.release' manifest.json)"
patch_name="$(jq -er '.patch' manifest.json)"
expected_patch_sha="$(jq -er '.patchSha256' manifest.json)"

[[ "$upstream_url" == "https://github.com/miuuyy/codex-chatgpt-web" ]] || {
  echo "Unexpected upstream URL in manifest.json" >&2
  exit 1
}
[[ "$base_ref" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]] || {
  echo "baseRef must be an upstream version tag" >&2
  exit 1
}
[[ "$base_commit" =~ ^[0-9a-f]{40}$ ]] || {
  echo "baseCommit must be a full Git commit id" >&2
  exit 1
}
[[ "$release_name" =~ ^v[0-9]+\.[0-9]+\.[0-9]+-custom\.[0-9]+$ ]] || {
  echo "release must be a custom prerelease tag" >&2
  exit 1
}
[[ "$patch_name" =~ ^codex-chatgpt-web-custom-v[0-9]+\.[0-9]+\.[0-9]+\.patch$ ]] || {
  echo "patch must be a versioned source patch filename" >&2
  exit 1
}
[[ "$expected_patch_sha" =~ ^[0-9a-f]{64}$ ]] || {
  echo "patchSha256 must be a full SHA-256 digest" >&2
  exit 1
}
[[ -f "$patch_name" ]] || {
  echo "Patch file not found: $patch_name" >&2
  exit 1
}

actual_patch_sha="$(sha256sum "$patch_name" | cut -d ' ' -f 1)"
[[ "$actual_patch_sha" == "$expected_patch_sha" ]] || {
  echo "Patch SHA-256 does not match manifest.json" >&2
  exit 1
}
sha256sum --check --strict SHA256SUMS.txt

if [[ "${GITHUB_REF_TYPE:-}" == "tag" && "${GITHUB_REF_NAME:-}" != "$release_name" ]]; then
  echo "Git tag ${GITHUB_REF_NAME} does not match manifest release $release_name" >&2
  exit 1
fi

verification_ref="refs/codex-upstream-verification/$base_ref"
git fetch --no-tags --depth=1 "$upstream_url" \
  "+refs/tags/$base_ref:$verification_ref"
actual_base_commit="$(git rev-parse "$verification_ref^{commit}")"
[[ "$actual_base_commit" == "$base_commit" ]] || {
  echo "Upstream tag $base_ref resolved to $actual_base_commit, expected $base_commit" >&2
  exit 1
}

tmp_dir="$(mktemp -d)"
base_path="$tmp_dir/upstream"
cleanup() {
  git worktree remove --force "$base_path" >/dev/null 2>&1 || true
  rmdir "$tmp_dir" >/dev/null 2>&1 || true
}
trap cleanup EXIT

git worktree add --detach "$base_path" "$actual_base_commit"
[[ -z "$(git -C "$base_path" status --porcelain --untracked-files=all)" ]] || {
  echo "Fetched upstream worktree is unexpectedly dirty" >&2
  exit 1
}
git -C "$base_path" apply --check --binary "$repo_root/$patch_name"
echo "Verified $release_name against upstream $base_ref ($base_commit)"
