#!/bin/bash
# playable_build.sh - the client's playable build, step by step (worker3, boss1 03:39; drafts/stageC/PLAYABLE_BUILD_STEPS.md).
# DEFAULT = DRY RUN: every read-only check runs and prints its line; nothing is built, copied or launched. --apply does the
# steps (only under a boss1 LOCK, after PLAYABLE_NEXT.md §2's checks on this very sha). Any stop line = exit != 0, nothing after it.
# usage: playable_build.sh <master sha (40 hex)> <worktree> [--apply]
#        playable_build.sh --check-lines <build stdout> <launch log> <probe log> <day log> [<save dir A> <save dir B>]   (no Unity: steps 2 and 4's stop lines
#        run on logs that already exist - positive = a good run's logs, negative = a copy with one line broken; worker2 H6)
#        playable_build.sh --check-copy <src dir> <new dir>   (no Unity: step 3's copy alone - the DoNotShip folder left out, the rest copied)
#        playable_build.sh --check-players <dir>   (no Unity: the pids of players running from <dir>, by /proc/<pid>/exe - step 4.s window check)
# Second read fixes (worker2 06:4x, boss1 06:41; worker3's agreement to follow): H1 step 2 reads the Unity batch log that the
# build stdout names (log=), as regress_all.sh:126-133 - the two lines are not in the stdout; H2 the worktree is an argument
# (no default: not a worker's active tree) and its branch is put back at the end; H4 timeouts; H6 --check-lines; H7 the seat0
# session is looked up. H3 (boss1 06:47): exceptions counted as 'Exception:'. H5: the save dir compared as a table (path, mtime, sha256).
set -u
if [ "${1:-}" = "--check-lines" ] || [ "${1:-}" = "--check-copy" ] || [ "${1:-}" = "--check-players" ]; then CHECK=1; SHA=none; else CHECK=0
  SHA=${1:?usage: playable_build.sh <master sha> <worktree> [--apply]}; WT=${2:?usage: playable_build.sh <master sha> <worktree> [--apply] (H2: no default worktree)}
  APPLY=0; [ "${3:-}" = "--apply" ] && APPLY=1
fi
MAIN=/home/ken/Documents/ikada-unity
PLAY=/home/ken/Documents/ikada-play
OUT=$PLAY/${SHA:0:7}
CTRL=$PLAY/2cb67ab; CTRL_SHA=75dc972e69da4953b2abd12fbcef41befa5d02d999a7ac90a612913d5be2b71e   # c30_play_guide_one_day.md:10
LOG=${LOG:-/tmp/playable_build_$([ $CHECK = 1 ] && echo check || echo ${SHA:0:7})_$(date +%H%M%S).log}
say(){ echo "$(date +%H:%M:%S) $*" | tee -a "$LOG"; }
stop(){ say "STOP: $*"; exit 1; }
dirsha(){ (cd "$1" && find . -type f -print0 | sort -z | xargs -0 sha256sum | sha256sum | cut -c1-64); }

# step 3's copy (PRESIDENT 09:5x, boss1 09:45): Builds/Linux -> the dir handed over, WITHOUT Unity's Burst debug folder
# (<product>_BurstDebugInformation_DoNotShip - its name says do not ship; 52e33b5 and 7261648 carried it, ba3de36's was removed
# by hand 09:4x). diff -rq skips that one name; a DoNotShip folder left in the copy stops. $1 = Builds/Linux, $2 = the new dir.
copyout() {
  cp -a "$1" "$2" || stop "copy failed"
  rm -rf "$2"/*_BurstDebugInformation_DoNotShip
  [ -z "$(find "$2" -maxdepth 1 -name '*_DoNotShip')" ] || stop "a DoNotShip folder is still in $2"
  local e   # diff every top-level entry but the removed one (diff -x would skip that name at every depth - worker2 09:48 check (2))
  for e in "$1"/* "$1"/.[!.]*; do [ -e "$e" ] || continue; case "${e##*/}" in *_BurstDebugInformation_DoNotShip) continue;; esac
    diff -rq "$e" "$2/${e##*/}" >>"$LOG" 2>&1 || stop "diff -rq not empty at ${e##*/}"; done
}

# the players still up from a dir (boss1 02:00, PRESIDENT 02:0x: the window must be gone before PRESIDENT starts the build on the
# client's screen). By /proc/<pid>/exe, not by comm (Unity renames it) nor by the cmdline (a ./Ikada.x86_64 start from inside the
# dir has no path in it - tonight's client player). exe is absolute even for a relative start; " (deleted)" = the file was replaced.
# (cwd alone is not used: a shell sitting in the dir would count.) Prints the pids, one per line.
playersof() {
  local want p e; want=$(readlink -f "$1")/Ikada.x86_64
  for p in /proc/[0-9]*; do e=$(readlink "$p/exe" 2>/dev/null) || continue; [ "${e% (deleted)}" = "$want" ] && echo "${p#/proc/}"; done; return 0
}
nowin() { local l; l=$(playersof "$OUT" | tr '\n' ' '); [ -z "$l" ] || stop "a player from $OUT is still up ($1): pid $l"; say "no player from $OUT ($1)"; }
SEAT=$(loginctl | awk '/seat0/{print $1; exit}')   # H7: not a fixed number
# the stop lines of steps 2 and 4, one place (the --apply path and --check-lines both call them)
check2() {   # $1 = the build's stdout (tools/unity-batch.sh exec ... BuildPerf)
  local blog; blog=$(grep -o 'log=[^ ]*' "$1" | tail -1 | cut -d= -f2)   # H1: the Unity batch log it names
  [ -n "$blog" ] && [ -f "$blog" ] || stop "no Unity batch log named by log= in $1"
  grep -q "result=Succeeded errors=0" "$blog" || stop "no 'result=Succeeded errors=0' line in $blog"
  grep -q "check_scene_embeds exit=0" "$blog" || stop "scene embeds check not 0 in $blog"
  [ "$(grep -c 'error CS' "$blog")" = 0 ] || stop "error CS in $blog"
  say "2 build ok: $(grep -o 'result=Succeeded.*' "$blog" | tail -1 | cut -c1-160) (log $blog)"
}
# H5: the game's save dir = persistentDataPath/save (LiveHost.cs:164; persistentDataPath = ~/.config/unity3d/<companyName>/<productName>,
# ProjectSettings.asset: DefaultCompany / ikada-unity). A table of every file: path, mtime (ns), sha256 - an overwrite shows, not only a count.
SAVE=$HOME/.config/unity3d/DefaultCompany/ikada-unity/save
savesnap() { [ -d "$1" ] || { echo "(no dir)"; return; }; (cd "$1" && find . -type f | sort | while IFS= read -r f; do echo "$f $(stat -c %.9Y "$f") $(sha256sum < "$f" | cut -c1-64)"; done); }
savecmp() {  # $1 = the table before, $2 = the table after, $3 = what was compared (the dir(s), for the lines)
  [ "$1" = "$2" ] || { say "save table before: $(echo "$1" | tr '\n' ';')"; say "save table after:  $(echo "$2" | tr '\n' ';')"; stop "save files changed (a file was written, touched, added or removed: $3)"; }
  say "save dir unchanged ($3): $(echo "$2" | wc -l) line(s) ($(echo "$2" | head -1 | cut -c1-60))"
}
check4() {   # $1 launch log, $2 probe log, $3 day log
  grep -q "\[Live\] start api" "$1" || stop "no [Live] start line in the 25 s launch"
  [ "$(grep -c 'Exception:' "$1")" = 0 ] || stop "Exception: in the 25 s launch"   # H3: the player's exception lines (memory: count 'Exception:')
  grep -q "\[SessionProbe\] RESULT ok=True" "$2" || stop "SessionProbe not ok"
  grep -q "\[Live\] RESULT ok=True" "$3" || stop "one AutoPilot day: no RESULT ok=True"
  # ok=True also comes from the time cap (LiveHost.cs:347 Finish(0) at TimeS >= quitAfterS): the day ended only if simS < DAY_S
  local sims; sims=$(grep -o '\[Live\] RESULT ok=True .*simS=[0-9.]*' "$3" | grep -o 'simS=[0-9.]*$' | cut -d= -f2)
  awk -v s="${sims:-x}" -v c="${DAY_S:-9200}" 'BEGIN { exit !(s ~ /^[0-9.]+$/ && s + 0 < c + 0) }' || stop "one AutoPilot day: simS=${sims:-none} not below the cap ${DAY_S:-9200} (stopped by the cap, not by the day)"
  grep -q '\[Speakers\] logic names=[0-9]* in table=[0-9]* missing=\[\]' "$1" || stop "no [Speakers] line with missing=[] (UiTheme.CheckSpeakers)"
  [ "$(grep -c 'Exception:' "$3")" = 0 ] || stop "Exception: in the AutoPilot day"   # H3
  }
if [ "$1" = "--check-players" ]; then   # the window check alone (no Unity): --check-players <dir> = the pids of players from it, 0 lines = none
  l=$(playersof "${2:?dir}"); say "CHECK-PLAYERS $2: $(echo -n "$l" | grep -c .) player(s) [$(echo "$l" | tr '\n' ' ')]"; exit 0
fi
if [ "$1" = "--check-copy" ]; then   # step 3's copy on a given src (no Unity): --check-copy <src dir> <new dir (must not exist)>
  [ -e "${3:?new dir}" ] && stop "$3 exists"; copyout "${2:?src dir}" "$3"
  say "CHECK-COPY: $(find "$2" -type f | wc -l) files in, $(find "$3" -type f | wc -l) out, top-level DoNotShip in the copy: $(find "$3" -maxdepth 1 -name '*_DoNotShip' | wc -l), deeper: $(find "$3" -mindepth 2 -name '*_DoNotShip' | wc -l)"; exit 0
fi
if [ $CHECK = 1 ]; then
  say "CHECK-LINES (no Unity): build stdout ${2:?} | launch ${3:?} | probe ${4:?} | day ${5:?}"
  check2 "$2"; check4 "$3" "$4" "$5"
  if [ -n "${6:-}" ]; then savecmp "$(savesnap "$6")" "$(savesnap "${7:?a second save dir}")" "$6 vs $7"; fi   # H5 on two dirs (before / after copies)
  say "CHECK-LINES: steps 2 and 4 pass on these logs"; exit 0
fi
say "HEAD $(loginctl show-session "$SEAT" -p LockedHint -p IdleHint 2>/dev/null | tr '\n' ' ')| Runner.Worker $(pgrep -xc Runner.Worker) | load $(cut -d' ' -f1-3 /proc/loadavg) | df / $(df -B1 --output=avail / | tail -1) B | mode $([ $APPLY = 1 ] && echo APPLY || echo DRY-RUN)"
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
# 1. worktree at SHA (H2: its branch is put back on every exit after this line)
WT_BRANCH=$(git -C "$WT" branch --show-current); WT_HEAD=$(git -C "$WT" rev-parse HEAD)
trap 'if [ -n "$WT_BRANCH" ]; then git -C "$WT" switch -q "$WT_BRANCH"; else git -C "$WT" switch -q --detach "$WT_HEAD"; fi; say "worktree $WT back to ${WT_BRANCH:-$WT_HEAD}"' EXIT
git -C "$WT" switch --detach "$SHA" >>"$LOG" 2>&1 || stop "detach failed"
[ "$(git -C "$WT" rev-parse HEAD)" = "$SHA" ] || stop "HEAD != SHA"
# 2. build (release = BuildOptions.None, BuildScript.cs:188; BuildPerf is the only build entry)
( cd "$WT" && tools/unity-batch.sh exec Ikada.EditorTools.BuildScript.BuildPerf ) >>"$LOG.build" 2>&1 || stop "build failed (see $LOG.build)"
check2 "$LOG.build"
[ "$(git -C "$WT" status --porcelain | wc -l)" = 0 ] || stop "tree not clean after the build"
# 3. copy and measure
mkdir -p "$PLAY"; copyout "$WT/Builds/Linux" "$OUT"
n=$(find "$OUT" -type f | wc -l); b=$(find "$OUT" -type f -printf '%s\n' | awk '{s+=$1} END {print s}')
say "3 $OUT: $n files, $b bytes, folder sha256 $(dirsha "$OUT"), Ikada.x86_64 sha256 $(sha256sum "$OUT/Ikada.x86_64" | cut -c1-64)"
# 4. launch checks (the copied player; the save dir must not appear)
before=$(savesnap "$SAVE")   # H5
nowin "before 4"
# -k 15: a player that does not end on timeout's TERM is killed 15 s later (a TERM-ignoring child is otherwise waited for; worker2 02:00)
timeout -k 15 25 "$OUT/Ikada.x86_64" -screen-width 1920 -screen-height 1080 -screen-fullscreen 0 -logFile "$LOG.launch" >/dev/null 2>&1
nowin "after 4a"
timeout -k 15 120 "$OUT/Ikada.x86_64" -ikadaSessionProbe -logFile "$LOG.probe" >/dev/null 2>&1   # H4
nowin "after 4b"
timeout -k 15 900 "$OUT/Ikada.x86_64" -screen-width 1920 -screen-height 1080 -screen-fullscreen 0 -ikadaLive -ikadaLockstep -ikadaLiveAutoPilot \
  -ikadaLiveSpeed 300 -ikadaSavePath none -ikadaLiveSeed 1 -ikadaLiveQuitAfterS ${DAY_S:-9200} -logFile "$LOG.day" >/dev/null 2>&1   # H4
nowin "after 4c"
check4 "$LOG.launch" "$LOG.probe" "$LOG.day"
savecmp "$before" "$(savesnap "$SAVE")" "$SAVE before vs after"   # H5
say "4 launch: $(grep -o '\[Live\] start api[^ ]* [^ ]*' "$LOG.launch" | head -1) | $(grep -o '\[SessionProbe\] RESULT.*' "$LOG.probe" | head -1) | $(grep -o '\[Live\] RESULT.*' "$LOG.day" | head -1 | cut -c1-160)"
say "DONE $OUT"
