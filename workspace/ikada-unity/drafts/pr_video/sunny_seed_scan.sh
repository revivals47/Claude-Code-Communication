#!/bin/bash
# sunny_seed_scan.sh - PR v2 ② (worker3, boss1 11:48): RefCheck 4/20 (ikada-sim 418b374) on the first N sunny seeds of the weather scan;
# per seed the first hookset and Landed times and the catches. Pick: the first Landed after a hookset before 1500 s, the fight >= 30 s.
# usage: sunny_seed_scan.sh <sunny_0420.tsv> <out dir> [N=30]   (dotnet only on boss1's signal)
set -u
T=${1:?tsv}; O=${2:?out}; N=${3:-30}; mkdir -p "$O"
export PATH=$HOME/.dotnet:$PATH DOTNET_ROOT=$HOME/.dotnet IKADA_SIM_CLI=$HOME/Documents/ikada-sim-w3/build/sim_cli
cd ~/Documents/ikada-sim-w3/pc
for seed in $(cut -f1 "$T" | head -$N); do
  nice -n 10 dotnet run --no-build --project tools/Ikada.RefCheck -- --seed $seed --log "$O/s$seed.log" > "$O/s$seed.out" 2>&1
  h=$(grep -m1 ' hookset band' "$O/s$seed.log" | cut -d' ' -f1); l=$(grep -m1 ' ev Landed$' "$O/s$seed.log" | cut -d' ' -f1)
  echo -e "$seed\t$(grep -oE 'catches [0-9]+' $O/s$seed.out)\thook ${h:-none}\tlanded ${l:-none}\t$(grep "^$seed	" "$T" | cut -f2)" | tee -a "$O/table.tsv"
done
