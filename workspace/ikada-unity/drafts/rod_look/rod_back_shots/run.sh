#!/bin/bash
# worker3's Unity turn (ROD_REST_A_W3.md §7.36): shots only in ikada-unity-track3 track3/rod-default 0ef08cf (no edit / commit / stash /
# checkout), output here. Run ONLY under boss1's LOCK, after bundle_compile8 0ef08cf is green.
set -u
O=$(cd "$(dirname "$0")" && pwd); T=/home/ken/Documents/ikada-unity-track3; W=/home/ken/Documents/Claude-Code-Communication/workspace/ikada-unity
say() { echo "[rb] $(date '+%F %T') $*" | tee -a $O/turn.log; }
say "head $(git -C $T rev-parse --short HEAD) branch $(git -C $T branch --show-current) porcelain $(git -C $T status --porcelain | wc -l)"
[ "$(git -C $T rev-parse --short HEAD)" = 0ef08cf ] || { say "STOP head is not 0ef08cf"; exit 5; }
[ -z "$(git -C $T status --porcelain)" ] || { say "STOP track3 dirty at the start"; exit 5; }
shot() { local id=$1 name=$2; shift 2; ( cd $T && env IKADA_WATER_T=10.0 SHOTS=$O "$@" tools/shoot.sh $id $name sans on ) > $O/$name.out 2>&1; local rc=$?
  local l=$(grep -o "log=[^ ]*" $O/$name.out | head -1 | cut -d= -f2)
  say "$name rc=$rc png=$([ -f $O/$name.png ] && echo yes || echo NO) exc=$(grep -c 'Exception:' $l 2>/dev/null) env=[$*]"
  grep -h '\[RodHolder\] rest\|\[BackdropBuilder\] rod pose\|fight floor\|tipOverRaft\|\[RodHand\]' $l 2>/dev/null | sort -u | head -6 | sed 's/^/    /' | tee -a $O/turn.log; }
F2="IKADA_ROD_MIN_ACROSS=1 IKADA_ROD_GUIDES_REAL=1"; A="IKADA_ROD_EDGE=a IKADA_ROD_FORWARD_M=1.73"
shot 06 C0_now_06
shot 06 W2_a_f2_06 $A $F2
shot 06 Ha2_a_f2_hand_06 $A $F2 IKADA_ROD_SHOT_HOLD=hand
shot 06 Hs2_a_f2_sinking_06 $A $F2 IKADA_ROD_SHOT_HOLD=sinking
shot 08 F2b_a_f2_08 $A $F2
shot 06 M_a_f2_mid_06 $A $F2 IKADA_ROD_SHOT_HOLD=hand IKADA_ROD_SHOT_EASE=0.5
shot 06 H0_f2_hand_06 $F2 IKADA_ROD_SHOT_HOLD=hand
shot 06 Hs0_f2_sinking_06 $F2 IKADA_ROD_SHOT_HOLD=sinking
shot 08 F0_f2_08 $F2
source $W/drafts/stageD/unity_direct.sh
R0=$W/drafts/rod_look/rest2_shots/R0_point1_06.png; P=$W/drafts/rod_look/rod_a_shots
say "C0 vs R0: $(cmp_px $O/C0_now_06.png $R0)"
say "W2 vs c199 W (rod_a_shots/W_a_f2_06): $(cmp_px $O/W2_a_f2_06.png $P/W_a_f2_06.png)"
say "Ha2 vs H0: $(cmp_px $O/Ha2_a_f2_hand_06.png $O/H0_f2_hand_06.png)"
say "Hs2 vs Hs0: $(cmp_px $O/Hs2_a_f2_sinking_06.png $O/Hs0_f2_sinking_06.png)"
say "F2b vs F0: $(cmp_px $O/F2b_a_f2_08.png $O/F0_f2_08.png)"
say "track3 porcelain at the end: $(git -C $T status --porcelain | wc -l) [$(git -C $T status --porcelain | tr '\n' ';')]"; say done
