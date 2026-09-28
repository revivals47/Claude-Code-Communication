#!/bin/bash
# playable_build.sh - the client's playable build, step by step (worker3, boss1 03:39; drafts/stageC/PLAYABLE_BUILD_STEPS.md).
# DEFAULT = DRY RUN: every read-only check runs and prints its line; nothing is built, copied or launched. --apply does the
# steps (only under a boss1 LOCK, after PLAYABLE_NEXT.md §2's checks on this very sha). Any stop line = exit != 0, nothing after it.
# usage: playable_build.sh <master sha (40 hex)> [--apply]
set -u
SHA=${1:?usage: playable_build.sh <master sha> [--apply]}; APPLY=0; [ "${2:-}" = "--apply" ] && APPLY=1
WT=${WT:-/home/ken/Documents/ikada-unity-track3}          # a track worktree, detached to SHA for the build (the precedent: track1)
MAIN=/home/ken/Documents/ikada-unity
PLAY=/home/ken/Documents/ikada-play
OUT=$PLAY/${SHA:0:7}
CTRL=$PLAY/2cb67ab; CTRL_SHA=75dc972e69da4953b2abd12fbcef41befa5d02d999a7ac90a612913d5be2b71e   # c30_play_guide_one_day.md:10
LOG=${LOG:-/tmp/playable_build_${SHA:0:7}_$(date +%H%M%S).log}
say(){ echo "$(date +%H:%M:%S) $*" | tee -a "$LOG"; }
stop(){ say "STOP: $*"; exit 1; }
dirsha(){ (cd "$1" && find . -type f -print0 | sort -z | xargs -0 sha256sum | sha256sum | cut -c1-64); }

say "HEAD $(loginctl show-session 2 -p LockedHint -p IdleHint 2>/dev/null | tr '\n' ' ')| Runner.Worker $(pgrep -xc Runner.Worker) | load $(cut -d' ' -f1-3 /proc/loadavg) | df / $(df -B1 --output=avail / | tail -1) B | mode $([ $APPLY = 1 ] && echo APPLY || echo DRY-RUN)"
# 0. preconditions (read only)
[[ $SHA =~ ^[0-9a-f]{40}$ ]] || stop "SHA must be 40 hex"
[ "$(git -C "$MAIN" rev-parse master)" = "$SHA" ] || stop "master is $(git -C "$MAIN" rev-parse master), not $SHA"
pin=$(git -C "$MAIN" show "$SHA":Packages/manifest.json | grep -o 'com.ikada.sim[^,]*#[0-9a-f]*' | grep -o '#[0-9a-f]*$'); say "0 master = $SHA, pin com.ikada.sim $pin"
[ -e "$OUT" ] && stop "$OUT exists already (never overwrite a handed-over build)"
[ "$(pgrep -xc Unity)" = 0 ] || stop "a Unity is running"
[ "$(git -C "$WT" status --porcelain | wc -l)" = 0 ] || stop "$WT not clean"
[ "$(df -B1 --output=avail / | tail -1)" -gt $((12*1024*1024*1024)) ] || stop "less than 12 GB free (disk_guard 10 + the copy)"
c=$(dirsha "$CTRL"); [ "$c" = "$CTRL_SHA" ] && say "0 positive control: folder sha of $CTRL = $CTRL_SHA (as recorded)" || stop "folder-sha method: $CTRL gives $c, recorded $CTRL_SHA"
if [ $APPLY = 0 ]; then
  say "DRY-RUN: would 1) detach $WT to $SHA  2) tools/unity-batch.sh exec Ikada.EditorTools.BuildScript.BuildPerf  3) cp -a Builds/Linux $OUT + diff -rq + count/bytes/folder sha  4) launch checks (25 s HostInput, SessionProbe, one AutoPilot day)"
  exit 0
fi
# 1. worktree at SHA
git -C "$WT" switch --detach "$SHA" >>"$LOG" 2>&1 || stop "detach failed"
[ "$(git -C "$WT" rev-parse HEAD)" = "$SHA" ] || stop "HEAD != SHA"
# 2. build (release = BuildOptions.None, BuildScript.cs:188; BuildPerf is the only build entry)
( cd "$WT" && tools/unity-batch.sh exec Ikada.EditorTools.BuildScript.BuildPerf ) >>"$LOG.build" 2>&1 || stop "build failed (see $LOG.build)"
grep -q "result=Succeeded errors=0" "$LOG.build" || stop "no 'result=Succeeded errors=0' line"
grep -q "check_scene_embeds exit=0" "$LOG.build" || stop "scene embeds check not 0"
[ "$(git -C "$WT" status --porcelain | wc -l)" = 0 ] || stop "tree not clean after the build"
say "2 build ok: $(grep -o 'result=Succeeded.*' "$LOG.build" | tail -1 | cut -c1-160)"
# 3. copy and measure
mkdir -p "$PLAY"; cp -a "$WT/Builds/Linux" "$OUT" || stop "copy failed"
diff -rq "$WT/Builds/Linux" "$OUT" >>"$LOG" 2>&1 || stop "diff -rq not empty"
n=$(find "$OUT" -type f | wc -l); b=$(find "$OUT" -type f -printf '%s\n' | awk '{s+=$1} END {print s}')
say "3 $OUT: $n files, $b bytes, folder sha256 $(dirsha "$OUT"), Ikada.x86_64 sha256 $(sha256sum "$OUT/Ikada.x86_64" | cut -c1-64)"
# 4. launch checks (the copied player; the save dir must not appear)
SAVE=$HOME/.config/unity3d; before=$(find "$SAVE" -path '*save*' 2>/dev/null | wc -l)
timeout 25 "$OUT/Ikada.x86_64" -screen-width 1920 -screen-height 1080 -screen-fullscreen 0 -logFile "$LOG.launch" >/dev/null 2>&1
grep -q "\[Live\] start api" "$LOG.launch" || stop "no [Live] start line in the 25 s launch"
[ "$(grep -c 'Exception' "$LOG.launch")" = 0 ] || stop "Exception in the 25 s launch"
"$OUT/Ikada.x86_64" -ikadaSessionProbe -logFile "$LOG.probe" >/dev/null 2>&1
grep -q "\[SessionProbe\] RESULT ok=True" "$LOG.probe" || stop "SessionProbe not ok"
"$OUT/Ikada.x86_64" -screen-width 1920 -screen-height 1080 -screen-fullscreen 0 -ikadaLive -ikadaLockstep -ikadaLiveAutoPilot \
  -ikadaLiveSpeed 300 -ikadaSavePath none -ikadaLiveSeed 1 -ikadaLiveQuitAfterS ${DAY_S:-9200} -logFile "$LOG.day" >/dev/null 2>&1
grep -q "\[Live\] RESULT ok=True" "$LOG.day" || stop "one AutoPilot day: no RESULT ok=True"
# ok=True also comes from the time cap (LiveHost.cs:347 Finish(0) at TimeS >= quitAfterS): the day ended only if simS < DAY_S
sims=$(grep -o '\[Live\] RESULT ok=True .*simS=[0-9.]*' "$LOG.day" | grep -o 'simS=[0-9.]*$' | cut -d= -f2)
awk -v s="${sims:-x}" -v c="${DAY_S:-9200}" 'BEGIN { exit !(s ~ /^[0-9.]+$/ && s + 0 < c + 0) }' || stop "one AutoPilot day: simS=${sims:-none} not below the cap ${DAY_S:-9200} (stopped by the cap, not by the day's Info page)"
grep -q '\[Speakers\] logic names=[0-9]* in table=[0-9]* missing=\[\]' "$LOG.launch" || stop "no [Speakers] line with missing=[] (UiTheme.CheckSpeakers)"
[ "$(grep -c 'Exception' "$LOG.day")" = 0 ] || stop "Exception in the AutoPilot day"
after=$(find "$SAVE" -path '*save*' 2>/dev/null | wc -l); [ "$before" = "$after" ] || stop "save files changed ($before -> $after)"
say "4 launch: $(grep -o '\[Live\] start api[^ ]* [^ ]*' "$LOG.launch" | head -1) | $(grep -o '\[SessionProbe\] RESULT.*' "$LOG.probe" | head -1) | $(grep -o '\[Live\] RESULT.*' "$LOG.day" | head -1 | cut -c1-160)"
say "DONE $OUT"
