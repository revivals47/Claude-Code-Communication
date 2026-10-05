#!/bin/bash
# 段 (3) S1 (worker3, boss1 04:42 GO): tree track3/rodhold-s1 43beea1. Under boss1's gate and LOCK only. The step logs stay in Logs/ (boss1: not
# copied to drafts); this dir keeps the short outputs. Stops at a red build.
set -u
T=$HOME/Documents/ikada-unity-track3; D=$(cd "$(dirname "$0")" && pwd); C=$HOME/Documents/Claude-Code-Communication/workspace/ikada-unity/drafts/stageD/rodhold_switch/rodhold_count.py
SH=/home/ken/Documents/Claude-Code-Communication/workspace/ikada-unity/shots/player_live
export LIVE_BASELINE=perseed LIVE_BASE_20260925=$SH/ae3b5c4_s20260925_231126 LIVE_BASE_1=$SH/ae3b5c4_s1_231126 LIVE_BASE_26=$SH/5e50ac7_s26_014332
cd "$T" || exit 1
[ "$(git rev-parse --short HEAD)" = 43beea1 ] && [ "$(git status --porcelain | wc -l)" = 0 ] || { echo "tree is not a clean 43beea1 - stop"; exit 1; }
echo "== 1 regress"; tools/regress_all.sh > "$D/regress.out" 2>&1; echo "   rc=$? $(grep -m1 '^RESULT' "$D/regress.out")"
RID=$(cd Logs/regress && ls -dt 43beea1_* 2>/dev/null | head -1); echo "   regress id $RID"; [ -n "$RID" ] || exit 1
grep -q "^build .*PASS" "Logs/regress/$RID/SUMMARY.txt" || { echo "build not PASS - stop"; exit 1; }
O=$T/Logs/regress/$RID/s1
echo "== 2 live, no step log (wall time)"; s=$(date +%s); tools/live_regress.sh "$O/plain" > "$D/live_plain.out" 2>&1; echo "   rc=$? wall $(( $(date +%s) - s )) s"
echo "== 3 live, IKADA_ROD_HOLD_STEP_LOG=1 (wall time)"; s=$(date +%s); IKADA_ROD_HOLD_STEP_LOG=1 tools/live_regress.sh "$O/steplog" > "$D/live_steplog.out" 2>&1; echo "   rc=$? wall $(( $(date +%s) - s )) s"
for seed in 20260925 1 26; do L=$O/steplog/seed_$seed/live.log; echo "== 4 count seed $seed: $(grep -c '\[RodHoldStep\]' "$L") lines"; python3 "$C" "$L" --expect pass > "$D/count_$seed.out" 2>&1; echo "   rc=$? $(tail -1 "$D/count_$seed.out")"; done
echo "== 5 control (i) the holder key once"; IKADA_ROD_HOLD_STEP_LOG=1 tools/key_day.sh "$D/kh_once.md" "05,07,06C,06,P1,04,J" 20260925 > "$D/kh.out" 2>&1; echo "   rc=$?"
KL=$(ls -dt Logs/player/keyday_43beea1_kh_once* | head -1)/live.log; echo "   log $KL $(grep -c '\[RodHoldStep\]' "$KL") lines"
python3 "$C" "$KL" --expect kh > "$D/count_kh.out" 2>&1; echo "   rc=$? $(tail -1 "$D/count_kh.out")"
echo "== 6 control (ii) practice set, IKADA_RODHAND_NO_LEADIN=1"; P=$T/Builds/Linux/Ikada.x86_64; mkdir -p "$O/noleadin"
IKADA_ROD_HOLD_STEP_LOG=1 IKADA_RODHAND_NO_LEADIN=1 timeout 1800 "$P" -screen-width 1920 -screen-height 1080 -screen-fullscreen 0 -ikadaLive -ikadaLiveAutoPilot -ikadaLockstep \
  -ikadaLiveSpeed 300 -ikadaSavePath none -ikadaWaterT 10 -ikadaTipSettle -ikadaLiveShot "$O/noleadin" -logFile "$O/noleadin/live.log" \
  -ikadaLivePractice set -ikadaLiveSeed 20260925 -ikadaLiveQuitAfterS 3600; echo "   rc=$? lines $(grep -c '\[RodHoldStep\]' "$O/noleadin/live.log") lead-in steps $(grep -c 'leadIn=True' "$O/noleadin/live.log")"
python3 "$C" "$O/noleadin/live.log" --expect unexplained > "$D/count_noleadin.out" 2>&1; echo "   rc=$? $(tail -1 "$D/count_noleadin.out")"
