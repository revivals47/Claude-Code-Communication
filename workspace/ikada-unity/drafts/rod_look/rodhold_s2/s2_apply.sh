#!/bin/bash
# 段 (3) S2 apply (worker3; waits for PRESIDENT's answer on seed 20260925's live_08). Gate and LOCK only. Tree = track3/rodhold-s2 09330dd.
# 1 live rebase (regress 09330dd_062303, dry table s2_live_dry_table.md: changed 4 = seed 20260925 live_08 + live.log x3) -> 2 regress ->
# 3 live 3 seeds with IKADA_ROD_HOLD_STEP_LOG=1 + rodhold_count.py (S2 3 seeds, S1 logs as the positive control) -> 4 PIN only if RESULT PASS.
set -u
T=$HOME/Documents/ikada-unity-track3; D=$(cd "$(dirname "$0")" && pwd); C=$HOME/Documents/Claude-Code-Communication/workspace/ikada-unity/drafts/stageD/rodhold_switch/rodhold_count.py
MOCK=/home/ken/Documents/Claude-Code-Communication/workspace/ikada-unity/shots/player/a9106ea_234105; SH=/home/ken/Documents/Claude-Code-Communication/workspace/ikada-unity/shots/player_live
export LIVE_BASELINE=perseed LIVE_BASE_20260925=$SH/ae3b5c4_s20260925_231126 LIVE_BASE_1=$SH/ae3b5c4_s1_231126 LIVE_BASE_26=$SH/5e50ac7_s26_014332
cd "$T" || exit 1
[ "$(git rev-parse --short HEAD)" = 09330dd ] && [ "$(git status --porcelain | wc -l)" = 0 ] || { echo "tree is not a clean 09330dd - stop"; exit 1; }
echo "== 1 live"; python3 "$D/../../stageD/live_rebase5.py" "$T/Logs/regress/09330dd_062303" --tag pre-s2 --project "$T" --table "$D/s2_live_dry_table.md" --apply \
  --reason "段 (3) S2 = RodHand が logic の RodHold を読む・_lowHeld を消す（PRESIDENT 05:5x / 07:0x, boss1 06:19）: ★種 20260925 live_08 = 長い K2 run で竿が手だった事の持ち越し（描きの位置の約 4e-6 m の残りが MSAA の縁で 1〜21 段）★（§7.56: 2 build の state dump で 描きの field の差は 1473 で ≤ 4.3e-6、陽性対照 = S1 の build で竿を −4.29e-6 m ずらすと 339 px・1 段 318・最大 21・孤立 147 = 同じ形）、live.log ×3 = [RodHand] の行の語（at logic 等）" \
  || { echo "live apply FAILED - stop"; exit 1; }
echo "== 2 regress"; tools/regress_all.sh > "$D/apply_regress.out" 2>&1; echo "   rc=$? $(grep -m1 '^RESULT' "$D/apply_regress.out")"
RID=$(cd Logs/regress && ls -dt 09330dd_* | head -1); echo "   regress id $RID"; [ "$RID" != 09330dd_062303 ] || { echo "no new regress dir - stop"; exit 1; }
grep -h "(697,726)" Logs/regress/$RID/live/seed_*/live_08.cmp 2>/dev/null | sed 's/^/   known: /'
grep -q "^RESULT PASS" "Logs/regress/$RID/SUMMARY.txt" || { echo "RESULT not PASS - stop (no step log, no PIN)"; exit 1; }
O=$T/Logs/regress/$RID/s2
echo "== 3 live, IKADA_ROD_HOLD_STEP_LOG=1"; IKADA_ROD_HOLD_STEP_LOG=1 tools/live_regress.sh "$O/steplog" > "$D/apply_live_steplog.out" 2>&1; echo "   rc=$?"
for seed in 20260925 1 26; do python3 "$C" "$O/steplog/seed_$seed/live.log" --expect pass > "$D/apply_count_s2_$seed.out" 2>&1; echo "   S2 seed $seed: rc=$? $(head -1 "$D/apply_count_s2_$seed.out" | cut -c1-110)"; done
S1=$T/Logs/regress/43beea1_051728/s1/steplog
for seed in 20260925 1 26; do python3 "$C" "$S1/seed_$seed/live.log" --expect pass > "$D/apply_count_s1pos_$seed.out" 2>&1; echo "   S1 log (positive) seed $seed: rc=$? $(head -1 "$D/apply_count_s1pos_$seed.out" | cut -c1-110)"; done
echo "== 4 PIN"; tools/baseline_pin.sh "$MOCK" "$RID" "$T"; echo "   rc=$?"; cat "$MOCK/PIN"
