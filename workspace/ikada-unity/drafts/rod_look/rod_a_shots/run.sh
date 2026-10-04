#!/bin/bash
# worker3's Unity turn (ROD_REST_A_W3.md §7.35): shots only in ikada-unity-track3 track3/rod-edge 01df0df (no edit / commit / stash /
# checkout), output here. Run ONLY under boss1's LOCK, after bundle_compile8 01df0df is green.
set -u
O=$(cd "$(dirname "$0")" && pwd); T=/home/ken/Documents/ikada-unity-track3; W=/home/ken/Documents/Claude-Code-Communication/workspace/ikada-unity
say() { echo "[ra] $(date '+%F %T') $*" | tee -a $O/turn.log; }
say "head $(git -C $T rev-parse --short HEAD) branch $(git -C $T branch --show-current) porcelain $(git -C $T status --porcelain | wc -l)"
[ "$(git -C $T rev-parse --short HEAD)" = 01df0df ] || { say "STOP head is not 01df0df"; exit 5; }
[ -z "$(git -C $T status --porcelain)" ] || { say "STOP track3 dirty at the start"; exit 5; }
shot() { local id=$1 name=$2; shift 2; ( cd $T && env IKADA_WATER_T=10.0 SHOTS=$O "$@" tools/shoot.sh $id $name sans on ) > $O/$name.out 2>&1; local rc=$?
  local l=$(grep -o "log=[^ ]*" $O/$name.out | head -1 | cut -d= -f2)
  say "$name rc=$rc png=$([ -f $O/$name.png ] && echo yes || echo NO) exc=$(grep -c 'Exception:' $l 2>/dev/null) env=[$*]"
  grep -h '\[RodHolder\] rest\|\[BackdropBuilder\] rod pose\|fight floor\|tipOverRaft\|\[RodHand\]' $l 2>/dev/null | sort -u | head -6 | sed 's/^/    /' | tee -a $O/turn.log; }
F2="IKADA_ROD_MIN_ACROSS=1 IKADA_ROD_GUIDES_REAL=1"; A="IKADA_ROD_EDGE=a IKADA_ROD_FORWARD_M=1.73"
shot 06 C0_now_06
shot 06 W_a_f2_06 $A $F2
shot 08 F_a_f2_08 $A $F2
shot 06 L1_f2_line3_06 $F2 IKADA_ROD_LINE_MM=3
shot 06 Ha_a_f2_hand_06 $A $F2 IKADA_ROD_SHOT_HOLD=hand
shot 06 Hs_a_f2_sinking_06 $A $F2 IKADA_ROD_SHOT_HOLD=sinking
shot 06 H1p_point1_hand_06 IKADA_ROD_SHOT_HOLD=hand
source $W/drafts/stageD/unity_direct.sh
R0=$W/drafts/rod_look/rest2_shots/R0_point1_06.png; E=$W/drafts/rod_look/thin_edge_shots
say "C0 vs R0: $(cmp_px $O/C0_now_06.png $R0)"
say "W vs Ea: $(cmp_px $O/W_a_f2_06.png $E/Ea_edge_two_fwd173_06.png)"
say "L1 vs T2: $(cmp_px $O/L1_f2_line3_06.png $E/T2_across_guides_06.png)"
say "Ha vs W: $(cmp_px $O/Ha_a_f2_hand_06.png $O/W_a_f2_06.png)"
say "Hs vs Ha: $(cmp_px $O/Hs_a_f2_sinking_06.png $O/Ha_a_f2_hand_06.png)"
say "H1p vs R0: $(cmp_px $O/H1p_point1_hand_06.png $R0)"
python3 - "$O/W_a_f2_06.png" "$E/T2_across_guides_06.png" <<'PY' | tee -a $O/turn.log
import sys, numpy as np
from PIL import Image
a=np.asarray(Image.open(sys.argv[1]).convert('RGB')).astype(int)[168:596,17:501]; b=np.asarray(Image.open(sys.argv[2]).convert('RGB')).astype(int)[168:596,17:501]
print("[ra] tip window (x 17-500, y 168-595) W vs T2: diff px", int((np.abs(a-b).sum(2)>0).sum()))
PY
say "track3 porcelain at the end: $(git -C $T status --porcelain | wc -l) [$(git -C $T status --porcelain | tr '\n' ';')]"; say done
