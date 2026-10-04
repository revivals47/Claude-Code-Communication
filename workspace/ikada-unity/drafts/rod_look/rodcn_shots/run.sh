#!/bin/bash
# ArcCFullN 2 / 3 N x T 1.0 / 3.8 with the close-up p4 soft x1.5, rings on the true taper (worker3, ROD_HOLDER_FIX_W3.md §7.12, PRESIDENT 17:3x). Under LOCK only.
# then 08 at T 1.0 and 3.8 x {p3, p4, p5, p4 + tip soft x2} with the [TipAngle] line per shot -> V4 vs 177002a -> new material check. Under LOCK only.
set -u
O=$(cd "$(dirname "$0")" && pwd); T=/home/ken/Documents/ikada-unity-track3; W=/home/ken/Documents/Claude-Code-Communication/workspace/ikada-unity
say() { echo "[v4] $(date '+%F %T') $*" | tee -a $O/turn.log; }
[ -z "$(git -C $T status --porcelain)" ] || { say "STOP dirty"; exit 5; }
H=$(git -C $T rev-parse --short HEAD); say "head $H"
bash $W/drafts/stageC/bundle_compile8.sh $H > $O/bc8.out 2>&1; say "roslyn: $(grep -E 'errors=' $O/bc8.out | tr '\n' ' ' | cut -c1-260)"
grep -q "editor rc=0 errors=0" $O/bc8.out && grep -q "game rc=0 errors=0" $O/bc8.out || { grep 'error CS' $O/bc8.out | head -5 | tee -a $O/turn.log; say "STOP roslyn"; exit 5; }
shot() { local name=$1 scr=$2; shift 2; ( cd $T && env IKADA_WATER_T=10.0 SHOTS=$O "$@" tools/shoot.sh $scr $name sans on ) > $O/$name.out 2>&1; local rc=$?
  local l=$(grep -o "log=[^ ]*" $O/$name.out | head -1 | cut -d= -f2)
  say "$name rc=$rc png=$([ -f $O/$name.png ] && echo yes || echo NO) exc=$(grep -c 'Exception:' $l 2>/dev/null) env=[$*] | $(grep -h '\[TipAngle\]' $l 2>/dev/null | tail -1 | cut -c1-200)"; }
shot W_1wait_06 06
for t in 1.0 3.8; do for cn in 3 2; do
  shot C_T${t}_cn${cn}_08 08 IKADA_ROD_T=$t IKADA_ROD_ARC_CN=$cn IKADA_ROD_ARC_P=4 IKADA_TIP_SOFT=1.5
done; done
source $W/drafts/stageD/unity_direct.sh
say "W 06 vs 177002a: $(cmp_px $O/W_1wait_06.png $W/shots/editor/177002a_152845/06_A_sans.png)"
say "porcelain [$(git -C $T status --porcelain | tr '\n' ';')]"; say done
