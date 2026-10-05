#!/bin/bash
# §7.49 c206 / c207 shots (worker3; ROD_REST_A_W3.md §7.49). Editor shots only, one at a time (shoot.sh), tree = ikada-unity-track3
# track3/stance-shots. Under boss1's gate and LOCK only. Output: this dir, <name>.png + <name>.out (shoot.sh's stdout).
set -u
T=$HOME/Documents/ikada-unity-track3; D=$(cd "$(dirname "$0")" && pwd)
export SHOTS=$D
S309="IKADA_ROD_SINK_DEG=25.9 IKADA_ROD_SINK_BUTT_UP_M=0.65 IKADA_ROD_SINK_BUTT_FWD_M=1.39"
S150="IKADA_ROD_LENGTH_M=1.5 IKADA_ROD_SINK_DEG=75 IKADA_ROD_SINK_BUTT_UP_M=0.75 IKADA_ROD_SINK_BUTT_FWD_M=2.373"
shot() { local name=$1 id=$2 hud=$3; shift 3
  echo "== $name: $* $id hud=$hud"
  ( cd "$T" && env "$@" tools/shoot.sh "$id" "$name" sans "$hud" ) > "$D/$name.out" 2>&1; echo "   rc=$? $(tail -1 "$D/$name.out")"; }
shot L309_sink       06S on  $S309
shot L309_sink_side  06S off $S309 IKADA_SHOT_ROD_SIDE=1
shot L150_sink       06S on  $S150
shot L150_sink_side  06S off $S150 IKADA_SHOT_ROD_SIDE=1
shot L309_hand       06H on  IKADA_ROD_LENGTH_M=
shot L150_hand       06H on  IKADA_ROD_LENGTH_M=1.5
shot L309_fight      08  on  IKADA_ROD_LENGTH_M=
shot L150_fight      08  on  IKADA_ROD_LENGTH_M=1.5
shot L150_win_stance      06S on $S150 IKADA_SHOT_TIP_STANCE=1
shot L150_win_now_bite    06S on $S150 IKADA_TIP_T=1.0
shot L150_win_stance_bite 06S on $S150 IKADA_SHOT_TIP_STANCE=1 IKADA_TIP_T=1.0
