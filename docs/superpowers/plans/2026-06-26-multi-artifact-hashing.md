# Multi-artifact hashing + Intel sunset — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make both `update.sh` scripts hash every url at its own location (handling multi-artifact packages), and sunset the macOS-Intel build.

**Architecture:** Homebrew `update.sh` uses a bash line-walk that pairs each `url` line with its following `sha256` line, hashing each url individually. Scoop `update.sh`'s python becomes type-aware (string | list | architecture.64bit) for url/hash/extract_dir. The release workflow drops the `macos-13` matrix row and the formula drops its `on_intel` block.

**Tech Stack:** Bash, curl, shasum, sed (homebrew formula `.rb`); python3 (scoop JSON); GitHub Actions YAML.

**Spec:** [`docs/superpowers/specs/2026-06-26-multi-artifact-hashing-design.md`](../specs/2026-06-26-multi-artifact-hashing-design.md)

**THREE REPOS:**
- `~/Projects/recurse/2026/homebrew-tap` — Tasks 1, 4 (branch `multi-artifact-hashing`, already created; spec committed there).
- `~/Projects/recurse/2026/scoop-bucket` — Task 2 (branches in-task).
- `~/Projects/engleader.tools/engleader-tools-scripts` — Task 3 (branches in-task).

Both scripts are macOS-targeted: BSD `sed -i ''`, `shasum -a 256`. They loop over ALL formulae/manifests; single-artifact packages MUST behave identically after the change.

---

## File Structure

- `homebrew-tap/update.sh` — `update_formula`: replace the single-hash block (lines ~55-71) with a line-walk that pairs each `url`→next `sha256`. (Task 1)
- `scoop-bucket/update.sh` — `update_manifest`: make the two python passes + URL read-back type-aware. (Task 2)
- `eng-leader-tools/.github/workflows/mcp-release.yml` — drop the `macos-13` matrix row. (Task 3)
- `homebrew-tap/Formula/eng-leader-tools.rb` — delete the `on_intel` resource block. (Task 4)

---

## Task 1: Homebrew update.sh — per-pair line-walk hashing

**Files:**
- Modify: `~/Projects/recurse/2026/homebrew-tap/update.sh` (the `update_formula` function)

**Context:** The current hashing block (after the version-bump sed) is:
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
The `grep -m1 url` + global `sed` is the bug: it hashes only the first url and stamps that hash into EVERY sha256 line.

- [ ] **Step 1: Replace that block** (from `# Bump version/URL strings` through `echo "       updated $rb ($latest_version)"`) with a version-bump sed (kept) + a line-walk:

```bash
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
```

Notes: the temp-file + `mv` keeps the write atomic and avoids editing the file while reading it. A failed curl removes the temp and returns 1 WITHOUT touching `$rb` (no partial write). `pending_url` is cleared after each consumed sha256 so a stray sha256 without a preceding url is left untouched.

- [ ] **Step 2: Syntax check**

Run: `bash -n ~/Projects/recurse/2026/homebrew-tap/update.sh && echo "syntax OK"`
Expected: `syntax OK`

- [ ] **Step 3: Verify on the multi-resource formula (the shipped bug)**

The current `Formula/eng-leader-tools.rb` is at 0.3.2 with correct distinct hashes. Force a re-hash by zeroing ALL its sha256 lines, run, and confirm each is restored to its correct DISTINCT value:

```bash
cd ~/Projects/recurse/2026/homebrew-tap
cp Formula/eng-leader-tools.rb /tmp/eng-multi-backup.rb
sed -i '' 's/sha256 "[a-f0-9]*"/sha256 "0000000000000000000000000000000000000000000000000000000000000000"/' Formula/eng-leader-tools.rb
./update.sh eng-leader-tools
echo "--- resulting hashes (expect 4 DISTINCT) ---"
grep 'sha256' Formula/eng-leader-tools.rb | grep -oE '[a-f0-9]{64}'
```
Expected: 4 distinct hashes:
- main url (source tarball): `f38c1f896995f11473fec9a2be71699d24af829f71bdf8dbc57652db85ba305a`
- macos-aarch64 resource: `36272755b616c74391df51380dad5a82db86422568b55c0e81e7bf810a7fa5ff`
- macos-x86_64 resource: `c0ee6f3077734911757d9285ea9b0517edb354a0898874539e6bf096910eee65`
- linux-x86_64 resource: `74605e3621f34ddbe7220381fa7a1ed0e64c60aadbb01d3a58a737e22628329a`

(The order in the file is main, then on_arm/macos-aarch64, then on_intel/macos-x86_64, then on_linux/linux-x86_64 — Task 4 removes on_intel later, but at THIS point it's still present, so all 4 should appear.)

Then restore the pristine formula:
```bash
mv /tmp/eng-multi-backup.rb Formula/eng-leader-tools.rb
git diff --stat Formula/eng-leader-tools.rb
```
Expected: no changes to the formula.

- [ ] **Step 4: Verify a single-artifact formula is unchanged (no regression)**

`whereami` is a single-url-per-arch binary formula. Run update against it and confirm it still resolves correctly (idempotent — already current → no-op, OR if stale it bumps with correct hashes):

```bash
cd ~/Projects/recurse/2026/homebrew-tap
./update.sh whereami
git diff --stat Formula/whereami.rb
```
Expected: either "already at <v>" with no diff, or a legitimate version bump. If it shows a diff, inspect: each sha256 must match its own url (spot-check one via `curl -fsSL <that url> | shasum -a 256`). If `whereami` is already current, the no-op + no-diff is the pass condition. Then restore if anything changed: `git checkout Formula/whereami.rb`.

- [ ] **Step 5: Commit**

```bash
cd ~/Projects/recurse/2026/homebrew-tap
git add update.sh
git commit -m "update.sh: hash each url->sha256 pair (handles multi-resource formulae)"
```

---

## Task 2: Scoop update.sh — type-aware (string | array | architecture)

**Files:**
- Modify: `~/Projects/recurse/2026/scoop-bucket/update.sh` (the `update_manifest` function)

**Context:** Branch the repo first. The current function has THREE python/bash pieces: Pass-1 python (version+url+extract_dir bump), a bash URL read-back + curl, and Pass-2 python (write hash). All assume url/hash are strings (Pass-1 `.replace()` crashes on a list) and write a single hash.

- [ ] **Step 1: Branch the repo**

Run: `cd ~/Projects/recurse/2026/scoop-bucket && git checkout -b multi-artifact-hashing && git branch --show-current`
Expected: `multi-artifact-hashing`

- [ ] **Step 2: Read the current `update_manifest`** to locate the exact block to replace.

Run: `sed -n '/Pass 1: bump version/,/updated \$json/p' ~/Projects/recurse/2026/scoop-bucket/update.sh`
Note the three sub-blocks (Pass-1 python, url read-back + curl/guard, Pass-2 python) so you replace from `# Pass 1: bump version` through `echo "       updated $json ($latest_version)"`.

- [ ] **Step 3: Replace that whole block** with a type-aware version that loops over all URLs:

```bash
  # Pass 1: bump version + url(s) + extract_dir for whichever shape this manifest
  # uses: flat string url/hash, a top-level url/hash ARRAY, or architecture.64bit.
  python3 -c "
import json
with open('$json') as f:
    data = json.load(f)
old_ver = data['version']
new_ver = '$latest_version'
data['version'] = new_ver

def bump(v):
    return v.replace(old_ver, new_ver) if isinstance(v, str) else [x.replace(old_ver, new_ver) for x in v]

if 'architecture' in data and '64bit' in data['architecture']:
    arch = data['architecture']['64bit']
    arch['url'] = bump(arch['url'])
elif 'url' in data:
    data['url'] = bump(data['url'])
if 'extract_dir' in data:
    data['extract_dir'] = bump(data['extract_dir'])

with open('$json', 'w') as f:
    json.dump(data, f, indent=4, ensure_ascii=False)
    f.write('\n')
"

  # Emit the finalized URL(s) to hash, one per line (order preserved).
  local urls
  urls=$(python3 -c "
import json
d = json.load(open('$json'))
arch = d.get('architecture', {}).get('64bit')
if arch:
    print(arch['url'])
else:
    u = d.get('url', '')
    if isinstance(u, list):
        for x in u: print(x)
    else:
        print(u)
")

  # Hash each URL (what Scoop will download); abort loudly on any failure.
  local shas=() url sha curl_rc
  while IFS= read -r url; do
    [ -z "$url" ] && continue
    sha=$(set -o pipefail; curl -fsSL "$url" | shasum -a 256 | awk '{print $1}')
    curl_rc=$?
    if [ "$curl_rc" -ne 0 ] || [ -z "$sha" ]; then
      echo "  ✗  $name: failed to hash $url (curl exit $curl_rc)" >&2
      return 1
    fi
    shas+=("$sha")
  done <<< "$urls"

  # Pass 2: write the hash(es) back, matching the manifest's shape.
  SHAS="${shas[*]}" python3 -c "
import json, os
shas = os.environ['SHAS'].split()
with open('$json') as f:
    data = json.load(f)

if 'architecture' in data and '64bit' in data['architecture']:
    data['architecture']['64bit']['hash'] = shas[0]
elif isinstance(data.get('url'), list):
    data['hash'] = shas
else:
    data['hash'] = shas[0]

with open('$json', 'w') as f:
    json.dump(data, f, indent=4, ensure_ascii=False)
    f.write('\n')
"

  echo "       updated $json ($latest_version)"
```

Notes: `bump()` handles str-or-list uniformly. The URL emit + bash loop produces one hash per url in order. Pass-2 writes a list hash for a list url, else a scalar — matching the input shape. A failed curl returns 1 before Pass-2 runs (no partial write). `SHAS` is passed via env to avoid quoting issues in the python `-c` string.

- [ ] **Step 4: Syntax check**

Run: `bash -n ~/Projects/recurse/2026/scoop-bucket/update.sh && echo "syntax OK"`
Expected: `syntax OK`

- [ ] **Step 5: Verify on the array manifest (the crash case)**

`eng-leader-tools.json` is at 0.3.2 with a 2-element url/hash array. Zero both hashes, run, confirm both restored to correct distinct values, no crash:

```bash
cd ~/Projects/recurse/2026/scoop-bucket
cp eng-leader-tools.json /tmp/eng-scoop-multi.json
python3 -c "import json; d=json.load(open('eng-leader-tools.json')); d['hash']=['0'*64,'0'*64]; json.dump(d, open('eng-leader-tools.json','w'), indent=4, ensure_ascii=False); open('eng-leader-tools.json','a').write('\n')"
./update.sh eng-leader-tools
python3 -c "import json; print(json.load(open('eng-leader-tools.json'))['hash'])"
```
Expected: no crash; printed hash list =
`['f38c1f896995f11473fec9a2be71699d24af829f71bdf8dbc57652db85ba305a', 'e8d5d654c0464703b8cfeedda8e8c8e54e379c2b8b85abf6d591e112e49de775']`
(source tarball hash, then windows eng-mcp zip hash — two distinct values).

Restore:
```bash
mv /tmp/eng-scoop-multi.json eng-leader-tools.json
git diff --stat eng-leader-tools.json
```
Expected: no changes.

- [ ] **Step 6: Verify architecture.64bit manifest unchanged (no regression)**

`loupe.json` uses `architecture.64bit`. Force a re-hash and confirm it matches a direct curl of its url:

```bash
cd ~/Projects/recurse/2026/scoop-bucket
cp loupe.json /tmp/loupe-multi.json
url=$(python3 -c "import json; print(json.load(open('loupe.json'))['architecture']['64bit']['url'])")
expected=$(curl -fsSL "$url" | shasum -a 256 | awk '{print $1}')
python3 -c "import json; d=json.load(open('loupe.json')); d['architecture']['64bit']['hash']='0'*64; json.dump(d, open('loupe.json','w'), indent=4, ensure_ascii=False); open('loupe.json','a').write('\n')"
./update.sh loupe
got=$(python3 -c "import json; print(json.load(open('loupe.json'))['architecture']['64bit']['hash'])")
[ "$got" = "$expected" ] && echo "MATCH" || echo "MISMATCH got=$got expected=$expected"
mv /tmp/loupe-multi.json loupe.json
git diff --stat loupe.json
```
Expected: `MATCH`; no diff after restore.

- [ ] **Step 7: Verify a flat string manifest unchanged (no regression)**

`engsight.json` uses flat string url/hash. Confirm it still resolves:

```bash
cd ~/Projects/recurse/2026/scoop-bucket
./update.sh engsight
git diff --stat engsight.json
```
Expected: "already at <v>" no-op + no diff (it's a source-tarball flat manifest); or a legitimate bump with a correct hash. Restore if changed: `git checkout engsight.json`.

- [ ] **Step 8: Commit**

```bash
cd ~/Projects/recurse/2026/scoop-bucket
git add update.sh
git commit -m "update.sh: type-aware hashing (string | url-array | architecture.64bit)"
```

---

## Task 3: Drop the macOS-Intel build from the release workflow

**Files:**
- Modify: `~/Projects/engleader.tools/engleader-tools-scripts/.github/workflows/mcp-release.yml`

- [ ] **Step 1: Branch the source repo**

Run: `cd ~/Projects/engleader.tools/engleader-tools-scripts && git checkout -b intel-sunset && git branch --show-current`
Expected: `intel-sunset`

- [ ] **Step 2: Remove the macos-13 matrix row.** In `.github/workflows/mcp-release.yml`, delete this exact line:

```yaml
          - { os: macos-13,       target: bun-darwin-x64,   asset: macos-x86_64 }
```

The `matrix.include:` list should then have exactly three rows: macos-latest/arm64, ubuntu-latest/linux-x64, windows-latest/win-x64.

- [ ] **Step 3: Validate YAML**

Run: `cd ~/Projects/engleader.tools/engleader-tools-scripts && python3 -c "import yaml; d=yaml.safe_load(open('.github/workflows/mcp-release.yml')); rows=d['jobs']['build']['strategy']['matrix']['include']; print('matrix rows:', len(rows)); assert len(rows)==3; assert all('macos-13' not in str(r) for r in rows); print('OK: 3 rows, no macos-13')"` — if PyYAML is missing, instead `grep -c 'os:' .github/workflows/mcp-release.yml` should be `3` and `grep -c macos-13 .github/workflows/mcp-release.yml` should be `0`.
Expected: 3 matrix rows, no macos-13.

- [ ] **Step 4: Commit**

```bash
cd ~/Projects/engleader.tools/engleader-tools-scripts
git add .github/workflows/mcp-release.yml
git commit -m "ci: drop macOS Intel (macos-13) from the eng-mcp build matrix"
```

---

## Task 4: Remove the on_intel resource from the formula

**Files:**
- Modify: `~/Projects/recurse/2026/homebrew-tap/Formula/eng-leader-tools.rb`

**Context:** Back on the `multi-artifact-hashing` branch in homebrew-tap (Task 1's branch). The formula's `on_macos` block currently contains both `on_arm` and `on_intel` resource blocks.

- [ ] **Step 1: Confirm branch**

Run: `cd ~/Projects/recurse/2026/homebrew-tap && git branch --show-current`
Expected: `multi-artifact-hashing` (continue on Task 1's branch).

- [ ] **Step 2: Delete the `on_intel` block.** Remove these exact lines from `Formula/eng-leader-tools.rb` (the `on_intel do … end` inside `on_macos`):

```ruby
    on_intel do
      resource "eng-mcp" do
        url "https://github.com/georgemandis/eng-leader-tools/releases/download/v0.3.2/eng-mcp-v0.3.2-macos-x86_64.tar.gz"
        sha256 "c0ee6f3077734911757d9285ea9b0517edb354a0898874539e6bf096910eee65"
      end
    end
```

After removal, `on_macos do` should contain only the `on_arm` block; `on_linux` stays.

- [ ] **Step 3: Ruby syntax + structure check**

Run:
```bash
cd ~/Projects/recurse/2026/homebrew-tap
ruby -c Formula/eng-leader-tools.rb
grep -c 'on_intel\|macos-x86_64' Formula/eng-leader-tools.rb
grep -c 'resource "eng-mcp"' Formula/eng-leader-tools.rb
```
Expected: `Syntax OK`; `0` (no on_intel / macos-x86_64 refs); `2` (arm + linux resources remain).

- [ ] **Step 4: Commit**

```bash
cd ~/Projects/recurse/2026/homebrew-tap
git add Formula/eng-leader-tools.rb
git commit -m "formula: drop macOS Intel (on_intel) eng-mcp resource"
```

---

## Task 5: Cross-repo verification sweep

**Files:** none (verification only)

- [ ] **Step 1: Homebrew — multi-resource still hashes correctly AFTER on_intel removal**

Now the formula has 3 sha256 lines (main + arm + linux). Force a re-hash:
```bash
cd ~/Projects/recurse/2026/homebrew-tap
cp Formula/eng-leader-tools.rb /tmp/f.rb
sed -i '' 's/sha256 "[a-f0-9]*"/sha256 "0000000000000000000000000000000000000000000000000000000000000000"/' Formula/eng-leader-tools.rb
./update.sh eng-leader-tools
grep 'sha256' Formula/eng-leader-tools.rb | grep -oE '[a-f0-9]{64}'
mv /tmp/f.rb Formula/eng-leader-tools.rb
```
Expected: exactly 3 distinct hashes —
`f38c1f89...` (source), `36272755...` (arm64), `74605e36...` (linux); NO `c0ee6f30...` (intel, now removed). After restore, `git diff --stat Formula/eng-leader-tools.rb` shows no change.

- [ ] **Step 2: Bad-url guard (homebrew) — loud failure, no partial write**

```bash
cd ~/Projects/recurse/2026/homebrew-tap
cp Formula/eng-leader-tools.rb /tmp/g.rb
# point the linux resource url at a nonexistent tag + zero its hash to force hashing
sed -i '' 's|download/v0.3.2/eng-mcp-v0.3.2-linux-x86_64.tar.gz|download/v999.0.0/eng-mcp-v999.0.0-linux-x86_64.tar.gz|' Formula/eng-leader-tools.rb
sed -i '' 's/sha256 "[a-f0-9]*"/sha256 "0000000000000000000000000000000000000000000000000000000000000000"/' Formula/eng-leader-tools.rb
./update.sh eng-leader-tools; echo "exit=$?"
mv /tmp/g.rb Formula/eng-leader-tools.rb
```
Expected: prints `✗ eng-leader-tools: failed to hash ...v999.0.0...`, `exit=1`. After restore, formula pristine (no diff).

- [ ] **Step 3: Scoop — array + arch + flat all green** (re-run the Task 2 verifications quickly)

```bash
cd ~/Projects/recurse/2026/scoop-bucket
bash -n update.sh && echo "syntax OK"
./update.sh eng-leader-tools 2>&1 | tail -1   # array -> already at, no crash
./update.sh loupe 2>&1 | tail -1              # arch -> already at
./update.sh engsight 2>&1 | tail -1           # flat -> already at
git status --short                            # no manifest changes (all already current)
```
Expected: syntax OK; three "✓ already at" lines; no manifest diffs.

- [ ] **Step 4: Workflow — 3 matrix rows, no Intel**

```bash
cd ~/Projects/engleader.tools/engleader-tools-scripts
grep -c 'os:' .github/workflows/mcp-release.yml
grep -c 'macos-13' .github/workflows/mcp-release.yml
```
Expected: `3` and `0`.

- [ ] **Step 5: (No commit — verification only.)** Report results.

---

## Self-Review Notes

- **Spec coverage:** Homebrew line-walk per-pair hashing (Task 1) ✓; Scoop type-aware string|array|architecture (Task 2) ✓; Intel sunset workflow row (Task 3) + formula on_intel (Task 4) ✓; per-url loud-failure guard (Tasks 1,2; tested Task 5.2) ✓; single-artifact/arch/flat regression checks (Tasks 1.4, 2.6, 2.7, 5.3) ✓; idempotency (Tasks 1.3, 2.5, 5.3) ✓. Out-of-scope items (no re-release of v0.3.2, no linux-arm64, no migration of arch tools) honored.
- **Placeholder scan:** No TBD/TODO; every step has concrete commands + the exact known hashes to assert against.
- **Consistency:** The four real v0.3.2 hashes are used identically wherever asserted (`f38c1f89`=source, `36272755`=arm64, `c0ee6f30`=intel, `74605e36`=linux, `e8d5d654`=windows-zip). The per-url guard (`set -o pipefail`/`curl_rc`/`-z` → stderr ✗ + return 1) is identical in both scripts. Homebrew stays bash+sed; Scoop stays python3.
- **Ordering note:** Task 1 verifies WITH on_intel still present (4 hashes); Task 4 removes it; Task 5.1 re-verifies WITHOUT it (3 hashes). This sequencing is intentional and the expected hash sets differ accordingly.
