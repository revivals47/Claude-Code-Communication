#!/bin/bash
# worker3's apply turn (PRESIDENT 23:8x GO, boss1 23:35 LOCK): (1) the live_08 label (sheet + table reason) (2) the baseline swap: live 10
# (live_rebase5 --apply, from Logs/regress/ed4fe86_230630) + mock 12 (shots/player/68f766b_113126 in place, old kept as pre-roddefault_<name>,
# sha before / after, NOTE lines; PIN untouched) (3) regress_all once on b763128 (16/16 predicted). No code edit / commit in the tree.
set -u
O=$(cd "$(dirname "$0")" && pwd); T=/home/ken/Documents/ikada-unity-track3; W=/home/ken/Documents/Claude-Code-Communication/workspace/ikada-unity
say() { echo "[ap] $(date '+%F %T') $*" | tee -a $O/turn.log; }
stop() { say "STOP: $*"; exit 5; }
[ "$(git -C $T rev-parse --short HEAD)" = b763128 ] && [ -z "$(git -C $T status --porcelain)" ] || stop "head / dirty"
( source $T/tools/lock_guard.sh ) 2>>$O/turn.log || stop "screen locked"
RS=$T/Logs/regress/ed4fe86_230630; PS=$W/shots/player/ed4fe86_231608; MB=$W/shots/player/68f766b_113126
LABEL="live_08 (seed 26) = 33 frames (0.55 s) after the strike (HookSet): the rod is 68 % of the way back to the hand (butt z 1.78 of 2.96 -> 1.24), still on the rests' side in the picture (ROD_REST_A_W3.md §7.40, PRESIDENT 23:8x)"
REASON="rod defaults (track3/rod-default: edge rests (a) + 1.73 m forward and back in the hand / fight, hand side 0.158, F2, line 3 mm; PRESIDENT 22:5x / 23:8x GO, worker3). $LABEL"
# (1)+(2a) live: a fresh dry table from the same regress, then --apply against it
python3 $W/drafts/stageD/live_rebase5.py $RS --project $T --tag pre-roddefault --reason "$REASON" --table $O/LIVE_SWAP_TABLE.md --sheet $O/live_sheet.png > $O/live_dry.out 2>&1; say "live dry rc=$? $(tail -1 $O/live_dry.out | cut -c1-160)"
grep -q "'changed': 10, 'added': 0, 'gone': 0" $O/live_dry.out || stop "the dry table is not changed 10 / added 0 / gone 0"
printf '\n- label (PRESIDENT 23:8x): %s\n' "$LABEL" >> $O/LIVE_SWAP_TABLE.md
python3 - "$O/live_sheet.png" <<'PY' | tee -a $O/turn.log
import sys
from PIL import Image, ImageDraw, ImageFont
p=sys.argv[1]; im=Image.open(p).convert('RGB'); F=ImageFont.truetype('/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc',22)
cap='札 live_08（種 26）= アワセの 33 フレーム（0.55 s）後: 竿は手元へ 68 %（根元 z 2.96 → 1.78、手元 1.24）、画ではまだ受けの側（§7.40, PRESIDENT 23:8x）'
out=Image.new('RGB',(im.width,im.height+44),(24,24,26)); out.paste(im,(0,0)); ImageDraw.Draw(out).text((8,im.height+8),cap,font=F,fill=(240,220,150)); out.save(p)
print('[ap] label on the sheet', p, out.size)
PY
python3 $W/drafts/stageD/live_rebase5.py $RS --project $T --tag pre-roddefault --reason "$REASON" --table $O/LIVE_SWAP_TABLE.md --apply > $O/live_apply.out 2>&1; RC=$?; say "live apply rc=$RC $(tail -2 $O/live_apply.out | tr '\n' ' ' | cut -c1-240)"
[ $RC = 0 ] || stop "live apply refused / failed"
# (2b) mock 12 in place
python3 - "$MB" "$PS" "$REASON" <<'PY' | tee -a $O/turn.log
import sys, os, shutil, hashlib, time
mb, ps, reason = sys.argv[1:4]
sha=lambda p: hashlib.sha256(open(p,'rb').read()).hexdigest()
names=[f'{s}_{t}.png' for s in ['06','06C','06M','08','P1','P2'] for t in ['A_sans','B_serif']]
plan=[]
for n in names:
    old=os.path.join(mb,n); new=os.path.join(ps,n); keep=os.path.join(mb,'pre-roddefault_'+n)
    assert os.path.exists(old) and os.path.exists(new) and not os.path.exists(keep), n
    plan.append((n,old,new,keep,sha(old),sha(new)))
    assert plan[-1][4]!=plan[-1][5], ('same sha', n)
lines=[]
for n,old,new,keep,so,sn in plan:
    os.rename(old,keep); shutil.copyfile(new,old)
    assert sha(keep)==so and sha(old)==sn, ('verify', n)
    lines.append(f'- {n}: {so[:16]} -> {sn[:16]} (old kept as pre-roddefault_{n}; source {os.path.basename(ps)}/{n})')
    print(f'[ap] mock {n}: {so[:16]} -> {sn[:16]} ok')
with open(os.path.join(mb,'NOTE_baseline_changes.md'),'a') as f:
    f.write(f"\n## {time.strftime('%Y-%m-%d %H:%M')} worker3: {reason} - 06/06C/06M/08/P1/P2 x A/B; the other 14 unchanged; PIN untouched\n"+'\n'.join(lines)+'\n')
print('[ap] mock swapped', len(lines))
PY
[ ${PIPESTATUS[0]} = 0 ] || stop "mock swap failed"
say "PIN untouched: $(cat $MB/PIN | tr '\n' ' ')"
# (3) regress once
(cd $T && REGRESS_LIVE=1 tools/regress_all.sh) > $O/regress.out 2>&1; RC=$?; say "regress rc=$RC"
grep -E "^RESULT|^[a-z_]+ +(PASS|FAIL|SKIPPED|NOT RUN)" $O/regress.out | cut -c1-300 | sed "s/^/[r] /" | tee -a $O/turn.log
say "regress dir $(ls -td $T/Logs/regress/*/ | head -1)"
say "players left: $(for p in /proc/[0-9]*; do case "$(readlink $p/exe 2>/dev/null)" in *Ikada.x86_64) echo x;; esac; done | wc -l); end porcelain $(git -C $T status --porcelain | wc -l) head $(git -C $T rev-parse --short HEAD)"
say done
