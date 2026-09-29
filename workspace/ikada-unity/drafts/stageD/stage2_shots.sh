#!/bin/bash
# stage2_shots.sh - unlock step 2's pictures on the track3 tree (worker3, boss1 01:50 LOCK): editor 06 + 06G, player G (12-10 seed 1,
# t 1912.5) and F (10-15 seed 1, t 2812.5) 06 with the same arguments as turn_after020.sh:52-54 (c156). Compares: 06G vs 06 outside
# the top right (x 1380-1920 y 0-150, GOAL_BAND_W3.md R1: nothing else moves); the new G / F vs c156's (ba3de36) outside the top right
# (0 px expected: practice and goal-band change nothing else on a story day) and inside it (R2: the band grows left, R3: the words
# stay). Run after the regress (its Builds/Linux = this tree's build). usage: stage2_shots.sh <out dir>
set -u
O=${1:?out}; mkdir -p "$O"; O=$(cd "$O" && pwd); T3=/home/ken/Documents/ikada-unity-track3
source /home/ken/Documents/Claude-Code-Communication/workspace/ikada-unity/drafts/stageD/unity_direct.sh   # cmp_px only (ub is track1's)
OLD=/home/ken/Documents/Claude-Code-Communication/workspace/ikada-unity/shots/after020_0922
say() { echo "[s2] $(date '+%F %T') $*" | tee -a $O/turn.log; }
seat=$(loginctl | awk '/seat0/{print $1; exit}')
say "head $(loginctl show-session $seat -p LockedHint -p IdleHint | tr '\n' ' ')Unity=$(pgrep -xc Unity) player=$(pgrep -xc Ikada.x86_64) Runner.Worker=$(pgrep -xc Runner.Worker) tree=$(git -C $T3 rev-parse --short HEAD) porcelain=$(git -C $T3 status --porcelain | wc -l)"
[ -z "$(git -C $T3 status --porcelain)" ] || { say "STOP track3 dirty"; exit 2; }
say "build $(stat -c %y $T3/Builds/Linux/Ikada_Data/Managed/Assembly-CSharp.dll | cut -c1-19)"
for id in 06 06G; do
  (cd $T3 && IKADA_WATER_T=10 tools/unity-batch.sh exec Ikada.EditorTools.ShotRunner.Shoot -ikadaScreen $id -ikadaOut $O/ed_$id.png -ikadaSmallFont sans -ikadaHud on) > $O/ed_$id.out 2>&1
  say "editor $id rc=${PIPESTATUS[0]:-?} png=$([ -f $O/ed_$id.png ] && echo yes || echo NO)"
done
say "ed_06G vs ed_06 outside the top right: $(cmp_px $O/ed_06G.png $O/ed_06.png 1380 0 1920 150)"
for r in "G 12-10 1912.5 1914 AG1912/live_06_t1912.5.png" "F 10-15 2812.5 2814 AF2812/live_06_t2812.5.png"; do
  set -- $r; D=$O/$1; mkdir -p $D
  timeout 900 $T3/Builds/Linux/Ikada.x86_64 -screen-width 1920 -screen-height 1080 -screen-fullscreen 0 -logFile $D/live.log \
    -ikadaLive -ikadaLockstep -ikadaLiveAutoPilot -ikadaLiveSpeed 300 -ikadaSavePath none -ikadaWaterT 10 -ikadaLiveSeed 1 \
    -ikadaLiveShot $D -ikadaLiveShotAt $3 -ikadaLiveQuitAfterS $4 -ikadaLiveStoryFrom $2 > /dev/null 2>&1; prc=$?
  new=$(ls $D/live_06_t*.png 2>/dev/null | head -1)
  say "$1 rc=$prc exc=$(grep -c 'Exception' $D/live.log) shot=${new:-NONE}"
  [ -n "$new" ] && { say "$1 vs c156 outside the top right: $(cmp_px $new $OLD/$5 1380 0 1920 150)"
                     say "$1 vs c156 whole: $(cmp_px $new $OLD/$5)"; }
done
say "end Unity=$(pgrep -xc Unity) player=$(pgrep -xc Ikada.x86_64) porcelain=$(git -C $T3 status --porcelain | wc -l)"
