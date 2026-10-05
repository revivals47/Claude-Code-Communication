#!/bin/bash
# worker3's Unity turn (ROD_REST_A_W3.md §7.46, PRESIDENT 09:7x): track3/side-shot d95bd5a (= the build-order fix bad4d3c + probe / side view,
# sink pose removed): Roslyn -> regress_all once (16/16 predicted, mock 26 + live 0 px) -> the fix's own check: the editor hand / sinking
# [TipJoint] (gap 0 predicted, was -0.0333 side) + 08 fight (the chord step only). No apply, no edit / commit.
set -u
O=$(cd "$(dirname "$0")" && pwd); T=/home/ken/Documents/ikada-unity-track3; W=/home/ken/Documents/Claude-Code-Communication/workspace/ikada-unity
say() { echo "[tf] $(date '+%F %T') $*" | tee -a $O/turn.log; }
stop() { say "STOP: $*"; exit 5; }
[ "$(git -C $T rev-parse --short HEAD)" = d95bd5a ] && [ -z "$(git -C $T status --porcelain)" ] || stop "head / dirty"
( source $T/tools/lock_guard.sh ) 2>>$O/turn.log || stop "screen locked"
bash $W/drafts/stageC/bundle_compile8.sh d95bd5a > $O/bc8.out 2>&1; say "roslyn: $(grep -E 'errors=' $O/bc8.out | tr '\n' ' ' | cut -c1-260)"
grep -q "editor rc=0 errors=0" $O/bc8.out && grep -q "game rc=0 errors=0" $O/bc8.out || stop "Roslyn not 0"
(cd $T && REGRESS_LIVE=1 tools/regress_all.sh) > $O/regress.out 2>&1; say "regress rc=$? dir $(ls -td $T/Logs/regress/*/ | head -1)"
grep -E "^RESULT|^[a-z_]+ +(PASS|FAIL|SKIPPED|NOT RUN)" $O/regress.out | cut -c1-260 | sed "s/^/[r] /" | tee -a $O/turn.log
shot() { local id=$1 name=$2; shift 2; ( cd $T && env IKADA_WATER_T=10.0 SHOTS=$O "$@" tools/shoot.sh $id $name sans on ) > $O/$name.out 2>&1
  say "$name rc=$? | $(grep -h '\[TipJoint\]' $(grep -o 'log=[^ ]*' $O/$name.out | head -1 | cut -d= -f2) 2>/dev/null | head -1 | grep -o 'side(+right) [-0-9.]*\|up [-0-9.]* m\|angle [0-9.]*\|px mainB ([0-9.,]*) tipA ([0-9.,]*)' | tr '\n' ' ')"; }
shot 06 TF_hand_06 IKADA_ROD_SHOT_HOLD=hand IKADA_SHOT_TIP_JOINT=1
shot 06 TF_sinking_06 IKADA_ROD_SHOT_HOLD=sinking IKADA_SHOT_TIP_JOINT=1
shot 08 TF_fight_08 IKADA_SHOT_TIP_JOINT=1
say "players left: $(for p in /proc/[0-9]*; do case "$(readlink $p/exe 2>/dev/null)" in *Ikada.x86_64) echo x;; esac; done | wc -l); end porcelain $(git -C $T status --porcelain | wc -l) head $(git -C $T rev-parse --short HEAD)"
say done
