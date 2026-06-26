# Multi-artifact hashing in update.sh + macOS Intel sunset

## Problem

The two `update.sh` scripts (homebrew-tap, scoop-bucket) recompute a package's
checksum(s) on a version bump. Both assume **one url/hash pair per package**.
`eng-leader-tools` now ships **multiple artifacts** — a source tarball (the CLI)
plus per-platform compiled `eng-mcp` binaries — and both scripts mishandle it:

- **Homebrew** (`update_formula`): greps a single `url` and then runs a *global*
  `sed` replacing **every** `sha256` line with that one hash. For the
  multi-`resource` formula this stamped the source-tarball hash into all three
  `eng-mcp` resource blocks (wrong for every binary).
- **Scoop** (`update_manifest`): the python treats `url`/`hash` as **strings**
  (`.replace()`) and writes a **single** hash. The new top-level `url`/`hash`
  **array** form crashes it: `'list' object has no attribute 'replace'`, leaving
  the manifest unbumped.

Both were worked around by hand for v0.3.2, but the **next release repeats both
failures**. Separately, GitHub's macOS-Intel (`macos-13`) CI runner is now
unreliable (queued for days, then auto-cancelled), and Intel Macs are being
sunset, so the Intel build is being dropped.

## Solution

Two coordinated changes:

1. **Make both `update.sh` scripts shape-agnostic** — hash *every* url at its own
   location into its paired hash field. This covers single-artifact packages
   (N=1, unchanged), the Homebrew multi-`resource` formula (N=4→3 after Intel
   sunset), and the Scoop top-level array (N=2) with one code path each. Future
   multi-artifact packages then "just work".

2. **Sunset macOS Intel** — remove the `macos-13` matrix row from the release
   workflow and the `on_intel` resource block from the formula.

## Scope (three repos)

- **`homebrew-tap`**: `update.sh` line-walk pairing; remove `on_intel` from
  `Formula/eng-leader-tools.rb`.
- **`scoop-bucket`**: `update.sh` type-aware (string | array | architecture)
  python.
- **`eng-leader-tools`** (source): remove the `macos-13` row from
  `.github/workflows/mcp-release.yml`.

Both scripts loop over ALL formulae/manifests in their repo; the fix must leave
every single-artifact package's behavior identical.

## Component 1 — Homebrew `update.sh` (line-walk pairing)

In `update_formula`, the current hashing block is:
- `sed -i '' "/sha256/!s/$current/$latest_version/g" "$rb"` (version bump — KEEP,
  it correctly bumps version strings in url lines while skipping sha256 lines)
- a single `grep -m1 url` + `curl|shasum` + a global
  `sed "s/sha256 \"[a-f0-9]*\"/sha256 \"$sha\"/"` that overwrites ALL sha256
  lines. **This global sed is the bug.**

Replace the single-hash logic (everything after the version-bump sed) with a
**line-walk state machine** that pairs each `url` with the *next* `sha256` line:

```
keep the version-bump sed as-is
read the formula line by line into an output buffer:
  - on a line matching:  ^<ws>url "<X>"     -> pending_url = X
  - on a line matching:  ^<ws>sha256 "..."  and pending_url is set:
        sha = curl -fsSL "$pending_url" | shasum -a 256   (with pipefail/-z guard)
        on failure: print "✗ <name>: failed to hash <pending_url>" >&2; return 1
        emit the sha256 line with its hash replaced by $sha
        clear pending_url
  - any other line: emit unchanged
write the buffer back to the formula
```

- Each `url`→`sha256` adjacency is one pair. The main `url`/`sha256` (source
  tarball) and each `resource`'s `url`/`sha256` (release asset) are handled
  identically — the script hashes whatever each url points at.
- A single-artifact formula has exactly one pair → byte-identical result to
  today.
- Per-url failure aborts the whole formula loudly (no partially/incorrectly
  written hashes).

Implementation notes:
- Use the same `url "..."` extraction regex the script already uses
  (`sed 's/.*"\(.*\)".*/\1/'`).
- Preserve BSD-isms: the script is macOS-targeted; keep `shasum -a 256` and avoid
  GNU-only flags.
- **Chosen implementation: bash `while IFS= read -r line`** over the formula,
  accumulating transformed lines, written back via a temp file + `mv` (atomic).
  This matches the existing script's bash idiom and lets the existing
  `set -o pipefail; curl … | shasum` + `curl_rc`/`-z` guard snippet be reused
  verbatim inside the loop. (Not awk — keeps one language and reuses the guard.)

## Component 2 — Scoop `update.sh` (type-aware python)

The script already uses python3 for JSON. Extend both passes to branch on type.

**Pass 1 (version bump)** — handle `url`/`extract_dir` being a string OR a list,
plus `architecture.64bit`:
```
new_ver applied:
  if 'architecture'.'64bit' present: arch['url'] = arch['url'].replace(old,new)
  elif url is a list:  url = [u.replace(old,new) for u in url]
  elif url is a str:   url = url.replace(old,new)
  extract_dir: same str-vs-list .replace handling (list -> per element)
```

**URL read-back + hashing** — emit the URL(s) to hash (one per line) so bash can
curl+guard each:
```
if architecture.64bit: print arch url
elif url is list:      print each url (in order)
else:                  print the string url
```
Bash loops over those URLs; for each, `curl -fsSL | shasum` with the existing
`pipefail`/`curl_rc`/`-z` guard. Collect the hashes in order.

**Pass 2 (write hashes)** — write back matching the shape:
```
if architecture.64bit: arch['hash'] = hashes[0]
elif hash is/should be a list: hash = hashes (in url order)
else: hash = hashes[0]
```

Covers all three shapes present in the bucket: flat string (most tools), the
top-level array (eng-leader-tools), and `architecture.64bit` (loupe, fulton,
copycat, patui, poltergeist, whereami). Any url that fails to hash aborts the
manifest loudly.

## Component 3 — macOS Intel sunset

- **`eng-leader-tools/.github/workflows/mcp-release.yml`**: remove the matrix
  row `{ os: macos-13, target: bun-darwin-x64, asset: macos-x86_64 }`. Remaining
  targets: `macos-latest/bun-darwin-arm64/macos-aarch64`,
  `ubuntu-latest/bun-linux-x64/linux-x86_64`,
  `windows-latest/bun-windows-x64/windows-x86_64`.
- **`homebrew-tap/Formula/eng-leader-tools.rb`**: delete the entire
  `on_intel do … end` block inside `on_macos`. Keep `on_arm` and the top-level
  `on_linux` resource. Re-run `ruby -c` to confirm valid.
- **Scoop**: no change (its only binary asset is windows; never had Intel).
- The already-published v0.3.2 `eng-mcp-...-macos-x86_64.tar.gz` asset is left on
  the release (orphaned, harmless). Intel-mac Homebrew users get the CLI but no
  bundled `eng-mcp` (acceptable per the sunset; `eng mcp build` remains available
  to them if they have bun).

## Error handling

Both scripts keep the `set -o pipefail; curl -fsSL … | shasum`,
`curl_rc=$?`, `[ "$curl_rc" -ne 0 ] || [ -z "$sha" ]` → stderr `✗` + `return 1`
guard, now applied per-url. A failure on ANY artifact aborts that package before
any hash is written back (homebrew: the line-walk returns 1 mid-walk without
writing the buffer; scoop: the bash loop returns 1 before pass 2), so a
package can never be left with a mix of new and stale/zero hashes.

## Testing

Release scripts (network-dependent, mutate real files) — pragmatic verification:

**Homebrew:**
- Run `./update.sh eng-leader-tools` against the multi-resource formula →
  assert the main `url` hash equals the **source-tarball** hash AND each resource
  hash equals **its own asset** hash (exactly the bug that shipped). All hashes
  distinct.
- Run against a single-artifact formula (e.g. `whereami`) → one correct hash,
  behavior unchanged; re-run → "already at" no-op, no diff.
- Bad-url guard: point a copy's resource url at a nonexistent tag → confirm loud
  failure + non-zero + no partial write.

**Scoop:**
- Run `./update.sh eng-leader-tools` against the array manifest → no crash; both
  array hashes correct and distinct; version + both urls + extract_dir bumped.
- Run against an `architecture.64bit` manifest (e.g. `loupe`) and a flat manifest
  → both still correct (no regression).
- Re-run each → idempotent no-op.

No test commits/pushes — verification confirms correct hashes and loud failure;
the operator commits the resulting manifest changes.

## Out of Scope (YAGNI)

- Re-tagging or re-releasing v0.3.2 (its shipped formula/manifest are already
  correct by hand; this work fixes the tooling for the NEXT release and removes
  `on_intel` from the live formula going forward).
- `linux-arm64` builds.
- Migrating the 6 `architecture.64bit` windows-zip tools to any new shape.
- The `eng mcp` installer / source code (unchanged — this is release tooling
  only).
