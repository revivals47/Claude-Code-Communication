#!/bin/bash
# worker2 (boss1 01:57): 段 5's pin as ONE commit on the tree given (master after 段 4 = bf95f05's shape: pin d0118ce + dropside),
# copied from worker1's pin_0220.sh. Changed: OLD = d0118ce, NEW = an argument (worker1's fix; 22d6f61 for the --dry trials until it
# is set), no cherry-pick (DROP none), refcheck_probe's note is rewritten from the 0.22.0 text, and the RefCheck table can be
# re-fixed from a file (the fix may move some days' events - RECORD_PLACEMENT_W1.md §8: the 4/20 four and E' are predicted to move).
# No Unity, no dotnet. --dry = every check, prints what would change, writes nothing.
# usage: pin_0230.sh <unity worktree> <new ikada-sim sha (40 hex)> [--dry] [--table <file>]   (PIN_OLD=<40 hex> forces the old pin;
#   default = the manifest's: the first use moved d0118ce -> 22d6f61, the re-pin moves 22d6f61 -> the fix, boss1 02:57)
#   --table <file>: lines "<key>=<16 hex>" with the keys of refcheck_probe.sh's TABLE ("/20260925", "7-20/1", "4-20@3/20260925", ...);
#   every key named must be in the table once, and is replaced; keys not named keep their value. Without --table the table stays.
set -u
T=${1:?usage: pin_0230.sh <worktree> <new sha> [--dry] [--table <file>]}; NEW=${2:?new ikada-sim sha (40 hex)}; shift 2
DRY=""; TABLEF=""
while [ $# -gt 0 ]; do case "$1" in --dry) DRY=1;; --table) TABLEF=${2:?--table <file>}; shift;; *) echo "unknown arg $1"; exit 2;; esac; shift; done
[ -n "$TABLEF" ] && TABLEF=$(readlink -f "$TABLEF")   # the script cds into the worktree below (a relative --table failed at 04:14)
OLD=${PIN_OLD:-}   # empty = read from the tree's manifest below (the re-pin from 22d6f61, boss1 02:57); the first use was d0118ce
SIM=/home/ken/Documents/ikada-sim                       # the repo tools/logic_font_chars.py reads (its SIM)
say() { echo "[pin0230] $(date '+%F %T') $*"; }
[[ $NEW =~ ^[0-9a-f]{40}$ ]] || { say "STOP the new sha is not 40 hex: $NEW (Unity's git package needs the full hash)"; exit 2; }
git -C "$SIM" cat-file -e "$NEW^{commit}" 2>/dev/null || { say "STOP $NEW is not in $SIM (git -C $SIM fetch first)"; exit 2; }
API=$(git -C "$SIM" show "$NEW:pc/src/Ikada.Game/IkadaSession.cs" | grep -o 'ApiVersion = "[0-9.]*"' | head -1 | grep -o '[0-9][0-9.]*')
[ -n "$API" ] || { say "STOP no ApiVersion in $NEW's IkadaSession.cs"; exit 2; }
cd "$T" || exit 2
[ -z "$(git status --porcelain)" ] || { say "STOP dirty"; exit 3; }
[ -n "$OLD" ] || OLD=$(grep 'com.ikada.sim' Packages/manifest.json | grep -o '#[0-9a-f]\{40\}' | head -1 | cut -c2-)
[[ $OLD =~ ^[0-9a-f]{40}$ ]] || { say "STOP could not read the old pin from the manifest"; exit 4; }
[ "$OLD" != "$NEW" ] || { say "STOP the tree is already on $NEW"; exit 4; }
grep -q "#$OLD" Packages/manifest.json || { say "STOP manifest is not on $OLD: $(grep -o 'com.ikada.sim.*' Packages/manifest.json)"; exit 4; }
git -C "$SIM" merge-base --is-ancestor "$OLD" "$NEW" || { say "STOP $OLD is not an ancestor of $NEW"; exit 4; }
P=tools/refcheck_probe.sh
NOTE_A=$(grep -o "API [0-9.]* = ikada-sim ${OLD:0:7} (the table is" "$P" | head -1)   # the note the last pin wrote, at the old pin
[ "$(grep -cF "${NOTE_A:-x}" "$P")" = 1 ] || { say "STOP refcheck_probe's note for ${OLD:0:7} not found once ('$NOTE_A')"; exit 4; }
OLDAPI=$(echo "$NOTE_A" | grep -o 'API [0-9.]*' | cut -c5-)
if [ -n "$TABLEF" ]; then   # check the file before anything: each key once in the table, a 16-hex value
  [ -f "$TABLEF" ] || { say "STOP no table file $TABLEF"; exit 2; }
  while IFS='=' read -r k v; do
    [ -z "$k" ] && continue; [[ $v =~ ^[0-9a-f]{16}$ ]] || { say "STOP table value for '$k' is not 16 hex: '$v'"; exit 2; }
    n=$(grep -oF "[$k]=" "$P" | wc -l); [ "$n" = 1 ] || { say "STOP key [$k] found $n times in $P's TABLE (want 1)"; exit 2; }
  done < "$TABLEF"
  say "table file $TABLEF: $(grep -c '=' "$TABLEF") key(s) checked"
fi
say "tree $(git rev-parse --short HEAD) on $(git branch --show-current), manifest $OLD -> $NEW (API $API)"
python3 tools/logic_font_chars.py "$NEW" "$OLD" . 2>&1 | grep -E '^\[chars\] [0-9a-f]{7}|^\[chars\] new|missing of new [1-9]' | sed 's/^/[pin0230] /'
if [ -n "$DRY" ]; then
  say "dry: would change manifest 1 + lock 2 to $NEW, regenerate LogicChars (SimRef and the header line change even with no new char), rewrite refcheck_probe's note${TABLEF:+, replace $(grep -c '=' "$TABLEF") table value(s)}; no cherry-pick"
  [ -n "$TABLEF" ] && while IFS='=' read -r k v; do [ -n "$k" ] && say "dry table [$k] $(grep -oE "\[$(printf '%s' "$k" | sed 's/[][\.*^$/@-]/\\&/g')\]=[0-9a-f]{16}" "$P" | cut -d= -f2) -> $v"; done < "$TABLEF"
  exit 0
fi
sed -i "s/$OLD/$NEW/g" Packages/manifest.json Packages/packages-lock.json
[ "$(grep -c "$NEW" Packages/manifest.json)" = 1 ] && [ "$(grep -c "$NEW" Packages/packages-lock.json)" = 2 ] || { say "STOP pin count"; exit 5; }
python3 tools/logic_font_chars.py "$NEW" "$OLD" . Assets/Scripts/UI/LogicChars.cs > /tmp/pin0230_chars.$$ 2>&1
grep -q "new since ${OLD:0:7}: 0" /tmp/pin0230_chars.$$ || say "NOTE new chars since ${OLD:0:7}: $(grep '^\[chars\] new' /tmp/pin0230_chars.$$ | cut -c1-120) (bake at the Unity turn)"
rm -f /tmp/pin0230_chars.$$
NEW7=${NEW:0:7}
if [ -n "$TABLEF" ]; then TN="re-fixed at $NEW7 from $(basename "$TABLEF") for the named keys, the rest still #13"; else TN="still #13 at $NEW7, checked by this probe at the pin"; fi
NOTE_B="API $API = ikada-sim $NEW7 (the table is $TN; $OLDAPI = ${OLD:0:7}: the table is"
python3 - "$P" "$NOTE_A" "$NOTE_B" <<'EOF'
import sys
p, a, b = sys.argv[1:4]; s = open(p, encoding='utf-8').read()
assert s.count(a) == 1, 'note not found once'
open(p, 'w', encoding='utf-8').write(s.replace(a, b, 1)); print('[pin0230] refcheck_probe note updated')
EOF
if [ -n "$TABLEF" ]; then
  python3 - "$P" "$TABLEF" "$NEW7" <<'EOF'
import re, sys
p, f = sys.argv[1:3]; s = open(p, encoding='utf-8').read()
for line in open(f):
    line = line.strip()
    if not line: continue
    k, v = line.split('=', 1)
    s, n = re.subn(r'\[' + re.escape(k) + r'\]=[0-9a-f]{16}', '[' + k + ']=' + v, s)
    assert n == 1, (k, n)
    print(f'[pin0230] table [{k}] = {v}')
keys = [l.split('=', 1)[0] for l in open(f) if l.strip()]
c = '# 0.20.0 (777950e), fixed again #13; kept for 0.21.0 (22e566a)'
assert s.count(c) == 1, 'table comment not found once'
s = s.replace(c, c + '; re-fixed at ' + sys.argv[3] + ' for ' + ' '.join(keys) + ' (the rest kept)')
open(p, 'w', encoding='utf-8').write(s)
EOF
fi
git add -u && git commit -q -m "pin ikada-sim $NEW (API $API; 段 5, worker2's pin_0230.sh, boss1 01:57): manifest 1 + lock 2; LogicChars regenerated; refcheck_probe note${TABLEF:+ and table re-fixed for the keys in $(basename "$TABLEF")}

Co-Authored-By: Claude Opus 5.5 (1M context) <noreply@anthropic.com>" && say "pin commit $(git rev-parse --short HEAD)"
[ -z "$(git status --porcelain)" ] && say "porcelain 0" || say "STOP dirty at the end"
