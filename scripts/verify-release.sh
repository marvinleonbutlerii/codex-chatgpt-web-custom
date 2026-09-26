#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

command -v jq >/dev/null || { echo "jq is required" >&2; exit 1; }
command -v sha256sum >/dev/null || { echo "sha256sum is required" >&2; exit 1; }

upstream_url="$(jq -er '.upstream' manifest.json)"
upstream_version="$(jq -er '.upstreamVersion' manifest.json)"
base_ref="$(jq -er '.baseRef' manifest.json)"
base_commit="$(jq -er '.baseCommit' manifest.json)"
release_name="$(jq -er '.release' manifest.json)"
patch_name="$(jq -er '.patch' manifest.json)"
expected_patch_sha="$(jq -er '.patchSha256' manifest.json)"
expected_source_tree="$(jq -er '.sourceTree' manifest.json)"
expected_files="$(jq -er '.patchSummary.filesChanged' manifest.json)"
expected_insertions="$(jq -er '.patchSummary.insertions' manifest.json)"
expected_deletions="$(jq -er '.patchSummary.deletions' manifest.json)"

[[ "$upstream_url" == "https://github.com/miuuyy/codex-chatgpt-web" ]] || {
  echo "Unexpected upstream URL in manifest.json" >&2
  exit 1
}
[[ "$upstream_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || {
  echo "upstreamVersion must be a semantic version" >&2
  exit 1
}
[[ "$base_ref" == "v$upstream_version" ]] || {
  echo "baseRef must match upstreamVersion" >&2
  exit 1
}
[[ "$base_commit" =~ ^[0-9a-f]{40}$ ]] || {
  echo "baseCommit must be a full Git commit id" >&2
  exit 1
}
[[ "$release_name" =~ ^v[0-9]+\.[0-9]+\.[0-9]+-custom\.[0-9]+$ && "$release_name" == "v$upstream_version-custom."* ]] || {
  echo "release must match upstreamVersion and use the custom prerelease form" >&2
  exit 1
}
[[ "$patch_name" == "codex-chatgpt-web-custom-v$upstream_version.patch" ]] || {
  echo "patch filename must match upstreamVersion" >&2
  exit 1
}
[[ "$expected_patch_sha" =~ ^[0-9a-f]{64}$ ]] || {
  echo "patchSha256 must be a full SHA-256 digest" >&2
  exit 1
}
[[ "$expected_source_tree" =~ ^[0-9a-f]{40}$ ]] || {
  echo "sourceTree must be a full Git tree id" >&2
  exit 1
}
[[ "$expected_files" =~ ^[0-9]+$ && "$expected_insertions" =~ ^[0-9]+$ && "$expected_deletions" =~ ^[0-9]+$ ]] || {
  echo "patchSummary values must be non-negative integers" >&2
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

read -r actual_files actual_insertions actual_deletions < <(
  git apply --numstat --binary "$patch_name" |
    awk 'BEGIN { files=0; ins=0; del=0 }
      { files++; if ($1 ~ /^[0-9]+$/) ins += $1; if ($2 ~ /^[0-9]+$/) del += $2 }
      END { print files, ins, del }'
)
[[ "$actual_files" == "$expected_files" &&
   "$actual_insertions" == "$expected_insertions" &&
   "$actual_deletions" == "$expected_deletions" ]] || {
  echo "Patch summary mismatch: found $actual_files files, $actual_insertions insertions, $actual_deletions deletions" >&2
  exit 1
}

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
tmp_index="$tmp_dir/index"
cleanup() {
  rm -f "$tmp_index"
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

GIT_INDEX_FILE="$tmp_index" git -C "$base_path" read-tree "$actual_base_commit"
GIT_INDEX_FILE="$tmp_index" git -C "$base_path" apply --cached --binary "$repo_root/$patch_name"
actual_source_tree="$(GIT_INDEX_FILE="$tmp_index" git -C "$base_path" write-tree)"
[[ "$actual_source_tree" == "$expected_source_tree" ]] || {
  echo "Patched source tree resolved to $actual_source_tree, expected $expected_source_tree" >&2
  exit 1
}

echo "Verified $release_name against upstream $base_ref ($base_commit), source tree $expected_source_tree"
