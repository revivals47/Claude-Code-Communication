#!/bin/bash
# worker3's Unity turn (ROD_REST_A_W3.md §7.39, PRESIDENT 23:1x-23:5x): track3/rod-default 4232827 = ed4fe86 + the fight frame log.
# Roslyn -> BuildPerf (player) -> run A: seed 26, slow window 785-800 (speed 1), NO -ikadaTipSettle, shots at HookSet + 0/0.1/0.25/0.5/1.0/1.5 s
# (the strip, to look at once) -> run B: the live regress's own args (ARGS.txt of seed 26) + the slow window + a shot at HookSet + 2.31 s.
# Both with IKADA_ROD_FRAME_LOG=1. No apply, no baseline change, no edit / commit (the font prebake would be reported, not committed).
set -u
O=$(cd "$(dirname "$0")" && pwd); T=/home/ken/Documents/ikada-unity-track3; W=/home/ken/Documents/Claude-Code-Communication/workspace/ikada-unity
say() { echo "[l8] $(date '+%F %T') $*" | tee -a $O/turn.log; }
stop() { say "STOP: $*"; say "porcelain: [$(git -C $T status --porcelain | tr '\n' ';')] head $(git -C $T rev-parse --short HEAD)"; exit 5; }
[ "$(git -C $T rev-parse --short HEAD)" = 4232827 ] && [ -z "$(git -C $T status --porcelain)" ] || stop "head / dirty"
( source $T/tools/lock_guard.sh ) 2>>$O/turn.log || stop "screen locked"
bash $W/drafts/stageC/bundle_compile8.sh 4232827 > $O/bc8.out 2>&1; say "roslyn: $(grep -E 'errors=' $O/bc8.out | tr '\n' ' ' | cut -c1-260)"
grep -q "editor rc=0 errors=0" $O/bc8.out && grep -q "game rc=0 errors=0" $O/bc8.out || stop "Roslyn not 0"
ubT() { local m=$1; shift
  ( source $T/tools/disk_guard.sh; local log=$T/Logs/batch/exec-$(date +%H%M%S)-l8.log; mkdir -p $T/Logs/batch
    exec 9>/tmp/ikada-unity-batch.lock; flock 9
    DISPLAY=${DISPLAY:-:1} /home/ken/Unity/Hub/Editor/6000.4.11f1/Editor/Unity -batchmode -projectPath $T -logFile $log -quit -executeMethod "$m" "$@"
    local rc=$?; echo "[ubT] $m rc=$rc log=$log exiting_ok=$(grep -c 'Exiting batchmode successfully' $log) exceptions=$(grep -c 'Exception:' $log) cs=$(grep -c 'error CS' $log)"; return $rc ) }
[ -e $T/Builds/Linux ] && mv $T/Builds/Linux $T/Builds/Linux_prev_$(date +%H%M%S)
ubT Ikada.EditorTools.BuildScript.BuildPerf > $O/bake.out 2>&1; say "bake: $(tail -1 $O/bake.out)"; grep -q "exiting_ok=1" $O/bake.out || stop "BuildPerf failed"
say "porcelain after the bake: [$(git -C $T status --porcelain | tr '\n' ';')]"
H=792.40; at() { python3 -c "print(','.join('%.3f'%($H+d) for d in [$1]))"; }
run() { local d=$O/$1; shift; mkdir -p $d
  ( source $T/tools/lock_guard.sh ) 2>>$O/turn.log || stop "screen locked before $(basename $d)"
  IKADA_ROD_FRAME_LOG=1 timeout -k 15 1200 $T/Builds/Linux/Ikada.x86_64 -screen-width 1920 -screen-height 1080 -screen-fullscreen 0 "$@" -ikadaLiveShot $d -logFile $d/live.log >/dev/null 2>&1
  say "run $(basename $d) rc=$? png=[$(ls $d | grep png | tr '\n' ' ')] exc=$(grep -c 'Exception:' $d/live.log) hookset=[$(grep -m1 'hand at HookSet' $d/live.log)] framelines=$(grep -c 'fight frame' $d/live.log)"; }
BASE="-ikadaLive -ikadaLockstep -ikadaLiveAutoPilot -ikadaLiveSpeed 300 -ikadaSavePath none -ikadaWaterT 10 -ikadaLiveSeed 26 -ikadaLiveSlowWindows 785-800"
run A_strip $BASE -ikadaLiveShotAt $(at 0,0.1,0.25,0.5,1.0,1.5) -ikadaLiveQuitAfterS 800
run B_regress08 -ikadaLive -ikadaLockstep -ikadaLiveAutoPilot -ikadaLiveSpeed 300 -ikadaSavePath none -ikadaWaterT 10 -ikadaTipSettle -ikadaLiveShotScreens 05,07,06C,06,08,03,04,J -ikadaLiveQuitAfterShots -ikadaLiveSeed 26 -ikadaLiveSlowWindows 785-800 -ikadaLiveShotAt $(at 2.31)
for r in A_strip B_regress08; do grep -h "\[Live\] shot screen\|fight frame [0-9]*:" $O/$r/live.log | grep -E "shot screen|fight frame (1|2|3|139|140|141):" | cut -c1-330 | sed "s/^/[l8] $r /" | tee -a $O/turn.log; done
python3 - "$O" <<'PY' | tee -a $O/turn.log
import sys, os, glob
from PIL import Image, ImageDraw, ImageFont
O=sys.argv[1]; F=ImageFont.truetype('/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc',22)
fs=sorted(glob.glob(O+'/A_strip/live_*_t*.png'), key=lambda p: float(p.rsplit('_t',1)[1][:-4]))
labels=['+0','+0.1','+0.25','+0.5','+1.0','+1.5']
w,h=480,270; im=Image.new('RGB',(3*w+20,2*(h+34)+44),(24,24,26)); d=ImageDraw.Draw(im)
d.text((8,8),'live 種 26 HookSet（792.40）からの 6 枚 = 竿が受けから手へ（-ikadaTipSettle なし・遅くした窓 785-800 = 1 倍, 4232827）',font=F,fill=(240,220,150))
for i,p in enumerate(fs[:6]):
    x=(i%3)*(w+10); y=44+(i//3)*(h+34); d.text((x+4,y),labels[i] if i<6 else os.path.basename(p),font=F,fill=(230,230,230)); im.paste(Image.open(p).convert('RGB').resize((w,h)),(x,y+30))
im.save(O+'/strip.png'); print('[l8] strip', O+'/strip.png', len(fs), 'shots')
PY
say "players left: $(for p in /proc/[0-9]*; do case "$(readlink $p/exe 2>/dev/null)" in *Ikada.x86_64) echo x;; esac; done | wc -l); end porcelain $(git -C $T status --porcelain | wc -l) head $(git -C $T rev-parse --short HEAD)"
say done
