#!/bin/bash
# §7.55 (worker3, PRESIDENT 06:1x GO): the regress with the new known point, then the PIN only if the RESULT is PASS. Gate and LOCK only.
set -u
T=$HOME/Documents/ikada-unity-track3; D=$(cd "$(dirname "$0")" && pwd); MOCK=/home/ken/Documents/Claude-Code-Communication/workspace/ikada-unity/shots/player/a9106ea_234105
cd "$T" || exit 1
[ "$(git rev-parse --short HEAD)" = 9061767 ] && [ "$(git status --porcelain | wc -l)" = 0 ] || { echo "tree is not a clean 9061767 - stop"; exit 1; }
echo "== regress"; tools/regress_all.sh > "$D/known_regress.out" 2>&1; echo "   rc=$? $(grep -m1 '^RESULT' "$D/known_regress.out")"
RID=$(cd Logs/regress && ls -dt 9061767_* | head -1); echo "   regress id $RID"; [ -n "$RID" ] || exit 1
echo "   known (697,726) lines: $(grep -h '(697,726)' Logs/regress/$RID/live/seed_*/live_08.cmp 2>/dev/null | tee "$D/known_697_726_lines.out" | wc -l)"
grep -q "^RESULT PASS" "Logs/regress/$RID/SUMMARY.txt" || { echo "RESULT not PASS - no PIN, stop"; exit 1; }
echo "== PIN"; tools/baseline_pin.sh "$MOCK" "$RID" "$T"; echo "   rc=$?"; cat "$MOCK/PIN"
