#!/bin/bash
# 段 (4) 4a-4c (worker3, PRESIDENT 07:3x GO): playable_build.sh's step 4 on the copied player, logs OUTSIDE the handed-over dir (absolute),
# the save dir compared as a table before / after, players counted by /proc/<pid>/exe, the folder sha before / after. Then the script's own
# stop lines on the logs (--check-lines). Gate and LOCK only.
set -u
OUT=$HOME/Documents/ikada-play/074918b; D=$(cd "$(dirname "$0")" && pwd); SAVE=$HOME/.config/unity3d/DefaultCompany/ikada-unity/save
PB=$HOME/Documents/Claude-Code-Communication/workspace/ikada-unity/drafts/stageC/playable_build.sh
fsha(){ (cd "$OUT" && find . -type f -print0 | sort -z | xargs -0 sha256sum | sha256sum | cut -c1-64); }
snap(){ [ -d "$SAVE" ] || { echo "(no dir)"; return; }; (cd "$SAVE" && find . -type f | sort | while IFS= read -r f; do echo "$f $(stat -c %.9Y "$f") $(sha256sum < "$f" | cut -c1-64)"; done); }
players(){ local want; want=$(readlink -f "$OUT")/Ikada.x86_64; for p in /proc/[0-9]*; do e=$(readlink "$p/exe" 2>/dev/null) || continue; [ "${e% (deleted)}" = "$want" ] && echo "${p#/proc/}"; done; return 0; }
f0=$(fsha); s0=$(snap); echo "before: folder $f0 | players $(players | wc -l) | save $(echo "$s0" | wc -l) line(s)"
timeout -k 15 25 "$OUT/Ikada.x86_64" -screen-width 1920 -screen-height 1080 -screen-fullscreen 0 -logFile "$D/4a_launch.log" >/dev/null 2>&1; echo "4a rc=$? players after $(players | wc -l)"
timeout -k 15 120 "$OUT/Ikada.x86_64" -ikadaSessionProbe -logFile "$D/4b_probe.log" >/dev/null 2>&1; echo "4b rc=$? players after $(players | wc -l)"
timeout -k 15 900 "$OUT/Ikada.x86_64" -screen-width 1920 -screen-height 1080 -screen-fullscreen 0 -ikadaLive -ikadaLockstep -ikadaLiveAutoPilot \
  -ikadaLiveSpeed 300 -ikadaSavePath none -ikadaLiveSeed 1 -ikadaLiveQuitAfterS 9200 -logFile "$D/4c_day.log" >/dev/null 2>&1; echo "4c rc=$? players after $(players | wc -l)"
s1=$(snap); [ "$s0" = "$s1" ] && echo "4d save dir: SAME ($(echo "$s1" | wc -l) line(s))" || { echo "4d save dir: CHANGED"; diff <(echo "$s0") <(echo "$s1") | head; }
echo "4 lines: $(grep -o '\[Live\] start api[^ ]* [^ ]*' "$D/4a_launch.log" | head -1) | $(grep -o '\[SessionProbe\] RESULT.*' "$D/4b_probe.log" | head -1 | cut -c1-120) | $(grep -o '\[Live\] RESULT.*' "$D/4c_day.log" | head -1 | cut -c1-150)"
echo "4 Exception: launch $(grep -c 'Exception:' "$D/4a_launch.log") probe $(grep -c 'Exception:' "$D/4b_probe.log") day $(grep -c 'Exception:' "$D/4c_day.log")"
bash "$PB" --check-lines "$D/build.out" "$D/4a_launch.log" "$D/4b_probe.log" "$D/4c_day.log" 2>&1 | tail -2
f1=$(fsha); echo "after: folder $f1 $([ "$f0" = "$f1" ] && echo SAME || echo CHANGED) | players $(players | wc -l)"
