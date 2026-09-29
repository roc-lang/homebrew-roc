#!/usr/bin/env bash
# Points Formula/roc.rb at a roc-lang/nightlies release.
# Usage: scripts/update-formula.sh [nightly-YYYY-MM-DD-<sha>]   (default: latest release)
set -euo pipefail

NIGHTLIES_REPO=roc-lang/nightlies
PLATFORMS=(macos_apple_silicon macos_x86_64 linux_arm64 linux_x86_64)
FORMULA="$(cd "$(dirname "$0")/.." && pwd)/Formula/roc.rb"

tag="${1:-$(gh release view -R "$NIGHTLIES_REPO" --json tagName --jq .tagName)}"
if [[ ! "$tag" =~ ^nightly-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9a-f]{7,40}$ ]]; then
  echo "error: unexpected tag '$tag'" >&2
  exit 1
fi

new_version="${tag#nightly-}"
old_version="$(sed -nE 's/^  version "(.*)"$/\1/p' "$FORMULA")"
if [ "$new_version" = "$old_version" ]; then
  echo "Formula is already at $tag"
  exit 0
fi

# A nightly ships whichever platforms built that day; only take one that has all of ours.
# GitHub computes each asset's sha256 on upload, so nothing needs downloading here.
assets="$(gh release view "$tag" -R "$NIGHTLIES_REPO" --json assets --jq '.assets[] | "\(.name) \(.digest // "")"')"
shas=()
for platform in "${PLATFORMS[@]}"; do
  name="roc_nightly-$platform-$new_version.tar.gz"
  digest="$(awk -v n="$name" '$1 == n { print $2 }' <<<"$assets")"
  if [[ ! "$digest" =~ ^sha256:[0-9a-f]{64}$ ]]; then
    echo "error: $tag has no $name (or no sha256 digest for it)" >&2
    exit 1
  fi
  shas+=("${digest#sha256:}")
done

OLD="$old_version" NEW="$new_version" \
  perl -0777 -pi -e 's/\Q$ENV{OLD}\E/$ENV{NEW}/g or die "old version not found\n"' "$FORMULA"
for i in "${!PLATFORMS[@]}"; do
  PLATFORM="${PLATFORMS[$i]}" SHA="${shas[$i]}" \
    perl -0777 -pi -e 's/(roc_nightly-\Q$ENV{PLATFORM}\E-[^"]*"\n\s*sha256 ")[0-9a-f]{64}/$1$ENV{SHA}/ or die "no sha256 line for $ENV{PLATFORM}\n"' "$FORMULA"
done

echo "Updated formula from $old_version to $new_version"
