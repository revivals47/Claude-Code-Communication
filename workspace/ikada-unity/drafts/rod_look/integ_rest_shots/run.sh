#!/bin/bash
# worker3's step in the integ/next-build Unity turn (boss1 19:18): shots only in ikada-unity-track2 (no edit / commit / stash / checkout),
# output here. 06 x {1 point (default), 2 points (control vs c193), 2 points close-up (not the game's view), 2 points + rod 0.30 m forward}.
set -u
O=$(cd "$(dirname "$0")" && pwd); T=/home/ken/Documents/ikada-unity-track2; W=/home/ken/Documents/Claude-Code-Communication/workspace/ikada-unity
say() { echo "[ir] $(date '+%F %T') $*" | tee -a $O/turn.log; }
say "head $(git -C $T rev-parse --short HEAD) branch $(git -C $T branch --show-current) porcelain $(git -C $T status --porcelain | wc -l)"
[ -z "$(git -C $T status --porcelain)" ] || { say "STOP track2 dirty at the start"; exit 5; }
shot() { local name=$1 hud=$2; shift 2; ( cd $T && env IKADA_WATER_T=10.0 SHOTS=$O "$@" tools/shoot.sh 06 $name sans $hud ) > $O/$name.out 2>&1; local rc=$?
  local l=$(grep -o "log=[^ ]*" $O/$name.out | head -1 | cut -d= -f2)
  say "$name rc=$rc png=$([ -f $O/$name.png ] && echo yes || echo NO) exc=$(grep -c 'Exception:' $l 2>/dev/null) env=[$*] | $(grep -h '\[RodHolder\] rest\|\[Shot\] rod close-up' $l 2>/dev/null | head -2 | tr '\n' ' ' | cut -c1-260)"; }
shot I0_point1_06 on
shot I1_point2_06 on IKADA_ROD_HOLDER2=1
shot I2_point2_closeup_06 off IKADA_ROD_HOLDER2=1 IKADA_SHOT_ROD_CLOSEUP=1
shot I3_point2_fwd030_06 on IKADA_ROD_HOLDER2=1 IKADA_ROD_FORWARD_M=0.3
source $W/drafts/stageD/unity_direct.sh
say "I1 (2 points, integ) vs c193's holder2 (47a253e): $(cmp_px $O/I1_point2_06.png $W/drafts/rod_look/holder2_shots/holder2_06_A_sans.png)"
say "I0 (1 point, integ) vs 47a253e now: $(cmp_px $O/I0_point1_06.png $W/drafts/rod_look/holder2_shots/now_06_A_sans.png)"
say "track2 porcelain at the end: $(git -C $T status --porcelain | wc -l) [$(git -C $T status --porcelain | tr '\n' ';')]"; say done
