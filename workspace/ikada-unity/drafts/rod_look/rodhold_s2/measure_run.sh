#!/bin/bash
# §7.56 measure (worker3, boss1 06:33 GO): seed 20260925 live with IKADA_ROD_FRAME_LOG=1 on two builds - track3/s1-measure 197be0e
# (master + log) and track3/s2-measure 0f91f51 (S2 + log). Gate and LOCK only. Never merged. Ends back on track3/rodhold-s2 09330dd.
set -u
T=$HOME/Documents/ikada-unity-track3; D=$(cd "$(dirname "$0")" && pwd); SH=/home/ken/Documents/Claude-Code-Communication/workspace/ikada-unity/shots/player_live
export LIVE_BASELINE=perseed LIVE_BASE_20260925=$SH/ae3b5c4_s20260925_231126 LIVE_SEEDS=20260925
cd "$T" || exit 1; O=$T/Logs/regress/09330dd_062303/measure
for pair in "s1 track3/s1-measure 197be0e" "s2 track3/s2-measure 0f91f51"; do set -- $pair
  [ "$(git status --porcelain | wc -l)" = 0 ] || { echo "tree not clean - stop"; exit 1; }
  git checkout -q "$2" && [ "$(git rev-parse --short HEAD)" = "$3" ] || { echo "checkout $2 failed - stop"; exit 1; }
  python3 tools/check_scene_embeds.py > /dev/null 2>&1 || { echo "embeds FAILED - stop"; exit 1; }
  s=$(date +%s); tools/unity-batch.sh exec Ikada.EditorTools.BuildScript.BuildPerf > "$D/measure_build_$1.out" 2>&1; echo "== $1 build rc=$? $(grep 'error CS lines' "$D/measure_build_$1.out") wall $(( $(date +%s) - s )) s"
  IKADA_ROD_FRAME_LOG=1 tools/live_regress.sh "$O/$1" > "$D/measure_live_$1.out" 2>&1; echo "   $1 live rc=$? lines $(grep -c 'hold frame' "$O/$1/seed_20260925/live.log") cap $(grep -c 'cap reached' "$O/$1/seed_20260925/live.log")"
done
git checkout -q track3/rodhold-s2; echo "== back on $(git rev-parse --short HEAD) porcelain $(git status --porcelain | wc -l)"
