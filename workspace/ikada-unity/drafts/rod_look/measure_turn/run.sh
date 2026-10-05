#!/bin/bash
# §7.51 (worker3): seed 26 live_08 - one build of track3/sink-measure 2ae11c7, then M1 (frame log) and M2 (frame log + the stance at 0)
# on the SAME build. Under boss1's gate and LOCK only.
set -u
T=$HOME/Documents/ikada-unity-track3; D=$(cd "$(dirname "$0")" && pwd)
export LIVE_BASELINE=perseed LIVE_BASE_26=/home/ken/Documents/Claude-Code-Communication/workspace/ikada-unity/shots/player_live/5e50ac7_s26_014332 LIVE_SEEDS=26
cd "$T" || exit 1
echo "== tree $(git rev-parse --short HEAD) porcelain $(git status --porcelain | wc -l)"
python3 tools/check_scene_embeds.py > "$D/embeds_pre.out" 2>&1 || { echo "embeds check FAILED"; exit 1; }
tools/unity-batch.sh exec Ikada.EditorTools.BuildScript.BuildPerf > "$D/build.out" 2>&1; echo "== build rc=$? $(grep 'error CS lines' "$D/build.out")"
python3 tools/check_scene_embeds.py > "$D/embeds_post.out" 2>&1 || { echo "embeds check after build FAILED"; exit 1; }
sha256sum Builds/Linux/Ikada.x86_64 > "$D/player_sha.txt"
echo "== M1"; IKADA_ROD_FRAME_LOG=1 tools/live_regress.sh "$D/M1" > "$D/M1.out" 2>&1; echo "   rc=$? $(grep -m1 'seed 26 FAIL\|seed 26 PASS\|seed 26 ok' "$D/M1.out" | cut -c1-120)"
echo "== M2"; IKADA_ROD_FRAME_LOG=1 IKADA_ROD_SINK_DEG=0 IKADA_ROD_SINK_BUTT_UP_M=0 IKADA_ROD_SINK_BUTT_FWD_M=0 tools/live_regress.sh "$D/M2" > "$D/M2.out" 2>&1; echo "   rc=$? $(grep -m1 'seed 26 FAIL\|seed 26 PASS\|seed 26 ok' "$D/M2.out" | cut -c1-120)"
sha256sum -c "$D/player_sha.txt" && echo "== same build for M1 and M2"
