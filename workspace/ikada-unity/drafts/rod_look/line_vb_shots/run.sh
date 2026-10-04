#!/bin/bash
# worker3's Unity turn (§7.32: b + F1 (H1 / H3), F2 + line 3 mm, control): shots only in ikada-unity-track3 track3/rod-edge be3ec28
# (no edit / commit / stash / checkout), 06, output here. Run ONLY under boss1's LOCK, after bundle_compile8 be3ec28 is green.
set -u
O=$(cd "$(dirname "$0")" && pwd); T=/home/ken/Documents/ikada-unity-track3; W=/home/ken/Documents/Claude-Code-Communication/workspace/ikada-unity
say() { echo "[te] $(date '+%F %T') $*" | tee -a $O/turn.log; }
say "head $(git -C $T rev-parse --short HEAD) branch $(git -C $T branch --show-current) porcelain $(git -C $T status --porcelain | wc -l)"
[ "$(git -C $T rev-parse --short HEAD)" = be3ec28 ] || { say "STOP head is not be3ec28"; exit 5; }
[ -z "$(git -C $T status --porcelain)" ] || { say "STOP track3 dirty at the start"; exit 5; }
shot() { local name=$1; shift; ( cd $T && env IKADA_WATER_T=10.0 SHOTS=$O "$@" tools/shoot.sh 06 $name sans on ) > $O/$name.out 2>&1; local rc=$?
  local l=$(grep -o "log=[^ ]*" $O/$name.out | head -1 | cut -d= -f2)
  say "$name rc=$rc png=$([ -f $O/$name.png ] && echo yes || echo NO) exc=$(grep -c 'Exception:' $l 2>/dev/null) env=[$*] | $(grep -h '\[RodHolder\] rest\|\[BackdropBuilder\] rod pose' $l 2>/dev/null | head -2 | tr '\n' ' ' | cut -c1-300)"; }
shot C0_now_06
shot B1_edge_one_across_06 IKADA_ROD_EDGE=b IKADA_ROD_MIN_ACROSS=1
shot L1_f2_line3_06 IKADA_ROD_MIN_ACROSS=1 IKADA_ROD_GUIDES_REAL=1 IKADA_ROD_LINE_MM=3
source $W/drafts/stageD/unity_direct.sh
R0=$W/drafts/rod_look/rest2_shots/R0_point1_06.png; E=$W/drafts/rod_look/thin_edge_shots
say "C0 vs R0: $(cmp_px $O/C0_now_06.png $R0)"
say "B1 vs Eb: $(cmp_px $O/B1_edge_one_across_06.png $E/Eb_edge_one_06.png)"
say "L1 vs T2: $(cmp_px $O/L1_f2_line3_06.png $E/T2_across_guides_06.png)"
say "track3 porcelain at the end: $(git -C $T status --porcelain | wc -l) [$(git -C $T status --porcelain | tr '\n' ';')]"; say done
