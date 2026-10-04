#!/bin/bash
# LINE_SIDE (worker3, ROD_HOLDER_FIX_W3.md §7.20): angle 0 off / on (control), -0.5 / +0.5 on; T 2.55, exp 0.5, fill 2 N. Under LOCK only.
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
B=(IKADA_ROD_ARC_CN=2 IKADA_ROD_ARC_EXP=0.5 IKADA_ROD_T=2.55)
fl() { local l=$(grep -o "log=[^ ]*" $O/$1.out | head -1 | cut -d= -f2); say "$1 | $(grep -h '\[FightLine\]' $l | tail -1 | cut -c1-260)"; }
shot S0_off_line0_08 08 "${B[@]}" IKADA_ROD_LINE=0; fl S0_off_line0_08
shot S1_on_line0_08 08 "${B[@]}" IKADA_ROD_LINE=0 IKADA_ROD_LINE_SIDE=1; fl S1_on_line0_08
shot S2_on_lineM05_08 08 "${B[@]}" IKADA_ROD_LINE=-0.5 IKADA_ROD_LINE_SIDE=1; fl S2_on_lineM05_08
shot S3_on_lineP05_08 08 "${B[@]}" IKADA_ROD_LINE=0.5 IKADA_ROD_LINE_SIDE=1; fl S3_on_lineP05_08
source $W/drafts/stageD/unity_direct.sh
say "S1 (on, 0) vs S0 (off, 0): $(cmp_px $O/S1_on_line0_08.png $O/S0_off_line0_08.png)"
say "S0 (off, 0) vs L11 (b8b47ac, same env): $(cmp_px $O/S0_off_line0_08.png $W/drafts/rod_look/rodline_shots/L11_e0.5_line0_T2.55_08.png)"
say "porcelain [$(git -C $T status --porcelain | tr '\n' ';')]"; say done
