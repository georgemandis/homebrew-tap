# Robust hashing in `update.sh` (homebrew-tap + scoop-bucket)

## Problem

Both `update.sh` scripts (one in `homebrew-tap`, one in `scoop-bucket`) bump a
formula/manifest to the latest GitHub release and recompute its checksum. They
compute that checksum by **downloading a release asset** (`gh release download
--pattern "*.tar.gz"` for Homebrew, `--pattern "*windows*.zip"` for Scoop) and
hashing the downloaded file.

This breaks for tools whose manifest installs from the **GitHub source tarball**
(`archive/refs/tags/v$VERSION.tar.gz`) rather than an attached release asset:

- **Homebrew:** `gh release download` finds no matching asset (a `--generate-notes`
  release has no attached `.tar.gz`), the `|| true` swallows the failure, the
  asset loop iterates over nothing, and the `sha256` line is never updated — while
  the `url`/`version` *were* rewritten. Result: new URL/version, **stale hash**.
- **Scoop:** the script only updates `architecture.64bit.{url,hash}`, but
  source-tarball tools use a flat top-level `url`/`hash`. For those, the manifest
  is **silently not updated at all**.

This is exactly what happened to `eng-leader-tools` v0.3.0: the Homebrew formula
ended up with the v0.3.0 URL but the v0.2.1 hash, and the Scoop manifest stayed
entirely at v0.2.1. Both failures were silent.

A survey of the current Scoop bucket confirms the two shapes:

- **flat** (top-level `url`/`hash`, source tarball): `eng-leader-tools`, `engsight`
- **arch** (`architecture.64bit.url/hash`, windows zip): `copycat`, `fulton`,
  `loupe`, `patui`, `poltergeist`, `whereami`

## Solution

Change both scripts to **hash the exact URL the manifest already points at**,
rather than a separately-downloaded release asset. After the version bump rewrites
the URL, read that URL back out of the file, `curl -sL` it, hash the bytes, and
write the hash into the matching field.

The invariant: *the artifact we hash is, by construction, the artifact the package
manager will download.* There is no second source of truth that can drift. This
works uniformly for source-tarball tools and asset-based tools, because both put
a real download URL in the manifest.

Verified: `curl -sL <archive url> | shasum -a 256` of the v0.3.0 tarball produces
`d1a2eb65fd7228b66e8020a4cab52ddffa367b13b8e9e5dc08a922e0959f4d5d`, exactly the
hash Homebrew accepts for that release.

## Homebrew (`homebrew-tap/update.sh`)

Within `update_formula`, after the version `sed` that rewrites `url`/`version`:

1. **Remove** the `gh release download` line and the entire asset-matching loop
   (the `for asset in "$tmpdir"/*.tar.gz` block) and the `mktemp`/`rm -rf tmpdir`.
2. Extract the (now version-bumped) URL from the formula:
   `url=$(grep -m1 '^[[:space:]]*url ' "$rb" | sed 's/.*"\(.*\)".*/\1/')`.
3. Compute the hash by fetching that URL:
   `sha=$(curl -fsSL "$url" | shasum -a 256 | awk '{print $1}')`.
4. **Guard:** if `curl` fails (non-zero) or `sha` is empty, print
   `✗ <name>: failed to hash <url>` to stderr and `return 1` — do NOT write an
   empty or stale hash.
5. Write the hash into the `sha256` line:
   `sed -i '' "s/sha256 \"[a-f0-9]*\"/sha256 \"$sha\"/" "$rb"`.

Homebrew formulas here are single-URL/single-platform, so no per-arch loop is
needed.

## Scoop (`scoop-bucket/update.sh`)

Within `update_manifest`, replace the `gh release download --pattern
"*windows*.zip"` block and the python that only edits `architecture.64bit`:

1. **Remove** the `gh release download` and `mktemp`/zip-asset logic.
2. Do the version + URL substitution and hashing in one python3 pass that handles
   **both shapes**:
   - Bump `data['version']` to the new version.
   - Locate the URL field: prefer `data['architecture']['64bit']['url']` if an
     `architecture.64bit` block exists, else top-level `data['url']`.
   - Substitute `old_ver -> new_ver` in that URL field.
   - Bump `data['extract_dir']` (`old_ver -> new_ver`) if present.
   - Write the file.
3. After the python pass, read the resulting URL back out (whichever field) and
   fetch it: `sha=$(curl -fsSL "$url" | shasum -a 256 | awk '{print $1}')`.
4. **Guard:** if `curl` fails or `sha` is empty, print
   `✗ <name>: failed to hash <url>` to stderr and `return 1`.
5. Write the hash into the matching field (`architecture.64bit.hash` if present,
   else top-level `hash`) via a second small python3 edit.

This fixes the silent no-op on flat/source-tarball tools (`eng-leader-tools`,
`engsight`) while preserving correct behavior for the six arch/zip tools.

Implementation note: this is deliberately **two python3 passes around a curl**,
in strict order: (1) python writes the new version + URL + extract_dir to the
file; (2) bash reads the finalized URL back and curls it for the hash; (3) python
writes the hash into the matching field. The URL must be finalized in the file
*before* step 2 fetches it — do not try to compute the hash before the version
substitution is written. python3 is used for all JSON reads/writes (the script
already does) to avoid brittle `sed` editing of JSON.

## Error handling (the bug that bit us)

The root cause was **silent failure**: `gh release download ... 2>/dev/null || true`
let a missing asset pass without updating the hash. The new scripts must fail
loudly:

- Use `curl -fsSL` (`-f` makes HTTP errors non-zero; `-sS` is quiet but still
  shows real errors).
- If the fetch fails or yields an empty hash, print a `✗ <name>: ...` error to
  stderr and `return 1` from the per-item function so the item is visibly skipped
  with an error, never written with a bad hash.
- The top-level loop continues to the next item (one bad formula shouldn't abort
  the whole run), but each failure is loud and the function returns non-zero.

## Testing

These are release scripts (network-dependent, mutate real manifest files), so
verification is pragmatic, not unit-style. Run from each repo:

1. **Idempotency on the already-correct state:** with `eng-leader-tools` already
   at the correct v0.3.0 + `d1a2eb6...`, run `./update.sh eng-leader-tools`.
   Expect: detects "already at 0.3.0", makes no change, exits clean. (Confirms the
   no-op path and that the computed hash matches what's in the file.)
2. **Both Scoop shapes resolve a correct hash:** in `scoop-bucket`, run
   `./update.sh engsight` (flat/source-tarball) and `./update.sh loupe`
   (arch/zip). For each, confirm the written hash equals
   `curl -fsSL "$url" | shasum -a 256` of that manifest's URL. (Confirms both
   shapes are handled.)
3. **Loud failure on a bad URL:** copy a manifest to a temp file, point its URL at
   a non-existent tag, run the hashing path against it, and confirm the script
   prints a `✗ ... failed to hash` error and returns non-zero **without** writing
   an empty/garbage hash.

No test commits or pushes — verification only confirms the scripts produce correct
hashes and fail loudly. The operator commits the resulting manifest changes.

## Out of Scope (YAGNI)

- Auto-committing or pushing from `update.sh` — it produces correct files; the
  operator reviews and commits.
- Changing the release process to attach assets — this design removes the need for
  attached assets entirely.
- The `gh release view` / `gh release list` tag-resolution logic — that works and
  is unchanged.
- Multi-arch source builds, per-OS Homebrew bottles — not used by these tools.
