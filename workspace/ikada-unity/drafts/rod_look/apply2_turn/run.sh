#!/bin/bash
# worker3's apply turn for case C (PRESIDENT 00:8x GO, boss1 00:40 LOCK) on track3/shot-hold f7af1d2: regress (the source; live FAIL = 7 to swap,
# predicted) -> live_rebase5 dry (changed 7 predicted) -> apply (labels; old kept as pre-shotwait_<name>; sha before / after; NOTE) -> regress
# once more (16/16 predicted). Live only: mock and PIN untouched. No code edit / commit in the tree.
set -u
O=$(cd "$(dirname "$0")" && pwd); T=/home/ken/Documents/ikada-unity-track3; W=/home/ken/Documents/Claude-Code-Communication/workspace/ikada-unity
say() { echo "[a2] $(date '+%F %T') $*" | tee -a $O/turn.log; }
stop() { say "STOP: $*"; exit 5; }
[ "$(git -C $T rev-parse --short HEAD)" = f7af1d2 ] && [ -z "$(git -C $T status --porcelain)" ] || stop "head / dirty"
( source $T/tools/lock_guard.sh ) 2>>$O/turn.log || stop "screen locked"
MB=$W/shots/player/68f766b_113126; PIN0=$(cat $MB/PIN | tr '\n' ' ')
reg() { (cd $T && REGRESS_LIVE=1 tools/regress_all.sh) > $O/regress_$1.out 2>&1; local rc=$?; say "regress $1 rc=$rc dir $(ls -td $T/Logs/regress/*/ | head -1)"
  grep -E "^RESULT|^[a-z_]+ +(PASS|FAIL|SKIPPED|NOT RUN)" $O/regress_$1.out | cut -c1-260 | sed "s/^/[r$1] /" | tee -a $O/turn.log; }
reg 1
RS=$(ls -td $T/Logs/regress/*/ | head -1)
L06="live_06 = after the dango is dropped: the rod in the hand, waiting for it to sink (shot after the 139-frame wait)"
L08="live_08 (seed 26) = after the strike: the rod settled in the hand (139-frame wait: the move < 1 %, the tip spring 0.14 %)"
REASON="the live shots wait 139 frames instead of -ikadaTipSettle (track3/shot-hold f7af1d2, ROD_REST_A_W3.md §7.41-7.42, PRESIDENT 00:2x / 00:8x, worker2 the owner's GO). $L06. $L08. live_06C: the tip's line only."
python3 $W/drafts/stageD/live_rebase5.py $RS --project $T --tag pre-shotwait --reason "$REASON" --table $O/LIVE_SWAP_TABLE.md --sheet $O/live_sheet.png > $O/live_dry.out 2>&1; say "live dry rc=$? $(tail -1 $O/live_dry.out | cut -c1-160)"
grep -E "\| changed \|" $O/LIVE_SWAP_TABLE.md | cut -c1-60 | sed 's/^/[a2] /' | tee -a $O/turn.log
grep -q "'changed': 7, 'added': 0, 'gone': 0" $O/live_dry.out || stop "the dry table is not changed 7 / added 0 / gone 0 (prediction) - not applied"
printf '\n- labels (PRESIDENT 00:8x): %s / %s\n' "$L06" "$L08" >> $O/LIVE_SWAP_TABLE.md
python3 - "$O/live_sheet.png" <<'PY' | tee -a $O/turn.log
import sys
from PIL import Image, ImageDraw, ImageFont
p=sys.argv[1]; im=Image.open(p).convert('RGB'); F=ImageFont.truetype('/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc',22)
cap=['札 live_06 = ダンゴを落とした後 手元で沈みを待つ（139 フレーム待ってから撮る）','札 live_08（種 26）= アワセの後 落ち着いた手元（戻し < 1 %・穂先のばね 0.14 %）']
out=Image.new('RGB',(im.width,im.height+76),(24,24,26)); out.paste(im,(0,0)); d=ImageDraw.Draw(out)
for i,c in enumerate(cap): d.text((8,im.height+6+i*34),c,font=F,fill=(240,220,150))
out.save(p); print('[a2] labels on the sheet', p, out.size)
PY
python3 $W/drafts/stageD/live_rebase5.py $RS --project $T --tag pre-shotwait --reason "$REASON" --table $O/LIVE_SWAP_TABLE.md --apply > $O/live_apply.out 2>&1; RC=$?; say "live apply rc=$RC $(tail -2 $O/live_apply.out | tr '\n' ' ' | cut -c1-240)"
[ $RC = 0 ] || stop "live apply refused / failed"
say "PIN untouched: $( [ "$(cat $MB/PIN | tr '\n' ' ')" = "$PIN0" ] && echo yes || echo NO ) ($PIN0)"
reg 2
say "players left: $(for p in /proc/[0-9]*; do case "$(readlink $p/exe 2>/dev/null)" in *Ikada.x86_64) echo x;; esac; done | wc -l); end porcelain $(git -C $T status --porcelain | wc -l) head $(git -C $T rev-parse --short HEAD)"
say done
