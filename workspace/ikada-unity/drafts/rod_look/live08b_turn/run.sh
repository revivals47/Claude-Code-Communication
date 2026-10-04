#!/bin/bash
# worker3's Unity turn (ROD_REST_A_W3.md §7.40, PRESIDENT 23:6x): track3/rod-default b763128 = 4232827 + the hold frame log + -ikadaLiveShotFrames.
# Roslyn -> BuildPerf -> (a) the live regress's own args for seed 26 (no slow window), TWICE, with IKADA_ROD_FRAME_LOG=1 -> which frame
# live_08 is and whether the two runs agree -> (c) the strip by frames after 08 shows (+0 6 15 30 60 90), no -ikadaTipSettle, slow window
# 785-800 (speed 1). No apply / baseline change / edit / commit.
set -u
O=$(cd "$(dirname "$0")" && pwd); T=/home/ken/Documents/ikada-unity-track3; W=/home/ken/Documents/Claude-Code-Communication/workspace/ikada-unity
say() { echo "[lb] $(date '+%F %T') $*" | tee -a $O/turn.log; }
stop() { say "STOP: $*"; say "porcelain: [$(git -C $T status --porcelain | tr '\n' ';')] head $(git -C $T rev-parse --short HEAD)"; exit 5; }
[ "$(git -C $T rev-parse --short HEAD)" = b763128 ] && [ -z "$(git -C $T status --porcelain)" ] || stop "head / dirty"
( source $T/tools/lock_guard.sh ) 2>>$O/turn.log || stop "screen locked"
bash $W/drafts/stageC/bundle_compile8.sh b763128 > $O/bc8.out 2>&1; say "roslyn: $(grep -E 'errors=' $O/bc8.out | tr '\n' ' ' | cut -c1-260)"
grep -q "editor rc=0 errors=0" $O/bc8.out && grep -q "game rc=0 errors=0" $O/bc8.out || stop "Roslyn not 0"
ubT() { local m=$1; shift
  ( source $T/tools/disk_guard.sh; local log=$T/Logs/batch/exec-$(date +%H%M%S)-lb.log; mkdir -p $T/Logs/batch
    exec 9>/tmp/ikada-unity-batch.lock; flock 9
    DISPLAY=${DISPLAY:-:1} /home/ken/Unity/Hub/Editor/6000.4.11f1/Editor/Unity -batchmode -projectPath $T -logFile $log -quit -executeMethod "$m" "$@"
    local rc=$?; echo "[ubT] $m rc=$rc log=$log exiting_ok=$(grep -c 'Exiting batchmode successfully' $log) exceptions=$(grep -c 'Exception:' $log) cs=$(grep -c 'error CS' $log)"; return $rc ) }
[ -e $T/Builds/Linux ] && mv $T/Builds/Linux $T/Builds/Linux_prev_$(date +%H%M%S)
ubT Ikada.EditorTools.BuildScript.BuildPerf > $O/bake.out 2>&1; say "bake: $(tail -1 $O/bake.out)"; grep -q "exiting_ok=1" $O/bake.out || stop "BuildPerf failed"
say "porcelain after the bake: [$(git -C $T status --porcelain | tr '\n' ';')]"
run() { local d=$O/$1; shift; mkdir -p $d
  ( source $T/tools/lock_guard.sh ) 2>>$O/turn.log || stop "screen locked before $(basename $d)"
  IKADA_ROD_FRAME_LOG=1 timeout -k 15 1200 $T/Builds/Linux/Ikada.x86_64 -screen-width 1920 -screen-height 1080 -screen-fullscreen 0 "$@" -ikadaLiveShot $d -logFile $d/live.log >/dev/null 2>&1
  say "run $(basename $d) rc=$? png=[$(ls $d | grep png | tr '\n' ' ')] exc=$(grep -c 'Exception:' $d/live.log) hookset=[$(grep -m1 'hand at HookSet' $d/live.log)] holdlines=$(grep -c 'hold frame' $d/live.log)"; }
REG="-ikadaLive -ikadaLockstep -ikadaLiveAutoPilot -ikadaLiveSpeed 300 -ikadaSavePath none -ikadaWaterT 10 -ikadaTipSettle -ikadaLiveShotScreens 05,07,06C,06,08,03,04,J -ikadaLiveQuitAfterShots -ikadaLiveSeed 26"
say "the regress's own args (Logs/regress/ed4fe86_230630/live/seed_26/ARGS.txt): $(cat $T/Logs/regress/ed4fe86_230630/live/seed_26/ARGS.txt)"
run R1 $REG
run R2 $REG
source $W/drafts/stageD/unity_direct.sh
say "R1 live_08 vs R2 live_08: $(cmp_px $O/R1/live_08.png $O/R2/live_08.png)"
say "R1 live_08 vs the ed4fe86 regress live_08: $(cmp_px $O/R1/live_08.png $T/Logs/regress/ed4fe86_230630/live/seed_26/live_08.png)"
for r in R1 R2; do python3 - $O/$r/live.log $r <<'PY' | tee -a $O/turn.log
import re,sys
L=open(sys.argv[1],errors='ignore').read().splitlines(); r=sys.argv[2]; last=None; hs=None
for i,l in enumerate(L):
    if 'hand at HookSet' in l: hs=i; print(f'[lb] {r} {l.strip()}')
    if 'hold frame' in l and hs is not None and i>hs: last=l
    if 'shot screen=08 ' in l:
        prev=[x for x in L[hs:i] if 'hold frame' in x] if hs is not None else []
        print(f'[lb] {r} hold frames between HookSet and the 08 picture: {len(prev)}')
        for x in prev[:2]+prev[-2:]: print(f'[lb] {r}   {x.strip()[:300]}')
        print(f'[lb] {r} {l.strip()[:200]}'); break
PY
done
C="-ikadaLive -ikadaLockstep -ikadaLiveAutoPilot -ikadaLiveSpeed 300 -ikadaSavePath none -ikadaWaterT 10 -ikadaLiveSeed 26 -ikadaLiveSlowWindows 785-800 -ikadaLiveShotFrames 08:0,6,15,30,60,90 -ikadaLiveQuitAfterS 800"
run C_strip $C
grep -h "shot screen=08_f" $O/C_strip/live.log | cut -c1-200 | sed 's/^/[lb] C /' | tee -a $O/turn.log
python3 - "$O" "$C" <<'PY' | tee -a $O/turn.log
import sys, glob, re
from PIL import Image, ImageDraw, ImageFont
O,args=sys.argv[1:3]; F=ImageFont.truetype('/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc',20)
fs=sorted(glob.glob(O+'/C_strip/live_08_f*.png'), key=lambda p:int(re.search(r'_f(\d+)',p).group(1)))
w,h=480,270; im=Image.new('RGB',(3*w+20,2*(h+32)+70),(24,24,26)); d=ImageDraw.Draw(im)
d.text((8,6),'live 種 26: 08 が出てから（アワセ）の frame で 6 枚 = 竿が受けから手へ（b763128）',font=F,fill=(240,220,150))
d.text((8,34),'引数: TipSettle なし・遅くした窓 785-800（1 倍）・-ikadaLiveShotFrames 08:0,6,15,30,60,90（撮りで止めない）',font=F,fill=(200,200,200))
for i,p in enumerate(fs[:6]):
    x=(i%3)*(w+10); y=70+(i//3)*(h+32); n=re.search(r'_f(\d+)',p).group(1)
    d.text((x+4,y),f'+{n} frame（{int(n)/60:.2f} s）',font=F,fill=(230,230,230)); im.paste(Image.open(p).convert('RGB').resize((w,h)),(x,y+28))
im.save(O+'/strip_frames.png'); print('[lb] strip', O+'/strip_frames.png', len(fs))
PY
say "players left: $(for p in /proc/[0-9]*; do case "$(readlink $p/exe 2>/dev/null)" in *Ikada.x86_64) echo x;; esac; done | wc -l); end porcelain $(git -C $T status --porcelain | wc -l) head $(git -C $T rev-parse --short HEAD)"
say done
