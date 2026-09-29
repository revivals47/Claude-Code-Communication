#!/bin/bash
# lock_trial_player.sh - ONE player live run while the screen is locked (PRESIDENT 02:2x, boss1 02:23; worker3). The repo's tools are
# not touched: lock_guard.sh stops every tools/*.sh that starts Unity or the player, so this script uses COPIES without it, in the
# form of worker1's unity_direct.sh (disk_guard, flock and the log place kept).
#   1. gates: Unity 0, player 0, Runner.Worker 0, dotnet (not VBCSCompiler) 0, track3 porcelain 0; LockedHint / IdleHint printed.
#   2. track3 detached at master 5296d34 (its tree = 84ead9a = step 2's regressed tree; checked, else STOP).
#   3. build = regress_all.sh:121-134 by hand: Builds/Linux moved aside, Unity -batchmode ... BuildScript.BuildPerf, then the same
#      PASS conditions (rc 0, check_scene_embeds exit=0, result=Succeeded, error CS 0, prebake_table_check, species_chars_check, the
#      player exists) + porcelain after the build.
#   4. live = a copy of tools/live_regress.sh with ONLY its lock_guard line removed and HERE fixed to track3/tools, LIVE_SEEDS=20260925,
#      LIVE_BASE_20260925 = regress_all.sh:69's default (ae3b5c4_s20260925_231126): pictures 0 px, logic sequence, sound 5b as usual.
#      Its seed-1 positive control has no seed-1 run here -> "FAIL control" is expected and printed as such (not a verdict on 20260925).
#   Stop rule (PRESIDENT): any difference for 20260925 (black / missing / sequence) -> keep that run, run nothing more.
# usage: lock_trial_player.sh <out dir>
set -u
O=${1:?out}; mkdir -p "$O"; O=$(cd "$O" && pwd)
T3=/home/ken/Documents/ikada-unity-track3; MASTER=5296d3447270f7e155901a1f47d0d041dbdd826d
UNITY=/home/ken/Unity/Hub/Editor/6000.4.11f1/Editor/Unity
SHOTS=/home/ken/Documents/Claude-Code-Communication/workspace/ikada-unity/shots
say() { echo "[lt] $(date '+%F %T') $*" | tee -a "$O/turn.log"; }
stop() { say "STOP: $*"; exit 1; }
seat=$(loginctl | awk '/seat0/{print $1; exit}')
hint() { loginctl show-session "$seat" -p LockedHint -p IdleHint | tr '\n' ' '; }
source $T3/tools/disk_guard.sh
say "head $(hint)Unity=$(pgrep -xc Unity) player=$(pgrep -xc Ikada.x86_64) Runner.Worker=$(pgrep -xc Runner.Worker) dotnet=$(pgrep -xa dotnet | grep -vc VBCSCompiler) load=$(cut -d' ' -f1-3 /proc/loadavg)"
[ "$(pgrep -xc Unity)" = 0 ] || stop "Unity running"
[ "$(pgrep -xc Ikada.x86_64)" = 0 ] || stop "a player running"
[ "$(pgrep -xc Runner.Worker)" = 0 ] || stop "a CI job on this PC's runner"
[ "$(pgrep -xa dotnet | grep -vc VBCSCompiler)" = 0 ] || stop "dotnet running (worker2?)"
[ -z "$(git -C $T3 status --porcelain)" ] || stop "track3 not clean"
git -C $T3 switch -q --detach $MASTER || stop "cannot detach track3 at master"
[ "$(git -C $T3 rev-parse HEAD^{tree})" = "$(git -C ~/Documents/ikada-unity rev-parse 84ead9a^{tree})" ] || stop "master's tree is not step 2's regressed tree"
say "tree track3 = $(git -C $T3 rev-parse --short HEAD) (tree = 84ead9a's)"
# --- 3. build (regress_all.sh:121-134, without lock_guard) ---
cd $T3
STAMP=$(date +%H%M%S)
[ -e Builds/Linux ] && mv Builds/Linux "Builds/Linux_prev_$(git rev-parse --short HEAD)_$STAMP" && say "previous Builds/Linux moved aside"
tools/builds_prune.sh "$T3" > /dev/null 2>&1
mkdir -p Logs/batch; blog=$T3/Logs/batch/exec-$STAMP-locktrial.log
( exec 9>/tmp/ikada-unity-batch.lock; flock 9
  DISPLAY=${DISPLAY:-:1} "$UNITY" -batchmode -projectPath $T3 -logFile "$blog" -quit -executeMethod Ikada.EditorTools.BuildScript.BuildPerf )
rc=$?
fonts=$(python3 tools/prebake_table_check.py "$blog"); frc=$?
species=$(python3 tools/species_chars_check.py); src=$?
ncs=$(grep -c 'error CS' "$blog")
if [ $rc -eq 0 ] && grep -q "check_scene_embeds exit=0" "$blog" && grep -q "result=Succeeded" "$blog" && [ "$ncs" -eq 0 ] \
   && [ $frc -eq 0 ] && [ $src -eq 0 ] && [ -x Builds/Linux/Ikada.x86_64 ]; then b=PASS; else b=FAIL; fi
say "build $b rc=$rc CS=$ncs fonts_rc=$frc species_rc=$src log=$blog porcelain_after=$(git status --porcelain | wc -l) $(hint)"
[ $b = PASS ] || stop "build not PASS (kept: $blog)"
# --- 4. live, seed 20260925 (a copy of live_regress.sh, the lock_guard line removed, HERE = track3/tools) ---
LR=$O/live_regress_nolock.sh
sed -e '/source "\$(dirname "\$0")\/lock_guard.sh"/d' -e "s|^HERE=\$(cd \"\$(dirname \"\$0\")\" \&\& pwd); PROJECT=\$(cd \"\$HERE/..\" \&\& pwd)|HERE=$T3/tools; PROJECT=$T3|" \
  tools/live_regress.sh > "$LR"
[ "$(grep -c 'lock_guard' "$LR")" = 0 ] && grep -q "^HERE=$T3/tools; PROJECT=$T3" "$LR" || stop "the copy of live_regress.sh is not as intended"
say "copy: $(diff <(sed 's/[[:space:]]*$//' tools/live_regress.sh) <(sed 's/[[:space:]]*$//' "$LR") | grep -c '^[<>]') changed lines (the lock_guard line out, HERE fixed)"
export LIVE_BASE_20260925=$SHOTS/player_live/ae3b5c4_s20260925_231126
LIVE_SEEDS=20260925 LIVE_BASELINE=perseed bash "$LR" "$O/live" > "$O/live.out" 2>&1; lrc=$?
say "live rc=$lrc $(hint)"
grep -E '^\[live_regress\] (seed 20260925|PASS|FAIL)' "$O/live.out" | grep -v 'FAIL control' | while read -r l; do say "  $l"; done
grep -q '^\[live_regress\] FAIL control' "$O/live.out" && say "  (FAIL control = the seed-1 positive control has no seed-1 run in this one-seed trial: expected, not a verdict on 20260925)"
say "end Unity=$(pgrep -xc Unity) player=$(pgrep -xc Ikada.x86_64) porcelain=$(git status --porcelain | wc -l)"
