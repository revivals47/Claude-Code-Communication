#!/bin/bash
# V4 default + the shared bend (worker3, ROD_HOLDER_FIX_W3.md §7.10, PRESIDENT 17:2x): Roslyn -> editor: V4 06 wait / 06 raised / 08 fight,
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
shot V4_1wait_06 06
shot V4_2held_06 06 IKADA_ROD_ANGLE=0.30
shot V4_3fight_08 08
for t in 1.0 3.8; do
  for v in p3 p4 p5 p4soft2; do
    case $v in p3) E=(IKADA_ROD_ARC_P=3);; p4) E=(IKADA_ROD_ARC_P=4);; p5) E=(IKADA_ROD_ARC_P=5);; p4soft2) E=(IKADA_ROD_ARC_P=4 IKADA_TIP_SOFT=2);; esac
    shot B_T${t}_${v}_08 08 IKADA_ROD_T=$t "${E[@]}"
  done
done
source $W/drafts/stageD/unity_direct.sh
say "V4 06 vs 177002a: $(cmp_px $O/V4_1wait_06.png $W/shots/editor/177002a_152845/06_A_sans.png)"
say "V4 08 vs 177002a: $(cmp_px $O/V4_3fight_08.png $W/shots/editor/177002a_152845/08_A_sans.png)"
say "porcelain [$(git -C $T status --porcelain | tr '\n' ';')]"; say done
