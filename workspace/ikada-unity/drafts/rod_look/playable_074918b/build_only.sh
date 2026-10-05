#!/bin/bash
# 段 (4) build only (worker3, boss1 07:10: batchmode build GO, the player steps 4a-4c / 4e wait for PRESIDENT). playable_build.sh's steps 0-3
# by hand (its --apply goes on to step 4): preconditions, BuildPerf on master 074918b, the copy without the DoNotShip folder, diff -rq, measures.
set -u
SHA=074918b073c8767e40d80ef04460d4a054722f56; WT=$HOME/Documents/ikada-unity; OUT=$HOME/Documents/ikada-play/074918b; D=$(cd "$(dirname "$0")" && pwd)
stop(){ echo "STOP: $*"; exit 1; }
cd "$WT" || exit 1
[ "$(git rev-parse HEAD)" = "$SHA" ] && [ "$(git rev-parse master)" = "$SHA" ] || stop "HEAD / master != $SHA"
[ "$(git status --porcelain | wc -l)" = 0 ] || stop "$WT not clean"
[ -e "$OUT" ] && stop "$OUT exists already"
[ "$(df -B1 --output=avail / | tail -1)" -gt $((12*1024*1024*1024)) ] || stop "less than 12 GB free"
for p in /proc/[0-9]*; do e=$(readlink $p/exe 2>/dev/null); case "$e" in *Editor/Unity|*Ikada.x86_64) stop "running: $e";; esac; done
echo "0 ok: master $SHA, pin $(grep -o '#[0-9a-f]*' Packages/manifest.json | head -1), $OUT free, no Unity / player"
s=$(date +%s); tools/unity-batch.sh exec Ikada.EditorTools.BuildScript.BuildPerf > "$D/build.out" 2>&1; rc=$?
blog=$(grep -o 'log=[^ ]*' "$D/build.out" | tail -1 | cut -d= -f2); echo "2 build rc=$rc wall $(( $(date +%s) - s )) s log $blog"
grep -q "result=Succeeded errors=0" "$blog" || stop "no result=Succeeded errors=0"; grep -q "check_scene_embeds exit=0" "$blog" || stop "embeds not 0"
[ "$(grep -c 'error CS' "$blog")" = 0 ] || stop "error CS"; echo "2 ok: $(grep -o 'result=Succeeded.*' "$blog" | tail -1 | cut -c1-120)"
[ "$(git status --porcelain | wc -l)" = 0 ] || stop "tree not clean after the build"
mkdir -p "$(dirname "$OUT")"; cp -a Builds/Linux "$OUT" || stop "copy failed"; rm -rf "$OUT"/*_BurstDebugInformation_DoNotShip
[ -z "$(find "$OUT" -maxdepth 1 -name '*_DoNotShip')" ] || stop "DoNotShip still in $OUT"
for e in Builds/Linux/* Builds/Linux/.[!.]*; do [ -e "$e" ] || continue; case "${e##*/}" in *_BurstDebugInformation_DoNotShip) continue;; esac
  diff -rq "$e" "$OUT/${e##*/}" > /dev/null 2>&1 || stop "diff -rq not empty at ${e##*/}"; done
n=$(find "$OUT" -type f | wc -l); b=$(find "$OUT" -type f -printf '%s\n' | awk '{s+=$1} END {print s}')
fs=$(cd "$OUT" && find . -type f -print0 | sort -z | xargs -0 sha256sum | sha256sum | cut -c1-64)
echo "3 $OUT: $n files, $b bytes, folder sha256 $fs, Ikada.x86_64 sha256 $(sha256sum "$OUT/Ikada.x86_64" | cut -c1-64)"
echo "3 vs 0b53e4a: files $(find $HOME/Documents/ikada-play/0b53e4a -type f | wc -l), bytes $(find $HOME/Documents/ikada-play/0b53e4a -type f -printf '%s\n' | awk '{s+=$1} END {print s}')"
