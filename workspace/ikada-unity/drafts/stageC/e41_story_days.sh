#!/bin/bash
# e41_story_days.sh - PLAYABLE_NEXT.md §2 items 4 and 5 for master e41e21c (worker3, boss1 04:57 LOCK) on the player of the SAME tree:
# ikada-unity-stage5/Builds/Linux (82d6de2, 04:31; its tree = e41e21c's, checked). The (E) days 9/1, 10/15, 12/10, 1/20 as turn_c.sh:24
# (lockstep, AutoPilot, speed 300, seed 20260925, -ikadaLiveStepLog, no -ikadaTipSettle), shots 07, 06C, 06, 04, J (no 08: these days have
# no fight, -ikadaLiveQuitAfterShots would wait for it). Item 5 (D6) is read from 1/20's [Tip] lines and the step log.
set -u
O=${1:?out dir}; mkdir -p "$O"; O=$(cd "$O" && pwd)
P=/home/ken/Documents/ikada-unity-stage5/Builds/Linux/Ikada.x86_64
say() { echo "[e41] $(date '+%F %T') $*" | tee -a "$O/turn.log"; }
seat=$(loginctl | awk '/seat0/{print $1; exit}')
say "head $(loginctl show-session $seat -p LockedHint -p IdleHint | tr '\n' ' ')Unity=$(pgrep -xc Unity) player=$(pgrep -xc Ikada.x86_64) Runner.Worker=$(pgrep -xc Runner.Worker) dotnet=$(pgrep -xa dotnet | grep -vc VBCSCompiler)"
[ "$(git -C /home/ken/Documents/ikada-unity rev-parse e41e21c^{tree})" = "$(git -C /home/ken/Documents/ikada-unity-stage5 rev-parse HEAD^{tree})" ] || { say "STOP: stage5 HEAD's tree != e41e21c's"; exit 1; }
say "player $P built $(stat -c %y /home/ken/Documents/ikada-unity-stage5/Builds/Linux/Ikada_Data/Managed/Assembly-CSharp.dll | cut -c1-19), stage5 HEAD $(git -C /home/ken/Documents/ikada-unity-stage5 rev-parse --short HEAD) porcelain $(git -C /home/ken/Documents/ikada-unity-stage5 status --porcelain | wc -l)"
for day in 9-1 10-15 12-10 1-20; do
  D=$O/d$day; mkdir -p "$D"
  A=(-ikadaLive -ikadaLockstep -ikadaLiveAutoPilot -ikadaLiveSpeed 300 -ikadaSavePath none -ikadaWaterT 10 -ikadaLiveShotScreens 07,06C,06,04,J
     -ikadaLiveQuitAfterShots -ikadaLiveSeed 20260925 -ikadaLiveStoryFrom $day -ikadaLiveStepLog)
  echo "${A[*]}" > "$D/ARGS.txt"
  timeout 900 "$P" -screen-width 1920 -screen-height 1080 -screen-fullscreen 0 -logFile "$D/live.log" "${A[@]}" -ikadaLiveShot "$D" > /dev/null 2>&1; rc=$?
  say "$day rc=$rc exc=$(grep -c 'Exception:' $D/live.log) shots=$(ls $D/*.png 2>/dev/null | wc -l) $(grep -o '\[Live\] RESULT.*' $D/live.log | cut -c1-110)"
  grep -h "\[Live\] test story\|\[Tip\]\|\[Gear\]" "$D/live.log" | cut -c1-220 | sed 's/^/    /' | tee -a "$O/turn.log"
  grep -h "\[Live\] text screen=\(07\|06C\|06\|04\|J\) name=\(Place\|Location\|Head\|Title\|Body\|Raft\|JRight0\|JLeft0\)" "$D/live.log" | cut -c1-160 | sed 's/^/    /' | tee -a "$O/turn.log"
done
say "end Unity=$(pgrep -xc Unity) player=$(pgrep -xc Ikada.x86_64)"
