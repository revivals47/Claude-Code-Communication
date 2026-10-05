#!/bin/bash
# 段 (3) S1 apply (worker3; PRESIDENT 05:5x GO on condition: worker1's logic run explains seed 26's cast-42 shift as predicted).
# Under boss1's gate and LOCK only. Tree = ikada-unity-track3 track3/rodhold-s1 43beea1. Live baselines of 3 seeds re-taken from
# regress 43beea1_051728 (the dry table s1_live_dry_table.md is the pre-check); the mock baseline is NOT swapped (30/30 0 px at the new
# pin); then the regress, then the PIN (the new pin db43865) only if that regress's baseline is PASS. Stops at the first failed step.
set -u
T=$HOME/Documents/ikada-unity-track3; D=$(cd "$(dirname "$0")" && pwd)
MOCK=/home/ken/Documents/Claude-Code-Communication/workspace/ikada-unity/shots/player/a9106ea_234105
cd "$T" || exit 1
[ "$(git rev-parse --short HEAD)" = 43beea1 ] && [ "$(git status --porcelain | wc -l)" = 0 ] || { echo "tree is not a clean 43beea1 - stop"; exit 1; }
echo "== 1 live"; python3 "$D/../../stageD/live_rebase5.py" "$T/Logs/regress/43beea1_051728" --tag pre-s1 --project "$T" --table "$D/s1_live_dry_table.md" --apply \
  --reason "段 (3) S1 = logic 0.26.0 の pin db43865（PRESIDENT 05:5x 画として可・条件付き GO）: 窓の穂先の線（受けの間の手の揺れの項 0）、種 26 live_08 の竿が右へ寝る（FishSide の左右）、種 20260925 は並びが cast 12 から替わる（live_03・live_08 が足される）、種 26 は cast 42 から時刻が 0.4 s ずれる（logic の測り = worker1）" \
  || { echo "live apply FAILED - stop"; exit 1; }
echo "== 2 regress"; tools/regress_all.sh > "$D/apply_regress.out" 2>&1; echo "   rc=$? $(grep -m1 '^RESULT' "$D/apply_regress.out")"
RID=$(cd Logs/regress && ls -dt 43beea1_* | head -1); echo "   regress id $RID"
[ "$RID" != 43beea1_051728 ] || { echo "no new regress dir - stop"; exit 1; }
grep -q "^baseline .*PASS" "Logs/regress/$RID/SUMMARY.txt" || { echo "baseline not PASS - no PIN"; exit 1; }
echo "== 3 PIN"; tools/baseline_pin.sh "$MOCK" "$RID" "$T"; echo "   rc=$?"; cat "$MOCK/PIN"
