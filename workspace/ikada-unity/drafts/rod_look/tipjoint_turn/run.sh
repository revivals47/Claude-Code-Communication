#!/bin/bash
# worker3's Unity turn (ROD_REST_A_W3.md §7.43, PRESIDENT 01:5x): track3/side-shot dfa2b29, shots only (no edit / commit), 06 x {hand, sinking} x
# {the game's view, the side view (IKADA_SHOT_ROD_SIDE=1, HUD off)}. Run ONLY under boss1's LOCK, after bundle_compile8 dfa2b29 is green.
set -u
O=$(cd "$(dirname "$0")" && pwd); T=/home/ken/Documents/ikada-unity-track3; W=/home/ken/Documents/Claude-Code-Communication/workspace/ikada-unity
say() { echo "[tj] $(date '+%F %T') $*" | tee -a $O/turn.log; }
stop() { say "STOP: $*"; exit 5; }
[ "$(git -C $T rev-parse --short HEAD)" = dfa2b29 ] && [ -z "$(git -C $T status --porcelain)" ] || stop "head / dirty"
( source $T/tools/lock_guard.sh ) 2>>$O/turn.log || stop "screen locked"
bash $W/drafts/stageC/bundle_compile8.sh dfa2b29 > $O/bc8.out 2>&1; say "roslyn: $(grep -E 'errors=' $O/bc8.out | tr '\n' ' ' | cut -c1-260)"
grep -q "editor rc=0 errors=0" $O/bc8.out && grep -q "game rc=0 errors=0" $O/bc8.out || stop "Roslyn not 0"
shot() { local name=$1 hud=$2; shift 2; ( cd $T && env IKADA_WATER_T=10.0 SHOTS=$O "$@" tools/shoot.sh 06 $name sans $hud ) > $O/$name.out 2>&1; local rc=$?
  local l=$(grep -o "log=[^ ]*" $O/$name.out | head -1 | cut -d= -f2)
  say "$name rc=$rc png=$([ -f $O/$name.png ] && echo yes || echo NO) exc=$(grep -c 'Exception:' $l 2>/dev/null) env=[$*] | $(grep -h '\[TipJoint\]' $l 2>/dev/null | head -2 | tr '\n' ' ' | cut -c1-330)"; }
shot TJ_hand_06 on IKADA_ROD_SHOT_HOLD=hand IKADA_SHOT_TIP_JOINT=1
shot TJ_sinking_06 on IKADA_ROD_SHOT_HOLD=sinking IKADA_SHOT_TIP_JOINT=1
shot TJ_rest06_06 on IKADA_SHOT_TIP_JOINT=1
( cd $T && env IKADA_WATER_T=10.0 SHOTS=$O IKADA_SHOT_TIP_JOINT=1 tools/shoot.sh 06C TJ_rest06C sans on ) > $O/TJ_rest06C.out 2>&1; say "TJ_rest06C rc=$? | $(grep -h '\[TipJoint\]' $(grep -o 'log=[^ ]*' $O/TJ_rest06C.out | head -1 | cut -d= -f2) 2>/dev/null | head -1 | cut -c1-330)"
for f in $O/*.out; do l=$(grep -o 'log=[^ ]*' $f | head -1 | cut -d= -f2); grep -h '\[TipJoint\]' $l 2>/dev/null | head -1 | sed "s#^#[tj] $(basename $f .out) #" >> $O/tipjoint_lines.txt; done
say "track3 porcelain at the end: $(git -C $T status --porcelain | wc -l)"; say done
