#!/bin/bash
# worker3's Unity turn (ROD_REST_A_W3.md §7.41-7.42, PRESIDENT 00:2x case C, worker2's 5 orders): track3/shot-hold f7af1d2.
# Roslyn -> BuildPerf -> (5) the positive control BEFORE taking it in: each seed (20260925, 1, 26) twice with live_regress.sh's NEW args
# (no -ikadaTipSettle, -ikadaLiveShotWait 139) -> the two runs' pictures must be 0 px (else STOP, not taken in) -> the default-30 control:
# seed 26 once with the OLD args (-ikadaTipSettle, no wait arg) vs today's live baseline = 0 px -> the new pictures vs today's baseline
# (the table to compare with §7.41's predictions) + one sheet per changed picture. No apply, no baseline change, no edit / commit.
set -u
O=$(cd "$(dirname "$0")" && pwd); T=/home/ken/Documents/ikada-unity-track3; W=/home/ken/Documents/Claude-Code-Communication/workspace/ikada-unity
say() { echo "[sw] $(date '+%F %T') $*" | tee -a $O/turn.log; }
stop() { say "STOP: $*"; exit 5; }
[ "$(git -C $T rev-parse --short HEAD)" = f7af1d2 ] && [ -z "$(git -C $T status --porcelain)" ] || stop "head / dirty"
( source $T/tools/lock_guard.sh ) 2>>$O/turn.log || stop "screen locked"
bash $W/drafts/stageC/bundle_compile8.sh f7af1d2 > $O/bc8.out 2>&1; say "roslyn: $(grep -E 'errors=' $O/bc8.out | tr '\n' ' ' | cut -c1-260)"
grep -q "editor rc=0 errors=0" $O/bc8.out && grep -q "game rc=0 errors=0" $O/bc8.out || stop "Roslyn not 0"
ubT() { local m=$1; shift
  ( source $T/tools/disk_guard.sh; local log=$T/Logs/batch/exec-$(date +%H%M%S)-sw.log; mkdir -p $T/Logs/batch
    exec 9>/tmp/ikada-unity-batch.lock; flock 9
    DISPLAY=${DISPLAY:-:1} /home/ken/Unity/Hub/Editor/6000.4.11f1/Editor/Unity -batchmode -projectPath $T -logFile $log -quit -executeMethod "$m" "$@"
    local rc=$?; echo "[ubT] $m rc=$rc log=$log exiting_ok=$(grep -c 'Exiting batchmode successfully' $log) exceptions=$(grep -c 'Exception:' $log) cs=$(grep -c 'error CS' $log)"; return $rc ) }
[ -e $T/Builds/Linux ] && mv $T/Builds/Linux $T/Builds/Linux_prev_$(date +%H%M%S)
ubT Ikada.EditorTools.BuildScript.BuildPerf > $O/bake.out 2>&1; say "bake: $(tail -1 $O/bake.out)"; grep -q "exiting_ok=1" $O/bake.out || stop "BuildPerf failed"
say "porcelain after the bake: [$(git -C $T status --porcelain | tr '\n' ';')]"
NEW=(-ikadaLive -ikadaLockstep -ikadaLiveAutoPilot -ikadaLiveSpeed 300 -ikadaSavePath none -ikadaWaterT 10 -ikadaLiveShotWait 139 -ikadaLiveShotScreens 05,07,06C,06,08,03,04,J -ikadaLiveQuitAfterShots)
OLD=(-ikadaLive -ikadaLockstep -ikadaLiveAutoPilot -ikadaLiveSpeed 300 -ikadaSavePath none -ikadaWaterT 10 -ikadaTipSettle -ikadaLiveShotScreens 05,07,06C,06,08,03,04,J -ikadaLiveQuitAfterShots)
grep -q -- "-ikadaLiveShotWait 139" $T/tools/live_regress.sh && ! grep -q "^ARGS=.*-ikadaTipSettle" $T/tools/live_regress.sh || stop "live_regress.sh's args are not the new ones"
run() { local d=$O/$1 seed=$2; shift 2; mkdir -p $d
  ( source $T/tools/lock_guard.sh ) 2>>$O/turn.log || stop "screen locked before $(basename $d)"
  timeout -k 15 1200 $T/Builds/Linux/Ikada.x86_64 -screen-width 1920 -screen-height 1080 -screen-fullscreen 0 "$@" -ikadaLiveSeed $seed -ikadaLiveShot $d -logFile $d/live.log >/dev/null 2>&1
  say "run $(basename $d) rc=$? png=$(ls $d | grep -c png) exc=$(grep -c 'Exception:' $d/live.log) start=[$(grep -m1 '\[Live\] start' $d/live.log | grep -o 'seed=[0-9]*\|shotWait=[0-9]*' | tr '\n' ' ')] result=[$(grep -m1 '\[Live\] RESULT' $d/live.log | grep -o 'ok=[A-Za-z]*\|steps=[0-9]*\|page=[A-Za-z]*' | tr '\n' ' ')]"; }
source $W/drafts/stageD/unity_direct.sh
declare -A BASE=([20260925]=$W/shots/player_live/ae3b5c4_s20260925_231126 [1]=$W/shots/player_live/ae3b5c4_s1_231126 [26]=$W/shots/player_live/5e50ac7_s26_014332)
for s in 20260925 1 26; do run new_${s}_a $s "${NEW[@]}"; run new_${s}_b $s "${NEW[@]}"; done
bad=0
for s in 20260925 1 26; do for f in $(ls $O/new_${s}_a | grep '^live_.*png$'); do r=$(cmp_px $O/new_${s}_a/$f $O/new_${s}_b/$f); say "(5) seed $s $f a vs b: $r"; echo "$r" | grep -q "diff_px=0 " || bad=1; done; done
[ $bad = 0 ] || stop "(5) the two runs differ - NOT taken in (worker2's condition)"
say "(5) PASS: every picture of the two runs is 0 px, every seed"
run old_26 26 "${OLD[@]}"
for f in $(ls $O/old_26 | grep '^live_.*png$'); do say "default-30 control seed 26 $f (old args, f7af1d2) vs baseline: $(cmp_px $O/old_26/$f ${BASE[26]}/$f)"; done
for s in 20260925 1 26; do for f in $(ls $O/new_${s}_a | grep '^live_.*png$'); do say "new seed $s $f vs baseline: $(cmp_px $O/new_${s}_a/$f ${BASE[$s]}/$f)"; done; done
python3 - "$O" <<'PY' | tee -a $O/turn.log
import sys, os, subprocess
from PIL import Image, ImageDraw, ImageFont, ImageChops
O=sys.argv[1]; F=ImageFont.truetype('/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc',22)
base={'20260925':'/home/ken/Documents/Claude-Code-Communication/workspace/ikada-unity/shots/player_live/ae3b5c4_s20260925_231126','1':'/home/ken/Documents/Claude-Code-Communication/workspace/ikada-unity/shots/player_live/ae3b5c4_s1_231126','26':'/home/ken/Documents/Claude-Code-Communication/workspace/ikada-unity/shots/player_live/5e50ac7_s26_014332'}
os.makedirs(O+'/sheets',exist_ok=True); n=0
for s,b in base.items():
    d=f'{O}/new_{s}_a'
    for f in sorted(x for x in os.listdir(d) if x.startswith('live_') and x.endswith('.png')):
        a=Image.open(f'{b}/{f}').convert('RGB'); c=Image.open(f'{d}/{f}').convert('RGB')
        if ImageChops.difference(a,c).getbbox() is None: continue
        im=Image.new('RGB',(2*960+10,540+40),(24,24,26)); dr=ImageDraw.Draw(im)
        dr.text((6,6),f'種 {s} {f}: 左 = 今の基準（TipSettle・待ち 30）｜ 右 = 案 C（TipSettle なし・待ち 139, f7af1d2）',font=F,fill=(240,220,150))
        im.paste(a.resize((960,540)),(0,40)); im.paste(c.resize((960,540)),(970,40)); im.save(f'{O}/sheets/{s}_{f}'); n+=1
print('[sw] sheets', n)
PY
say "players left: $(for p in /proc/[0-9]*; do case "$(readlink $p/exe 2>/dev/null)" in *Ikada.x86_64) echo x;; esac; done | wc -l); end porcelain $(git -C $T status --porcelain | wc -l) head $(git -C $T rev-parse --short HEAD)"
say done
