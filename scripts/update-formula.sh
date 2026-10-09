#!/usr/bin/env bash
# Syncs Formula/roc.rb with the Roc release pinned in the website's install_roc.sh, and with the
# roc-lang/examples revision pinned in the website's examples.json (used by the formula's test).
# Usage: scripts/update-formula.sh [website-ref]   (default: main; needs gh and curl)
set -euo pipefail

WEBSITE_REPO=roc-lang/www.roc-lang.org
EXAMPLES_REPO=roc-lang/examples
FORMULA="$(cd "$(dirname "$0")/.." && pwd)/Formula/roc.rb"

# Resolve to a commit so both files come from the same website state.
sha="$(gh api "repos/$WEBSITE_REPO/commits/${1:-main}" --jq .sha)"
raw() { curl --proto '=https' --tlsv1.2 -fsSL "https://raw.githubusercontent.com/$WEBSITE_REPO/$sha/website/$1"; }
install_sh="$(raw public/install_roc.sh)"
examples_json="$(raw examples.json)"

# Reads `NAME="value"` from install_roc.sh.
var() { sed -nE "s/^$1=\"([^\"]*)\"\$/\1/p" <<<"$install_sh"; }

date="$(var VERSION_DATE)"
build="$(var BUILD_ID)"
if [[ ! "$date" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ || ! "$build" =~ ^[0-9a-f]{7,40}$ ]]; then
  echo "error: could not parse VERSION_DATE/BUILD_ID from install_roc.sh" >&2
  exit 1
fi
new_version="$date-$build"
old_version="$(sed -nE 's/^  version "(.*)"$/\1/p' "$FORMULA")"

# Formula platform -> variable in install_roc.sh (parallel arrays: macOS ships bash 3.2)
PLATFORMS=(macos_apple_silicon macos_x86_64 linux_arm64 linux_x86_64)
SHA_VARS=(SHA_MACOS_ARM64 SHA_MACOS_X86_64 SHA_LINUX_ARM64 SHA_LINUX_X86_64)
shas=()
for i in "${!PLATFORMS[@]}"; do
  sha_value="$(var "${SHA_VARS[$i]}")"
  if [[ ! "$sha_value" =~ ^[0-9a-f]{64}$ ]]; then
    echo "error: no valid ${SHA_VARS[$i]} in install_roc.sh" >&2
    exit 1
  fi
  shas+=("$sha_value")
done

examples_repo_url="$(sed -nE 's/^ *"repository": *"([^"]*)".*/\1/p' <<<"$examples_json")"
new_rev="$(sed -nE 's/^ *"revision": *"([^"]*)".*/\1/p' <<<"$examples_json")"
if [ "$examples_repo_url" != "https://github.com/$EXAMPLES_REPO" ] || [[ ! "$new_rev" =~ ^[0-9a-f]{40}$ ]]; then
  echo "error: unexpected repository/revision in examples.json" >&2
  exit 1
fi
old_rev="$(sed -nE 's#^    url "https://github.com/'"$EXAMPLES_REPO"'/archive/([0-9a-f]{40})\.tar\.gz"$#\1#p' "$FORMULA")"

OLD="$old_version" NEW="$new_version" \
  perl -0777 -pi -e 's/\Q$ENV{OLD}\E/$ENV{NEW}/g or die "old version not found\n"' "$FORMULA"
for i in "${!PLATFORMS[@]}"; do
  PLATFORM="${PLATFORMS[$i]}" SHA="${shas[$i]}" \
    perl -0777 -pi -e 's/(roc_nightly-\Q$ENV{PLATFORM}\E-[^"]*"\n\s*sha256 ")[0-9a-f]{64}/$1$ENV{SHA}/ or die "no sha256 line for $ENV{PLATFORM}\n"' "$FORMULA"
done

if [ "$new_rev" != "$old_rev" ]; then
  tmp="$(mktemp)"
  trap 'rm -f "$tmp"' EXIT
  curl --proto '=https' --tlsv1.2 -fsSL -o "$tmp" "https://github.com/$EXAMPLES_REPO/archive/$new_rev.tar.gz"
  examples_sha="$(shasum -a 256 "$tmp" | awk '{print $1}')"
  OLD="$old_rev" NEW="$new_rev" SHA="$examples_sha" \
    perl -0777 -pi -e 's/\Q$ENV{OLD}\E(\.tar\.gz"\n\s*sha256 ")[0-9a-f]{64}/$ENV{NEW}$1$ENV{SHA}/ or die "examples resource not found\n"' "$FORMULA"
fi

echo "Roc: $old_version -> $new_version, examples: ${old_rev:0:7} -> ${new_rev:0:7} (website $sha)"
