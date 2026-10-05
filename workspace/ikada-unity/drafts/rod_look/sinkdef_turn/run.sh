#!/bin/bash
# §7.50 the sinking stance by default (worker3; ROD_REST_A_W3.md §7.50). Tree = ikada-unity-track3 track3/sink-stance-default.
# Under boss1's gate and LOCK only. 1) two editor control shots (shoot.sh), 2) the full regress (worker2's tools/regress_all.sh).
set -u
T=$HOME/Documents/ikada-unity-track3; D=$(cd "$(dirname "$0")" && pwd)
shot() { local name=$1; shift
  echo "== $name: $*"; ( cd "$T" && env SHOTS="$D" "$@" tools/shoot.sh 06S "$name" sans on ) > "$D/$name.out" 2>&1; echo "   rc=$? $(tail -1 "$D/$name.out")"; }
shot P1_default_06S   IKADA_ROD_SINK_DEG=
shot E1_sinkdeg40_06S IKADA_ROD_SINK_DEG=40
echo "== regress"; ( cd "$T" && tools/regress_all.sh ) > "$D/regress.out" 2>&1; echo "   rc=$? $(grep -m1 -E 'RESULT' "$D/regress.out")"
