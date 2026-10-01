#!/bin/bash
# stage3_swap.sh - unlock step 3b + seed 26 (worker3, boss1 2026-10-02 01:41: PRESIDENT's GO for the swap; run only under boss1's LOCK).
#   0. gates (Unity / player / Runner.Worker / dotnet 0, LockedHint printed), track3 = 5e50ac7 clean, its build = the bc4ffd5 build
#      (bc4ffd5..5e50ac7 touches tools/live_regress.sh only - checked), the regress the table came from exists.
#   1. live_rebase.py --apply with the dry-run table US_SWAP_TABLE.md (tag pre-us_, seeds 20260925 and 1): its own sha re-check refuses
#      any file that moved since the dry run.
#   2. AUDIO.txt (live_rebase.py does not take it; live_regress.sh:148-152 compares 5b against the baseline's): the same steps by hand
#      per seed - old -> pre-us__AUDIO.txt (refuse if there), the regress run's copied in, both sha256 checked, one NOTE line.
#   3. seed 26's first baseline, A/A (worker2): tools/live_regress.sh twice with LIVE_SEEDS=26 and an EMPTY baseline dir (the dir check
#      passes, the comparisons fail - expected; only the run dirs are used). Then a vs b: RESULT line (page= / screens= / steps), AUDIO.txt,
#      every live_*.png 0 px. All equal -> run a becomes shots/player_live/5e50ac7_s26_<HHMMSS> (+ NOTE). Pictures differ -> print the
#      bbox and colours, STOP (to boss1). The screens / page differ -> STOP.
#   Prints the 3c command at the end (LIVE_BASE_26 passed in the environment: regress_all.sh exports only 20260925 and 1).
# usage: stage3_swap.sh <out dir>
set -u
O=${1:?out}; mkdir -p "$O"; O=$(cd "$O" && pwd)
T3=/home/ken/Documents/ikada-unity-track3; WANT=5e50ac7; R=$T3/Logs/regress/bc4ffd5_010720
W=/home/ken/Documents/Claude-Code-Communication/workspace/ikada-unity; SHOTS=$W/shots; TABLE=$W/drafts/stageD/US_SWAP_TABLE.md
TAG=pre-us_; REASON="input-us 2d51b94 (#15: the live pilot's clock = frame/60.0, not a float sum; the logic sequence moves) merged onto master 5296d34 = bc4ffd5, unlock step 3 (boss1 10/02 01:06); PRESIDENT GO via boss1 01:41"
source $W/drafts/stageD/unity_direct.sh   # cmp_px only
say() { echo "[s3] $(date '+%F %T') $*" | tee -a "$O/turn.log"; }
stop() { say "STOP: $*"; exit 1; }
sh256() { sha256sum "$1" | cut -d' ' -f1; }
seat=$(loginctl | awk '/seat0/{print $1; exit}')
say "head $(loginctl show-session $seat -p LockedHint -p IdleHint | tr '\n' ' ')Unity=$(pgrep -xc Unity) player=$(pgrep -xc Ikada.x86_64) Runner.Worker=$(pgrep -xc Runner.Worker) dotnet=$(pgrep -xa dotnet | grep -vc VBCSCompiler)"
[ "$(pgrep -xc Unity)" = 0 ] && [ "$(pgrep -xc Ikada.x86_64)" = 0 ] && [ "$(pgrep -xc Runner.Worker)" = 0 ] || stop "Unity / player / CI busy"
[ "$(git -C $T3 rev-parse --short HEAD)" = $WANT ] || stop "track3 is not $WANT"
[ -z "$(git -C $T3 status --porcelain)" ] || stop "track3 not clean"
[ "$(git -C $T3 diff --name-only bc4ffd5 HEAD)" = tools/live_regress.sh ] || stop "bc4ffd5..HEAD touches more than tools/live_regress.sh (the build would be stale)"
[ -d "$R/live/seed_20260925" ] && [ -d "$R/live/seed_1" ] || stop "the regress the table came from is missing: $R"
say "build $(stat -c %y $T3/Builds/Linux/Ikada_Data/Managed/Assembly-CSharp.dll | cut -c1-19) (bc4ffd5's regress build)"
# --- 1. the table's swap ---
python3 $W/drafts/stageC/live_rebase.py "$R" --tag $TAG --reason "$REASON" --table "$TABLE" --seeds 20260925,1 --apply > "$O/rebase_apply.out" 2>&1 \
  || { cat "$O/rebase_apply.out" | tail -5 | tee -a "$O/turn.log"; stop "live_rebase --apply refused / failed"; }
say "$(tail -1 $O/rebase_apply.out)"
# --- 2. AUDIO.txt, by hand, the same checks ---
for sd in 20260925 1; do
  B=$SHOTS/player_live/ae3b5c4_s${sd}_231126; S=$R/live/seed_$sd
  [ -f "$S/AUDIO.txt" ] || stop "no AUDIO.txt in $S"
  hb=$(sh256 $B/AUDIO.txt); hs=$(sh256 $S/AUDIO.txt)
  if [ "$hb" = "$hs" ]; then say "seed $sd AUDIO.txt same - untouched"; continue; fi
  [ -e "$B/${TAG}_AUDIO.txt" ] && stop "$B/${TAG}_AUDIO.txt exists already"
  mv "$B/AUDIO.txt" "$B/${TAG}_AUDIO.txt" && cp -p "$S/AUDIO.txt" "$B/AUDIO.txt"
  [ "$(sh256 $B/AUDIO.txt)" = "$hs" ] && [ "$(sh256 $B/${TAG}_AUDIO.txt)" = "$hb" ] || stop "seed $sd AUDIO.txt sha check failed"
  echo "  - AUDIO.txt: sha256 差し替え前 $hb → 差し替え後 $hs（出所 $S と同じ, stage3_swap.sh = live_rebase.py が取らない file を同じ手順で）。旧 = ${TAG}_AUDIO.txt。" >> "$B/NOTE_baseline_changes.md"
  say "seed $sd AUDIO.txt swapped ($hb -> $hs), NOTE line added"
done
# --- 3. seed 26, A/A ---
E=$O/empty_base_26; mkdir -p "$E"
for k in a b; do
  (cd $T3 && LIVE_SEEDS=26 LIVE_BASE_26=$E tools/live_regress.sh "$O/s26_$k") > "$O/s26_$k.out" 2>&1
  say "seed 26 run $k: $(grep -m1 '^\[live_regress\] seed 26:' $O/s26_$k.out | cut -c1-200)"
done
A=$O/s26_a/seed_26; Bd=$O/s26_b/seed_26
ra=$(cat $A/RESULT.txt); rb=$(cat $Bd/RESULT.txt)
[ -n "$ra" ] || stop "seed 26 run a has no RESULT"
pa=$(grep -oE 'page=[^ ]+ screens=[^ ]+' $A/RESULT.txt); pb=$(grep -oE 'page=[^ ]+ screens=[^ ]+' $Bd/RESULT.txt)
[ "$pa" = "$pb" ] || stop "seed 26 a / b: the page / screens differ (a: ${pa:0:120} / b: ${pb:0:120})"
say "seed 26 a = b: page/screens same; steps a $(grep -oE 'steps=[0-9]+' $A/RESULT.txt) b $(grep -oE 'steps=[0-9]+' $Bd/RESULT.txt); AUDIO $( cmp -s $A/AUDIO.txt $Bd/AUDIO.txt && echo same || echo DIFFER )"
bad=0
for f in $(cd $A && ls live_*.png); do
  [ -f "$Bd/$f" ] || { say "  $f: only in a"; bad=1; continue; }
  d=$(cmp_px $A/$f $Bd/$f); say "  $f: $d"
  if [ "$d" != "diff_px=0 bbox=None" ]; then bad=1
    python3 - "$A/$f" "$Bd/$f" <<'PY' | tee -a "$O/turn.log"
import sys
from PIL import Image, ImageChops
a=Image.open(sys.argv[1]).convert('RGB'); b=Image.open(sys.argv[2]).convert('RGB'); d=ImageChops.difference(a,b)
pts=[(x,y) for y in range(a.size[1]) for x in range(a.size[0]) if d.getpixel((x,y))!=(0,0,0)][:5]
for p in pts: print(f'    {p}: a {a.getpixel(p)} b {b.getpixel(p)}')
PY
  fi
done
for f in $(cd $Bd && ls live_*.png); do [ -f "$A/$f" ] || { say "  $f: only in b"; bad=1; }; done
cmp -s $A/AUDIO.txt $Bd/AUDIO.txt || bad=1
[ $bad = 0 ] || stop "seed 26 a / b differ (pictures above, or AUDIO.txt) - to boss1, no baseline made"
N=$SHOTS/player_live/${WANT}_s26_$(date +%H%M%S); mkdir -p "$N"
cp -p $A/live_*.png $A/RESULT.txt $A/live.log $A/ARGS.txt $A/AUDIO.txt "$N/"
echo "- $(date '+%F %T') stage3_swap.sh: seed 26 の最初の基準（boss1 01:41, worker2 の A/A）= $A（b = $Bd と page/screens・AUDIO・全 live_*.png 0 px で同じ）、build = bc4ffd5（track3 5e50ac7）。" > "$N/NOTE_baseline_changes.md"
say "seed 26 baseline = $N ($(ls $N/live_*.png | wc -l) pictures)"
say "3c: cd $T3 && LIVE_BASE_26=$N REGRESS_LIVE=1 tools/regress_all.sh   (regress_all.sh exports only 20260925 / 1: a default line for 26 is worker2's)"
say "end Unity=$(pgrep -xc Unity) player=$(pgrep -xc Ikada.x86_64) porcelain=$(git -C $T3 status --porcelain | wc -l)"
