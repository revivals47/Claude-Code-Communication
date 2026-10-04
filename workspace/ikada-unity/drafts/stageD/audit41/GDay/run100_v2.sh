#!/bin/bash
# v2 (GDay all DayLogs + per-day rows; use the 12/10 rows, boss1 12:38): 12/10 x seeds 1-100, base / koaji, 10 seeds per process; stop: touch $S/STOP_GDAY (checked between chunks); resumable by output lines
export PATH=$HOME/.dotnet:$PATH DOTNET_ROOT=$HOME/.dotnet
S=/tmp/claude-1000/-home-ken-Documents-Claude-Code-Communication/7c5144a7-e556-4299-98c8-a56dfe00444d/scratchpad/audit41
O=$HOME/Documents/Claude-Code-Communication/workspace/ikada-unity/drafts/stageD/audit41/GDay/gday_12_10_x100_v2.txt
for k in $(seq 0 9); do for lab in base koaji; do
  [ -f $S/STOP_GDAY ] && { echo "stopped before $lab chunk $k" >> $O; exit 0; }
  grep -q "^$lab $((k*10+10)):12-10:" $O 2>/dev/null && continue
  L=$(python3 -c "print(','.join(f'{s}:12-10' for s in range($k*10+1,$k*10+11)))")
  timeout 1200 nice -n 10 dotnet $S/gday2_$lab/GDay.dll $lab $L >> $O 2>&1
done; done
echo "done $(date +%T)" >> $O
