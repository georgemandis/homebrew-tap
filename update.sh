#!/usr/bin/env bash
set -euo pipefail

# Update all Homebrew formulas to their latest GitHub release versions.
# Usage: ./update.sh [formula_name]
#   No args: updates all formulas in Formula/
#   With arg: updates only that formula (e.g. ./update.sh loupe)

FORMULA_DIR="$(cd "$(dirname "$0")/Formula" && pwd)"

update_formula() {
  local rb="$1"
  local name
  name="$(basename "$rb" .rb)"

  # Extract repo from homepage
  local homepage
  homepage=$(grep -m1 'homepage' "$rb" | sed 's/.*"\(.*\)".*/\1/')
  local repo
  repo=$(echo "$homepage" | sed 's|https://github.com/||')

  # Optional tag prefix for monorepo-resident tools (read from a comment marker)
  local tag_prefix
  tag_prefix=$(grep -m1 '^[[:space:]]*# tag_prefix:' "$rb" 2>/dev/null | sed 's/^[[:space:]]*# tag_prefix:[[:space:]]*//; s/[[:space:]]*$//' | tr -d '\r' || echo "")

  # Get latest release tag
  local latest latest_version
  if [ -n "$tag_prefix" ]; then
    # Monorepo: pick the latest release whose tag starts with this product's prefix.
    latest=$(gh release list --repo "$repo" --limit 100 --json tagName -q "[.[].tagName | select(startswith(\"$tag_prefix\"))] | .[0]" 2>/dev/null | tr -d '\r') || latest=""
    if [ -z "$latest" ] || [ "$latest" = "null" ]; then
      echo "  ⏭  $name: no $tag_prefix* releases, skipping"
      return
    fi
    latest_version="${latest#$tag_prefix}"
  else
    latest=$(gh release view --repo "$repo" --json tagName -q .tagName 2>/dev/null) || {
      echo "  ⏭  $name: no releases found, skipping"
      return
    }
    latest_version="${latest#v}"
  fi

  # Get current version
  local current
  current=$(grep -m1 'version ' "$rb" | sed 's/.*"\(.*\)".*/\1/')

  if [ "$current" = "$latest_version" ] && ! grep -q 'sha256 "0\{64\}"' "$rb"; then
    echo "  ✓  $name: already at $current"
    return
  fi

  echo "  ↑  $name: $current → $latest_version"

  # Bump version/URL strings (skip sha256 lines so the old hash isn't mangled).
  sed -i '' "/sha256/!s/$current/$latest_version/g" "$rb"

  # Hash the exact URL the formula now points at — that is precisely what
  # Homebrew will download, so the hash can never drift from the artifact.
  local url
  url=$(grep -m1 '^[[:space:]]*url ' "$rb" | sed 's/.*"\(.*\)".*/\1/')
  local sha
  sha=$(set -o pipefail; curl -fsSL "$url" | shasum -a 256 | awk '{print $1}')
  local curl_rc=$?
  if [ "$curl_rc" -ne 0 ] || [ -z "$sha" ]; then
    echo "  ✗  $name: failed to hash $url (curl exit $curl_rc)" >&2
    return 1
  fi
  sed -i '' "s/sha256 \"[a-f0-9]*\"/sha256 \"$sha\"/" "$rb"

  echo "       updated $rb ($latest_version)"
}

if [ $# -gt 0 ]; then
  formulas=("$FORMULA_DIR/$1.rb")
else
  formulas=("$FORMULA_DIR"/*.rb)
fi

echo "Checking Homebrew formulas..."
for rb in "${formulas[@]}"; do
  if [ -f "$rb" ]; then
    update_formula "$rb"
  else
    echo "  ✗  $(basename "$rb"): not found"
  fi
done
