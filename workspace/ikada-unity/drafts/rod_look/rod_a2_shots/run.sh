#!/bin/bash
# worker3's Unity turn (ROD_REST_A_W3.md §7.37): shots only in ikada-unity-track3 track3/rod-default 1b1a1da (no edit / commit / stash /
# checkout), output here. Run ONLY under boss1's LOCK, after bundle_compile8 1b1a1da is green.
set -u
O=$(cd "$(dirname "$0")" && pwd); T=/home/ken/Documents/ikada-unity-track3; W=/home/ken/Documents/Claude-Code-Communication/workspace/ikada-unity
say() { echo "[rc] $(date '+%F %T') $*" | tee -a $O/turn.log; }
say "head $(git -C $T rev-parse --short HEAD) branch $(git -C $T branch --show-current) porcelain $(git -C $T status --porcelain | wc -l)"
[ "$(git -C $T rev-parse --short HEAD)" = 1b1a1da ] || { say "STOP head is not 1b1a1da"; exit 5; }
[ -z "$(git -C $T status --porcelain)" ] || { say "STOP track3 dirty at the start"; exit 5; }
shot() { local id=$1 name=$2; shift 2; ( cd $T && env IKADA_WATER_T=10.0 SHOTS=$O "$@" tools/shoot.sh $id $name sans on ) > $O/$name.out 2>&1; local rc=$?
  local l=$(grep -o "log=[^ ]*" $O/$name.out | head -1 | cut -d= -f2)
  say "$name rc=$rc png=$([ -f $O/$name.png ] && echo yes || echo NO) exc=$(grep -c 'Exception:' $l 2>/dev/null) env=[$*]"
  grep -h '\[RodHolder\] rest\|\[BackdropBuilder\] rod pose\|fight floor\|tipOverRaft\|\[RodHand\]' $l 2>/dev/null | sort -u | head -6 | sed 's/^/    /' | tee -a $O/turn.log; }
F2="IKADA_ROD_MIN_ACROSS=1 IKADA_ROD_GUIDES_REAL=1"; A="IKADA_ROD_EDGE=a IKADA_ROD_FORWARD_M=1.73"
shot 06 W3_a_f2_06 $A $F2
shot 06 Ha3_a_f2_hand_06 $A $F2 IKADA_ROD_SHOT_HOLD=hand
shot 06 Hs3_a_f2_sinking_06 $A $F2 IKADA_ROD_SHOT_HOLD=sinking
source $W/drafts/stageD/unity_direct.sh
P=$W/drafts/rod_look/rod_back_shots
say "W3 vs W2: $(cmp_px $O/W3_a_f2_06.png $P/W2_a_f2_06.png)"
say "Ha3 vs Ha2: $(cmp_px $O/Ha3_a_f2_hand_06.png $P/Ha2_a_f2_hand_06.png)"
say "Hs3 vs Hs2: $(cmp_px $O/Hs3_a_f2_sinking_06.png $P/Hs2_a_f2_sinking_06.png)"
say "track3 porcelain at the end: $(git -C $T status --porcelain | wc -l) [$(git -C $T status --porcelain | tr '\n' ';')]"; say done
