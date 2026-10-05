#!/bin/bash
# 段 (3) S2 (worker3, boss1 06:22 GO): tree track3/rodhold-s2 09330dd. Gate and LOCK only. Logs stay in Logs/; short outputs here.
set -u
T=$HOME/Documents/ikada-unity-track3; D=$(cd "$(dirname "$0")" && pwd); C=$HOME/Documents/Claude-Code-Communication/workspace/ikada-unity/drafts/stageD/rodhold_switch/rodhold_count.py
SH=/home/ken/Documents/Claude-Code-Communication/workspace/ikada-unity/shots/player_live
export LIVE_BASELINE=perseed LIVE_BASE_20260925=$SH/ae3b5c4_s20260925_231126 LIVE_BASE_1=$SH/ae3b5c4_s1_231126 LIVE_BASE_26=$SH/5e50ac7_s26_014332
cd "$T" || exit 1
[ "$(git rev-parse --short HEAD)" = 09330dd ] && [ "$(git status --porcelain | wc -l)" = 0 ] || { echo "tree is not a clean 09330dd - stop"; exit 1; }
echo "== 1 regress"; tools/regress_all.sh > "$D/regress.out" 2>&1; echo "   rc=$? $(grep -m1 '^RESULT' "$D/regress.out")"
RID=$(cd Logs/regress && ls -dt 09330dd_* 2>/dev/null | head -1); echo "   regress id $RID"; [ -n "$RID" ] || exit 1
grep -q "^build .*PASS" "Logs/regress/$RID/SUMMARY.txt" || { echo "build not PASS - stop"; exit 1; }
grep -h "(697,726)" Logs/regress/$RID/live/seed_*/live_08.cmp 2>/dev/null | sed 's/^/   known: /'
O=$T/Logs/regress/$RID/s2
echo "== 2 live, IKADA_ROD_HOLD_STEP_LOG=1"; IKADA_ROD_HOLD_STEP_LOG=1 tools/live_regress.sh "$O/steplog" > "$D/live_steplog.out" 2>&1; echo "   rc=$?"
for seed in 20260925 1 26; do L=$O/steplog/seed_$seed/live.log; python3 "$C" "$L" --expect pass > "$D/count_s2_$seed.out" 2>&1; echo "== 3 S2 seed $seed: rc=$? $(head -1 "$D/count_s2_$seed.out" | cut -c1-120)"; done
S1=$T/Logs/regress/43beea1_051728/s1/steplog
for seed in 20260925 1 26; do python3 "$C" "$S1/seed_$seed/live.log" --expect pass > "$D/count_s1pos_$seed.out" 2>&1; echo "== 4 S1 log (positive) seed $seed: rc=$? $(head -1 "$D/count_s1pos_$seed.out" | cut -c1-120)"; done
