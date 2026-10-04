#!/bin/bash
# 竿の作り 15 枚（V4 = 参考の竿の画の形, PRESIDENT 17:1x）（V3 = 依頼者の実物の割合, PRESIDENT 17:0x）（worker3, ROD_HOLDER_FIX_W3.md §7.3-7.5）: Roslyn → editor 06 / 06+angle 0.30 / 08 × V0 V1 V2 → V0 vs 177002a → sheet. Unity only under boss1 LOCK.
set -u
O=$(cd "$(dirname "$0")" && pwd); T=/home/ken/Documents/ikada-unity-track3; W=/home/ken/Documents/Claude-Code-Communication/workspace/ikada-unity
say() { echo "[rb] $(date '+%F %T') $*" | tee -a $O/turn.log; }
[ -z "$(git -C $T status --porcelain)" ] || { say "STOP dirty"; exit 5; }
H=$(git -C $T rev-parse --short HEAD); [ "$(git -C $T branch --show-current)" = track3/rod-build ] || { say "STOP not on track3/rod-build"; exit 5; }
say "head $H"
bash $W/drafts/stageC/bundle_compile8.sh $H > $O/bc8.out 2>&1; say "roslyn: $(grep -E 'errors=' $O/bc8.out | tr '\n' ' ' | cut -c1-260)"
grep -q "editor rc=0 errors=0" $O/bc8.out && grep -q "game rc=0 errors=0" $O/bc8.out || { grep 'error CS' $O/bc8.out | head -5 | tee -a $O/turn.log; say "STOP roslyn"; exit 5; }
shot() { local name=$1 scr=$2; shift 2; ( cd $T && env IKADA_WATER_T=10.0 SHOTS=$O "$@" tools/shoot.sh $scr $name sans on ) > $O/$name.out 2>&1; local rc=$?
  local l=$(grep -o "log=[^ ]*" $O/$name.out | head -1 | cut -d= -f2); say "$name rc=$rc png=$([ -f $O/$name.png ] && echo yes || echo NO) exc=$(grep -c 'Exception:' $l 2>/dev/null) env=[$*]"; }
for v in V0 V1 V2 V3 V4; do
  case $v in V0) E=();; V1) E=(IKADA_ROD_GRIP_FRAC=0.20 IKADA_ROD_GUIDES=15 IKADA_ROD_ARC_P=3);; V2) E=(IKADA_ROD_GRIP_FRAC=0.26 IKADA_ROD_GUIDES=18 IKADA_ROD_ARC_P=4);; V3) E=(IKADA_ROD_GUIDES=14 IKADA_ROD_ARC_P=3 IKADA_ROD_TAPER_RATIO=30);; V4) E=(IKADA_ROD_GRIP_FRAC=0.197 IKADA_ROD_GUIDES=14 IKADA_ROD_ARC_P=3 IKADA_ROD_TAPER_RATIO=24 IKADA_ROD_GOLD=0.206,0.25);; esac
  shot ${v}_1wait_06 06 "${E[@]}"
  shot ${v}_2held_06 06 "${E[@]}" IKADA_ROD_ANGLE=0.30
  shot ${v}_3fight_08 08 "${E[@]}"
done
source $W/drafts/stageD/unity_direct.sh
say "V0 06 vs 177002a: $(cmp_px $O/V0_1wait_06.png $W/shots/editor/177002a_152845/06_A_sans.png)"
say "V0 08 vs 177002a: $(cmp_px $O/V0_3fight_08.png $W/shots/editor/177002a_152845/08_A_sans.png)"
for s in 1wait_06 2held_06 3fight_08; do for v in V1 V2 V3 V4; do say "$v $s vs V0: $(cmp_px $O/${v}_$s.png $O/V0_$s.png)"; done; done
for f in $(git -C $T status --porcelain | awk '$1=="??"{print $2}' | grep "RodGoldTrial"); do rm -f "$T/$f"; say "removed the shot-only material $f (IKADA_ROD_GOLD)"; done
say "porcelain $(git -C $T status --porcelain | wc -l)"; say done
