#!/bin/bash
# boss1 01:0x GO: apply the dry table of apply2_turn (changed 13, source Logs/regress/f7af1d2_004153) -> regress (16/16 predicted).
set -u
O=$(cd "$(dirname "$0")" && pwd); T=/home/ken/Documents/ikada-unity-track3; W=/home/ken/Documents/Claude-Code-Communication/workspace/ikada-unity
say() { echo "[a3] $(date '+%F %T') $*" | tee -a $O/turn.log; }
stop() { say "STOP: $*"; exit 5; }
[ "$(git -C $T rev-parse --short HEAD)" = f7af1d2 ] && [ -z "$(git -C $T status --porcelain)" ] || stop "head / dirty"
( source $T/tools/lock_guard.sh ) 2>>$O/turn.log || stop "screen locked"
RS=$T/Logs/regress/f7af1d2_004153; MB=$W/shots/player/68f766b_113126; PIN0=$(cat $MB/PIN | tr '\n' ' ')
L06="live_06 = after the dango is dropped: the rod in the hand, waiting for it to sink (shot after the 139-frame wait)"
L08="live_08 (seed 26) = after the strike: the rod settled in the hand (139-frame wait: the move < 1 %, the tip spring 0.14 %)"
REASON="the live shots wait 139 frames instead of -ikadaTipSettle (track3/shot-hold f7af1d2, ROD_REST_A_W3.md §7.41-7.42, PRESIDENT 00:2x / 00:8x, worker2 the owner's GO, boss1 01:0x GO). $L06. $L08. live_06C: the tip's line only. live.log: the logic lines 0 diff in all 3 seeds; the frame counts and the drawn values ([RodHolder] dip / placed, [FishSurface] position) differ = the settling itself (drafts/rod_look/apply2_turn/livelog_diff_kinds.md)."
grep -q "'changed': 13, 'added': 0, 'gone': 0" $O/live_dry.out || stop "the dry table is not the one GO'd (changed 13)"
grep -q "^- labels" $O/LIVE_SWAP_TABLE.md || printf '\n- labels (PRESIDENT 00:8x): %s / %s\n- live.log diff (boss1 01:0x): logic lines 0 diff (3 seeds); frame counts + drawn values differ = drafts/rod_look/apply2_turn/livelog_diff_kinds.md\n' "$L06" "$L08" >> $O/LIVE_SWAP_TABLE.md
python3 - "$O/live_sheet.png" <<'PY' | tee -a $O/turn.log
import sys
from PIL import Image, ImageDraw, ImageFont
p=sys.argv[1]; im=Image.open(p).convert('RGB'); F=ImageFont.truetype('/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc',22)
cap=['札 live_06 = ダンゴを落とした後 手元で沈みを待つ（139 フレーム待ってから撮る）','札 live_08（種 26）= アワセの後 落ち着いた手元（戻し < 1 %・穂先のばね 0.14 %）']
out=Image.new('RGB',(im.width,im.height+76),(24,24,26)); out.paste(im,(0,0)); d=ImageDraw.Draw(out)
for i,c in enumerate(cap): d.text((8,im.height+6+i*34),c,font=F,fill=(240,220,150))
out.save(p); print('[a3] labels on the sheet', p, out.size)
PY
python3 $W/drafts/stageD/live_rebase5.py $RS/ --project $T --tag pre-shotwait --reason "$REASON" --table $O/LIVE_SWAP_TABLE.md --apply > $O/live_apply.out 2>&1; RC=$?; say "live apply rc=$RC $(tail -2 $O/live_apply.out | tr '\n' ' ' | cut -c1-240)"
[ $RC = 0 ] || stop "live apply refused / failed"
say "PIN untouched: $( [ "$(cat $MB/PIN | tr '\n' ' ')" = "$PIN0" ] && echo yes || echo NO ) ($PIN0)"
(cd $T && REGRESS_LIVE=1 tools/regress_all.sh) > $O/regress_2.out 2>&1; say "regress 2 rc=$? dir $(ls -td $T/Logs/regress/*/ | head -1)"
grep -E "^RESULT|^[a-z_]+ +(PASS|FAIL|SKIPPED|NOT RUN)" $O/regress_2.out | cut -c1-260 | sed "s/^/[r2] /" | tee -a $O/turn.log
say "players left: $(for p in /proc/[0-9]*; do case "$(readlink $p/exe 2>/dev/null)" in *Ikada.x86_64) echo x;; esac; done | wc -l); end porcelain $(git -C $T status --porcelain | wc -l) head $(git -C $T rev-parse --short HEAD)"
say done
