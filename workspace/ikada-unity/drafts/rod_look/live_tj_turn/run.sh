#!/bin/bash
# worker3's Unity turn (ROD_REST_A_W3.md §7.44, PRESIDENT 09:5x (2)): the tip joint in PLAY, on 6c90269 (the probe, WITHOUT the build-order
# fix bad4d3c): detach ikada-unity-track3 to 6c90269 -> Roslyn -> BuildPerf -> one live run, seed 26, live_regress.sh's args (incl.
# -ikadaLiveShotWait 139) + IKADA_ROD_TIP_JOINT_LOG=1 -> every hand / fight frame's [TipJoint] (up to 300) -> back to track3/side-shot.
set -u
O=$(cd "$(dirname "$0")" && pwd); T=/home/ken/Documents/ikada-unity-track3; W=/home/ken/Documents/Claude-Code-Communication/workspace/ikada-unity
say() { echo "[lt] $(date '+%F %T') $*" | tee -a $O/turn.log; }
stop() { say "STOP: $*"; git -C $T checkout -q track3/side-shot 2>/dev/null; exit 5; }
[ "$(git -C $T branch --show-current)" = track3/side-shot ] && [ -z "$(git -C $T status --porcelain)" ] || stop "branch / dirty"
( source $T/tools/lock_guard.sh ) 2>>$O/turn.log || stop "screen locked"
git -C $T checkout -q --detach 6c90269 || stop "checkout"
say "head $(git -C $T rev-parse --short HEAD)"
bash $W/drafts/stageC/bundle_compile8.sh 6c90269 > $O/bc8.out 2>&1; say "roslyn: $(grep -E 'errors=' $O/bc8.out | tr '\n' ' ' | cut -c1-260)"
grep -q "editor rc=0 errors=0" $O/bc8.out && grep -q "game rc=0 errors=0" $O/bc8.out || stop "Roslyn not 0"
ubT() { local m=$1; shift
  ( source $T/tools/disk_guard.sh; local log=$T/Logs/batch/exec-$(date +%H%M%S)-lt.log; mkdir -p $T/Logs/batch
    exec 9>/tmp/ikada-unity-batch.lock; flock 9
    DISPLAY=${DISPLAY:-:1} /home/ken/Unity/Hub/Editor/6000.4.11f1/Editor/Unity -batchmode -projectPath $T -logFile $log -quit -executeMethod "$m" "$@"
    local rc=$?; echo "[ubT] $m rc=$rc log=$log exiting_ok=$(grep -c 'Exiting batchmode successfully' $log) exceptions=$(grep -c 'Exception:' $log) cs=$(grep -c 'error CS' $log)"; return $rc ) }
[ -e $T/Builds/Linux ] && mv $T/Builds/Linux $T/Builds/Linux_prev_$(date +%H%M%S)
ubT Ikada.EditorTools.BuildScript.BuildPerf > $O/bake.out 2>&1; say "bake: $(tail -1 $O/bake.out)"; grep -q "exiting_ok=1" $O/bake.out || stop "BuildPerf failed"
say "porcelain after the bake: [$(git -C $T status --porcelain | tr '\n' ';')]"
ARGS=$(sed -n '/^ARGS=(/,/)/p' $T/tools/live_regress.sh | tr -d '()\n' | sed 's/ARGS=//'); say "live_regress.sh args: $ARGS"
d=$O/live26; mkdir -p $d
IKADA_ROD_TIP_JOINT_LOG=1 timeout -k 15 1200 $T/Builds/Linux/Ikada.x86_64 -screen-width 1920 -screen-height 1080 -screen-fullscreen 0 $ARGS -ikadaLiveSeed 26 -ikadaLiveShot $d -logFile $d/live.log >/dev/null 2>&1
say "run rc=$? png=$(ls $d | grep -c png) exc=$(grep -c 'Exception:' $d/live.log) lines=$(grep -c '\[TipJoint\] play frame' $d/live.log)"
python3 - "$d/live.log" <<'PY' | tee -a $O/turn.log
import re,sys
L=[l for l in open(sys.argv[1],errors='ignore') if '[TipJoint] play frame' in l]
rows=[]
for l in L:
    m=re.search(r'play frame (\d+): frameCount=(\d+) TimeS=([\d.-]+) hold=(\w+) fight=(\w+).*along ([-\d.]+) side\(\+right\) ([-\d.]+) up ([-\d.]+) m \| angle ([\d.]+)',l)
    if m: rows.append(m.groups())
print(f'[lt] frames logged {len(rows)}')
bad=[r for r in rows if abs(float(r[5]))>1e-4 or abs(float(r[6]))>1e-4 or abs(float(r[7]))>1e-4 or float(r[8])>0.01]
print(f'[lt] frames with |along|,|side|,|up| > 0.0001 m or angle > 0.01 deg: {len(bad)}')
for r in bad[:10]: print('[lt]   BAD', r)
# the first frame of each hand / fight run (frameCount not consecutive = a new run)
prev=None
for r in rows:
    fc=int(r[1])
    if prev is None or fc!=prev+1: print(f'[lt]   run start frame {r[0]} frameCount {fc} TimeS {r[2]} hold {r[3]} fight {r[4]} gap along/side/up {r[5]}/{r[6]}/{r[7]} angle {r[8]}')
    prev=fc
PY
git -C $T checkout -q track3/side-shot; say "back to $(git -C $T branch --show-current) $(git -C $T rev-parse --short HEAD), porcelain $(git -C $T status --porcelain | wc -l)"
say "players left: $(for p in /proc/[0-9]*; do case "$(readlink $p/exe 2>/dev/null)" in *Ikada.x86_64) echo x;; esac; done | wc -l)"; say done
