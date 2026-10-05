#!/bin/bash
# 段 (4) 4e (worker3, PRESIDENT 07:1x): the handed-over player, mock 06S serif, vs regress 09330dd_065232's player 06S_B_serif. Writes NOTHING
# inside the handed-over dir (the shot and the log go to this dir by absolute path - 0b53e4a's relative-path mistake). Gate and LOCK only.
set -u
OUT=$HOME/Documents/ikada-play/074918b; D=$(cd "$(dirname "$0")" && pwd)
REF=/home/ken/Documents/Claude-Code-Communication/workspace/ikada-unity/shots/player/09330dd_065741/06S_B_serif.png
[ -x "$OUT/Ikada.x86_64" ] || { echo "no player at $OUT - stop"; exit 1; }
before=$(cd "$OUT" && find . -type f -print0 | sort -z | xargs -0 sha256sum | sha256sum | cut -c1-64)
timeout -k 15 60 "$OUT/Ikada.x86_64" -screen-width 1920 -screen-height 1080 -screen-fullscreen 0 -ikadaMock -logFile "$D/4e_06S_serif.log" \
  -ikadaScreen 06S -ikadaSmallFont serif -ikadaShot "$D/4e_06S_B_serif.png" -ikadaWaterT 10 -ikadaTipSettle >/dev/null 2>&1; echo "4e rc=$? Exception: $(grep -c 'Exception:' "$D/4e_06S_serif.log")"
after=$(cd "$OUT" && find . -type f -print0 | sort -z | xargs -0 sha256sum | sha256sum | cut -c1-64)
echo "4e folder sha before $before after $after $([ "$before" = "$after" ] && echo SAME || echo CHANGED)"
python3 $HOME/Documents/ikada-unity/tools/compare_outside_water.py "$REF" "$D/4e_06S_B_serif.png" --top 0 --bottom 0 | tail -3
