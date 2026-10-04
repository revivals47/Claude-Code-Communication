#!/bin/bash
# worker3's step in the rod-rest2 e7f7269 Unity turn (boss1 20:44): shots only in ikada-unity-track3 track3/rod-rest2 (no edit / commit / stash / checkout),
# output here. 06 x {1 point (default), 2 points (control vs c193), 2 points close-up (not the game's view), 2 points + rod 0.30 m forward}.
set -u
O=$(cd "$(dirname "$0")" && pwd); T=/home/ken/Documents/ikada-unity-track3; W=/home/ken/Documents/Claude-Code-Communication/workspace/ikada-unity
say() { echo "[ir] $(date '+%F %T') $*" | tee -a $O/turn.log; }
say "head $(git -C $T rev-parse --short HEAD) branch $(git -C $T branch --show-current) porcelain $(git -C $T status --porcelain | wc -l)"
[ -z "$(git -C $T status --porcelain)" ] || { say "STOP track3 dirty at the start"; exit 5; }
shot() { local name=$1 hud=$2; shift 2; ( cd $T && env IKADA_WATER_T=10.0 SHOTS=$O "$@" tools/shoot.sh 06 $name sans $hud ) > $O/$name.out 2>&1; local rc=$?
  local l=$(grep -o "log=[^ ]*" $O/$name.out | head -1 | cut -d= -f2)
  say "$name rc=$rc png=$([ -f $O/$name.png ] && echo yes || echo NO) exc=$(grep -c 'Exception:' $l 2>/dev/null) env=[$*] | $(grep -h '\[RodHolder\] rest\|\[Shot\] rod close-up' $l 2>/dev/null | head -2 | tr '\n' ' ' | cut -c1-260)"; }
shot R0_point1_06 on
shot R1_point2_06 on IKADA_ROD_HOLDER2=1
shot R2_point2_closeup_06 off IKADA_ROD_HOLDER2=1 IKADA_SHOT_ROD_CLOSEUP=1
shot R3_point2_fwd030_06 on IKADA_ROD_HOLDER2=1 IKADA_ROD_FORWARD_M=0.3
source $W/drafts/stageD/unity_direct.sh
say "R0 (1 point, e7f7269) vs I0 (1 point, integ 506dfab = 521a92c tree): $(cmp_px $O/R0_point1_06.png /home/ken/Documents/Claude-Code-Communication/workspace/ikada-unity/drafts/rod_look/integ_rest_shots/I0_point1_06.png)"
say "R1 (rest2) vs I1 (old 2 points, integ): $(cmp_px $O/R1_point2_06.png /home/ken/Documents/Claude-Code-Communication/workspace/ikada-unity/drafts/rod_look/integ_rest_shots/I1_point2_06.png)"
say "R3 (rest2 fwd 0.30) vs I3: $(cmp_px $O/R3_point2_fwd030_06.png /home/ken/Documents/Claude-Code-Communication/workspace/ikada-unity/drafts/rod_look/integ_rest_shots/I3_point2_fwd030_06.png)"
say "track3 porcelain at the end: $(git -C $T status --porcelain | wc -l) [$(git -C $T status --porcelain | tr '\n' ';')]"; say done
