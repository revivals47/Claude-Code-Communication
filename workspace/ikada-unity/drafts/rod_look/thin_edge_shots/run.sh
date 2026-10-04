#!/bin/bash
# worker3's Unity turn (§7.30 thinness x 4 + §7.31 edge clamp x 2, PRESIDENT 21:3x GO): shots only in ikada-unity-track3 track3/rod-edge 49b53df
# (no edit / commit / stash / checkout), 06, output here. Run ONLY under boss1's LOCK, after bundle_compile8 49b53df is green.
set -u
O=$(cd "$(dirname "$0")" && pwd); T=/home/ken/Documents/ikada-unity-track3; W=/home/ken/Documents/Claude-Code-Communication/workspace/ikada-unity
say() { echo "[te] $(date '+%F %T') $*" | tee -a $O/turn.log; }
say "head $(git -C $T rev-parse --short HEAD) branch $(git -C $T branch --show-current) porcelain $(git -C $T status --porcelain | wc -l)"
[ "$(git -C $T rev-parse --short HEAD)" = 49b53df ] || { say "STOP head is not 49b53df"; exit 5; }
[ -z "$(git -C $T status --porcelain)" ] || { say "STOP track3 dirty at the start"; exit 5; }
shot() { local name=$1; shift; ( cd $T && env IKADA_WATER_T=10.0 SHOTS=$O "$@" tools/shoot.sh 06 $name sans on ) > $O/$name.out 2>&1; local rc=$?
  local l=$(grep -o "log=[^ ]*" $O/$name.out | head -1 | cut -d= -f2)
  say "$name rc=$rc png=$([ -f $O/$name.png ] && echo yes || echo NO) exc=$(grep -c 'Exception:' $l 2>/dev/null) env=[$*] | $(grep -h '\[RodHolder\] rest\|\[BackdropBuilder\] rod pose' $l 2>/dev/null | head -2 | tr '\n' ' ' | cut -c1-300)"; }
shot T0_now_06
shot T1_across_06 IKADA_ROD_MIN_ACROSS=1
shot T2_across_guides_06 IKADA_ROD_MIN_ACROSS=1 IKADA_ROD_GUIDES_REAL=1
shot T3_across_guides_x12_06 IKADA_ROD_MIN_ACROSS=1 IKADA_ROD_GUIDES_REAL=1 IKADA_ROD_TAPER_RATIO=12
shot Ea_edge_two_fwd173_06 IKADA_ROD_EDGE=a IKADA_ROD_FORWARD_M=1.73
shot Eb_edge_one_06 IKADA_ROD_EDGE=b
source $W/drafts/stageD/unity_direct.sh
R0=$W/drafts/rod_look/rest2_shots/R0_point1_06.png
for n in T0_now_06 T1_across_06 T2_across_guides_06 T3_across_guides_x12_06 Ea_edge_two_fwd173_06 Eb_edge_one_06; do say "$n vs R0 (e7f7269 default): $(cmp_px $O/$n.png $R0)"; done
say "track3 porcelain at the end: $(git -C $T status --porcelain | wc -l) [$(git -C $T status --porcelain | tr '\n' ';')]"; say done
