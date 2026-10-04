#!/bin/bash
# 板を広げる Unity の番（worker3, LOCK 15:11, 4cd7a74, PIN_A8CCA9E_W3.md）: Roslyn (+positive) -> bake (font commit: 標) -> regress REGRESS_LIVE=1
# -> player: A practice free + settings shots + 07, B practice winter+break+stroke + settings shots, C G 12/10 seed 1 J -> live swap dry + sheet, STOP.
# Copied from stage5_turn2/run.sh (worker2). tree = ~/Documents/ikada-unity-track3 (track3/logic-a8cca9e).
set -u
O=$(cd "$(dirname "$0")" && pwd); T=/home/ken/Documents/ikada-unity-track3; W=/home/ken/Documents/Claude-Code-Communication/workspace/ikada-unity
say() { echo "[ta8] $(date '+%F %T') $*" | tee -a $O/turn.log; }
stop() { say "STOP: $*"; say "porcelain: [$(git -C $T status --porcelain | tr '\n' ';')]"; exit 5; }
dfchk() { local g=$(df -BG --output=avail / | tail -1 | tr -dc 0-9); say "df ${g} GB ($1)"; [ "$g" -ge 12 ] || stop "df under 12 GB before $1"; }
ubT() { local m=$1; shift
  ( source $T/tools/disk_guard.sh; local log=$T/Logs/batch/exec-$(date +%H%M%S)-ta8.log; mkdir -p $T/Logs/batch
    exec 9>/tmp/ikada-unity-batch.lock; flock 9
    DISPLAY=${DISPLAY:-:1} /home/ken/Unity/Hub/Editor/6000.4.11f1/Editor/Unity -batchmode -projectPath $T -logFile $log -quit -executeMethod "$m" "$@"
    local rc=$?; echo "[ubT] $m rc=$rc log=$log exiting_ok=$(grep -c 'Exiting batchmode successfully' $log) exceptions=$(grep -c 'Exception:' $log) cs=$(grep -c 'error CS' $log)"; return $rc ) }
say "head unity=$(pgrep -fc '[E]ditor/Unity') dotnet=$(pgrep -xc dotnet) tree=$(git -C $T rev-parse --short HEAD) porcelain $(git -C $T status --porcelain | wc -l) manifest $(grep -o '#[0-9a-f]\{7\}' $T/Packages/manifest.json)"
[ -z "$(git -C $T status --porcelain)" ] || stop "dirty at the start"
H=$(git -C $T rev-parse --short HEAD)
if [ "${SKIP_TO:-}" != regress ] && [ "${SKIP_TO:-}" != players ]; then
dfchk roslyn
bash $W/drafts/stageC/bundle_compile8.sh $H > $O/bc8.out 2>&1; say "roslyn: $(grep -E 'errors=' $O/bc8.out | tr '\n' ' ' | cut -c1-300)"
grep -q "editor rc=0 errors=0" $O/bc8.out && grep -q "game rc=0 errors=0" $O/bc8.out || { grep 'error CS' $O/bc8.out | head -5 | tee -a $O/turn.log; stop "Roslyn not 0 errors"; }
bash $W/drafts/stageC/bundle_compile8.sh $H --inject-error > $O/bc8_inject.out 2>&1; say "roslyn positive: $(grep -E 'game rc' $O/bc8_inject.out | cut -c1-120)"
[ -e $T/Builds/Linux ] && mv $T/Builds/Linux $T/Builds/Linux_prev_$(date +%H%M%S)
ubT Ikada.EditorTools.BuildScript.BuildPerf > $O/bake.out 2>&1; say "bake: $(tail -1 $O/bake.out)"; grep -q "exiting_ok=1" $O/bake.out || stop "BuildPerf failed"
CH=$(git -C $T status --porcelain); say "after the bake: [$(echo "$CH" | tr '\n' ';')]"
echo "$CH" | grep -v "Assets/Resources/Fonts/" | grep -q . && stop "the bake changed files other than the fonts"
if [ -n "$CH" ]; then ADDED=$(git -C $T diff -U0 -- Assets/Resources/Fonts | grep -oE "^\+ +m_Unicode: [0-9]+" | awk '{print $3}' | sort -un | python3 -c "import sys; print(''.join(chr(int(x)) for x in sys.stdin.read().split()))")
  say "chars added: [$ADDED]"; git -C $T add -A Assets/Resources/Fonts && git -C $T commit -q -m "font atlases after the build's prebake (widen turn, worker3): added [$ADDED]

Co-Authored-By: Claude Opus 5.5 (1M context) <noreply@anthropic.com>" && say "font commit $(git -C $T rev-parse --short HEAD)"; fi
[ -z "$(git -C $T status --porcelain)" ] || stop "dirty after the font commit"
fi
if [ "${SKIP_TO:-}" != players ]; then
dfchk regress
(cd $T && REGRESS_LIVE=1 tools/regress_all.sh) > $O/regress.out 2>&1; RRC=$?; say "regress rc=$RRC"
grep -E "^RESULT|^live |^baseline |^input_test |^player_shots |^editor_shots |^git_clean " $O/regress.out | cut -c1-230 | tee -a $O/turn.log
[ -z "$(git -C $T status --porcelain)" ] || stop "dirty after regress"
echo $RRC > $O/regress.rc
fi
P=$T/Builds/Linux/Ikada.x86_64; [ -x $P ] || stop "no player"
run() { local name=$1 cap=$2; shift 2; mkdir -p $O/$name
  timeout -k 15 $cap "$@" >/dev/null 2>&1; local rc=$?
  say "$name rc=$rc pngs=[$(ls $O/$name 2>/dev/null | tr '\n' ' ')] exc=$(grep -c 'Exception:' $O/$name.log)"; }
base() { echo $P -screen-width 1920 -screen-height 1080 -screen-fullscreen 0 -ikadaLive -ikadaLiveAutoPilot -ikadaLockstep -ikadaLiveSpeed 300 -ikadaSavePath none -ikadaWaterT 10 -ikadaTipSettle -ikadaLiveShot $O/$1 -logFile $O/$1.log; }
dfchk players
IKADA_PRACTICE_SETTINGS_SHOT=1 run A_free 600 $(base A_free) -ikadaLivePractice free -ikadaLiveSeed 20260925 -ikadaLiveShotScreens 07 -ikadaLiveQuitAfterS 1200
grep -h "\[Practice\] shot\|\[Practice\] settings" $O/A_free.log | cut -c1-260 | sed 's/^/[ta8] A log: /' | tee -a $O/turn.log
IKADA_PRACTICE_SETTINGS_SHOT=1 run B_winter 1500 $(base B_winter) -ikadaLivePractice winter+break+stroke -ikadaLiveSeed 20260925 -ikadaLiveQuitAfterS 14400
grep -h "\[Practice\] shot\|\[Practice\] settings" $O/B_winter.log | cut -c1-260 | sed 's/^/[ta8] B log: /' | tee -a $O/turn.log
say "players left: $(for p in /proc/[0-9]*; do [ "$(readlink $p/exe 2>/dev/null)" = "$P" ] && echo ${p#/proc/}; done | wc -l)"
RRC=$(cat $O/regress.rc 2>/dev/null || echo ?)
if [ "$RRC" != 0 ]; then
  R=$(ls -td $T/Logs/regress/*/ | head -1); N=170; while ls $W/drafts/user_review | grep -q "^c$N"; do N=$((N+1)); done
  python3 $W/drafts/stageD/live_rebase5.py ${R%/} --project $T --tag pre-widen_ --reason "the wider pause panel and the two-line 07 Note (PRESIDENT 15:1x)" --table $O/SWAP_TABLE.md --sheet $W/drafts/user_review/c${N}_widen_swap_sheet.png > $O/rebase_dry.out 2>&1
  say "swap dry: $(grep -E 'counts|sheet' $O/rebase_dry.out | tr '\n' ' ' | cut -c1-260) = STOP (no apply here)"
fi
say "end porcelain $(git -C $T status --porcelain | wc -l) head $(git -C $T rev-parse --short HEAD)"; say "done"
