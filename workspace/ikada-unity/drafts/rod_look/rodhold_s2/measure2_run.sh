#!/bin/bash
# §7.56 measure 2 (worker3, PRESIDENT 06:5x ①): seed 20260925 on two builds with the state dump on frames 1460..1473 (the 08 shot = 1473 in
# measure 1). track3/s1-measure 3c32ad4, track3/s2-measure 18145ee (log / dump only, never merged). Gate and LOCK only. Ends on track3/rodhold-s2.
set -u
T=$HOME/Documents/ikada-unity-track3; D=$(cd "$(dirname "$0")" && pwd); SH=/home/ken/Documents/Claude-Code-Communication/workspace/ikada-unity/shots/player_live
export LIVE_BASELINE=perseed LIVE_BASE_20260925=$SH/ae3b5c4_s20260925_231126 LIVE_SEEDS=20260925 IKADA_ROD_FRAME_LOG=1 IKADA_ROD_STATE_DUMP_FRAMES=1460-1473
cd "$T" || exit 1; O=$T/Logs/regress/09330dd_062303/measure2
for pair in "s1 track3/s1-measure 3c32ad4" "s2 track3/s2-measure 18145ee"; do set -- $pair
  rm -f Assets/Scripts/Render/RodStateDump.cs.meta
  [ "$(git status --porcelain | wc -l)" = 0 ] || { echo "tree not clean - stop"; git status --porcelain; exit 1; }
  git checkout -q "$2" && [ "$(git rev-parse --short HEAD)" = "$3" ] || { echo "checkout $2 failed - stop"; exit 1; }
  python3 tools/check_scene_embeds.py > /dev/null 2>&1 || { echo "embeds FAILED - stop"; exit 1; }
  s=$(date +%s); tools/unity-batch.sh exec Ikada.EditorTools.BuildScript.BuildPerf > "$D/measure2_build_$1.out" 2>&1; echo "== $1 build rc=$? $(grep 'error CS lines' "$D/measure2_build_$1.out") wall $(( $(date +%s) - s )) s"
  tools/live_regress.sh "$O/$1" > "$D/measure2_live_$1.out" 2>&1; L=$O/$1/seed_20260925/live.log; echo "   $1 live rc=$? state lines $(grep -c '\[RodState\]' "$L") shot08 before line $(grep -n 'shot screen=08' "$L" | head -1 | cut -d: -f1)"
done
rm -f Assets/Scripts/Render/RodStateDump.cs.meta; git checkout -q track3/rodhold-s2; echo "== back on $(git rev-parse --short HEAD) porcelain $(git status --porcelain | wc -l)"
