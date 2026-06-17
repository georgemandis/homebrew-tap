# Robust hashing in `update.sh` Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Change both `update.sh` scripts (homebrew-tap and scoop-bucket) to hash the exact URL the manifest points at — via `curl` — instead of a separately-downloaded release asset, and to fail loudly instead of silently writing a stale/empty hash.

**Architecture:** In each script's per-item function, after the version bump rewrites the URL in the file, read that URL back out, `curl -fsSL` it, hash the bytes, and write the hash into the matching field. Replace the `gh release download` + asset-matching logic. The artifact hashed is, by construction, what the package manager installs.

**Tech Stack:** Bash, `curl`, `shasum`, `sed` (Homebrew formula `.rb` editing), `python3` (Scoop JSON editing — already used by that script).

**Spec:** [`docs/superpowers/specs/2026-06-17-robust-hashing-design.md`](../specs/2026-06-17-robust-hashing-design.md)

**NOTE — two repos:** This plan touches two separate git repos:
- `~/Projects/recurse/2026/homebrew-tap/update.sh` (Tasks 1–2)
- `~/Projects/recurse/2026/scoop-bucket/update.sh` (Tasks 3–4)

The homebrew-tap repo is on a `robust-hashing` branch (where the spec lives). The scoop-bucket repo is on `main` — Task 3 begins by creating a `robust-hashing` branch there.

Both scripts are macOS-targeted and use BSD `sed -i ''` (note the empty-string argument) — preserve that exact syntax; do not switch to GNU `sed -i`.

---

## File Structure

**Modify:**
- `homebrew-tap/update.sh` — in `update_formula()`: remove `gh release download` + the asset loop; add curl-the-formula-URL + write-sha + loud-failure guard.
- `scoop-bucket/update.sh` — in `update_manifest()`: remove `gh release download` + zip logic; do version/url/extract_dir bump for BOTH manifest shapes (flat top-level `url`/`hash` and `architecture.64bit`), then curl-the-URL + write-hash + loud-failure guard.

No new files. Each script's change is self-contained within its one per-item function.

---

## Task 1: Homebrew — hash the formula's own URL

**Files:**
- Modify: `~/Projects/recurse/2026/homebrew-tap/update.sh` (the `update_formula` function, lines ~55–84)

**Context:** The current function (after the `echo "  ↑  ..."` progress line at ~53) does:
```bash
  # Download assets and compute hashes
  local tmpdir
  tmpdir=$(mktemp -d)
  gh release download "$latest" --repo "$repo" --dir "$tmpdir" --pattern "*.tar.gz" 2>/dev/null || true

  # Update version string and URLs (skip sha256 lines to avoid corrupting hashes)
  sed -i '' "/sha256/!s/$current/$latest_version/g" "$rb"

  # Update sha256 hashes by matching each downloaded asset to its URL line
  for asset in "$tmpdir"/*.tar.gz; do
    [ -f "$asset" ] || continue
    local basename_asset
    basename_asset=$(basename "$asset")
    local sha
    sha=$(shasum -a 256 "$asset" | awk '{print $1}')

    local url_line
    url_line=$(grep -n "$basename_asset" "$rb" | head -1 | cut -d: -f1)
    if [ -n "$url_line" ]; then
      local sha_line
      sha_line=$(tail -n +"$url_line" "$rb" | grep -n 'sha256' | head -1 | cut -d: -f1)
      if [ -n "$sha_line" ]; then
        local actual_line=$((url_line + sha_line - 1))
        sed -i '' "${actual_line}s/sha256 \"[a-f0-9]*\"/sha256 \"$sha\"/" "$rb"
      fi
    fi
  done

  rm -rf "$tmpdir"
  echo "       updated $rb"
```

- [ ] **Step 1: Replace that whole block** (from `# Download assets and compute hashes` through `echo "       updated $rb"`) with:

```bash
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
```

CRITICAL guard note (learned during implementation): the failure check must use
`set -o pipefail` *inside* the command-substitution subshell plus `$?`, NOT a bare
`[ -z "$sha" ]` test and NOT `${PIPESTATUS[0]}`. Reasons: (1) on a 404, `curl -fsSL`
writes nothing but `shasum` of empty input is `e3b0c44298fc1...` (SHA-256 of the
empty string) — non-empty, so `[ -z "$sha" ]` alone does NOT fire; (2) `${PIPESTATUS[0]}`
after `sha=$(pipeline)` reflects the *assignment* (always 0), not the pipeline inside
the subshell, so it also misses the failure. `set -o pipefail; ...` makes the
substitution's exit status reflect curl's failure, captured by `$?`. Do NOT capture
the body into a variable — the tarball is binary/gzip and bash mangles null bytes
(producing a wrong hash). `-f` = HTTP errors non-zero, `-sS` = quiet but real errors shown, `-sS` is quiet but still surfaces real errors, `-L` follows the GitHub archive redirect. The `mktemp`/`tmpdir`/`gh release download` lines are gone entirely.

- [ ] **Step 2: Syntax check**

Run: `bash -n ~/Projects/recurse/2026/homebrew-tap/update.sh && echo "syntax OK"`
Expected: `syntax OK`

- [ ] **Step 3: Verify idempotency on the already-correct eng formula**

`eng-leader-tools` is already at v0.3.0 with the correct hash, so the script should detect "already at" and make no change.

Run:
```bash
cd ~/Projects/recurse/2026/homebrew-tap && ./update.sh eng-leader-tools
```
Expected: prints `  ✓  eng-leader-tools: already at 0.3.0` and exits 0. (This proves the "already current" short-circuit at line ~48 still works and nothing was rewritten.)

Then confirm the formula is unchanged:
Run: `cd ~/Projects/recurse/2026/homebrew-tap && git diff --stat update.sh Formula/eng-leader-tools.rb`
Expected: `update.sh` shows as modified (our edit), `Formula/eng-leader-tools.rb` shows NO changes.

- [ ] **Step 4: Verify the hashing path actually computes the right hash (forced re-hash)**

Temporarily zero the formula's hash so the "already at" guard falls through to the hashing path, run, and confirm it restores the correct hash.

Run:
```bash
cd ~/Projects/recurse/2026/homebrew-tap
cp Formula/eng-leader-tools.rb /tmp/eng-formula-backup.rb
sed -i '' 's/sha256 "[a-f0-9]*"/sha256 "0000000000000000000000000000000000000000000000000000000000000000"/' Formula/eng-leader-tools.rb
./update.sh eng-leader-tools
grep sha256 Formula/eng-leader-tools.rb
```
Expected: the `./update.sh` run reports updating eng-leader-tools, and the final `grep` shows
`sha256 "d1a2eb65fd7228b66e8020a4cab52ddffa367b13b8e9e5dc08a922e0959f4d5d"` (the real v0.3.0 hash, recomputed from the URL).

Then restore the pristine formula (so this test leaves no diff):
Run: `cd ~/Projects/recurse/2026/homebrew-tap && mv /tmp/eng-formula-backup.rb Formula/eng-leader-tools.rb && git diff --stat Formula/eng-leader-tools.rb`
Expected: no changes to `Formula/eng-leader-tools.rb`.

- [ ] **Step 5: Commit**

```bash
cd ~/Projects/recurse/2026/homebrew-tap
git add update.sh
git commit -m "update.sh: hash the formula URL via curl instead of downloaded asset"
```

---

## Task 2: Homebrew — verify loud failure on a bad URL

**Files:** none (verification only — confirms the guard added in Task 1)

**Context:** The spec requires the script to fail loudly (stderr message + non-zero return) rather than write an empty/stale hash when the artifact can't be fetched. Task 1 added the guard; this task proves it on a copy so no real formula is harmed.

- [ ] **Step 1: Build a temp formula pointing at a non-existent tag**

Run:
```bash
cd ~/Projects/recurse/2026/homebrew-tap
cp Formula/eng-leader-tools.rb Formula/zzz-badurl-test.rb
# point it at a tag that doesn't exist, and zero the hash to force the hashing path
sed -i '' 's|tags/v0.3.0.tar.gz|tags/v999.999.999.tar.gz|' Formula/zzz-badurl-test.rb
sed -i '' 's/version "0.3.0"/version "999.999.999"/' Formula/zzz-badurl-test.rb
```

- [ ] **Step 2: Run the hashing path directly against the bad URL and confirm loud failure**

We bypass the `gh release`/version-detection logic (which would try to look up releases) and exercise just the curl-hash guard, mirroring exactly what Task 1's code does:

Run:
```bash
cd ~/Projects/recurse/2026/homebrew-tap
url=$(grep -m1 '^[[:space:]]*url ' Formula/zzz-badurl-test.rb | sed 's/.*"\(.*\)".*/\1/')
echo "testing url: $url"
sha=$(curl -fsSL "$url" | shasum -a 256 | awk '{print $1}')
# An empty file still hashes to e3b0c4... so check curl's exit, which -f makes non-zero on 404:
curl -fsSL "$url" >/dev/null 2>&1; echo "curl exit: $?"
```
Expected: `curl exit:` is non-zero (e.g. `22` for HTTP 404). This confirms `curl -fsSL` fails on a missing tag, which in the real function drives the `if [ -z "$sha" ]` / non-zero path.

IMPORTANT NUANCE to note in the report: a 404 from GitHub may return an empty body, and `curl -fsSL` returns non-zero so `$sha` ends up empty → the guard fires. But if a URL returned a non-empty error page with 200, `$sha` would be non-empty garbage. Confirm the guard relies on `curl -f` (HTTP-error → non-zero → empty `$sha`), which it does. If Task 1's guard only checks `[ -z "$sha" ]`, that is sufficient here because `-f` guarantees an empty `$sha` on HTTP failure. Report whether you think an explicit `curl` exit-code check would be more robust (it would; note it as an optional hardening, but the spec's `[ -z "$sha" ]` guard is acceptable).

- [ ] **Step 3: Clean up the temp formula**

Run:
```bash
cd ~/Projects/recurse/2026/homebrew-tap
rm -f Formula/zzz-badurl-test.rb
git status --short
```
Expected: no `zzz-badurl-test.rb` present; `git status` shows only expected/no changes (the temp file was never committed).

- [ ] **Step 4: (No commit — verification only)**

If Step 2 confirmed non-zero curl exit on a bad URL and the temp file is cleaned up, this task is complete. Report findings (including the optional-hardening note).

---

## Task 3: Scoop — hash the manifest's own URL (both shapes)

**Files:**
- Modify: `~/Projects/recurse/2026/scoop-bucket/update.sh` (the `update_manifest` function, lines ~55–103)

**Context:** Start by branching the scoop-bucket repo. The current function downloads a windows zip and only edits `architecture.64bit`:
```bash
  # Download the windows asset
  local tmpdir
  tmpdir=$(mktemp -d)
  gh release download "$latest" --repo "$repo" --dir "$tmpdir" --pattern "*windows*.zip" 2>/dev/null || {
    echo "       no windows zip found, skipping"
    rm -rf "$tmpdir"
    return
  }
  local asset
  asset=$(ls "$tmpdir"/*.zip 2>/dev/null | head -1)
  if [ -z "$asset" ]; then
    echo "       no zip asset downloaded, skipping"
    rm -rf "$tmpdir"
    return
  fi
  local sha
  sha=$(shasum -a 256 "$asset" | awk '{print $1}')
  # Update version, url, hash, and extract_dir using python3 for safe JSON editing
  python3 -c "
import json, re
with open('$json') as f:
    data = json.load(f)
old_ver = data['version']
new_ver = '$latest_version'
data['version'] = new_ver
if 'architecture' in data and '64bit' in data['architecture']:
    arch = data['architecture']['64bit']
    arch['url'] = arch['url'].replace(old_ver, new_ver)
    arch['hash'] = '$sha'
if 'extract_dir' in data:
    data['extract_dir'] = data['extract_dir'].replace(old_ver, new_ver)
with open('$json', 'w') as f:
    json.dump(data, f, indent=4, ensure_ascii=False)
    f.write('\n')
"
  rm -rf "$tmpdir"
  echo "       updated $json"
```

This handles ONLY `architecture.64bit` (6 tools) and silently no-ops on flat top-level `url`/`hash` tools (`eng-leader-tools`, `engsight`).

- [ ] **Step 1: Branch the scoop-bucket repo**

Run:
```bash
cd ~/Projects/recurse/2026/scoop-bucket && git checkout -b robust-hashing && git branch --show-current
```
Expected: `robust-hashing`

- [ ] **Step 2: Replace the whole block** (from `# Download the windows asset` through `echo "       updated $json"`) with a two-python-passes-around-a-curl implementation that handles BOTH shapes:

```bash
  # Pass 1: bump version + URL + extract_dir for whichever shape this manifest
  # uses (flat top-level url/hash, or architecture.64bit). Writes the file so the
  # finalized URL can be hashed next.
  python3 -c "
import json
with open('$json') as f:
    data = json.load(f)
old_ver = data['version']
new_ver = '$latest_version'
data['version'] = new_ver
if 'architecture' in data and '64bit' in data['architecture']:
    arch = data['architecture']['64bit']
    arch['url'] = arch['url'].replace(old_ver, new_ver)
elif 'url' in data:
    data['url'] = data['url'].replace(old_ver, new_ver)
if 'extract_dir' in data:
    data['extract_dir'] = data['extract_dir'].replace(old_ver, new_ver)
with open('$json', 'w') as f:
    json.dump(data, f, indent=4, ensure_ascii=False)
    f.write('\n')
"

  # Read the finalized URL back, hash exactly that (what Scoop will download).
  local url
  url=$(python3 -c "import json; d=json.load(open('$json')); print(d.get('url') or d.get('architecture',{}).get('64bit',{}).get('url',''))")
  local sha
  sha=$(set -o pipefail; curl -fsSL "$url" | shasum -a 256 | awk '{print $1}')
  local curl_rc=$?
  if [ "$curl_rc" -ne 0 ] || [ -z "$sha" ]; then
    echo "  ✗  $name: failed to hash $url (curl exit $curl_rc)" >&2
    return 1
  fi

  # Pass 2: write the hash into the matching field (arch or flat).
  python3 -c "
import json
with open('$json') as f:
    data = json.load(f)
if 'architecture' in data and '64bit' in data['architecture']:
    data['architecture']['64bit']['hash'] = '$sha'
else:
    data['hash'] = '$sha'
with open('$json', 'w') as f:
    json.dump(data, f, indent=4, ensure_ascii=False)
    f.write('\n')
"

  echo "       updated $json ($latest_version)"
```

The `mktemp`/`gh release download`/zip lines are gone. Note the strict order: write URL → read URL → curl → write hash.

- [ ] **Step 3: Syntax check**

Run: `bash -n ~/Projects/recurse/2026/scoop-bucket/update.sh && echo "syntax OK"`
Expected: `syntax OK`

- [ ] **Step 4: Verify idempotency on the already-correct eng manifest (flat shape)**

Run: `cd ~/Projects/recurse/2026/scoop-bucket && ./update.sh eng-leader-tools`
Expected: prints `  ✓  eng-leader-tools: already at 0.3.0` and exits 0.

Confirm no change to the manifest:
Run: `cd ~/Projects/recurse/2026/scoop-bucket && git diff --stat eng-leader-tools.json`
Expected: no changes to `eng-leader-tools.json`.

- [ ] **Step 5: Verify the flat-shape hashing path computes the right hash (forced re-hash)**

Zero the eng manifest's hash to force the hashing path, run, confirm it restores the correct hash, then restore.

Run:
```bash
cd ~/Projects/recurse/2026/scoop-bucket
cp eng-leader-tools.json /tmp/eng-scoop-backup.json
python3 -c "import json; d=json.load(open('eng-leader-tools.json')); d['hash']='0'*64; json.dump(d, open('eng-leader-tools.json','w'), indent=4, ensure_ascii=False); open('eng-leader-tools.json','a').write('\n')"
./update.sh eng-leader-tools
python3 -c "import json; print(json.load(open('eng-leader-tools.json'))['hash'])"
```
Expected: the run reports updating eng-leader-tools, and the printed hash is
`d1a2eb65fd7228b66e8020a4cab52ddffa367b13b8e9e5dc08a922e0959f4d5d`.

Restore:
Run: `cd ~/Projects/recurse/2026/scoop-bucket && mv /tmp/eng-scoop-backup.json eng-leader-tools.json && git diff --stat eng-leader-tools.json`
Expected: no changes to `eng-leader-tools.json`.

- [ ] **Step 6: Verify the arch-shape path still works (forced re-hash on loupe)**

`loupe` uses `architecture.64bit`. Zero its hash, run, confirm the recomputed hash equals a direct curl-hash of its URL, then restore.

Run:
```bash
cd ~/Projects/recurse/2026/scoop-bucket
cp loupe.json /tmp/loupe-backup.json
url=$(python3 -c "import json; print(json.load(open('loupe.json'))['architecture']['64bit']['url'])")
expected=$(curl -fsSL "$url" | shasum -a 256 | awk '{print $1}')
echo "expected hash: $expected"
python3 -c "import json; d=json.load(open('loupe.json')); d['architecture']['64bit']['hash']='0'*64; json.dump(d, open('loupe.json','w'), indent=4, ensure_ascii=False); open('loupe.json','a').write('\n')"
./update.sh loupe
got=$(python3 -c "import json; print(json.load(open('loupe.json'))['architecture']['64bit']['hash'])")
echo "got hash: $got"
[ "$got" = "$expected" ] && echo "MATCH" || echo "MISMATCH"
```
Expected: `MATCH` (the arch-shape path recomputes loupe's hash correctly from its own URL).

Restore:
Run: `cd ~/Projects/recurse/2026/scoop-bucket && mv /tmp/loupe-backup.json loupe.json && git diff --stat loupe.json`
Expected: no changes to `loupe.json`.

- [ ] **Step 7: Confirm only update.sh is changed, then commit**

Run: `cd ~/Projects/recurse/2026/scoop-bucket && git status --short`
Expected: only ` M update.sh` (plus any pre-existing untracked files; NO changes to any `.json` manifest).

```bash
cd ~/Projects/recurse/2026/scoop-bucket
git add update.sh
git commit -m "update.sh: hash the manifest URL via curl; handle flat + arch shapes"
```

---

## Task 4: Scoop — verify loud failure on a bad URL

**Files:** none (verification only)

**Context:** Mirror of Task 2 for the scoop script: confirm a bad URL produces a loud failure, not a silent bad write.

- [ ] **Step 1: Build a temp manifest pointing at a non-existent tag**

Run:
```bash
cd ~/Projects/recurse/2026/scoop-bucket
cp eng-leader-tools.json /tmp/zzz-badurl.json
python3 -c "import json; d=json.load(open('/tmp/zzz-badurl.json')); d['url']=d['url'].replace('v0.3.0','v999.999.999'); json.dump(d, open('/tmp/zzz-badurl.json','w'), indent=4)"
```

- [ ] **Step 2: Exercise the curl-hash guard against the bad URL**

Run:
```bash
url=$(python3 -c "import json; d=json.load(open('/tmp/zzz-badurl.json')); print(d.get('url') or d.get('architecture',{}).get('64bit',{}).get('url',''))")
echo "testing url: $url"
sha=$(curl -fsSL "$url" | shasum -a 256 | awk '{print $1}')
curl -fsSL "$url" >/dev/null 2>&1; echo "curl exit: $?"
echo "sha is: '${sha}'"
```
Expected: `curl exit:` is non-zero, and (because `-f` yields an empty body on HTTP error) `sha is: ''` — empty, which in the real function triggers the `if [ -z "$sha" ]` loud-failure guard and `return 1`.

- [ ] **Step 3: Clean up**

Run: `rm -f /tmp/zzz-badurl.json && echo "cleaned"`
Expected: `cleaned`

- [ ] **Step 4: (No commit — verification only)**

Report findings. Task complete when the bad URL is confirmed to drive an empty `$sha` (→ loud guard).

---

## Task 5: Re-run the real updates as the true end-to-end test

**Files:** potentially `Formula/eng-leader-tools.rb` and `eng-leader-tools.json` (should already be correct → no change)

**Context:** The ultimate proof the fix works: run the fixed scripts the way they'd actually be run at release time, and confirm they produce correct, install-matching hashes with no manual intervention. Since everything is already at 0.3.0, the expectation is "already at" no-ops — but this exercises the real entry path (`gh release view` → version compare → hash) end to end.

- [ ] **Step 1: Run the full homebrew update (all formulas)**

Run: `cd ~/Projects/recurse/2026/homebrew-tap && ./update.sh 2>&1 | tail -30`
Expected: each formula reports either `✓ already at <v>` or `↑ ... updated`; eng-leader-tools shows `✓ already at 0.3.0`; the command exits 0; NO `✗ failed to hash` errors for tools that have real releases. (Some tools may legitimately show `⏭ no releases found` — that's the existing skip behavior, fine.)

- [ ] **Step 2: Confirm the homebrew run left no unexpected manifest changes**

Run: `cd ~/Projects/recurse/2026/homebrew-tap && git status --short`
Expected: no changes to `Formula/eng-leader-tools.rb`. If OTHER formulas show changes, that means they were genuinely stale and the script correctly updated them — inspect each `git diff` and report; do NOT commit those without confirming the new hashes are correct (spot-check one via `curl -fsSL <url> | shasum -a 256`).

- [ ] **Step 3: Run the full scoop update (all manifests)**

Run: `cd ~/Projects/recurse/2026/scoop-bucket && ./update.sh 2>&1 | tail -30`
Expected: each manifest reports `✓ already at` or `↑ updated`; eng-leader-tools and engsight (flat shape) both resolve without the old silent-skip; exits 0; no spurious `✗ failed to hash`.

- [ ] **Step 4: Confirm the scoop run left no unexpected manifest changes**

Run: `cd ~/Projects/recurse/2026/scoop-bucket && git status --short`
Expected: only ` M update.sh` (already committed in Task 3, so actually nothing new) and no `.json` changes for eng-leader-tools. Report any manifest that DID change with its diff and a spot-checked hash.

- [ ] **Step 5: (No commit unless a genuinely-stale manifest was correctly updated)**

If any manifest was legitimately updated (a real version bump the old broken script had missed), report it with the verified hash and ask before committing — that's a separate content change, not part of the tooling fix.

---

## Self-Review Notes

- **Spec coverage:** Homebrew curl-the-URL + guard (Task 1) ✓; Homebrew loud-failure proof (Task 2) ✓; Scoop both-shapes curl-the-URL + guard (Task 3) ✓; Scoop loud-failure proof (Task 4) ✓; idempotency + both-shape verification (Tasks 1,3) ✓; real end-to-end re-run (Task 5) ✓. Error-handling (`curl -fsSL`, `[ -z "$sha" ]` guard, stderr + `return 1`) present in Tasks 1 & 3 and proven in 2 & 4. Out-of-scope items (no auto-commit, no release-asset changes, tag-resolution untouched) honored.
- **Placeholder scan:** No TBD/TODO; every step has concrete commands and expected output.
- **Consistency:** Both scripts use the same invariant (hash the finalized URL field), same guard (`if [ -z "$sha" ]` → stderr `✗` + `return 1`), same `curl -fsSL ... | shasum -a 256 | awk '{print $1}'`. The Scoop URL-read expression (`d.get('url') or d.get('architecture',{}).get('64bit',{}).get('url','')`) is identical across Task 3 Step 2, Task 4, and matches the field the hash is written back to. BSD `sed -i ''` preserved in the Homebrew edits.
- **Two-repo logistics:** homebrew-tap already on `robust-hashing`; scoop-bucket branches in Task 3 Step 1. Each commit targets its own repo.
