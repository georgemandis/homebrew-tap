#!/usr/bin/env bash
set -euo pipefail

# Update all Homebrew formulas to their latest GitHub release versions.
# Usage: ./update.sh [--verify] [formula_name]
#   No args:    updates all formulas in Formula/
#   With arg:   updates only that formula (e.g. ./update.sh loupe)
#   --verify:   checks every sha256 against the artifact its url points at
#               without modifying anything; exits non-zero on mismatch.
#               Run this after a release: assets rebuilt and re-uploaded
#               after a formula was written leave it pinned to bytes that
#               no longer exist, which breaks `brew install`.

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

  # Hash EACH url into the sha256 line that immediately follows it. A formula may
  # have several (a main url + one per `resource` block); each is hashed against
  # exactly the artifact it points at. Single-url formulae have one pair.
  local tmp; tmp="$(mktemp)"
  local pending_url=""
  local line url sha curl_rc
  while IFS= read -r line; do
    if printf '%s\n' "$line" | grep -Eq '^[[:space:]]*url '; then
      pending_url=$(printf '%s\n' "$line" | sed 's/.*"\(.*\)".*/\1/')
      printf '%s\n' "$line" >> "$tmp"
    elif printf '%s\n' "$line" | grep -Eq '^[[:space:]]*sha256 ' && [ -n "$pending_url" ]; then
      sha=$(set -o pipefail; curl -fsSL "$pending_url" | shasum -a 256 | awk '{print $1}')
      curl_rc=$?
      if [ "$curl_rc" -ne 0 ] || [ -z "$sha" ]; then
        echo "  ✗  $name: failed to hash $pending_url (curl exit $curl_rc)" >&2
        rm -f "$tmp"
        return 1
      fi
      printf '%s\n' "$line" | sed "s/sha256 \"[a-f0-9]*\"/sha256 \"$sha\"/" >> "$tmp"
      pending_url=""
    else
      printf '%s\n' "$line" >> "$tmp"
    fi
  done < "$rb"
  mv "$tmp" "$rb"

  echo "       updated $rb ($latest_version)"
}

# Verify (don't modify) that every sha256 in a formula matches the artifact its
# url points at. Catches formulas pinned to assets that were rebuilt and
# re-uploaded after the formula was last written. Returns 1 on any mismatch.
verify_formula() {
  local rb="$1"
  local name
  name="$(basename "$rb" .rb)"

  local tmp_out; tmp_out="$(mktemp)"
  local pending_url="" line want got n=0 bad=0

  while IFS= read -r line; do
    if printf '%s\n' "$line" | grep -Eq '^[[:space:]]*url '; then
      pending_url=$(printf '%s\n' "$line" | sed 's/.*"\(.*\)".*/\1/')
    elif printf '%s\n' "$line" | grep -Eq '^[[:space:]]*sha256 ' && [ -n "$pending_url" ]; then
      want=$(printf '%s\n' "$line" | sed 's/.*sha256 "\([a-f0-9]*\)".*/\1/')
      got=$(curl -fsSL "$pending_url" | shasum -a 256 | awk '{print $1}')
      n=$((n + 1))
      if [ -z "$got" ]; then
        bad=$((bad + 1))
        printf '     ✗ unreachable %s\n' "$(basename "$pending_url")" >> "$tmp_out"
      elif [ "$want" != "$got" ]; then
        bad=$((bad + 1))
        {
          printf '     ✗ %s\n' "$(basename "$pending_url")"
          printf '         formula: %s\n' "$want"
          printf '         actual:  %s\n' "$got"
        } >> "$tmp_out"
      fi
      pending_url=""
    fi
  done < "$rb"

  if [ "$bad" -eq 0 ]; then
    echo "  ✓  $name ($n urls)"
    rm -f "$tmp_out"
    return 0
  fi

  echo "  ✗  $name: $bad of $n urls mismatched"
  cat "$tmp_out"
  rm -f "$tmp_out"
  return 1
}

mode="update"
if [ "${1:-}" = "--verify" ]; then
  mode="verify"
  shift
fi

if [ $# -gt 0 ]; then
  formulas=("$FORMULA_DIR/$1.rb")
else
  formulas=("$FORMULA_DIR"/*.rb)
fi

failed=0

if [ "$mode" = "verify" ]; then
  echo "Verifying formula checksums against published assets..."
  for rb in "${formulas[@]}"; do
    if [ -f "$rb" ]; then
      verify_formula "$rb" || failed=1
    else
      echo "  ✗  $(basename "$rb"): not found"
      failed=1
    fi
  done
  echo
  if [ "$failed" -eq 0 ]; then
    echo "All checksums verified."
  else
    echo "Checksum mismatches found. Re-run ./update.sh to rehash." >&2
  fi
  exit "$failed"
fi

echo "Checking Homebrew formulas..."
for rb in "${formulas[@]}"; do
  if [ -f "$rb" ]; then
    update_formula "$rb" || failed=1
  else
    echo "  ✗  $(basename "$rb"): not found"
    failed=1
  fi
done

exit "$failed"
