#!/bin/bash
# §7.52 (worker3, PRESIDENT 03:0x GO): the baseline swap for the sinking stance by default, then the regress and the PIN.
# Under boss1's gate and LOCK only. Tree = ikada-unity-track3 track3/sink-stance-default f2b113b. Stops at the first failed step.
set -u
T=$HOME/Documents/ikada-unity-track3; D=$(cd "$(dirname "$0")" && pwd)
MOCK=/home/ken/Documents/Claude-Code-Communication/workspace/ikada-unity/shots/player/a9106ea_234105
cd "$T" || exit 1
[ "$(git rev-parse --short HEAD)" = f2b113b ] && [ "$(git status --porcelain | wc -l)" = 0 ] || { echo "tree is not a clean f2b113b - stop"; exit 1; }
echo "== 1 mock"; python3 "$D/mock_apply.py" --apply || { echo "mock apply FAILED - stop"; exit 1; }
echo "== 2 live"; python3 "$D/../../stageD/live_rebase5.py" "$T/Logs/regress/f2b113b_021733" --tag pre-stance --project "$T" --table "$D/live_dry_table.md" --apply \
  --reason "沈み待ちの構えを既定に（依頼者 02:0x c206 左: 3.09 m・26°・竿尻 甲板から 1.0 m, PRESIDENT 03:0x GO, ROD_REST_A_W3.md §7.50）。★種 26 の live_08 は 沈みからアワセへの戻りの ease の残りを含む★（speed 300 で 底→アワセ 15 フレーム, shot の時 構えの角 −2.1e-4 rad・竿尻 0.3 / 0.7 mm, §7.51 の測り）" \
  || { echo "live apply FAILED - stop"; exit 1; }
echo "== 3 regress"; tools/regress_all.sh > "$D/apply_regress.out" 2>&1; echo "   rc=$? $(grep -m1 '^RESULT' "$D/apply_regress.out")"
RID=$(cd "$T/Logs/regress" && ls -dt f2b113b_* | head -1); echo "   regress id $RID"
[ "$RID" != f2b113b_021733 ] || { echo "no new regress dir - stop"; exit 1; }
grep -q "^baseline .*PASS" "$T/Logs/regress/$RID/SUMMARY.txt" || { echo "baseline not PASS - no PIN"; exit 1; }
echo "== 4 PIN"; tools/baseline_pin.sh "$MOCK" "$RID" "$T"; echo "   rc=$?"; cat "$MOCK/PIN"
