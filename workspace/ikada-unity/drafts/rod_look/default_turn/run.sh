#!/bin/bash
# worker3's Unity turn (ROD_REST_A_W3.md §7.38, boss1 22:4x): track3/rod-default 2932798 = the rod defaults + the dip log text.
# Roslyn -> regress_all (REGRESS_LIVE=1, every step) -> controls (the "go back" envs: 06 vs R0, 08 vs master's 08) -> live_rebase5 DRY
# + sheet -> mock old|new sheet (editor + player 3D screens). ★No --apply, no baseline change★ (PRESIDENT looks first). No edit / commit.
set -u
O=$(cd "$(dirname "$0")" && pwd); T=/home/ken/Documents/ikada-unity-track3; W=/home/ken/Documents/Claude-Code-Communication/workspace/ikada-unity
say() { echo "[dt] $(date '+%F %T') $*" | tee -a $O/turn.log; }
stop() { say "STOP: $*"; say "porcelain: [$(git -C $T status --porcelain | tr '\n' ';')] head $(git -C $T rev-parse --short HEAD)"; exit 5; }
[ "$(git -C $T rev-parse --short HEAD)" = 2932798 ] && [ -z "$(git -C $T status --porcelain)" ] || stop "head / dirty"
( source $T/tools/lock_guard.sh ) 2>>$O/turn.log || stop "screen locked"
bash $W/drafts/stageC/bundle_compile8.sh 2932798 > $O/bc8.out 2>&1; say "roslyn: $(grep -E 'errors=' $O/bc8.out | tr '\n' ' ' | cut -c1-260)"
grep -q "editor rc=0 errors=0" $O/bc8.out && grep -q "game rc=0 errors=0" $O/bc8.out || stop "Roslyn not 0"
(cd $T && REGRESS_LIVE=1 tools/regress_all.sh) > $O/regress.out 2>&1; RC=$?; say "regress rc=$RC"
grep -E "^RESULT|^[a-z_]+ +(PASS|FAIL|SKIPPED|NOT RUN)" $O/regress.out | cut -c1-300 | sed "s/^/[r] /" | tee -a $O/turn.log
R=$(ls -td $T/Logs/regress/*/ | head -1); say "regress dir $R"
say "porcelain after the regress: [$(git -C $T status --porcelain | tr '\n' ';')]"
shot() { local id=$1 name=$2; shift 2; ( cd $T && env IKADA_WATER_T=10.0 SHOTS=$O "$@" tools/shoot.sh $id $name sans on ) > $O/$name.out 2>&1
  say "$name rc=$? png=$([ -f $O/$name.png ] && echo yes || echo NO) exc=$(grep -c 'Exception:' $(grep -o 'log=[^ ]*' $O/$name.out | head -1 | cut -d= -f2) 2>/dev/null) env=[$*]"; }
OLD="IKADA_ROD_EDGE=off IKADA_ROD_MIN_ACROSS=0 IKADA_ROD_GUIDES_REAL=0 IKADA_ROD_LINE_MM=6"
shot 06 K06_goback $OLD
shot 08 K08_goback $OLD
source $W/drafts/stageD/unity_direct.sh
M=$W/shots/editor/506dfab_194806
say "control K06 (go-back envs) vs R0: $(cmp_px $O/K06_goback.png $W/drafts/rod_look/rest2_shots/R0_point1_06.png)"
say "control K08 (go-back envs) vs master 08 ($M/08_A_sans.png): $(cmp_px $O/K08_goback.png $M/08_A_sans.png)"
python3 $W/drafts/stageD/live_rebase5.py $R --project $T --tag pre-roddefault_ --reason "dry (rod defaults 2932798)" --table $O/LIVE_SWAP_TABLE.md --sheet $O/live_sheet.png > $O/live_dry.out 2>&1; say "live dry rc=$? $(tail -1 $O/live_dry.out | cut -c1-200)"
grep -E "changed|added|gone" $O/live_dry.out | cut -c1-110 | tee -a $O/turn.log
E=$(ls -td $W/shots/editor/2932798_* 2>/dev/null | grep -v repeat | head -1); P=$(ls -td $W/shots/player/2932798_* 2>/dev/null | head -1)
say "new editor $E, new player $P"
for id in S0 05 07 06 08 03 04 J Z P1 P2 06C 06M; do for tg in A_sans B_serif; do
  say "editor $id $tg vs master: $(cmp_px $E/${id}_$tg.png $M/${id}_$tg.png)"; done; done
python3 - "$M" "$E" "$O/mock_sheet.png" <<'PY' | tee -a $O/turn.log
import sys
from PIL import Image, ImageDraw, ImageFont
old,new,out=sys.argv[1:4]; F=ImageFont.truetype('/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc',22)
ids=['06','06C','06M','08','P1','P2']; w,h=640,360
im=Image.new('RGB',(2*w+10,len(ids)*(h+30)),(24,24,26)); d=ImageDraw.Draw(im)
for i,s in enumerate(ids):
    y=i*(h+30); d.text((6,y+2),f'{s} A_sans  旧 master 506dfab ｜ 新 2932798',font=F,fill=(230,230,230))
    im.paste(Image.open(f'{old}/{s}_A_sans.png').convert('RGB').resize((w,h)),(0,y+30)); im.paste(Image.open(f'{new}/{s}_A_sans.png').convert('RGB').resize((w,h)),(w+10,y+30))
im.save(out); print('[dt] mock sheet',out,im.size)
PY
say "players left: $(for p in /proc/[0-9]*; do case "$(readlink $p/exe 2>/dev/null)" in *Ikada.x86_64) echo x;; esac; done | wc -l); end porcelain $(git -C $T status --porcelain | wc -l) head $(git -C $T rev-parse --short HEAD)"
say done
