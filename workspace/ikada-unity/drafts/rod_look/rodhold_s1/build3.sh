#!/bin/bash
# §7.55 (worker3, boss1 06:03 GO): the 3rd build of the same tree 43beea1, then live seeds 20260925 and 26 only. Gate and LOCK only.
set -u
T=$HOME/Documents/ikada-unity-track3; D=$(cd "$(dirname "$0")" && pwd); SH=/home/ken/Documents/Claude-Code-Communication/workspace/ikada-unity/shots/player_live
export LIVE_BASELINE=perseed LIVE_BASE_20260925=$SH/ae3b5c4_s20260925_231126 LIVE_BASE_26=$SH/5e50ac7_s26_014332 LIVE_SEEDS="20260925 26"
cd "$T" || exit 1
[ "$(git rev-parse --short HEAD)" = 43beea1 ] && [ "$(git status --porcelain | wc -l)" = 0 ] || { echo "tree is not a clean 43beea1 - stop"; exit 1; }
O=$T/Logs/regress/43beea1_054818/build3; mkdir -p "$O"
python3 tools/check_scene_embeds.py > "$O/embeds_pre.out" 2>&1 || { echo "embeds FAILED"; exit 1; }
s=$(date +%s); tools/unity-batch.sh exec Ikada.EditorTools.BuildScript.BuildPerf > "$O/build.out" 2>&1; echo "== build rc=$? $(grep 'error CS lines' "$O/build.out") wall $(( $(date +%s) - s )) s"
python3 tools/check_scene_embeds.py > "$O/embeds_post.out" 2>&1 || { echo "embeds after build FAILED"; exit 1; }
echo "== live"; tools/live_regress.sh "$O/live" > "$O/live.out" 2>&1; echo "   rc=$? $(grep -E 'seed (20260925|26) (FAIL|pictures 0)' "$O/live.out" | tr '\n' ' ' | cut -c1-200)"
