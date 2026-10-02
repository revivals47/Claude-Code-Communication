#!/bin/bash
# #42 cells, one process each; stop with: touch $S/STOP (checked between cells)
export PATH=$HOME/.dotnet:$PATH DOTNET_ROOT=$HOME/.dotnet
S=/tmp/claude-1000/-home-ken-Documents-Claude-Code-Communication/7c5144a7-e556-4299-98c8-a56dfe00444d/scratchpad/audit41
OUT=$HOME/Documents/Claude-Code-Communication/workspace/ikada-unity/drafts/stageD/audit41/rope100.txt
cd $S/probe41bin
for season in spring July; do for skill in Good Slack Locked; do for d in none 1 2 4; do
  [ -f $S/STOP ] && { echo "stopped before $skill $season $d" >> $OUT; exit 0; }
  grep -q "^rope $skill $season d=$d " $OUT 2>/dev/null && continue   # resumable
  IKADA_LIBIKD=$S/build/libikd.so timeout 600 nice -n 10 dotnet Probe41.dll rope 100 $skill $season $d >> $OUT 2>&1
done; done; done
echo "done $(date +%T)" >> $OUT
