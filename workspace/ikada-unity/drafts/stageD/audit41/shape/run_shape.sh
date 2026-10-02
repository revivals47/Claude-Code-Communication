#!/bin/bash
# #42 shape fix A/B (worker3): stages with a STOP file between steps; resumable (done markers in $D)
export PATH=$HOME/.dotnet:$PATH DOTNET_ROOT=$HOME/.dotnet
S=/tmp/claude-1000/-home-ken-Documents-Claude-Code-Communication/7c5144a7-e556-4299-98c8-a56dfe00444d/scratchpad/audit41
D=$HOME/Documents/Claude-Code-Communication/workspace/ikada-unity/drafts/stageD/audit41/shape
W=$HOME/Documents/ikada-sim-w3
export IKADA_LIBIKD=$S/build/libikd.so
stop() { [ -f $D/STOP ] && { echo "STOPPED before $1 $(date +%T)" >> $D/progress.log; exit 0; }; }
step() { [ -f $D/done_$1 ] && return 1; stop $1; echo "start $1 $(date +%T)" >> $D/progress.log; return 0; }
fin() { touch $D/done_$1; echo "end $1 $(date +%T)" >> $D/progress.log; }
refs() {   # $1 = label; the 11: CI 8 cells + README E', F, G
  cd $W/pc
  for date in 4-20 7-20; do for seed in 20260925 1 2 3; do
    k="$1 seed=$seed date=$date"; grep -q "^$k " $D/refcheck.txt 2>/dev/null && continue; stop "ref $k"
    echo "$k $(timeout 900 nice -n 10 dotnet run --no-build -c Release --project tools/Ikada.RefCheck -- --seed $seed --date $date 2>&1 | tr '\n' ' ' | cut -c1-300)" >> $D/refcheck.txt
  done; done
  for a in "--date 4-20 --place 3" "--seed 1 --date 10-15" "--seed 1 --date 12-10"; do
    k="$1 $a"; grep -q "^$k " $D/refcheck.txt 2>/dev/null && continue; stop "ref $k"
    echo "$k $(timeout 900 nice -n 10 dotnet run --no-build -c Release --project tools/Ikada.RefCheck -- $a 2>&1 | tr '\n' ' ' | cut -c1-300)" >> $D/refcheck.txt
  done
}
for v in base:2750f49 fix:w3/rope-shape; do
  L=${v%%:*}; R=${v#*:}
  if step build_$L; then cd $W && git checkout -q --detach $R 2>/dev/null || git checkout -q $R; git log --oneline -1 | cut -c1-60 >> $D/progress.log
    cd $W/pc && nice -n 10 dotnet build -m:1 -c Release Ikada.sln > $D/build_$L.log 2>&1; echo "build rc=$?" >> $D/progress.log; fin build_$L; fi
  if step test_$L; then cd $W && git checkout -q --detach $R 2>/dev/null || git checkout -q $R
    cd $W/pc && timeout 2400 nice -n 10 dotnet test --no-build -c Release -m:1 Ikada.sln > $D/test_$L.log 2>&1; echo "test rc=$?" >> $D/progress.log; fin test_$L; fi
  if step ref_$L; then cd $W && git checkout -q --detach $R 2>/dev/null || git checkout -q $R; refs $L; fin ref_$L; fi
done
if step probe_build; then cd $W && git checkout -q w3/rope-shape-probe
  cd $HOME/Documents/Claude-Code-Communication/workspace/ikada-unity/drafts/stageD/audit41/Probe41 && nice -n 10 dotnet build -m:1 -c Release -o $S/probe41bin > $D/probe_build.log 2>&1; echo "probe build rc=$?" >> $D/progress.log; fin probe_build; fi
cd $S/probe41bin
for season in spring July; do for skill in Good Slack Locked; do for d in 1 2 4; do
  grep -q "^rope $skill $season d=$d " $D/rope100_shape.txt 2>/dev/null && continue; stop "cell $skill $season $d"
  timeout 600 nice -n 10 dotnet Probe41.dll rope 100 $skill $season $d >> $D/rope100_shape.txt 2>&1
done; done; done
for sk in Locked Good Slack; do [ -f $D/ropetrace_$sk.txt ] && continue; stop "trace $sk"; timeout 500 nice -n 10 dotnet Probe41.dll ropetrace 50 $sk spring 2 > $D/ropetrace_$sk.txt 2>&1; done
echo "ALL DONE $(date +%T)" >> $D/progress.log
