#!/bin/bash
# sunny_seed_scan_v2.sh - PR v2 (2) (worker3, PRESIDENT 04:5x): on ikada-sim main 2750f49 (the combined tree's pin), the 4/20 weather of seeds
# 1..500 (Probe41 weather; control seed 26 = 雨), then RefCheck 4/20 on the first N sunny seeds: per seed the first hookset, its Landed, the
# fight length, and the cast before it (its Drop and Bottom = the "place and wait" cut). Stops between seeds on $O/STOP. dotnet on boss1's signal.
# usage: sunny_seed_scan_v2.sh <out dir> [N=30]
set -u
O=${1:?out}; N=${2:-30}; mkdir -p "$O"
export PATH=$HOME/.dotnet:$PATH DOTNET_ROOT=$HOME/.dotnet
S=/tmp/claude-1000/-home-ken-Documents-Claude-Code-Communication/7c5144a7-e556-4299-98c8-a56dfe00444d/scratchpad/audit41
export IKADA_LIBIKD=$S/build/libikd.so
W=$HOME/Documents/ikada-sim-w3
# Probe41 links the harness hooks (only on w3/rope-shape-probe): build it there; its weather mode reads Calendar only (FightAi untouched)
cd $W && git checkout -q w3/rope-shape-probe
cd $HOME/Documents/Claude-Code-Communication/workspace/ikada-unity/drafts/stageD/audit41/Probe41 && nice -n 10 dotnet build -m:1 -c Release -o $S/probe41bin > "$O/build_probe.log" 2>&1
[ -s "$O/sunny_0420.tsv" ] || dotnet $S/probe41bin/Probe41.dll weather 500 4-20 > "$O/sunny_0420.tsv" 2> "$O/weather.txt"
cd $W && git checkout -q --detach 2750f49 && git log --oneline -1 | cut -c1-40 > "$O/version.txt"
cd $W/pc && nice -n 10 dotnet build -m:1 -c Release tools/Ikada.RefCheck > "$O/build_refcheck.log" 2>&1 || { echo "refcheck build failed" >> "$O/version.txt"; exit 1; }
cd $W/pc
for seed in $(cut -f1 "$O/sunny_0420.tsv" | head -$N); do
  [ -f "$O/STOP" ] && { echo "stopped before $seed" >> "$O/table.tsv"; exit 0; }
  grep -q "^$seed	" "$O/table.tsv" 2>/dev/null && continue
  timeout 300 nice -n 10 dotnet run --no-build -c Release --project tools/Ikada.RefCheck -- --seed $seed --date 4-20 --log "$O/s$seed.log" > "$O/s$seed.out" 2>&1
  python3 - "$O/s$seed.log" "$O/s$seed.out" "$seed" "$(grep "^$seed	" "$O/sunny_0420.tsv" | cut -f2)" >> "$O/table.tsv" <<'PY'
import sys,re
log,out,seed,wind=sys.argv[1:5]
L=[l.split(' ',2) for l in open(log) if l[0].isdigit()]
ms=lambda x: int(x)/1000
hook=next((ms(l[0]) for l in L if len(l)>1 and l[1]=='hookset'),None)
landed=next((ms(l[0]) for l in L if len(l)>2 and l[1]=='ev' and l[2].strip()=='Landed' and hook is not None and ms(l[0])>hook),None)
drop=max((ms(l[0]) for l in L if len(l)>2 and l[1]=='ev' and l[2].strip()=='Drop' and hook is not None and ms(l[0])<hook),default=None)
bottom=next((ms(l[0]) for l in L if len(l)>2 and l[1]=='ev' and l[2].strip()=='Bottom' and drop is not None and drop<ms(l[0])<hook),None)
c=re.search(r'catches (\d+)',open(out).read())
f=lambda v: '-' if v is None else f'{v:.1f}'
print('\t'.join([seed, f'catches {c.group(1) if c else "?"}', f'hook {f(hook)}', f'landed {f(landed)}', f'fight {f(landed-hook) if hook and landed else "-"}', f'drop {f(drop)}', f'bottom {f(bottom)}', wind]))
PY
done
echo "done $(date +%T)" >> "$O/table.tsv"
