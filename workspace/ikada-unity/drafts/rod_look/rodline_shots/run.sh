#!/bin/bash
# 14 shots: fill 2 N x exp 0.25 / 0.5 x line 0.5 / 0 x T 1.34 / 2.55 / 0.37 + close-up soft x2 / x2.5 (worker3, ROD_HOLDER_FIX_W3.md §7.17). Under LOCK only.
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
n=0
for ex in 0.25 0.5; do for line in 0.5 0; do for t in 1.34 2.55 0.37; do
  n=$((n+1)); shot L$(printf %02d $n)_e${ex}_line${line}_T${t}_08 08 IKADA_ROD_ARC_CN=2 IKADA_ROD_ARC_EXP=$ex IKADA_ROD_LINE=$line IKADA_ROD_T=$t
done; done; done
shot L13_soft2_08 08 IKADA_ROD_ARC_CN=2 IKADA_ROD_ARC_EXP=0.5 IKADA_ROD_LINE=0 IKADA_ROD_T=1.34 IKADA_TIP_SOFT=2
shot L14_soft2.5_08 08 IKADA_ROD_ARC_CN=2 IKADA_ROD_ARC_EXP=0.5 IKADA_ROD_LINE=0 IKADA_ROD_T=1.34 IKADA_TIP_SOFT=2.5
say "porcelain [$(git -C $T status --porcelain | tr '\n' ';')]"; say done
